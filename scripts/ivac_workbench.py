#!/usr/bin/env python3
"""Verified workbench -> disposable typed rows; no qualification or adjudication."""
from decimal import Decimal
import json
from pathlib import Path
import subprocess
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ivac_regulatory as regulatory
from personal.ivac.workbench.generated import rows

PACKAGE = './contracts/personal/ivac/workbench:ivacworkbench'
MODELS = {'statement': rows.WorkbenchStatementRow, 'anchor': rows.WorkbenchAnchorRow,
          'statementAnchor': rows.WorkbenchStatementAnchorRow}


def cue_validate(value, definition='#RegulatoryWorkbench'):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory)/'input.json'
        path.write_text(regulatory.exact_json(value), encoding='utf-8')
        subprocess.run(['cue', 'vet', '-c', PACKAGE, str(path), '-d', definition],
                       cwd=regulatory.ROOT, check=True, capture_output=True)


def verify(value, *, evidence_paths, anchor_text_paths, corpus_paths):
    """Paths are explicit caller bindings, never resolved from untrusted data.

    All supplied source bytes and text anchors must verify before projection.
    File absence is an acquisition gap, never an empty/zero clinical result.
    """
    cue_validate(value)
    texts = {}
    for version, corpus in value['corpusVersions'].items():
        snapshot, origin = corpus_paths[version]
        texts[version] = regulatory.read_snapshot(corpus['source'], snapshot, origin)
        if 'compendium' in corpus:
            regulatory.verify(corpus['compendium'], snapshot, origin)
    for dependency in value['ruleDependencies'].values():
        for citation in (dependency['from'], dependency['to']):
            regulatory.verify_span(citation, texts[citation['sourceVersion']], citation['sourceVersion'])
    for key, anchor in value['anchors'].items():
        original = Path(evidence_paths[anchor['evidence']['id']]).read_bytes()
        page_bytes = Path(anchor_text_paths[key]).read_bytes()
        if regulatory.digest(original) != anchor['artifactDigest']:
            raise ValueError(f'artifact digest mismatch: {key}')
        if regulatory.digest(page_bytes) != anchor['textDigest']:
            raise ValueError(f'page text digest mismatch: {key}')
        page_text = page_bytes.decode('utf-8', errors='strict')
        if page_text[anchor['start']:anchor['end']] != anchor['exactText']:
            raise ValueError(f'citation offset/text mismatch: {key}')
        if anchor['end'] > len(page_text):
            raise ValueError(f'citation past page end: {key}')


def project(value, **bindings):
    verify(value, **bindings)
    result = {name: [] for name in MODELS}
    def add(name, row):
        model = MODELS[name].model_validate(row)
        # JSON mode encodes Decimal as strings: restore exact numeric values
        # before CUE round trip, using the canonical input's numeric keys.
        native = json.loads(model.model_dump_json(exclude_unset=True), parse_float=Decimal)
        for field in ('value', 'minimum', 'maximum'):
            if field in native:
                native[field] = Decimal(native[field])
        cue_validate(native, '#' + MODELS[name].__name__)
        result[name].append(native)
    for key, anchor in sorted(value['anchors'].items()):
        add('anchor', {'workbenchID': value['id'], 'anchorID': key,
                       'evidenceID': anchor['evidence']['id'],
                       **{k: anchor[k] for k in ('artifactDigest', 'textDigest', 'page', 'start', 'end', 'exactText', 'transcription')}})
    for key, statement in sorted(value['statements'].items()):
        record = value['records'][statement['recordID']]
        row = {'workbenchID': value['id'], 'caseID': value['caseID'],
               'snapshotID': record['snapshotID'], 'recordID': record['id'], 'recordKind': record['kind'],
               'statementID': key, 'topic': statement['topic'], 'assertion': statement['assertion'],
               'classState': statement['reportedClass']['state'],
               'percentageState': statement['reportedPercentage']['state'],
               'legalBasisState': statement['legalBasis']['state'], 'status': statement['status']}
        if statement['reportedClass']['state'] == 'recorded':
            row['classLabel'] = statement['reportedClass']['label']
        if statement['reportedPercentage']['state'] == 'recorded':
            percentage = statement['reportedPercentage']['percentage']
            row.update({'percentageKind': percentage['kind'], **{k: v for k, v in percentage.items() if k != 'kind'}})
        if statement['legalBasis']['state'] == 'cited':
            row.update({k: statement['legalBasis'][k] for k in ('sourceVersion', 'unitID')})
        add('statement', row)
        for anchor_id in sorted(statement['anchorIDs']):
            add('statementAnchor', {'workbenchID': value['id'], 'statementID': key, 'anchorID': anchor_id})
    return result


def missing_anchor_links_plan(left, right, *, basis):
    """Diagnostic row coverage only; an IR admission is not legal admission."""
    if not basis:
        raise ValueError('explicit diagnostic projection basis required')
    operation = {'kind': 'anti-join', 'right': right,
                 'on': [{'left': k, 'right': k} for k in ('workbenchID', 'statementID')]}
    grain = {'keys': ['workbenchID', 'statementID'], 'unit': 'attributed-statement'}
    return {'apiVersion': 'factory.analytics-ir/v1', 'kind': 'RelationalPlan',
            'id': 'ivac-workbench-missing-anchor-links',
            'request': {'apiVersion': 'factory.analytics-ir/v1', 'kind': 'AnalyticalRequest',
                        'id': 'ivac-workbench-missing-anchor-links', 'source': left,
                        'grain': grain, 'operations': [operation]},
            'steps': [operation], 'outputGrain': grain,
            'provenance': {'authority': 'contracts/personal/ivac/workbench/projections.cue', 'basis': [basis]}}


def execute_plan(plan, tables):
    from runtime.ibis_adapter import lower_relational_plan
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory)/'plan.json'
        path.write_text(regulatory.exact_json(plan), encoding='utf-8')
        subprocess.run(['cue', 'vet', '-c', './contracts/state:state', str(path), '-d', '#RelationalPlan'],
                       cwd=regulatory.ROOT, check=True, capture_output=True)
    return lower_relational_plan(plan, tables, upstream_node='cue:ivacworkbench:#RegulatoryWorkbench')
