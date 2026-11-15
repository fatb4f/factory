#!/usr/bin/env python3
"""Invented exchange data only. No case records are fixtures."""
import copy
from decimal import Decimal
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
import zipfile

import ibis
import pyarrow as pa
from pydantic import ValidationError
import ivac_timeline as timeline
from ivac_workbench import cue_validate, execute_plan


def fixture():
    text='Synthetic assessment alpha.\nSynthetic assessment beta.\n'
    raw=b'SYNTHETIC ORIGINAL BYTES; NOT A CLINICAL REPORT'
    sha=hashlib.sha256(raw).hexdigest()
    source={'id':'synthetic-source','title':'Invented source','origin':'synthetic-test','source_url':None,
            'parent_ids':[],'mime_type':'text/plain','raw_path':'raw/source.txt','raw_sha256':sha,
            'extraction_status':'synthetic-machine-unreviewed','pages':1,'text_paths':['text/source.txt'],
            'role':'synthetic-source','details':{}}
    evidence={'source_id':source['id'],'page':1,'text_path':'text/source.txt','start':0,
              'end':len('Synthetic assessment alpha.'),'quote':'Synthetic assessment alpha.','review':'machine_extraction'}
    exchange={'format':'ivac.complete.evidence.exchange','version':'0.2.0','authority':'synthetic acquisition only',
              'sources':[source],'timeline':[
                  {'id':'event-later','date_label':'2020-02-01','normalized_start':'2020-02-01','summary':'Invented later event',
                   'evidence_status':'unreviewed','evidence':[evidence],'content':{'provider_note':'Synthetic only'}},
                  {'id':'event-earlier','date_label':'2020-01-01','normalized_start':'2020-01-01','summary':'Invented earlier event',
                   'evidence_status':'unreviewed','evidence':[],'content':{}}],
              'assessments':[{'id':'assessment-one','kind':'synthetic-opinion','content':{'source_id':source['id'],
                  'date':'2020-01-01','assessor':'Invented author','percentage':Decimal('2.500000000000000001'),'gravity':'A'}},
                  {'id':'assessment-zero','kind':'synthetic-opinion','content':{'source_id':source['id'],'percentage':0}}],
              'sequelae_vectors':[{'id':'vector-one','kind':'candidate','content':{'domain':'synthetic-function',
                  'candidate':'Invented candidate','permanence':'unknown','causal_nexus':'unknown','percentage':None,
                  'evidence':[{'source_id':source['id'],'page':1,'quote':'Unanchored provider quote'}]}}],
              'coverage':{'semantics':'not-admitted'},'gaps':['Synthetic input only']}
    pages=[{'source_id':source['id'],'text_path':'text/source.txt','page':1,'text':text}]
    return exchange,{'raw/source.txt':raw,'text/source.txt':text.encode()},pages


def package(path, exchange=None, files=None, pages=None, extras=None, bad_manifest=False):
    default,source_files,source_pages=fixture()
    exchange=copy.deepcopy(default) if exchange is None else exchange
    members=dict(source_files if files is None else files)
    members['ivac-complete.json']=timeline.encoded(exchange).encode()
    members['document-pages.jsonl']=b'\n'.join(timeline.encoded(p).encode() for p in (source_pages if pages is None else pages))
    if extras: members.update(extras)
    manifest=[{'path':key,'bytes':len(value),'sha256':hashlib.sha256(value).hexdigest()} for key,value in sorted(members.items())]
    if bad_manifest: manifest[0]['sha256']='0'*64
    members['package-manifest.json']=json.dumps(manifest).encode()
    with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as archive:
        for key,value in sorted(members.items()): archive.writestr(key,value)
    return Path(path)


