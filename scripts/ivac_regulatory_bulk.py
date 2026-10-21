#!/usr/bin/env python3
"""Bounded official bulk acquisition; XML observations never imply legal admission."""
import argparse
import io
import json
from pathlib import Path, PurePosixPath
import re
import stat
import urllib.request
from urllib.parse import urlsplit
import zipfile
from datetime import datetime, timezone
from defusedxml import ElementTree as ET
import ivac_regulatory as spans
from ivac_regulatory_sources import encoded

DATASET = 'c8433300-f752-4815-8ea2-69cad416dd80'
CATALOG_URL = f'https://www.donneesquebec.ca/recherche/api/3/action/package_show?id={DATASET}'
MAX_DOWNLOAD = 100 * 1024 * 1024
MAX_MEMBER = 16 * 1024 * 1024
MAX_EXPANDED = 768 * 1024 * 1024


def fetch(url):
    def official(value):
        p = urlsplit(value)
        return p.scheme == 'https' and p.hostname == 'www.donneesquebec.ca' and not p.username and p.port in (None, 443)
    class Redirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            if not official(newurl):
                raise ValueError('redirect outside official origin')
            return super().redirect_request(req, fp, code, msg, headers, newurl)
    if not official(url):
        raise ValueError('not an official catalogue origin')
    with urllib.request.build_opener(Redirect).open(url, timeout=60) as response:
        data = response.read(MAX_DOWNLOAD + 1)
    if len(data) > MAX_DOWNLOAD:
        raise ValueError('download exceeds limit')
    return data


def inspect_zip(data, *, require_xml=True):
    """Accept observed backslash separators, reject ambiguity and extraction hazards."""
    result, seen, total = [], set(), 0
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        if len(archive.infolist()) > 20000:
            raise ValueError('too many members')
        for member in archive.infolist():
            name = member.filename.replace('\\', '/')
            parts = name.rstrip('/').split('/')
            if (not name or name.startswith('/') or any(p in ('', '.', '..') for p in parts)
                    or ':' in name or '\x00' in name or '\x00' in member.orig_filename):
                raise ValueError('unsafe ZIP member path')
            if name.casefold() in seen:
                raise ValueError('duplicate or ambiguous ZIP member')
            seen.add(name.casefold())
            mode = member.external_attr >> 16
            if stat.S_ISLNK(mode) or member.flag_bits & 1:
                raise ValueError('symlink or encrypted member')
            total += member.file_size
            if member.file_size > 64 * 1024 * 1024 or total > MAX_EXPANDED:
                raise ValueError('expanded ZIP exceeds limit')
            if member.file_size > max(1, member.compress_size) * 1000:
                raise ValueError('excessive ZIP compression ratio')
            if not member.is_dir():
                result.append((name, member.filename))
        if require_xml and not any(n.lower().endswith('.xml') for n, _ in result):
            raise ValueError('ZIP contains no XML')
    return sorted(result)


def xml_observation(data, instrument):
    if len(data) > MAX_MEMBER:
        raise ValueError('XML exceeds limit')
    root = ET.fromstring(data, forbid_dtd=True, forbid_entities=True, forbid_external=True)
    if root.tag != 'LegislativeDocument' or root.get('{http://www.w3.org/XML/1998/namespace}lang') != 'fr':
        raise ValueError('unexpected legislative XML root or language')
    identities = root.findall('./*/Identification/Id')
    if len(identities) != 1 or identities[0].text != instrument:
        raise ValueError('instrument identity mismatch')
    # Stable text stream is an extraction view; exact original XML is separately hashed.
    chunks = []
    raw_spans = {}
    for match in re.finditer(rb'<(Section|Schedule|AmendedBy)\b[^>]*\bCode="([^"]+)"[^>]*>', data):
        closing = b'</' + match[1] + b'>'
        end = data.find(closing, match.end())
        if end < 0: raise ValueError('unclosed provision')
        raw_spans[match[2].decode('utf-8')] = (match.start(), end + len(closing))
    observations = []
    cursor = 0
    for node in root.iter():
        if node.tag not in ('Section', 'Schedule', 'AmendedBy'):
            continue
        code = node.get('Code')
        if not code or any(o['code'] == code for o in observations):
            raise ValueError('missing or duplicate provision code')
        text = ''.join(node.itertext())
        if code not in raw_spans: raise ValueError('missing exact XML anchor')
        a, b = raw_spans[code]
        observations.append({'xmlByteStart': a, 'xmlByteEnd': b,
                             'xmlSpanDigest': spans.digest(data[a:b]), 'code': code, 'publisherAttributes': dict(node.attrib),
                             'start': cursor, 'end': cursor + len(text),
                             'textDigest': spans.digest(text.encode('utf-8'))})
        chunks.append(text + '\n')
        cursor += len(text) + 1
    if not observations:
        raise ValueError('no provisions in XML')
    snapshot = ''.join(chunks).encode('utf-8')
    return {'instrument': instrument, 'rootAttributes': dict(root.attrib),
            'snapshotDigest': spans.digest(snapshot), 'provisions': observations,
            'publicationDate': 'unknown', 'consolidationDate': 'unknown',
            'legalEffectiveInterval': 'requires-legal-review', 'legalEffect': 'not-determined'}, snapshot


