#!/usr/bin/env python3
"""Reject exporter success that silently yields a vacuous canonical schema."""
import json
import subprocess
from ivac_regulatory import ROOT
from ivac_regulatory_sources import encoded


def inspect():
    results=[]
    for package,definition in [('./contracts/personal/ivac:ivac','#RegulatoryCompendium'),
                               ('./contracts/personal/ivac:ivac','#RegulatoryExtraction'),
                               ('./contracts/personal/ivac/evaluations:ivaceval','#RegulatoryQualification')]:
        result=subprocess.run(['cue','export',package,'--out','jsonschema','-e',definition],cwd=ROOT,capture_output=True,text=True,timeout=60)
        if result.returncode:
            record={'definition':definition,'status':'export-failed','diagnostic':result.stderr.strip().splitlines()[0]}
        else:
            schema=json.loads(result.stdout)
            meaningful=any(schema.get(k) for k in ('properties','$defs','oneOf','anyOf','allOf'))
            record={'definition':definition,'status':'requires-loss-audit' if meaningful else 'unconstrained-schema-rejected',
                    'schemaKeywords':sorted(schema)}
        results.append(record)
    return {'format':'ivac.canonical-projection-gaps/v1','cueVersion':'v0.16.1',
            'admission':'blocked-pending-qualified-projection','results':results}


if __name__=='__main__': print(encoded(inspect()).decode(),end='')