class TimelineTests(unittest.TestCase):
    def test_end_to_end_persistence_native_roundtrip_and_queries(self):
        with tempfile.TemporaryDirectory() as directory:
            source=package(Path(directory)/'input.zip'); db=Path(directory)/'data.duckdb'
            result=timeline.ingest(source,db)
            self.assertEqual(result['tables']['sources'],1)
            self.assertEqual(result['tables']['events'],2)
            self.assertEqual(result['tables']['document_pages'],1)
            self.assertEqual(timeline.ingest(source,db)['table_digests'],result['table_digests'])
            chronology=timeline.query(db,'chronology')
            self.assertEqual([r['event_id'] for r in chronology],['event-earlier','event-later'])
            evidence=timeline.query(db,'event-evidence')
            self.assertEqual(len(evidence),1)
            self.assertEqual(evidence[0]['source_id'],'synthetic-source')
            self.assertEqual(timeline.query(db,'source-status')[0]['byte_verification'],'original-verified')
            self.assertIsNone(timeline.query(db,'vectors')[0]['percentage'])
            self.assertEqual(timeline.query(db,'assessment-comparisons'),[])
            con=ibis.duckdb.connect(str(db),read_only=True)
            try:
                rates={r['assessment_id']:r['percentage'] for r in con.table('assessments').to_pyarrow().to_pylist()}
                self.assertEqual(rates['assessment-one'],Decimal('2.500000000000000001'))
                self.assertEqual(rates['assessment-zero'],Decimal(0))
            finally: con.disconnect()
            verified=timeline.VerifiedPackage(source)
            try: tables=timeline.project(verified)
            finally: verified.close()
            for key,records in tables.items():
                for row in records:
                    model=timeline.TABLE_MODELS[key].model_validate(row)
                    cue_validate(row,'#'+type(model).__name__)
            with self.assertRaises(ValidationError):
                timeline.TABLE_MODELS['events'].model_validate({**tables['events'][0],'admitted':True})

    def test_manifest_raw_page_and_quote_integrity(self):
        with tempfile.TemporaryDirectory() as d:
            d=Path(d)
            source=package(d/'bad-manifest.zip',bad_manifest=True)
            with self.assertRaisesRegex(ValueError,'manifest digest'): timeline.VerifiedPackage(source)
            b,files,pages=fixture();files['raw/source.txt']=b'tampered'
            with self.assertRaisesRegex(ValueError,'original source digest'):
                timeline.VerifiedPackage(package(d/'bad-raw.zip',b,files,pages))
            b,files,pages=fixture();pages[0]['text']='different page'
            with self.assertRaisesRegex(ValueError,'page text/member'):
                timeline.VerifiedPackage(package(d/'bad-page.zip',b,files,pages))
            b,files,pages=fixture();b['timeline'][0]['evidence'][0]['start']=1
            source=package(d/'bad-quote.zip',b,files,pages)
            with self.assertRaisesRegex(ValueError,'offset/text'): timeline.ingest(source,d/'never-created.duckdb')
            self.assertFalse((d/'never-created.duckdb').exists())
            b,files,pages=fixture();del files['raw/source.txt']
            with self.assertRaisesRegex(ValueError,'missing package member'):
                timeline.VerifiedPackage(package(d/'missing-raw.zip',b,files,pages))

    def test_unsafe_zip_and_duplicate_json_keys(self):
        with tempfile.TemporaryDirectory() as d:
            source=package(Path(d)/'unsafe.zip',extras={'../escape':b'unsafe'})
            with self.assertRaisesRegex(ValueError,'unsafe ZIP'): timeline.VerifiedPackage(source)
        with self.assertRaisesRegex(ValueError,'duplicate JSON'): timeline.loads('{"id":1,"id":2}')
        with self.assertRaisesRegex(ValueError,'non-finite'): timeline.loads('{"rate":NaN}')

    def test_duplicate_and_dangling_identities(self):
        mutants=[lambda b:b['sources'].append(copy.deepcopy(b['sources'][0])),
                 lambda b:b['timeline'].append(copy.deepcopy(b['timeline'][0])),
                 lambda b:b['timeline'][0]['evidence'][0].update(source_id='absent'),
                 lambda b:b.update(adjudication='recognized')]
        with tempfile.TemporaryDirectory() as d:
            for i,mutate in enumerate(mutants):
                b,files,pages=fixture();mutate(b)
                with self.subTest(i=i),self.assertRaises(subprocess.CalledProcessError):
                    timeline.VerifiedPackage(package(Path(d)/f'bad-{i}.zip',b,files,pages))
            b,files,pages=fixture();pages.append(copy.deepcopy(pages[0]))
            with self.assertRaisesRegex(ValueError,'duplicate document page'):
                timeline.VerifiedPackage(package(Path(d)/'duplicate-page.zip',b,files,pages))

    def test_unknown_precision_and_snapshot_only(self):
        with tempfile.TemporaryDirectory() as d:
            b,files,pages=fixture();b['sources'][0].update(raw_path=None,raw_sha256=None)
            b['sources'][0]['text_paths'].append('payload/all-cells.json')
            files['payload/all-cells.json']=b'{"cells":[["synthetic",1]]}'
            source=package(Path(d)/'native-only.zip',b,files,pages)
            result=timeline.ingest(source,Path(d)/'native.duckdb')
            rows=timeline.query(Path(result['database']),'source-status')
            self.assertEqual(rows[0]['byte_verification'],'snapshot-only')
            self.assertEqual(result['tables']['source_payloads'],1)
            b,files,pages=fixture();b['assessments'][0]['content']['percentage']=Decimal('2.1234567890123456789')
            with self.assertRaisesRegex(ValueError,'refuse rounding'):
                timeline.ingest(package(Path(d)/'precision.zip',b,files,pages),Path(d)/'no-rounding.duckdb')

    def test_no_overwrite_or_silent_database_drift(self):
        with tempfile.TemporaryDirectory() as d:
            d=Path(d);source=package(d/'input.zip');db=d/'data.duckdb'
            timeline.ingest(source,db)
            con=ibis.duckdb.connect(str(db));con.raw_sql('DELETE FROM events');con.disconnect()
            with self.assertRaisesRegex(ValueError,'differs from verified input'):timeline.ingest(source,db)
            b,files,pages=fixture();b['gaps'].append('different dataset')
            with self.assertRaises(FileExistsError):timeline.ingest(package(d/'other.zip',b,files,pages),db)

    def test_ibis_join_is_dataset_scoped(self):
        con=ibis.duckdb.connect()
        try:
            anchors=pa.table({'dataset_id':['sha256:'+'a'*64],'anchor_id':['anchor'],'owner_id':['same-event'],'owner_kind':['event']})
            events=pa.table({'dataset_id':['sha256:'+'a'*64,'sha256:'+'b'*64],'event_id':['same-event','same-event'],'summary':['correct','other dataset']})
            tables={'evidence_anchors':con.create_table('evidence_anchors',anchors),'events':con.create_table('events',events)}
            def source(key):return {'id':key,'snapshotDigest':'sha256:'+'a'*64,'provenance':['synthetic-only'],
                                    'admissibility':{'state':'admitted','authority':'synthetic-diagnostic','basis':['synthetic-only']}}
            plan=timeline.query_plan('event-evidence',source,basis='synthetic-only')
            result=execute_plan(plan,tables).expression.to_pyarrow().to_pylist()
            self.assertEqual([r['summary'] for r in result],['correct'])
        finally: con.disconnect()

    def test_prior_digest_aliases_and_comparison_anchors(self):
        with tempfile.TemporaryDirectory() as d:
            b,files,pages=fixture()
            text=files['text/source.txt']; sha=hashlib.sha256(files['raw/source.txt']).hexdigest()
            prior={'sources':[{'sourceID':'old-source','sha256':sha}],
                   'anchors':[{'anchorID':'old-anchor','documentID':'assessment-one','sourceID':'old-source',
                               'textFile':'ocr/source.txt','textSHA256':hashlib.sha256(text).hexdigest(),
                               'sourceArtifactSHA256':sha,'pdfPage':1,'start':0,'end':len('Synthetic assessment alpha.'),
                               'quoteOCR':'Synthetic assessment alpha.','verification':'machine-unreviewed'}],
                   'comparison':{'rows':[{'topic':'synthetic interpretation','clinician':'Invented reading A',
                                         'ivacBMY':'Invented reading B','difference':'Unresolved synthetic readings',
                                         'anchors':['old-anchor']}]}}
            extras={'ivac/original-comparison.json':timeline.encoded(prior).encode(),'ivac/ocr/source.txt':text}
            result=timeline.ingest(package(Path(d)/'input.zip',b,files,pages,extras),Path(d)/'data.duckdb')
            self.assertEqual(result['tables']['source_aliases'],1)
            self.assertEqual(result['tables']['assessment_comparisons'],1)
            self.assertFalse(timeline.query(Path(result['database']),'assessment-comparisons')[0]['automatic_selection'])
            prior['comparison']['rows'][0]['anchors']=['absent']
            extras['ivac/original-comparison.json']=timeline.encoded(prior).encode()
            with self.assertRaisesRegex(ValueError,'comparison anchor reference'):
                timeline.ingest(package(Path(d)/'bad.zip',b,files,pages,extras),Path(d)/'never.duckdb')

    def test_generated_output_reproduces(self):
        subprocess.run(['python3','scripts/generate_ivac_timeline_types.py','--check'],cwd=timeline.regulatory.ROOT,check=True,capture_output=True)


if __name__=='__main__':unittest.main(verbosity=2)
