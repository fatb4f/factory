#!/usr/bin/env python3
"""Private exchange -> verified CUE/native projections -> Arrow/DuckDB/Ibis.

Never execute code from an input package. Source observations remain attributed
provider records, not clinical findings, legal qualifications or entitlements.
"""
import argparse
from datetime import date
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import tempfile
from urllib.parse import unquote
import zipfile

import ivac_regulatory as regulatory
from ivac_regulatory_bulk import inspect_zip
from ivac_workbench import cue_validate, execute_plan
from personal.ivac.workbench.generated import timeline_rows as native
from personal.ivac.workbench.generated import timeline_exchange as exchange_types

TABLE_MODELS = {
 'datasets': native.TimelineDatasetRow, 'sources': native.TimelineSourceRow,
 'document_pages': native.TimelinePageRow, 'source_payloads': native.TimelinePayloadRow, 'events': native.TimelineEventRow,
 'evidence_anchors': native.TimelineAnchorRow, 'assessments': native.TimelineAssessmentRow,
 'sequela_vectors': native.TimelineVectorRow, 'source_aliases': native.TimelineAliasRow,
 'assessment_comparisons': native.TimelineComparisonRow,
}
SCHEMA_PATH=regulatory.ROOT/'personal/ivac/workbench/generated/timeline_rows.schema.json'


def loads(value):
    def pairs(items):
        result={}
        for key, value in items:
            if key in result: raise ValueError('duplicate JSON key')
            result[key]=value
        return result
    def invalid(value): raise ValueError('non-finite JSON number')
    return json.loads(value, parse_float=Decimal, object_pairs_hook=pairs, parse_constant=invalid)


def encoded(value): return regulatory.exact_json(value)
def digest(data): return regulatory.digest(data)
def stable_id(*parts): return hashlib.sha256(encoded(list(parts)).encode()).hexdigest()


class VerifiedPackage:
    def __init__(self, path):
        self.path=Path(path)
        if self.path.stat().st_size>300*1024*1024: raise ValueError('package exceeds bound')
        self.dataset_id=digest(self.path.read_bytes())
        members=inspect_zip(self.path.read_bytes(),require_xml=False)
        self.archive=zipfile.ZipFile(self.path)
        self.members=dict(members)
        try:
            # Complete member verification, including OCR and original files.
            manifest=loads(self.read('package-manifest.json'))
            listed=set()
            for entry in manifest:
                if set(entry)!={'path','bytes','sha256'} or type(entry['bytes']) is not int or entry['bytes']<0:
                    raise ValueError('unexpected manifest structure')
                name=entry['path']
                if name in listed: raise ValueError('duplicate manifest identity')
                listed.add(name)
                data=self.read(name)
                if len(data)!=entry['bytes'] or hashlib.sha256(data).hexdigest()!=entry['sha256']:
                    raise ValueError('package manifest digest/size mismatch: '+name)
            if listed != set(self.members)-{'package-manifest.json'}:
                raise ValueError('manifest does not cover exact package member set')
            self.exchange=loads(self.read('ivac-complete.json'))
            cue_validate(self.exchange,'#TimelineExchange')
            # Validate native input records generated from CUE, not package code.
            for key,model in [('sources',exchange_types.TimelineSource),('timeline',exchange_types.TimelineEvent),
                              ('assessments',exchange_types.TimelineRecord),('sequelae_vectors',exchange_types.TimelineRecord)]:
                for record in self.exchange[key]: model.model_validate(record)
            self.sources={s['id']:s for s in self.exchange['sources']}
            for source in self.sources.values():
                if source['raw_path'] is not None:
                    raw=self.read(source['raw_path'])
                    if hashlib.sha256(raw).hexdigest()!=source['raw_sha256']:
                        raise ValueError('original source digest mismatch')
                elif source['raw_sha256'] is not None:
                    raise ValueError('original digest without original member')
                for path in source['text_paths']: self.read(path)
            self.page_records=[loads(line) for line in self.read('document-pages.jsonl').splitlines() if line.strip()]
            self.page_index={}
            self.page_paths={}
            for p in self.page_records:
                if set(p)!={'source_id','text_path','page','text'}: raise ValueError('unexpected page structure')
                source=self.sources[p['source_id']]
                if p['text_path'] not in source['text_paths']: raise ValueError('page outside source text inventory')
                text=self.text(p['text_path'])
                if text!=p['text']: raise ValueError('document page text/member mismatch')
                key=stable_id(p['source_id'],p['text_path'],p['page'])
                if key in self.page_index: raise ValueError('duplicate document page identity')
                self.page_index[key]={'page_id':key,'source_id':p['source_id'],'text_path':p['text_path'],
                                      'page':p['page'],'text_sha256':digest(text.encode()),'character_count':len(text)}
                self.page_paths.setdefault((p['source_id'],p['page']),[]).append(p['text_path'])
            expected={(sid,p) for sid,s in self.sources.items() for p in s['text_paths']}
            actual={(p['source_id'],p['text_path']) for p in self.page_records}
            if actual-expected: raise ValueError('page index outside source text inventory')
            # Spreadsheet/native serialized payloads are not fabricated PDF pages.
            self.payload_index={}
            for sid,path in sorted(expected-actual):
                text=self.text(path);key=stable_id(sid,path)
                self.payload_index[key]={'payload_id':key,'source_id':sid,'text_path':path,
                                         'text_sha256':digest(text.encode()),'character_count':len(text)}
            cue_validate({'format':'ivac.timeline-acquisition/v1','dataset_id':self.dataset_id,
                          'exchange':self.exchange,'pages':self.page_index,'payloads':self.payload_index,'semantic_admission':'none'},'#TimelineAcquisition')
        except Exception:
            self.close()
            raise

    def read(self,path):
        if path not in self.members: raise ValueError('missing package member: '+str(path))
        return self.archive.read(self.members[path])

    def text(self,path): return self.read(path).decode('utf-8',errors='strict')
    def close(self): self.archive.close()


