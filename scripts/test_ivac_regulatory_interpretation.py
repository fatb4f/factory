#!/usr/bin/env python3
"""Source integrity + adversarial readings + independent exact-arithmetic oracle."""
import copy
from decimal import Decimal
from fractions import Fraction
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from hypothesis import given, settings, strategies as st
import ibis
import pyarrow as pa
import ivac_regulatory as spans
import ivac_regulatory_sources as sources
import ivac_regulatory_math as math
from ivac_regulatory_analytics import execute_plan
from personal.ivac.regulatory.generated.rows import RegulatoryInterpretationScenario, InterpretationComparisonRow

DATA=sources.DATA/'interpretation'


def research(): return json.loads((DATA/'opportunity-register.json').read_text())


def oracle(rates):
    rates=sorted([Fraction(x) for x in rates],reverse=True)
    total=rates[0]
    for rate in rates[1:]:
        x=(100-total)*rate/100
        rounded=(2*x.numerator*100+x.denominator)//(2*x.denominator)
        total+=Fraction(rounded,100)
    return Fraction(-(-total.numerator//total.denominator)) if len(rates)>1 else total


class ResearchTests(unittest.TestCase):
    def test_sources_and_candidate_boundaries(self):
        bundle=research();spans.validate(bundle,'#RegulatoryInterpretationResearch')
        texts={}
        for identity,r in bundle['sourceArtifacts'].items():
            record=sources.read_json(sources.SOURCES/(identity+'.json'))
            self.assertEqual(record['artifactDigest'],r['artifactDigest'])
            self.assertEqual(record['textDigest'],r['snapshotDigest'])
            texts[identity]=sources.verify_acquisition(record)
        for opportunity in bundle['opportunities']:
            self.assertNotEqual(opportunity['claimantReading'],opportunity['restrictiveReading'])
            self.assertEqual(opportunity['clinicalConfidence'],'not-assessed')
            for a in opportunity['legalSource']:
                spans.verify_span(a['citation'],texts[a['artifactID']],a['artifactID'])
        self.assertEqual(len(bundle['opportunities']),25)
        self.assertEqual(len(bundle['scenarios']),25)
        for scenario in bundle['scenarios']:
            generated=RegulatoryInterpretationScenario.model_validate(scenario)
            self.assertEqual(json.loads(generated.model_dump_json()),scenario)
        for mutation in [lambda b:b['opportunities'].append(b['opportunities'][0]),
                         lambda b:b['opportunities'][0].update(reviewStatus='legally-reviewed'),
                         lambda b:b['opportunities'][0]['legalSource'][0]['citation'].update(sourceVersion='wrong'),
                         lambda b:b['scenarios'][0].update(opportunityID='missing'),
                         lambda b:b['coverage'].update(independentLegalReview=True),
                         lambda b:b['scenarios'][0].update(decisionBoundary='select-highest-payment')]:
            broken=copy.deepcopy(bundle);mutation(broken)
            with self.assertRaises(subprocess.CalledProcessError):spans.validate(broken,'#RegulatoryInterpretationResearch')

    def test_all_rubric_spans_and_incomplete_review(self):
        matrix=json.loads((DATA/'rubric-coverage.json').read_text());original=sources.read_json(sources.DATA/'annex-i-2021.candidate.json')
        self.assertEqual(len(matrix['rubrics']),25)
        self.assertEqual(sum(len(s['unitNumbers']) for s in matrix['rubrics']),48)
        for row,section in zip(matrix['rubrics'],original['sections'],strict=True):
            self.assertEqual(row['sourceSpanDigest'],spans.digest(section['text']['exactText'].encode()))
            self.assertEqual((row['start'],row['end']),(section['text']['start'],section['text']['end']))
            self.assertEqual(row['classPathReview'],'pending')

    def test_ibis_competing_outputs_without_selection(self):
        programs=json.loads(subprocess.check_output(['cue','export','./contracts/personal/ivac:ivac','-e','regulatoryInterpretationScenarioPrograms','--out','json'],cwd=spans.ROOT))
        known={x['scenarioID'] for x in research()['scenarios']};results=[]
        con=ibis.duckdb.connect()
        try:
            for i,p in enumerate(programs):
                self.assertIn(p['scenarioID'],known)
                data={'sourceVersion':['gazette-2021-39'],'scenarioID':[p['scenarioID']],
                      'opportunityID':[p['opportunityID']],'comparisonKind':[p['comparisonKind']],
                      'decisionBoundary':['unresolved-no-automatic-selection'],**{k:[v] for k,v in p['facts'].items()}}
                t=con.create_table('scenario_'+str(i),pa.table(data))
                source={'id':'scenario','snapshotDigest':spans.digest(spans.exact_json(data).encode()),
                        'provenance':['synthetic-diagnostic-only'],
                        'admissibility':{'state':'admitted','authority':'synthetic-research-projection','basis':['synthetic-only-not-legal-admission']}}
                steps=[{'kind':'derive','expressions':[
                    {'id':'claimantCandidate','expression':p['claimantExpression'],'basis':list(p['facts'])},
                    {'id':'restrictiveCandidate','expression':p['restrictiveExpression'],'basis':list(p['facts'])}]},
                    {'kind':'project','fields':['sourceVersion','scenarioID','opportunityID','claimantCandidate','restrictiveCandidate','comparisonKind','decisionBoundary']}]
                grain={'keys':['sourceVersion','scenarioID'],'unit':'synthetic-interpretation-comparison'}
                plan={'apiVersion':'factory.analytics-ir/v1','kind':'RelationalPlan','id':'interpretation-scenario',
                      'request':{'apiVersion':'factory.analytics-ir/v1','kind':'AnalyticalRequest','id':'interpretation-scenario','source':source,'grain':grain,'operations':steps},
                      'steps':steps,'outputGrain':grain,'provenance':{'authority':'contracts/personal/ivac/regulatory_interpretation.cue','basis':['synthetic-only']}}
                row=execute_plan(plan,{'scenario':t}).expression.to_pyarrow().to_pylist()[0]
                InterpretationComparisonRow.model_validate(row)
                self.assertTrue(row['claimantCandidate']);self.assertFalse(row['restrictiveCandidate'])
                results.append(row)
        finally:con.disconnect()
        self.assertEqual(len(results),8)
        # One genuine shared-tail issue; the rest intentionally test overrestriction,
        # rather than presenting a contradicted reading as equally lawful.
        self.assertEqual(sum(x['comparisonKind']=='genuine-scope-dispute' for x in results),1)


class ArithmeticTests(unittest.TestCase):
    def test_official_example_and_independent_worked_examples(self):
        # Directive2.7 p3:35 + (100-35)*.10 =41.5, final42. No money computation.
        self.assertEqual(math.aggregate(['35','10'])['percentage'],Decimal(42))
        r=math.aggregate(['15','10','5'])
        self.assertEqual(r['contributions'],[Decimal(15),Decimal('8.50'),Decimal('3.83')])
        self.assertEqual(r['percentage'],Decimal(28))
        # First-decimal-only bilateral rule:16.79/8=2.09875 ->2.0, not2.5.
        self.assertEqual(math.bilateral('8','8.79',eligible=True,cap_order='round-then-cap')['percentage'],Decimal(2))
        self.assertEqual(math.bilateral('4','4.8',eligible=True,cap_order='round-then-cap')['percentage'],Decimal('1.5'))
        self.assertEqual(math.aggregate(['1','0.1'])['percentage'],Decimal(2))
        self.assertEqual(math.aggregate(['0.5'])['percentage'],Decimal('0.5'))
        self.assertEqual(math.aggregate(['100','70'])['percentage'],Decimal(100))
        self.assertEqual(math.difference('35',None)['state'],'unresolved')
        self.assertEqual(math.difference('15','35')['state'],'unresolved')
        self.assertEqual(math.difference('35','5')['percentage'],Decimal(30))
        a=math.bilateral('0.7','8',eligible=True,cap_order='cap-then-round')
        b=math.bilateral('0.7','8',eligible=True,cap_order='round-then-cap')
        self.assertNotEqual(a['percentage'],b['percentage'])
        # This stress case has no demonstrated reachability from actual unit13/14
        # class rates and is not a real claimant opportunity or automatic choice.
        for bad in [float('nan'),0.5,True,'101','-1','NaN']:
            with self.assertRaises(ValueError):math.percentage(bad)
        with self.assertRaises(ValueError):math.aggregate([])
        with self.assertRaises(ValueError):math.bilateral('4','4',eligible=False,cap_order='round-then-cap')
        with self.assertRaises(ValueError):math.bilateral('4','4',eligible=True,cap_order='choose-largest')

    @settings(max_examples=100,derandomize=True,deadline=None,database=None)
    @given(st.lists(st.integers(0,10000),min_size=1,max_size=12))
    def test_fraction_oracle_and_order_invariance(self,values):
        rates=[Decimal(x)/100 for x in values]
        result=math.aggregate(rates)['percentage']
        self.assertEqual(Fraction(result),oracle(rates))
        self.assertEqual(result,math.aggregate(list(reversed(rates)))['percentage'])
        self.assertTrue(0<=result<=100)

    @settings(max_examples=100,derandomize=True,deadline=None,database=None)
    @given(st.integers(0,10000),st.integers(0,10000))
    def test_known_baseline_difference(self,a,b):
        a,b=Decimal(a)/100,Decimal(b)/100
        result=math.difference(a,b)
        if a>=b:self.assertEqual(result['percentage'],a-b)
        else:self.assertEqual(result['state'],'unresolved')


if __name__=='__main__':unittest.main(verbosity=2)
