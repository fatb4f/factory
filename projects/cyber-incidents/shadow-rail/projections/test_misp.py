#!/usr/bin/env python3
import copy
import importlib.util
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest
import urllib.request

import jsonschema

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('misp', HERE / 'misp.py')
misp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(misp)
PIN = 'e04830400cfeea238124ad4e1e42267aa0f672b7'
BASE = f'https://raw.githubusercontent.com/MISP/misp-galaxy/{PIN}/'


def catalog():
    return {'apiVersion': 'shadow-galaxy/0.1.0', 'id': 'example', 'version': 'source-v1',
            'terms': [{'id': 'actor-a', 'label': 'Actor A', 'description': 'An example', 'srw_concept': 'actor',
                       'source': {'uri': 'https://example.org/source', 'version': '1'},
                       'alignment': {'status': 'unmapped', 'reason': 'No mapping'}}],
            'boundaries': {'vocabulary_establishes_fact': False, 'mapping_establishes_fact': False,
                           'actor_affiliation_inferred': False}}


class ProjectionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.schemas = {}
        for kind, filename in [('galaxy', 'schema_galaxies.json'), ('clusters', 'schema_clusters.json')]:
            with urllib.request.urlopen(BASE + filename, timeout=30) as response:
                cls.schemas[kind] = json.load(response)

    def test_upstream_schema_and_explicit_loss(self):
        result = misp.project(catalog())
        for kind, schema in self.schemas.items():
            jsonschema.validate(result[kind], schema)
        invalid = copy.deepcopy(result['galaxy'])
        invalid['version'] = 'not-an-integer'
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(invalid, self.schemas['galaxy'])
        losses = result['loss_report']['losses']
        alignment = next(item for item in losses if item.get('field') == 'alignment')
        self.assertEqual(alignment['value']['status'], 'unmapped')
        self.assertEqual({item.get('field') for item in losses if 'field' in item}, {'id', 'srw_concept', 'source', 'alignment'})
        self.assertNotIn('country', json.dumps(result['clusters']))

    def test_order_and_stable_identity(self):
        first = catalog()
        second = copy.deepcopy(first['terms'][0])
        second.update(id='actor-b', label='Actor B')
        first['terms'].append(second)
        reordered = copy.deepcopy(first)
        reordered['terms'].reverse()
        self.assertEqual(misp.project(first), misp.project(reordered))
        revised = copy.deepcopy(first)
        revised['version'] = 'source-v2'
        revised['terms'][0]['label'] = 'Revised name'
        before = misp.project(first)['clusters']['values']
        after = misp.project(revised)['clusters']['values']
        self.assertEqual([v['uuid'] for v in before], [v['uuid'] for v in after])
        self.assertNotEqual(before[0]['uuid'], before[1]['uuid'])
        other = copy.deepcopy(first)
        other['id'] = 'another-catalog'
        self.assertNotEqual(before[0]['uuid'], misp.project(other)['clusters']['values'][0]['uuid'])

    def test_cli_rejects_invalid_inputs(self):
        for bad in ('duplicate', 'affiliation', 'unknown'):
            value = catalog()
            if bad == 'duplicate':
                value['terms'].append(copy.deepcopy(value['terms'][0]))
            elif bad == 'affiliation':
                value['terms'][0]['affiliation'] = 'unsupported'
            else:
                value['terms'][0]['srw_concept'] = 'unknown'
            with tempfile.NamedTemporaryFile(mode='w', suffix='.json') as handle:
                json.dump(value, handle)
                handle.flush()
                result = subprocess.run([sys.executable, str(HERE / 'misp.py'), handle.name], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0, bad)
            self.assertEqual(result.stdout, '')

    def test_cli_valid(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json') as handle:
            json.dump(catalog(), handle)
            handle.flush()
            result = subprocess.run([sys.executable, str(HERE / 'misp.py'), handle.name], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), misp.project(catalog()))


if __name__ == '__main__':
    unittest.main()