def project(package):
    result={key:[] for key in TABLE_MODELS}
    def add(table,row):
        row={'dataset_id':package.dataset_id,**row}
        TABLE_MODELS[table].model_validate(row)
        result[table].append(row)
    b=package.exchange
    add('datasets',{'format':b['format'],'version':b['version'],'authority':b['authority'],
                    'exchange_sha256':digest(package.read('ivac-complete.json')),'semantic_admission':'none',
                    'coverage_json':encoded(b['coverage']),'gaps_json':encoded(b['gaps'])})
    aliases={}
    prior=loads(package.read('ivac/original-comparison.json')) if 'ivac/original-comparison.json' in package.members else None
    if prior:
        for s in prior['sources']:
            targets=[v['id'] for v in b['sources'] if v['raw_sha256']==s['sha256']]
            if not targets: raise ValueError('prior assessment source digest has no acquired source')
            aliases[s['sourceID']]=targets
            for target in sorted(targets):
                add('source_aliases',{'alias_id':s['sourceID'],'source_id':target,'basis':'original-artifact-digest'})
    if 'prior/v0.1.0-snapshot.json' in package.members:
        legacy=loads(package.read('prior/v0.1.0-snapshot.json'))
        for old in legacy['sources']:
            targets=[v['id'] for v in b['sources'] if v['raw_sha256']==old['pdf_sha256']]
            targets=[sid for sid in targets if any(
                digest(package.read(path)).removeprefix('sha256:')==old['text_sha256']
                for path in package.sources[sid]['text_paths'])]
            if not targets: raise ValueError('legacy source has no digest-matched acquired source')
            aliases[old['id']]=targets
            for target in sorted(targets):
                add('source_aliases',{'alias_id':old['id'],'source_id':target,'basis':'original-and-text-digests'})
    def resolve(ref):
        if ref in package.sources: return ref
        targets=aliases.get(ref,[])
        return targets[0] if len(targets)==1 else None
    for s in sorted(b['sources'],key=lambda x:x['id']):
        add('sources',{'source_id':s['id'],'title':s['title'],'origin':s['origin'],'source_url':s['source_url'],
                       'mime_type':s['mime_type'],'raw_path':s['raw_path'],'raw_sha256':s['raw_sha256'],
                       'extraction_status':s['extraction_status'],
                       'byte_verification':'original-verified' if s['raw_path'] else 'snapshot-only',
                       'pages':s['pages'],'role':s['role'],'content_json':encoded(s)})
    for p in sorted(package.page_records,key=lambda x:(x['source_id'],x['text_path'],x['page'] or 0)):
        key=stable_id(p['source_id'],p['text_path'],p['page'])
        add('document_pages',{**package.page_index[key],'text':p['text']})

    for descriptor in package.payload_index.values():
        add('source_payloads',{**descriptor,'text':package.text(descriptor['text_path'])})

    def anchor(owner_kind,owner_id,position,evidence,review='unspecified-provider-status'):
        ref=evidence.get('source_id',evidence.get('sourceID'))
        source_id=resolve(ref)
        page=evidence.get('page')
        text_path=evidence.get('text_path')
        if text_path is None and source_id:
            candidates=package.sources[source_id]['text_paths']
            if len(candidates)==1: text_path=candidates[0]
            elif len(package.page_paths.get((source_id,page),[]))==1:
                text_path=package.page_paths[(source_id,page)][0]
        start=evidence.get('start');end=evidence.get('end');quote=evidence.get('quote')
        text_hash=None
        integrity='locator-only' if source_id else 'unresolved-source'
        if start is not None or end is not None:
            if source_id is None or text_path is None or start is None or end is None or quote is None:
                raise ValueError(f'incomplete exact evidence path: {owner_kind}/{owner_id}/{position}, source={bool(source_id)}, text={bool(text_path)}, offsets={start!r},{end!r}, quote={quote is not None}')
            # Explicit text paths must belong to the resolved source or the
            # source's prior OCR namespace verified by the same artifact digest.
            permitted=package.sources[source_id]['text_paths']
            if text_path not in permitted and not text_path.startswith('ivac/ocr/'):
                raise ValueError('anchor text outside source inventory')
            text=package.text(text_path)
            if not isinstance(start,int) or isinstance(start,bool) or not isinstance(end,int) or isinstance(end,bool):
                raise ValueError('non-integer anchor offsets')
            if not 0<=start<end<=len(text) or text[start:end]!=quote:
                raise ValueError('citation offset/text mismatch')
            text_hash=digest(text.encode());integrity='exact-verified'
        elif text_path is not None:
            text_hash=digest(package.read(text_path))
        key=stable_id(owner_kind,owner_id,position,evidence)
        add('evidence_anchors',{'anchor_id':key,'owner_kind':owner_kind,'owner_id':owner_id,'position':position,
                              'source_id':source_id,'original_source_id':ref,'page':page,'text_path':text_path,
                              'text_sha256':text_hash,'start':start,'end':end,'quote':quote,
                              'review':evidence.get('review',review),'integrity':integrity,'content_json':encoded(evidence)})

    for e in sorted(b['timeline'],key=lambda x:x['id']):
        if e['normalized_start'] is not None: date.fromisoformat(e['normalized_start'])
        add('events',{'event_id':e['id'],'date_label':e['date_label'],'normalized_start':e['normalized_start'],
                      'summary':e['summary'],'evidence_status':e['evidence_status'],'content_json':encoded(e)})
        for position,a in enumerate(e['evidence']): anchor('event',e['id'],position,a)
    def percentage(value):
        if value is None: return None,'unknown'
        if not isinstance(value,(int,Decimal)) or isinstance(value,bool): return None,'opaque'
        d=Decimal(value)
        if not d.is_finite() or d<0 or d>100: raise ValueError('percentage outside schedule bounds')
        if d.as_tuple().exponent < -18: raise ValueError('decimal scale exceeds storage policy; refuse rounding')
        return d,'recorded'
    def scalar(v): return None if v is None else v if isinstance(v,str) else encoded(v)
    for r in sorted(b['sequelae_vectors'],key=lambda x:x['id']):
        c=r['content'];value,state=percentage(c.get('percentage'))
        add('sequela_vectors',{'vector_id':r['id'],'kind':r['kind'],'domain':scalar(c.get('domain')),
                              'candidate':scalar(c.get('candidate')),'status':scalar(c.get('status',c.get('clinical_status'))),
                              'permanence':scalar(c.get('permanence')),'causal_nexus':scalar(c.get('causal_nexus')),
                              'regulatory_unit_id':scalar(c.get('regulatory_unit_id')),'class_label':scalar(c.get('regulatory_class')),
                              'percentage':value,'percentage_state':state,'content_json':encoded(r)})
        position=0
        for field in ('evidence','new_primary_evidence','crdm_primary_evidence'):
            for a in c.get(field,[]) or []:
                if isinstance(a,dict): anchor('vector',r['id'],position,a,'imported-provider-evidence');position+=1
    for r in sorted(b['assessments'],key=lambda x:x['id']):
        c=r['content'];value,state=percentage(c.get('percentage'));ref=c.get('source_id',c.get('sourceID'))
        add('assessments',{'assessment_id':r['id'],'kind':r['kind'],'source_id':resolve(ref),
                           'assessment_date':scalar(c.get('date',c.get('documentDate'))),
                           'assessor':scalar(c.get('assessor',c.get('author'))),'percentage':value,'percentage_state':state,
                           'class_label':scalar(c.get('gravity',c.get('regulatory_class'))),
                           'review_status':scalar(c.get('reviewStatus',c.get('status'))),'content_json':encoded(r)})
        if ref:
            for position,page in enumerate(c.get('pdfPages',[None])):
                anchor('assessment',r['id'],position,{'source_id':ref,'page':page},c.get('reviewStatus','provider-attribution'))
    if prior:
        prior_evidence={}
        for i,a in enumerate(prior['anchors']):
            if a['documentID'] not in {r['id'] for r in b['assessments']}:
                raise ValueError('prior anchor references unknown assessment')
            path='ivac/'+a['textFile']
            if digest(package.read(path)).removeprefix('sha256:')!=a['textSHA256']:
                raise ValueError('prior assessment text digest mismatch')
            source_id=resolve(a['sourceID'])
            if not source_id or package.sources[source_id]['raw_sha256']!=a['sourceArtifactSHA256']:
                raise ValueError('prior assessment original digest mismatch')
            evidence={'source_id':a['sourceID'],'page':a['pdfPage'],'text_path':path,
                      'start':a['start'],'end':a['end'],'quote':a['quoteOCR']}
            if a['anchorID'] in prior_evidence: raise ValueError('duplicate prior anchor identity')
            prior_evidence[a['anchorID']]=(evidence,a['verification'])
            anchor('assessment',a['documentID'],1000+i,evidence,a['verification'])
        for i,c in enumerate(prior['comparison']['rows']):
            key=stable_id('comparison',i,c)
            add('assessment_comparisons',{'comparison_id':key,'topic':c['topic'],'left_assertion':c['clinician'],
                                          'right_assertion':c['ivacBMY'],'difference':c['difference'],
                                          'origin_path':'ivac/original-comparison.json','status':'candidate-unresolved',
                                          'automatic_selection':False})
            for position,ref in enumerate(c.get('anchors',[])):
                if ref not in prior_evidence: raise ValueError('comparison anchor reference missing')
                evidence,review=prior_evidence[ref]
                anchor('comparison',key,position,evidence,review)
    return result


