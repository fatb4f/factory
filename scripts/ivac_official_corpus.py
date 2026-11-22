#!/usr/bin/env python3
"""Official-source acquisition and diagnostic projection; no legal admission."""
import argparse
from datetime import datetime, timezone
from html.parser import HTMLParser
import json
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile
import urllib.request
from urllib.parse import urlsplit, unquote
import zipfile

import ivac_regulatory as spans
import ivac_regulatory_bulk as bulk
from ivac_regulatory_sources import encoded

PACKAGE = './contracts/personal/ivac/corpus:ivaccorpus'
HOSTS = {'ivac.qc.ca', 'cnesst.gouv.qc.ca', 'legisquebec.gouv.qc.ca',
         'publicationsduquebec.gouv.qc.ca', 'donneesquebec.ca',
         'laws-lois.justice.gc.ca', 'quebec.ca'}
MAX_BYTES = 32 * 1024 * 1024

def validate(value, definition='#CorpusManifest'):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / 'input.json'
        # Escape Unicode only in the validation transport: CUE's JSON reader
        # rejects a literal interior U+FEFF. Decoded code points and pinned
        # original/text bytes remain unchanged.
        path.write_text(json.dumps(value, ensure_ascii=True, sort_keys=True), encoding='utf-8')
        subprocess.run(['cue', 'vet', '-c', PACKAGE, str(path), '-d', definition],
                       cwd=spans.ROOT, check=True, capture_output=True)

def now():
    return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')

def official(url):
    parsed = urlsplit(url)
    host = parsed.hostname or ''
    if host.startswith('www.'):
        host = host[4:]
    if (parsed.scheme != 'https' or host not in HOSTS or parsed.username
            or parsed.password or parsed.port not in (None, 443)):
        raise ValueError('URL outside official HTTPS origins')

def fetch(url):
    official(url)
    class Redirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            official(newurl)
            return super().redirect_request(req, fp, code, msg, headers, newurl)
    request = urllib.request.Request(url, headers={'User-Agent': 'factory-official-corpus/0.1'})
    with urllib.request.build_opener(Redirect).open(request, timeout=30) as response:
        official(response.url)
        raw = response.read(MAX_BYTES + 1)
        if len(raw) > MAX_BYTES:
            raise ValueError('source exceeds size limit')
        return raw, response.url, response.headers.get_content_type()

class TextView(HTMLParser):
    """Deterministic review text. Original HTML remains separately retained."""
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts, self.hidden = [], 0
    def handle_starttag(self, tag, attrs):
        if tag in ('script', 'style'):
            self.hidden += 1
        if not self.hidden and tag in ('p', 'div', 'br', 'li', 'tr', 'h1', 'h2', 'h3', 'h4'):
            self.parts.append('\n')
    def handle_endtag(self, tag):
        if tag in ('script', 'style') and self.hidden:
            self.hidden -= 1
        if not self.hidden and tag in ('p', 'div', 'li', 'tr'):
            self.parts.append('\n')
    def handle_data(self, data):
        if not self.hidden:
            self.parts.append(data)

def convert(raw, fmt, instrument=None):
    if fmt == 'pdf':
        if not raw.startswith(b'%PDF-'):
            raise ValueError('response is not PDF')
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'source.pdf'
            path.write_bytes(raw)
            text = subprocess.check_output(['pdftotext', '-layout', '-enc', 'UTF-8', str(path), '-'])
        version = subprocess.run(['pdftotext', '-v'], capture_output=True, text=True).stderr.splitlines()[0]
        return text, 'pdftotext -layout -enc UTF-8', version
    if fmt == 'quebec-xml':
        _, text = bulk.xml_observation(raw, instrument)
        return text, 'ivac_regulatory_bulk.xml_observation/v1', 'factory'
    source = raw.decode('utf-8-sig', errors='strict')
    if '<html' not in source.lower() and '<!doctype html' not in source.lower():
        raise ValueError('response is not HTML')
    parser = TextView()
    parser.feed(source)
    return ''.join(parser.parts).encode('utf-8'), 'html-text-view/v1', 'Python ' + platform.python_version()

def local(directory, name):
    """No absolute, parent, alternate-separator or symlink escapes."""
    if not name or '\\' in name or ':' in name:
        raise ValueError('unsafe path')
    path = Path(name)
    if path.is_absolute() or any(p in ('.', '..') for p in path.parts):
        raise ValueError('unsafe path')
    root = Path(directory).resolve()
    resolved = (root / path).resolve()
    if not resolved.is_relative_to(root):
        raise ValueError('path escapes corpus')
    return resolved

