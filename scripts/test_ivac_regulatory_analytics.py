#!/usr/bin/env python3
import copy
from decimal import Decimal
import json
import unittest
import ibis
from pydantic import ValidationError
import ivac_regulatory as spans
import ivac_regulatory_analytics as analytics
from personal.ivac.regulatory.generated import rows


class AnalyticsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.compendium = json.loads((spans.ROOT/'personal/ivac/regulatory/fixtures/compendium.json').read_text(), parse_float=Decimal)
        cls.snapshot = spans.ROOT/'personal/ivac/regulatory/fixtures/synthetic.txt'

    def test_projection_round_trip_and_unknown_zero(self):
        # Exact Decimal inputs stay numeric through upstream CUE validation.
        value = copy.deepcopy(self.compendium)
        tables = analytics.project(value, self.snapshot, self.snapshot)
        self.assertEqual([len(tables[n]) for n in ('unit','class','alternative','criterion','rule','citation')], [1,1,2,3,1,6])
        c = tables['class'][0]
        self.assertEqual(c['value'],Decimal('12.5'))
        for percentage in [{'kind':'fixed','value':0}, {'kind':'not-specified','reason':'unknown'},
                           {'kind':'range','minimum':1.25,'maximum':2.5}]:
            v = copy.deepcopy(value)
            v['units']['unitA']['classes']['classA']['percentage'] = percentage
            r = analytics.project(v, self.snapshot, self.snapshot)['class'][0]
            self.assertEqual('value' in r,percentage['kind']=='fixed')
        with self.assertRaises(ValidationError): rows.RegulatoryUnitRow.model_validate({**tables['unit'][0], 'extra':True})
        with self.assertRaises(ValidationError): rows.RegulatoryUnitRow.model_validate({**tables['unit'][0], 'sourceVersion':''})
        exact = rows.RegulatoryClassRow.model_validate({**c,'value':Decimal('12.1234567890123456789')})
        self.assertEqual(exact.value,Decimal('12.1234567890123456789'))
        analytics.cue_row({**c,'value':exact.value}, '#RegulatoryClassRow')

    def test_version_or_citation_mismatch_rejected(self):
        v = copy.deepcopy(self.compendium)
        v['units']['unitA']['citation']['sourceVersion']='wrong'
        with self.assertRaises(Exception): analytics.project(v,self.snapshot,self.snapshot)

    def test_ibis_duckdb_scoped_anti_join(self):
        import pyarrow as pa
        con = ibis.duckdb.connect()
        try:
            # Class for another version cannot conceal a coverage gap.
            units = pa.table({'sourceVersion':['v1','v2','v1'], 'compendiumID':['c','c','c'], 'unitID':['u','u','missing']})
            classes = pa.table({'sourceVersion':['v1'], 'compendiumID':['c'], 'unitID':['u']})
            tables = {'units':con.create_table('units',units),'classes':con.create_table('classes',classes)}
            def source(name):
                return {'id':name,'snapshotDigest':'sha256:'+'a'*64,'provenance':['synthetic-test'],
                        'admissibility':{'state':'admitted','authority':'synthetic-diagnostic-test','basis':['synthetic-test-only']}}
            plan=analytics.missing_classes_plan(source('units'),source('classes'),basis='synthetic-test-only')
            result=analytics.execute_plan(plan,tables).expression.to_pyarrow().to_pylist()
            self.assertEqual({(r['sourceVersion'],r['unitID']) for r in result},{('v2','u'),('v1','missing')})
        finally: con.disconnect()


if __name__ == '__main__': unittest.main(verbosity=2)
