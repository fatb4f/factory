#!/usr/bin/env python3
"""Synthetic acquisition, projection and adversarial integrity tests."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import ivac_official_corpus as corpus
import ivac_regulatory as spans
from ivac_regulatory_sources import encoded
from generate_ivac_regulatory_types import generate
from personal.ivac.corpus.generated.rows import CorpusSourceRow


class CorpusTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / 'synthetic-corpus'
        self.entry = {'id': 'synthetic', 'title': 'Invented fixture', 'category': 'discovery',
                      'sourceKind': 'official-index', 'url': 'https://www.ivac.qc.ca/synthetic',
                      'format': 'html', 'instrument': None}
        self.request = {'format': 'ivac.official-corpus-request/v1', 'entries': [self.entry]}
        with patch.object(corpus, 'fetch', return_value=(b'<html><p>Invented evidence only.</p></html>', self.entry['url'], 'text/html')):
            self.manifest = corpus.acquire(self.request, self.root)

    def tearDown(self):
        self.temp.cleanup()

    def save(self, value):
        (self.root / 'manifest.json').write_bytes(encoded(value))

    def test_native_roundtrip_and_conversion(self):
        corpus.verify(self.root, reconvert=True)
        row = self.manifest['sources'][0]
        native = json.loads(CorpusSourceRow.model_validate(row).model_dump_json())
        self.assertEqual(row, native)
        self.assertIsNone(native['publicationDate'])
        self.assertEqual(native['artifactBytes'], 43)
        corpus.validate(native, '#CorpusSourceRow')
        corpus.validate({'corpusID': 'synthetic-corpus', 'sourceID': 'synthetic',
                         'textDigest': spans.digest('avant\ufeffaprès'.encode()),
                         'text': 'avant\ufeffaprès'}, '#CorpusTextRow')
        native['status'] = 'failed'
        with self.assertRaises(subprocess.CalledProcessError):
            corpus.validate({**self.manifest, 'sources': [native]})

    def test_source_text_and_anchor_integrity(self):
        source = self.manifest['sources'][0]
        textpath = self.root / source['textPath']
        text = textpath.read_text()
        self.manifest['anchors'] = [{'sourceVersion': 'synthetic', 'locator': 'Invented paragraph',
                                    'start': 1, 'end': 9, 'exactText': text[1:9]}]
        self.save(self.manifest)
        corpus.verify(self.root)
        self.manifest['anchors'][0]['start'] += 1
        self.save(self.manifest)
        with self.assertRaisesRegex(ValueError, 'citation text mismatch'):
            corpus.verify(self.root)
        self.manifest['anchors'] = []
        self.save(self.manifest)
        textpath.write_text('tampered')
        with self.assertRaisesRegex(ValueError, 'text integrity'):
            corpus.verify(self.root)
        textpath.write_text(text)
        (self.root / source['artifactPath']).write_bytes(b'tampered')
        with self.assertRaisesRegex(ValueError, 'artifact integrity'):
            corpus.verify(self.root)

    def test_paths_origins_and_content_rejected(self):
        for value in ['../outside', '/outside', 'C:/outside', r'a\b']:
            with self.subTest(path=value), self.assertRaises(ValueError):
                corpus.local(self.root, value)
        outside = Path(self.temp.name) / 'outside'
        outside.write_text('x')
        (self.root / 'escape').symlink_to(outside)
        with self.assertRaises(ValueError):
            corpus.local(self.root, 'escape')
        for url in ['http://www.ivac.qc.ca/a', 'https://ivac.qc.ca.evil/a',
                    'https://www.ivac.qc.ca@evil/a', 'https://www.ivac.qc.ca:444/a', 'https://127.0.0.1/a']:
            with self.subTest(url=url), self.assertRaises(ValueError):
                corpus.official(url)
        with self.assertRaisesRegex(ValueError, 'not PDF'):
            corpus.convert(b'<html>Error</html>', 'pdf')
        with self.assertRaisesRegex(ValueError, 'not HTML'):
            corpus.convert(b'Error', 'html')

    def test_canonical_scope_and_admission_guards(self):
        mutations = [lambda v: v['sources'].append(v['sources'][0]),
                     lambda v: v.update(authority='legal-admission'),
                     lambda v: v['sources'][0].update(corpusID='other'),
                     lambda v: v['sources'][0].update(publicationDate='2026-01-01'),
                     lambda v: v['sources'][0].update(artifactBytes=0),
                     lambda v: v['sources'][0].update(applicability='selected'),
                     lambda v: v['sources'][0].update(extra='unexpected'),
                     lambda v: v.update(anchors=[{'sourceVersion':'missing','locator':'x','start':0,'end':1,'exactText':'x'}])]
        for mutate in mutations:
            value = copy.deepcopy(self.manifest)
            mutate(value)
            with self.assertRaises(subprocess.CalledProcessError):
                corpus.validate(value)
        value = copy.deepcopy(self.manifest)
        value['sources'][0]['title'] = 'changed'
        self.save(value)
        with self.assertRaisesRegex(ValueError, 'metadata mismatch'):
            corpus.verify(self.root)

    def test_failed_acquisition_remains_explicit_in_ir(self):
        request = copy.deepcopy(self.request)
        request['entries'].append({**self.entry, 'id': 'missing', 'url': 'https://www.ivac.qc.ca/missing'})
        target = Path(self.temp.name) / 'mixed-corpus'
        def fetch(url):
            if url.endswith('/missing'):
                raise OSError('synthetic unavailable')
            return b'<html>Invented.</html>', url, 'text/html'
        with patch.object(corpus, 'fetch', side_effect=fetch):
            corpus.acquire(request, target)
        result = corpus.project(target)
        self.assertEqual(result, {'sources': 2, 'acquired': 1, 'failed': 1})
        gaps = json.loads((target / 'coverage-gaps.json').read_bytes())
        self.assertEqual(gaps[0]['sourceID'], 'missing')
        self.assertIsNone(gaps[0]['artifactBytes'])
        import ibis
        con = ibis.duckdb.connect(str(target / 'corpus.duckdb'))
        try:
            self.assertEqual(con.table('source_text').count().execute(), 1)
            self.assertIn('Invented.', con.table('source_text').execute().iloc[0]['text'])
        finally:
            con.disconnect()
        with self.assertRaisesRegex(ValueError, 'overwrite'):
            corpus.project(target)
        with self.assertRaises(FileExistsError):
            corpus.acquire(request, target)
        before = json.loads((target / 'manifest.json').read_bytes())['sources'][0]
        with patch.object(corpus, 'fetch', return_value=(b'<html>Recovered invented source.</html>',
                          'https://www.ivac.qc.ca/missing', 'text/html')):
            recovered = corpus.retry(target, limit=1)
        self.assertEqual(recovered['sources'][0], before)
        self.assertTrue(all(s['status'] == 'acquired' for s in recovered['sources']))
        self.assertTrue(list((target / 'attempts').glob('*.json')))
        corpus.verify(target, reconvert=True)

    def test_generation_is_deterministic(self):
        schema, code = generate('corpusProjectionSchemas', corpus.PACKAGE)
        target = spans.ROOT / 'personal/ivac/corpus/generated'
        self.assertEqual(schema, (target / 'rows.schema.json').read_bytes())
        self.assertEqual(code.replace(b'(CUE regulatoryRowSchemas)', b'(CUE corpusProjectionSchemas)'),
                         (target / 'rows.py').read_bytes())


if __name__ == '__main__':
    unittest.main(verbosity=2)