def select_members(data, instrument):
    members = inspect_zip(data)
    found = []
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        # Match actual member basename only as discovery, then verify XML identity.
        basename = instrument.upper().replace(' ', '') + '_FR.XML'
        for normal, original in members:
            if PurePosixPath(normal).name.upper() == basename:
                raw = archive.read(original)  # CRC verified by zipfile
                observation, snapshot = xml_observation(raw, instrument)
                found.append(({'memberPath': original, 'normalizedMemberPath': normal,
                               'artifactDigest': spans.digest(raw), 'artifactBytes': len(raw),
                               'mediaType': 'application/xml', **observation}, raw, snapshot))
    if len(found) != 1:
        raise ValueError('expected exactly one French instrument member')
    return found[0]


def acquire(directory):
    directory = Path(directory)
    directory.mkdir(parents=True, exist_ok=False)
    catalog = fetch(CATALOG_URL)
    (directory / 'catalogue.json').write_bytes(catalog)
    result = json.loads(catalog)
    if not result.get('success') or result['result']['id'] != DATASET:
        raise ValueError('unexpected catalogue identity')
    package = result['result']
    report = {'format': 'ivac.bulk-observations/v1', 'authority': 'none',
              'retrievedAt': datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
              'catalogueURL': CATALOG_URL, 'catalogueDigest': spans.digest(catalog),
              'datasetID': DATASET, 'licenseID': package['license_id'],
              'licenseURL': package['license_url'], 'redistribution': 'pending-license-review',
              'resources': [], 'gaps': [], 'caseApplicability': 'unresolved'}
    targets = [('Lois', 'P-9.2.1'), ('Règlements', 'P-9.2.1, r. 1'),
               ('Liste des lois et des règlements en français', None)]
    for name, instrument in targets:
        matches = [r for r in package['resources'] if r['name'] == name]
        if len(matches) != 1:
            report['gaps'].append({'resource': name, 'error': 'missing or duplicate catalogue resource'})
            continue
        resource = matches[0]
        try:
            raw = fetch(resource['url'])
            filename = PurePosixPath(urlsplit(resource['url']).path).name
            (directory / filename).write_bytes(raw)
            record = {'resourceID': resource['id'], 'url': resource['url'],
                      'retrievedAt': datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
                      'path': filename, 'artifactDigest': spans.digest(raw), 'artifactBytes': len(raw)}
            if instrument:
                member, original, snapshot = select_members(raw, instrument)
                stem = 'act' if instrument == 'P-9.2.1' else 'regulation'
                (directory / f'{stem}.xml').write_bytes(original)
                (directory / f'{stem}.txt').write_bytes(snapshot)
                record['member'] = member
            report['resources'].append(record)
        except Exception as exc:
            report['gaps'].append({'resource': name, 'error': f'{type(exc).__name__}: {exc}'})
    spans.validate(report, '#RegulatoryBulkObservations')
    (directory / 'observations.json').write_bytes(encoded(report))
    return report


def verify(directory):
    directory = Path(directory)
    report = json.loads((directory / 'observations.json').read_bytes())
    spans.validate(report, '#RegulatoryBulkObservations')
    if spans.digest((directory / 'catalogue.json').read_bytes()) != report['catalogueDigest']:
        raise ValueError('catalogue digest mismatch')
    catalogue = json.loads((directory / 'catalogue.json').read_bytes())
    if not catalogue.get('success') or catalogue['result']['id'] != DATASET:
        raise ValueError('catalogue identity mismatch')
    seen = set()
    for r in report['resources']:
        matches = [x for x in catalogue['result']['resources'] if x['id'] == r['resourceID'] and x['url'] == r['url']]
        if len(matches) != 1 or r['resourceID'] in seen:
            raise ValueError('catalogue resource mismatch or duplicate')
        seen.add(r['resourceID'])
        if PurePosixPath(r['path']).name != r['path']:
            raise ValueError('unsafe resource path')
        raw = (directory / r['path']).read_bytes()
        if len(raw) != r['artifactBytes'] or spans.digest(raw) != r['artifactDigest']:
            raise ValueError('bulk artifact integrity mismatch')
        if 'member' in r:
            member, original, snapshot = select_members(raw, r['member']['instrument'])
            if member != r['member']:
                raise ValueError('member observation mismatch')
            stem = 'act' if member['instrument'] == 'P-9.2.1' else 'regulation'
            if (directory / f'{stem}.xml').read_bytes() != original or (directory / f'{stem}.txt').read_bytes() != snapshot:
                raise ValueError('extracted artifact integrity mismatch')
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['acquire', 'verify'])
    p.add_argument('directory', type=Path)
    a = p.parse_args()
    print(encoded(acquire(a.directory) if a.mode == 'acquire' else verify(a.directory)).decode(), end='')