def blank(entry, corpus_id):
    keys = ('finalURL mediaType artifactPath artifactDigest artifactBytes textPath textDigest '
            'conversion converterVersion containerPath containerDigest memberPath error '
            'publicationDate consolidatedAsOf effectiveFrom').split()
    return {**dict.fromkeys(keys), 'corpusID': corpus_id, 'sourceID': entry['id'],
            'title': entry['title'], 'category': entry['category'], 'sourceKind': entry['sourceKind'],
            'requestedURL': entry['url'], 'retrievedAt': now(), 'status': 'failed',
            'dateStatus': 'unreviewed', 'semanticStatus': 'not-normalized', 'applicability': 'unresolved'}

def acquire(request, directory, *, bulk_directory=None):
    validate(request, '#CorpusRequest')
    ids = [entry['id'] for entry in request['entries']]
    if len(set(ids)) != len(ids):
        raise ValueError('duplicate request identities')
    directory = Path(directory)
    directory.mkdir(parents=True, exist_ok=False)
    corpus_id = directory.name
    manifest = {'format': 'ivac.official-corpus/v1', 'id': corpus_id,
                'repositoryCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=spans.ROOT, text=True).strip(),
                'createdAt': now(), 'authority': 'acquisition-observations-only', 'sources': [], 'anchors': [],
                'gaps': ['Publication, consolidation and effective dates require source-anchored review.',
                         'Acquisition does not establish exhaustive history, semantic completeness or case applicability.',
                         'Published directives do not establish access to unpublished internal manuals.']}
    (directory / 'request.json').write_bytes(encoded(request))
    bulk_report = bulk.verify(bulk_directory) if bulk_directory else None
    for entry in request['entries']:
        row = blank(entry, corpus_id)
        try:
            if entry['format'] == 'quebec-xml' and bulk_report:
                resource = next(r for r in bulk_report['resources'] if r.get('member', {}).get('instrument') ==
                                ('P-9.2.1, r. 1' if ', r.' in entry['instrument'] else 'P-9.2.1'))
                archive = Path(bulk_directory) / resource['path']
                member, raw, _ = bulk.select_members(archive.read_bytes(), entry['instrument'])
                container_name = 'containers/' + resource['path']
                target = local(directory, container_name)
                target.parent.mkdir(exist_ok=True)
                if not target.exists():
                    shutil.copyfile(archive, target)
                final_url, media = resource['url'], 'application/xml'
                row.update(containerPath=container_name, containerDigest=resource['artifactDigest'],
                           memberPath=member['memberPath'], retrievedAt=resource['retrievedAt'])
            else:
                raw, final_url, media = fetch(entry['url'])
            text, conversion, version = convert(raw, entry['format'], entry['instrument'])
            if not text.strip():
                if entry['format'] != 'pdf':
                    raise ValueError('empty text extraction')
                manifest['gaps'].append(f"{entry['id']}: original PDF retained; empty text requires OCR and review.")
            suffix = {'pdf': 'pdf', 'html': 'html', 'quebec-xml': 'xml'}[entry['format']]
            artifact_path, text_path = f"originals/{entry['id']}.{suffix}", f"text/{entry['id']}.txt"
            for name, data in [(artifact_path, raw), (text_path, text)]:
                path = local(directory, name)
                path.parent.mkdir(exist_ok=True)
                path.write_bytes(data)
            row.update(finalURL=final_url, status='acquired', mediaType=media, artifactPath=artifact_path,
                       artifactDigest=spans.digest(raw), artifactBytes=len(raw), textPath=text_path,
                       textDigest=spans.digest(text), conversion=conversion, converterVersion=version)
        except Exception as exc:
            row = blank(entry, corpus_id)
            row['error'] = f'{type(exc).__name__}: {exc}'
        manifest['sources'].append(row)
        # Durable checkpoint for interrupted acquisitions; final CUE gate below.
        (directory / 'manifest.json').write_bytes(encoded(manifest))
        print(f"{row['sourceID']}: {row['status']}", flush=True)
    validate(manifest)
    verify(directory)
    return manifest

