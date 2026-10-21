#!/usr/bin/env python3
import copy
from decimal import Decimal
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
import ibis
import pyarrow as pa
from pydantic import ValidationError
import ivac_regulatory as regulatory
import ivac_workbench as workbench
from generate_ivac_regulatory_types import generate
from personal.ivac.workbench.generated import rows


class WorkbenchTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.root = regulatory.ROOT/'personal/ivac/workbench'
        cls.value = json.loads((cls.root/'synthetic-workbench.json').read_text(), parse_float=Decimal)
        cls.bindings = {'evidence_paths': {key: cls.root/'synthetic.txt' for key in ('clinical','internal')},
                        'anchor_text_paths': {key: cls.root/'synthetic.txt' for key in ('clinical','internal')},
                        'corpus_paths': {'synthetic-2021': (regulatory.ROOT/'personal/ivac/regulatory/fixtures/synthetic.txt',)*2}}

    def reject(self, mutate):
        value = copy.deepcopy(self.value)
        mutate(value)
        with self.assertRaises(subprocess.CalledProcessError):
            workbench.cue_validate(value)

    def test_native_projection_round_trip_and_determinism(self):
        result = workbench.project(self.value, **self.bindings)
        self.assertEqual([len(result[k]) for k in ('statement','anchor','statementAnchor')], [2,2,2])
        self.assertEqual(result['statement'][0]['value'], Decimal('2.5'))
        self.assertEqual(result['statement'][1]['value'], Decimal('0'))
        self.assertEqual(result, workbench.project(self.value, **self.bindings))
        schema, code = generate('workbenchProjectionSchemas', workbench.PACKAGE)
        self.assertEqual(schema, (self.root/'generated/rows.schema.json').read_bytes())
        self.assertEqual(code.replace(b'(CUE regulatoryRowSchemas)', b'(CUE workbenchProjectionSchemas)'), (self.root/'generated/rows.py').read_bytes())
        with self.assertRaises(ValidationError):
            rows.WorkbenchStatementRow.model_validate({**result['statement'][0], 'admitted':True})

    def test_unknown_is_not_zero_and_exact_decimal(self):
        value = copy.deepcopy(self.value)
        statement = value['statements']['clinical-statement']
        statement['reportedClass'] = {'state':'unknown','reason':'not stated'}
        statement['reportedPercentage'] = {'state':'unknown','reason':'not stated'}
        statement['legalBasis'] = {'state':'unknown','reason':'not stated'}
        result = workbench.project(value, **self.bindings)['statement'][0]
        self.assertNotIn('value', result)
        self.assertNotIn('classLabel', result)
        self.assertNotIn('sourceVersion', result)
        statement['reportedPercentage'] = {'state':'recorded','percentage':{'kind':'fixed','value':Decimal('2.1234567890123456789')}}
        result = workbench.project(value, **self.bindings)['statement'][0]
        self.assertEqual(result['value'], Decimal('2.1234567890123456789'))
        self.reject(lambda v: v['statements']['clinical-statement']['reportedPercentage'].update(state='unknown'))

    def test_referential_and_scope_integrity(self):
        cases = [lambda v: v['anchors']['clinical']['evidence'].update(id='absent'),
                 lambda v: v['statements']['clinical-statement'].update(recordID='absent'),
                 lambda v: v['records']['clinical'].update(snapshotID='absent'),
                 lambda v: v['statements']['clinical-statement'].update(anchorIDs=['internal']),
                 lambda v: v['corpusVersions']['synthetic-2021']['source'].update(id='wrong-version'),
                 lambda v: v['comparisons']['compare'].update(rightStatementID='absent'),
                 lambda v: v['comparisons']['compare'].update(rightStatementID='clinical-statement'),
                 lambda v: v['statements']['clinical-statement']['subject'].update(id='clinician'),
                 lambda v: v['snapshots']['initial'].update(caseID='other-case'),
                 lambda v: v.update(entitlement='granted'),
                 lambda v: v['corpusVersions']['synthetic-2021']['compendium']['source'].update(id='other'),
                 lambda v: v['statements']['clinical-statement']['legalBasis'].update(sourceVersion='other'),
                 lambda v: v['evidence']['clinical']['axes'][0].update(id='absent')]
        for i, mutate in enumerate(cases):
            with self.subTest(case=i): self.reject(mutate)

    def test_snapshot_append_order_and_no_self_promotion(self):
        value = copy.deepcopy(self.value)
        value['snapshots']['later'] = {'id':'later','caseID':'synthetic-case','stage':'supplement','ordinal':1,
                                      'recordedAt':'2026-02-01T00:00:00Z','previousSnapshotID':'initial'}
        workbench.cue_validate(value)
        for mutate in [lambda v: v['snapshots']['initial'].update(previousSnapshotID='initial'),
                       lambda v: v['snapshots']['initial'].update(stage='reassessment',previousSnapshotID='absent'),
                       lambda v: v['statements']['clinical-statement'].update(status='qualified-candidate'),
                       lambda v: v.update(coverage='complete'),
                       lambda v: v['comparisons']['compare'].update(automaticSelection=True)]:
            self.reject(mutate)
        value['snapshots']['later']['ordinal']=0
        with self.assertRaises(subprocess.CalledProcessError): workbench.cue_validate(value)

    def test_existing_qualification_and_proposal_boundary(self):
        from test_ivac_regulatory import RegulatoryTests
        RegulatoryTests.setUpClass()
        q = RegulatoryTests().qualification()
        value = copy.deepcopy(self.value)
        value['subject'] = q['case']['world']['subject']
        value['actors'].update(q['case']['review']['actors'])
        for statement in value['statements'].values(): statement['subject'] = value['subject']
        value['qualifications']['existing-qualification'] = q
        workbench.cue_validate(value)
        value['corpusVersions']['synthetic-2021']['publicationKind'] = 'proposal'
        with self.assertRaises(subprocess.CalledProcessError): workbench.cue_validate(value)
        # A source can be observed as a proposal without being used as a qualification.
        value['qualifications'] = {}
        workbench.cue_validate(value)

    def test_byte_and_quote_integrity_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            changed=Path(directory)/'changed';changed.write_text('tampered')
            bindings=copy.deepcopy(self.bindings)
            bindings['evidence_paths']['clinical']=changed
            with self.assertRaisesRegex(ValueError,'artifact digest'): workbench.verify(self.value,**bindings)
            bindings=copy.deepcopy(self.bindings);bindings['anchor_text_paths']['clinical']=changed
            with self.assertRaisesRegex(ValueError,'page text digest'): workbench.verify(self.value,**bindings)
            bindings=copy.deepcopy(self.bindings);bindings['evidence_paths']['clinical']=Path(directory)/'missing'
            with self.assertRaises(FileNotFoundError): workbench.verify(self.value,**bindings)
        value=copy.deepcopy(self.value);value['anchors']['clinical']['start']+=1
        with self.assertRaisesRegex(ValueError,'offset/text'): workbench.verify(value,**self.bindings)

    def test_ibis_duckdb_scope_coverage(self):
        con=ibis.duckdb.connect()
        try:
            statements=pa.table({'workbenchID':['w1','w2','w1'],'statementID':['s','s','missing']})
            links=pa.table({'workbenchID':['w1'],'statementID':['s']})
            tables={'statements':con.create_table('statements',statements),'links':con.create_table('links',links)}
            def source(name):
                return {'id':name,'snapshotDigest':'sha256:'+'a'*64,'provenance':['synthetic-only'],
                        'admissibility':{'state':'admitted','authority':'synthetic-diagnostic-test','basis':['synthetic-only']}}
            plan=workbench.missing_anchor_links_plan(source('statements'),source('links'),basis='synthetic-only')
            result=workbench.execute_plan(plan,tables).expression.to_pyarrow().to_pylist()
            self.assertEqual({(r['workbenchID'],r['statementID']) for r in result},{('w2','s'),('w1','missing')})
        finally: con.disconnect()


if __name__ == '__main__': unittest.main(verbosity=2)
