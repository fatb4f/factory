#!/usr/bin/env python3
"""Byte-anchored representation comparison, explicitly not an amendment audit."""
import argparse
import difflib
import json
from pathlib import Path
import ivac_regulatory_bulk as bulk
from ivac_regulatory_sources import DATA, encoded


def report(directory):
    observations = bulk.verify(directory)
    initial = json.loads((DATA/'annex-i-2021.candidate.json').read_bytes())
    from ivac_regulatory_sources import verify_acquisition, verify_candidate
    text = verify_acquisition(initial['acquisition'])
    verify_candidate(initial, text)
    matches = [r for r in observations['resources'] if r.get('member',{}).get('instrument') == 'P-9.2.1, r. 1']
    if len(matches) != 1: raise ValueError('missing regulation for comparison')
    member = matches[0]['member']
    annexes = [p for p in member['provisions'] if p['code'] == 'sc-nb:1']
    if len(annexes) != 1: raise ValueError('missing or duplicate Annex I')
    annex = annexes[0]
    xml_text = (Path(directory)/'regulation.txt').read_bytes().decode('utf-8')[annex['start']:annex['end']]
    # Whitespace token comparison is diagnostic only; PDF headers and XML table
    # boundaries differ. Never label the result an enacted amendment.
    before, after = initial['annex']['exactText'].split(), xml_text.split()
    diff = difflib.SequenceMatcher(None,before,after,autojunk=False)
    counts = {}
    for kind,a,b,c,d in diff.get_opcodes():
        item=counts.setdefault(kind,{'beforeTokens':0,'afterTokens':0,'runs':0})
        item['beforeTokens']+=b-a;item['afterTokens']+=d-c;item['runs']+=1
    relevant = {}
    for r in observations['resources']:
        if 'member' not in r: continue
        m=r['member']
        codes = ['se:18','se:24','se:25','se:26','sc-nb:1','ab'] if m['instrument'].endswith('r. 1') else ['se:'+str(i) for i in range(179,185)]
        relevant[m['instrument']] = {'artifactDigest':m['artifactDigest'],
                                    'rootPublisherAttributes':m['rootAttributes'],
                                    'provisions':[p for p in m['provisions'] if p['code'] in codes]}
    return {'format':'ivac.regulatory-coverage-diff/v1','authority':'none','legalEffect':'not-determined',
            'catalogueDigest':observations['catalogueDigest'],
            'before':{'acquisitionID':initial['acquisition']['id'],
                      'originalDigest':initial['acquisition']['artifactDigest'],
                      'textDigest':initial['acquisition']['textDigest'],
                      'start':initial['annex']['start'],'end':initial['annex']['end']},
            'after':{'resourceID':matches[0]['resourceID'],'zipDigest':matches[0]['artifactDigest'],
                     'memberPath':member['memberPath'],'xmlDigest':member['artifactDigest'],
                     'snapshotDigest':member['snapshotDigest'],'annex':annex},
            'comparison':{'method':'whitespace-token-diff/v1','classification':'representation-difference-only',
                          'operations':counts,'legalAmendment':'not-determined'},
            'relevantProvisionObservations':relevant,
            'coverage':{'initialFunctionalUnitLabels':40,'initialAestheticUnitLabels':8,
                        'normalizedOfficialClasses':0,'normalizedOfficialCriteria':0,
                        'independentlyReviewedUnits':0,'semanticCoverage':'incomplete'},
            'gaps':['Publisher date-eev attributes are retained without inferring consolidation or legal intervals.',
                    'Later XML acquired; exhaustive enactment/amendment history and 2026 proposal disposition remain unaudited.',
                    'Cross-format differences include table boundaries, headers and whitespace; no amendment conclusion follows.',
                    'All semantic class/path, conditional rate, exclusion and aesthetic table mapping remains pending.',
                    'CC-BY-NC-ND: no transformed bulk text is redistributed by this checkpoint.']}


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args()
    print(encoded(report(a.directory)).decode(),end='')