def verify(directory, reconvert=False):
    directory = Path(directory)
    manifest = json.loads((directory / 'manifest.json').read_bytes())
    request = json.loads((directory / 'request.json').read_bytes())
    validate(manifest)
    validate(request, '#CorpusRequest')
    entries = {entry['id']: entry for entry in request['entries']}
    if len(entries) != len(request['entries']) or set(entries) != {s['sourceID'] for s in manifest['sources']}:
        raise ValueError('request/source identity mismatch')
    texts, checked_containers = {}, set()
    for row in manifest['sources']:
        entry = entries[row['sourceID']]
        for left, right in [('title','title'), ('sourceKind','sourceKind'), ('category','category'), ('requestedURL','url')]:
            if row[left] != entry[right]:
                raise ValueError('request/source metadata mismatch')
        official(row['requestedURL'])
        if row['status'] == 'failed':
            continue
        official(row['finalURL'])
        raw = local(directory, row['artifactPath']).read_bytes()
        text = local(directory, row['textPath']).read_bytes()
        if len(raw) != row['artifactBytes'] or spans.digest(raw) != row['artifactDigest']:
            raise ValueError('artifact integrity mismatch')
        if spans.digest(text) != row['textDigest']:
            raise ValueError('text integrity mismatch')
        if row['memberPath'] is not None:
            container = local(directory, row['containerPath'])
            key = (container, row['containerDigest'])
            if key not in checked_containers:
                data = container.read_bytes()
                if spans.digest(data) != row['containerDigest']:
                    raise ValueError('container integrity mismatch')
                bulk.inspect_zip(data)
                checked_containers.add(key)
            with zipfile.ZipFile(container) as archive:
                if archive.read(row['memberPath']) != raw:
                    raise ValueError('member integrity mismatch')
            bulk.xml_observation(raw, entry['instrument'])
        if reconvert:
            converted, conversion, version = convert(raw, entry['format'], entry['instrument'])
            if converted != text or conversion != row['conversion'] or version != row['converterVersion']:
                raise ValueError('conversion drift; retain pinned conversion or audit new version')
        texts[row['sourceID']] = text.decode('utf-8')
    for anchor in manifest['anchors']:
        spans.verify_span(anchor, texts[anchor['sourceVersion']], anchor['sourceVersion'])
    return manifest

def retry(directory, limit=5):
    """Append a bounded acquisition attempt; preserve prior manifest and bytes."""
    directory = Path(directory)
    old = verify(directory)
    failed = {s['sourceID'] for s in old['sources'] if s['status'] == 'failed'}
    request = json.loads((directory / 'request.json').read_bytes())
    request['entries'] = [e for e in request['entries'] if e['id'] in failed][:limit]
    if not request['entries']:
        return old
    history = directory / 'attempts'
    history.mkdir(exist_ok=True)
    old_bytes = (directory / 'manifest.json').read_bytes()
    previous = history / (spans.digest(old_bytes).split(':')[1] + '.json')
    if not previous.exists():
        previous.write_bytes(old_bytes)
    attempt = history / ('retry-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ'))
    acquired = acquire(request, attempt)
    old['gaps'] = list(dict.fromkeys(old['gaps'] + acquired['gaps']))
    changed = {s['sourceID']: s for s in acquired['sources']}
    for i, row in enumerate(old['sources']):
        candidate = changed.get(row['sourceID'])
        if candidate and candidate['status'] == 'acquired':
            candidate = dict(candidate)
            candidate['corpusID'] = old['id']
            for key in ('artifactPath', 'textPath', 'containerPath'):
                if candidate[key] is not None:
                    candidate[key] = str(attempt.relative_to(directory) / candidate[key])
            old['sources'][i] = candidate
    validate(old)
    pending = directory / 'manifest.pending.json'
    pending.write_bytes(encoded(old))
    pending.replace(directory / 'manifest.json')
    verify(directory)
    return old