def arrow_schema(table):
    """Derive Arrow fields from generated CUE JSON Schema, not handwritten SQL."""
    import pyarrow as pa
    schema=loads(SCHEMA_PATH.read_bytes())
    def resolve(v):
        if '$ref' in v: return resolve(schema['$defs'][unquote(v['$ref'].split('/')[-1])])
        return v
    def dtype(v):
        v=resolve(v)
        if 'anyOf' in v:
            options=[resolve(x) for x in v['anyOf']]
            nonnull=[x for x in options if x.get('type')!='null']
            if len(nonnull)!=1: raise ValueError('unsupported Arrow union')
            return dtype(nonnull[0])[0],len(nonnull)!=len(options)
        t=v.get('type')
        if t is None and 'const' in v: t='boolean' if isinstance(v['const'],bool) else 'string'
        if t is None and 'enum' in v and all(isinstance(x,str) for x in v['enum']): t='string'
        types={'string':pa.string(),'integer':pa.int64(),'number':pa.decimal128(38,18),'boolean':pa.bool_()}
        if t not in types: raise ValueError('unsupported Arrow field type: '+str(t))
        return types[t],False
    row=resolve(schema['properties'][table])
    return pa.schema([pa.field(k,*dtype(v)) for k,v in sorted(row['properties'].items())])


