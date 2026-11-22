#!/usr/bin/env python3
"""Verified compendium → generated rows → existing analytics IR/Ibis adapter.

IR admission is explicit authorization of a diagnostic projection, not legal
admission of the source or clinical qualification. No case data is accepted.
"""
from decimal import Decimal
import json
from pathlib import Path
import subprocess
import sys
import tempfile
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ivac_regulatory as spans
from personal.ivac.regulatory.generated import rows as types
from runtime.ibis_adapter import lower_relational_plan

MODELS = {name: getattr(types, 'Regulatory' + name.title() + 'Row')
          for name in ('unit', 'class', 'alternative', 'criterion', 'citation', 'rule')}


exact_json = spans.exact_json


def cue_row(row, definition):
    with tempfile.TemporaryDirectory() as d:
        p = Path(d)/'row.json'
        p.write_text(exact_json(row), encoding='utf-8')
        subprocess.run(['cue', 'vet', '-c', str(p),
                        *map(str, (spans.ROOT/'contracts/personal/ivac').glob('*.cue')),
                        '-d', definition], cwd=spans.ROOT, check=True, capture_output=True)


def project(compendium, snapshot, original):
    spans.verify(compendium, snapshot, original)
    tables = {name: [] for name in MODELS}
    key = {'sourceVersion': compendium['source']['id'], 'compendiumID': compendium['id']}
    def add(name, value):
        model = MODELS[name].model_validate({**key, **value})
        # RootModel identifiers serialize as scalars; enum values stay explicit.
        row = json.loads(model.model_dump_json(exclude_unset=True), parse_float=Decimal)
        for field in ('value', 'minimum', 'maximum'):
            if field in row: row[field] = Decimal(row[field])
        cue_row(row, '#Regulatory' + name.title() + 'Row')
        tables[name].append(row)
    def cite(path, citation):
        if citation['sourceVersion'] != key['sourceVersion']: raise ValueError('version mismatch')
        add('citation', {'ownerPath': path, **{k:v for k,v in citation.items() if k != 'sourceVersion'}})
    for uid, u in sorted(compendium['units'].items()):
        add('unit', {'unitID': uid, 'number': u['number'], 'kind': u['kind'], 'label': u['label'],
                     'reviewState': compendium['review']['state']})
        path = '/units/' + uid
        cite(path, u['citation'])
        for i, rule in enumerate(u['evaluationRules']):
            owner = path + '/evaluationRules/' + str(i)
            add('rule', {'unitID': uid, 'position': i, 'ownerPath': owner})
            cite(owner, rule)
        for cid, c in sorted(u['classes'].items()):
            add('class', {'unitID': uid, 'classID': cid, 'label': c['label'],
                          'percentageKind': c['percentage']['kind'],
                          **{k: v for k,v in c['percentage'].items() if k != 'kind'}})
            cp = path + '/classes/' + cid
            cite(cp, c['citation'])
            for ai, alternative in enumerate(c['qualification']['alternatives']):
                aid = alternative['id']
                add('alternative', {'unitID': uid, 'classID': cid, 'alternativeID': aid,
                                    'operator': alternative['operator'], 'position': ai})
                for ki, criterion in enumerate(alternative['criteria']):
                    add('criterion', {'unitID': uid, 'classID': cid, 'alternativeID': aid,
                                      'criterionID': criterion['id'], 'position': ki})
                    cite(cp + '/alternatives/' + str(ai) + '/criteria/' + str(ki), criterion['citation'])
    return tables


def missing_classes_plan(left, right, *, basis):
    """Sources must be explicitly authorized as diagnostic projections by caller."""
    if not basis: raise ValueError('explicit diagnostic projection basis required')
    operation = {'kind': 'anti-join', 'right': right,
                 'on': [{'left': k, 'right': k} for k in ('sourceVersion','compendiumID','unitID')]}
    grain = {'keys': ['sourceVersion','compendiumID','unitID'], 'unit': 'regulatory-unit'}
    return {'apiVersion': 'factory.analytics-ir/v1', 'kind': 'RelationalPlan',
            'id': 'ivac-missing-classes',
            'request': {'apiVersion': 'factory.analytics-ir/v1', 'kind': 'AnalyticalRequest',
                        'id': 'ivac-missing-classes', 'source': left, 'grain': grain, 'operations': [operation]},
            'steps': [operation], 'outputGrain': grain,
            'provenance': {'authority': 'contracts/personal/ivac/regulatory_projections.cue', 'basis': [basis]}}


def execute_plan(plan, tables):
    with tempfile.TemporaryDirectory() as d:
        p = Path(d)/'plan.json'
        p.write_text(exact_json(plan), encoding='utf-8')
        subprocess.run(['cue', 'vet', '-c', str(p),
                        *map(str, (spans.ROOT/'contracts/state').glob('*.cue')),
                        '-d', '#RelationalPlan'], cwd=spans.ROOT, check=True, capture_output=True)
    return lower_relational_plan(plan, tables, upstream_node='cue:ivac:#RegulatoryCompendium')