def project(directory):
    """Canonical CUE + bytes -> generated rows -> IR -> Ibis -> DuckDB."""
    import ibis
    import pyarrow as pa
    import sys
    sys.path.insert(0, str(spans.ROOT))
    from personal.ivac.corpus.generated.rows import CorpusSourceRow, CorpusTextRow, CorpusAnchorRow
    from runtime.ibis_adapter import lower_relational_plan
    value = verify(directory)
    rows = [json.loads(CorpusSourceRow.model_validate(row).model_dump_json()) for row in value['sources']]
    for row in rows:
        validate(row, '#CorpusSourceRow')
    directory = Path(directory)
    text_rows = [json.loads(CorpusTextRow.model_validate({
        'corpusID': value['id'], 'sourceID': s['sourceID'], 'textDigest': s['textDigest'],
        'text': local(directory, s['textPath']).read_bytes().decode('utf-8')}).model_dump_json())
        for s in value['sources'] if s['status'] == 'acquired']
    anchor_rows = [json.loads(CorpusAnchorRow.model_validate({'corpusID': value['id'], **a}).model_dump_json())
                   for a in value['anchors']]
    for row in text_rows:
        validate(row, '#CorpusTextRow')
    for row in anchor_rows:
        validate(row, '#CorpusAnchorRow')
    database = directory / 'corpus.duckdb'
    if database.exists():
        raise ValueError('refuse to overwrite existing projection')
    con = ibis.duckdb.connect(str(database))
    try:
        # Derive storage scalar types from the CUE-generated JSON Schema. Value
        # inference alone turns all-unknown fields into unusable Arrow null types.
        schema = json.loads((spans.ROOT / 'personal/ivac/corpus/generated/rows.schema.json').read_bytes())
        def resolve(node):
            if '$ref' in node:
                ref = node['$ref']
                if not ref.startswith('#/'):
                    raise ValueError('external schema reference')
                target = schema
                for part in unquote(ref[2:]).split('/'):
                    target = target[part.replace('~1', '/').replace('~0', '~')]
                return resolve(target)
            return node
        def scalar(node):
            node = resolve(node)
            if 'anyOf' in node or 'oneOf' in node:
                options = [scalar(n) for n in node.get('anyOf', node.get('oneOf'))]
                nonnull = {n for n in options if n != 'null'}
                if len(nonnull) != 1:
                    raise ValueError('unsupported scalar projection union')
                return nonnull.pop()
            if 'const' in node:
                return 'string' if isinstance(node['const'], str) else 'null'
            if 'enum' in node and all(isinstance(v, str) for v in node['enum']):
                return 'string'
            return node.get('type')
        mapping = {'string': pa.string(), 'integer': pa.int64()}
        def create(name, kind, records):
            properties = resolve(schema['properties'][kind])['properties']
            fields = [pa.field(name, mapping[scalar(node)], nullable=True) for name, node in properties.items()]
            return con.create_table(name, pa.Table.from_pylist(records, schema=pa.schema(fields)))
        table = create('sources', 'source', rows)
        create('source_text', 'text', text_rows)
        create('anchors', 'anchor', anchor_rows)
        source = {'id': 'sources', 'snapshotDigest': spans.digest((directory / 'manifest.json').read_bytes()),
                  'provenance': ['verified-source-acquisition'],
                  'admissibility': {'state': 'admitted', 'authority': 'diagnostic-projection-only',
                                    'basis': ['acquisition-integrity-not-legal-admission']}}
        grain = {'keys': ['corpusID', 'sourceID'], 'unit': 'source-observation'}
        operation = {'kind': 'filter', 'predicate': "status == 'failed'",
                     'basis': ['explicit-failed-acquisition-status']}
        plan = {'apiVersion': 'factory.analytics-ir/v1', 'kind': 'RelationalPlan', 'id': 'ivac-corpus-gaps',
                'request': {'apiVersion': 'factory.analytics-ir/v1', 'kind': 'AnalyticalRequest',
                            'id': 'ivac-corpus-gaps', 'source': source, 'grain': grain, 'operations': [operation]},
                'steps': [operation], 'outputGrain': grain,
                'provenance': {'authority': 'contracts/personal/ivac/corpus/model.cue',
                               'basis': ['acquisition-integrity-not-legal-admission']}}
        (directory / 'coverage.plan.json').write_bytes(encoded(plan))
        subprocess.run(['cue', 'vet', '-c', './contracts/state:state', str(directory / 'coverage.plan.json'),
                        '-d', '#RelationalPlan'], cwd=spans.ROOT, check=True, capture_output=True)
        gaps = lower_relational_plan(plan, {'sources': table}, upstream_node='cue:ivaccorpus:#CorpusManifest').expression.to_pyarrow().to_pylist()
        (directory / 'coverage-gaps.json').write_bytes(encoded(gaps))
        (directory / 'sources.rows.json').write_bytes(encoded(rows))
        table.to_pandas().to_csv(directory / 'sources.csv', index=False)
        return {'sources': len(rows), 'acquired': len(rows) - len(gaps), 'failed': len(gaps)}
    finally:
        con.disconnect()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['acquire', 'verify', 'project', 'retry'])
    parser.add_argument('directory', type=Path)
    parser.add_argument('--request', type=Path)
    parser.add_argument('--bulk-directory', type=Path)
    parser.add_argument('--reconvert', action='store_true')
    parser.add_argument('--limit', type=int, default=5)
    args = parser.parse_args()
    if args.mode == 'acquire':
        if not args.request:
            parser.error('--request required')
        acquire(json.loads(args.request.read_bytes()), args.directory, bulk_directory=args.bulk_directory)
    elif args.mode == 'retry':
        retry(args.directory, args.limit)
    elif args.mode == 'verify':
        result = verify(args.directory, args.reconvert)
        print(json.dumps({'verified': len(result['sources']), 'anchors': len(result['anchors'])}))
    else:
        print(json.dumps(project(args.directory)))
