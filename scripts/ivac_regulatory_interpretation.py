#!/usr/bin/env python3
"""Verify/render candidate research; compare explicit synthetic readings via IR/Ibis."""
import argparse
import json
import subprocess
from ivac_regulatory import ROOT, digest, exact_json, validate, verify_span
import ivac_regulatory_sources as sources
from ivac_regulatory_analytics import execute_plan

DATA=sources.DATA/'interpretation'


def verify():
    bundle=sources.read_json(DATA/'opportunity-register.json')
    validate(bundle,'#RegulatoryInterpretationResearch')
    texts={}
    for identity,value in bundle['sourceArtifacts'].items():
        r=sources.read_json(sources.SOURCES/(identity+'.json'))
        if (r['artifactDigest'],r['textDigest']) != (value['artifactDigest'],value['snapshotDigest']):
            raise ValueError('research source digest mismatch')
        texts[identity]=sources.verify_acquisition(r)
    for opportunity in bundle['opportunities']:
        for anchor in opportunity['legalSource']:
            verify_span(anchor['citation'],texts[anchor['artifactID']],anchor['artifactID'])
    return bundle


def compare():
    import ibis
    import pyarrow as pa
    from personal.ivac.regulatory.generated.rows import InterpretationComparisonRow
    programs=json.loads(subprocess.check_output(['cue','export','./contracts/personal/ivac:ivac',
                        '-e','regulatoryInterpretationScenarioPrograms','--out','json'],cwd=ROOT))
    known={s['scenarioID'] for s in verify()['scenarios']}
    results=[];con=ibis.duckdb.connect()
    try:
        for i,p in enumerate(programs):
            if p['scenarioID'] not in known:raise ValueError('unknown scenario')
            data={'sourceVersion':['gazette-2021-39'],'scenarioID':[p['scenarioID']],
                  'opportunityID':[p['opportunityID']],'comparisonKind':[p['comparisonKind']],
                  'decisionBoundary':['unresolved-no-automatic-selection'],**{k:[v] for k,v in p['facts'].items()}}
            table=con.create_table('scenario_'+str(i),pa.table(data))
            source={'id':'scenario','snapshotDigest':digest(exact_json(data).encode()),'provenance':['synthetic-diagnostic-only'],
                    'admissibility':{'state':'admitted','authority':'synthetic-research-projection','basis':['synthetic-only-not-legal-admission']}}
            steps=[{'kind':'derive','expressions':[
                {'id':'claimantCandidate','expression':p['claimantExpression'],'basis':list(p['facts'])},
                {'id':'restrictiveCandidate','expression':p['restrictiveExpression'],'basis':list(p['facts'])}]},
                {'kind':'project','fields':['sourceVersion','scenarioID','opportunityID','claimantCandidate','restrictiveCandidate','comparisonKind','decisionBoundary']}]
            grain={'keys':['sourceVersion','scenarioID'],'unit':'synthetic-interpretation-comparison'}
            plan={'apiVersion':'factory.analytics-ir/v1','kind':'RelationalPlan','id':'interpretation-scenario',
                  'request':{'apiVersion':'factory.analytics-ir/v1','kind':'AnalyticalRequest','id':'interpretation-scenario','source':source,'grain':grain,'operations':steps},
                  'steps':steps,'outputGrain':grain,'provenance':{'authority':'contracts/personal/ivac/regulatory_interpretation.cue','basis':['synthetic-only']}}
            row=execute_plan(plan,{'scenario':table}).expression.to_pyarrow().to_pylist()[0]
            InterpretationComparisonRow.model_validate(row)
            results.append(row)
    finally:con.disconnect()
    return {'format':'ivac.synthetic-interpretation-comparison/v1','authority':'none','results':results,
            'selection':'none','adjudication':'not-determined'}


def scenario_markdown(bundle):
    lines=['# Adversarial synthetic scenarios','',
           'Every fact is invented. Outputs describe candidate readings; no interpretation is automatically selected. Executable Boolean comparisons are in regulatoryInterpretationScenarioPrograms; other scenarios remain review cases, not an automated legal evaluator.','']
    opportunities={o['opportunityID']:o for o in bundle['opportunities']}
    for s in bundle['scenarios']:
        o=opportunities[s['opportunityID']]
        lines+=['## '+s['scenarioID'],'','Source: '+'; '.join(x['citation']['locator'] for x in o['legalSource']),
                '', 'Facts: '+' '.join(s['facts']),'','Claimant output: '+s['claimantOutput'],
                '', 'Restrictive output: '+s['restrictiveOutput'],'','Divergence: '+s['divergence'],
                '', 'Resolution: '+s['resolutionEvidence'],'','Boundary: '+s['decisionBoundary'],'']
    return '\n'.join(lines)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['verify','compare','render-scenarios']);a=p.parse_args()
    if a.mode=='compare':print(sources.encoded(compare()).decode(),end='')
    elif a.mode=='render-scenarios':print(scenario_markdown(verify()),end='')
    else:verify();print('candidate research source anchors verified')
