#!/usr/bin/env python3
"""Project a validated Shadow Galaxy catalog to MISP Galaxy files and a loss report."""
import argparse
import json
import pathlib
import subprocess
import sys
import tempfile
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[4]
GALAXY = ROOT / 'projects/cyber-incidents/shadow-rail/galaxy'
NAMESPACE = uuid.UUID('c9eaf543-91f0-5e32-a144-305d817658f7')


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate JSON key: {key}')
        result[key] = value
    return result


def stable_uuid(kind, *parts):
    # JSON framing keeps arbitrary component boundaries unambiguous.
    return str(uuid.uuid5(NAMESPACE, json.dumps([kind, *parts], ensure_ascii=True, separators=(',', ':'))))


def project(catalog):
    terms = catalog['terms']
    ids = [term['id'] for term in terms]
    if len(ids) != len(set(ids)):
        raise ValueError('duplicate term ID')
    catalog_id = catalog['id']
    name = f'Shadow Galaxy: {catalog_id}'
    galaxy_type = f'shadow-rail-{catalog_id}'
    description = 'Source-qualified Shadow Rail vocabulary; inclusion does not establish a fact.'
    galaxy = {'name': name, 'type': galaxy_type, 'description': description,
              'uuid': stable_uuid('galaxy', catalog_id), 'version': 1, 'category': 'reference'}
    clusters = {'name': name, 'type': galaxy_type, 'description': description,
                'uuid': stable_uuid('cluster-collection', catalog_id), 'version': 1,
                'source': 'Shadow Rail', 'authors': ['Shadow Rail'], 'category': 'reference', 'values': []}
    losses = [{'path': '/version', 'reason': 'MISP integer version is a projection format version, not the source revision', 'value': catalog['version']},
              {'path': '/apiVersion', 'reason': 'Source contract version has no corresponding MISP field', 'value': catalog['apiVersion']},
              {'path': '/boundaries', 'reason': 'Epistemic boundaries are not represented structurally in MISP Galaxy', 'value': catalog['boundaries']}]
    for term in sorted(terms, key=lambda item: item['id']):
        clusters['values'].append({'value': term['label'], 'description': term['description'],
                                   'uuid': stable_uuid('term', catalog_id, term['id']),
                                   'meta': {'refs': [term['source']['uri']]}})
        for field, reason in [('id', 'Source term ID is used to derive UUID but is not recoverable from it'),
                              ('srw_concept', 'SRW concept is not represented as a MISP classification'),
                              ('source', 'Source version and qualification are not fully represented by a reference URI'),
                              ('alignment', 'External alignment and its limitations are not represented in the MISP cluster')]:
            losses.append({'term_id': term['id'], 'field': field, 'reason': reason, 'value': term[field]})
    return {'galaxy': galaxy, 'clusters': clusters, 'loss_report': {'catalog_id': catalog_id, 'losses': losses}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('catalog', type=pathlib.Path)
    args = parser.parse_args()
    try:
        raw = args.catalog.read_text(encoding='utf-8')
        catalog = json.loads(raw, object_pairs_hook=unique_object)
        # Validate the exact parsed content, not a separately reread file.
        with tempfile.TemporaryDirectory() as directory:
            normalized = pathlib.Path(directory) / 'catalog.json'
            normalized.write_text(json.dumps(catalog), encoding='utf-8')
            subprocess.run(['cue', 'vet', '-c', str(normalized), *map(str, sorted(GALAXY.glob('*.cue'))), '-d', '#Galaxy'],
                           check=True, stdout=subprocess.DEVNULL)
        print(json.dumps(project(catalog), ensure_ascii=False, sort_keys=True, indent=2))
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f'projection failed: {exc}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