def table_digest(records):
    def normalize(v):
        if isinstance(v,Decimal): return v.normalize()
        if isinstance(v,list): return [normalize(x) for x in v]
        if isinstance(v,dict): return {k:normalize(x) for k,x in v.items()}
        return v
    return digest(encoded(normalize(records)).encode())


def ingest(package_path,database_path):
    import ibis
    import pyarrow as pa
    package=VerifiedPackage(package_path)
    try: tables=project(package)
    finally: package.close()
    path=Path(database_path);path.parent.mkdir(parents=True,exist_ok=True)
    checks={key:table_digest(value) for key,value in tables.items()}
    if path.exists():
        con=ibis.duckdb.connect(str(path),read_only=True)
        try:
            existing=con.table('datasets').to_pyarrow().to_pylist()
            if len(existing)!=1 or existing[0]['dataset_id']!=package.dataset_id:
                raise FileExistsError('database contains a different dataset; select a new path')
            for key,records in tables.items():
                actual=con.table(key).to_pyarrow().to_pylist()
                # Rows are logically ordered, independent of physical backend order.
                if table_digest(sorted(actual,key=encoded))!=table_digest(sorted(records,key=encoded)):
                    raise ValueError('existing database projection differs from verified input')
        finally: con.disconnect()
    else:
        with tempfile.TemporaryDirectory(prefix='.ivac-ingest-',dir=path.parent) as directory:
            temporary=Path(directory)/'staging.duckdb'
            con=ibis.duckdb.connect(str(temporary))
            try:
                for key,records in tables.items():
                    con.create_table(key,pa.Table.from_pylist(records,schema=arrow_schema(key)))
            finally: con.disconnect()
            # No overwrite: a concurrent writer cannot silently replace a dataset.
            import os
            os.link(temporary,path)
            path.chmod(0o600)
    return {'dataset_id':package.dataset_id,'tables':{k:len(v) for k,v in tables.items()},
            'table_digests':checks,'semantic_admission':'none','database':str(path)}


def query_plan(name,source,*,basis):
    if not basis: raise ValueError('explicit diagnostic authorization required')
    names={'chronology':'events','source-status':'sources','vectors':'sequela_vectors','assessment-comparisons':'assessment_comparisons','event-evidence':'evidence_anchors'}
    table=names[name]
    key={'events':'event_id','sources':'source_id','sequela_vectors':'vector_id','assessment_comparisons':'comparison_id','evidence_anchors':'anchor_id'}[table]
    operations=[{'kind':'order','by':[{'field':key,'direction':'asc'}]}]
    if name=='chronology': operations=[{'kind':'order','by':[{'field':'normalized_start','direction':'asc'},{'field':'event_id','direction':'asc'}]}]
    if name=='event-evidence':
        operations=[{'kind':'filter','predicate':'owner_kind == "event"','basis':[basis]},
                    {'kind':'join','right':source('events'),'joinType':'inner',
                     'on':[{'left':'dataset_id','right':'dataset_id'},{'left':'owner_id','right':'event_id'}]}]
    grain={'keys':['dataset_id',key],'unit':'unadmitted-source-observation'}
    return {'apiVersion':'factory.analytics-ir/v1','kind':'RelationalPlan','id':'ivac-timeline-'+name,
            'request':{'apiVersion':'factory.analytics-ir/v1','kind':'AnalyticalRequest','id':'ivac-timeline-'+name,
                       'source':source(table),'grain':grain,'operations':operations},'steps':operations,'outputGrain':grain,
            'provenance':{'authority':'contracts/personal/ivac/workbench/timeline.cue','basis':[basis]}}


def query(database_path,name):
    import ibis
    con=ibis.duckdb.connect(str(database_path),read_only=True)
    try:
        tables={key:con.table(key) for key in TABLE_MODELS}
        data=tables['datasets'].to_pyarrow().to_pylist()
        if len(data)!=1: raise ValueError('expected one pinned dataset')
        def source(key):
            return {'id':key,'snapshotDigest':data[0]['dataset_id'],'provenance':[data[0]['dataset_id']],
                    'admissibility':{'state':'admitted','authority':'private-diagnostic-execution-only',
                                     'basis':['does-not-admit-clinical-or-legal-facts']}}
        plan=query_plan(name,source,basis='explicit-private-diagnostic-query')
        return execute_plan(plan,tables).expression.to_pyarrow().to_pylist()
    finally: con.disconnect()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest='mode',required=True)
    p=sub.add_parser('ingest');p.add_argument('package',type=Path);p.add_argument('database',type=Path)
    q=sub.add_parser('query');q.add_argument('database',type=Path);q.add_argument('view',choices=['chronology','source-status','vectors','assessment-comparisons','event-evidence'])
    args=parser.parse_args()
    value=ingest(args.package,args.database) if args.mode=='ingest' else query(args.database,args.view)
    print(encoded(value))


if __name__=='__main__': main()
