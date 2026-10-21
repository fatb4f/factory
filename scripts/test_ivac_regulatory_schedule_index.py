#!/usr/bin/env python3
"""Source-partition, shared-schedule and tamper regressions."""
import copy
import unittest

import ivac_regulatory_schedule_index as schedules
from ivac_regulatory_schedule_index import sources


class ScheduleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.candidate = sources.read_json(sources.DATA / 'annex-i-2021.candidate.json')
        cls.text = sources.verify_acquisition(cls.candidate['acquisition'])
        cls.index = sources.read_json(sources.DATA / 'annex-i-2021.schedule-index.json')

    def test_exact_partition_and_reproduction(self):
        schedules.verify(self.index, self.candidate, self.text)
        for original, section in zip(self.candidate['sections'], self.index['sections'], strict=True):
            pieces = section['pieces']
            self.assertEqual(pieces[0]['citation']['start'], original['text']['start'])
            self.assertEqual(pieces[-1]['citation']['end'], original['text']['end'])
            self.assertEqual(''.join(p['citation']['exactText'] for p in pieces), original['text']['exactText'])
            for left, right in zip(pieces, pieces[1:]):
                self.assertEqual(left['citation']['end'], right['citation']['start'])
        self.assertEqual(len(self.index['units']), 48)
        self.assertEqual(len(self.index['occurrences']), 1076)

    def test_shared_bilateral_and_aesthetic_context(self):
        units = {u['number']: u for u in self.index['units']}
        self.assertEqual(units['13.1']['pieceIDs'], units['13.2']['pieceIDs'])
        for n in range(1, 9):
            self.assertEqual(units[f'25.{n}']['pieceIDs'], units['25.8']['pieceIDs'])
        self.assertNotEqual(units['22.1']['pieceIDs'], units['22.2']['pieceIDs'])
        projected = list(schedules.rows(self.index))
        self.assertEqual(len({r['occurrenceID'] for r in projected}), 1076)
        self.assertEqual({r['unitNumber'] for r in projected}, set(units))
        self.assertTrue(all(r['semantics'] == 'pending-review' for r in projected))
        self.assertTrue(all(self.text[r['start']:r['end']] == r['exactText'] for r in projected))

    def test_loss_or_false_promotion_rejected(self):
        for mutate in [lambda x: x['units'].pop(),
                       lambda x: x['occurrences'].pop(),
                       lambda x: x['units'][0]['pieceIDs'].clear(),
                       lambda x: x['sections'][0]['pieces'][0]['citation'].update(start=0),
                       lambda x: x.update(semantics='complete'),
                       lambda x: x.update(status='reviewed')]:
            value = copy.deepcopy(self.index)
            mutate(value)
            with self.assertRaisesRegex(ValueError, 'source-derived projection'):
                schedules.verify(value, self.candidate, self.text)

    def test_ibis_query_roundtrip(self):
        import ibis
        import json
        import tempfile
        from pathlib import Path
        expected = list(schedules.rows(self.index))
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'occurrences.jsonl'
            path.write_text(''.join(json.dumps(r) + '\n' for r in expected))
            con = ibis.duckdb.connect()
            try:
                table = con.read_json(str(path))
                self.assertEqual(table.count().execute(), 2262)
                self.assertEqual(table.occurrenceID.nunique().execute(), 1076)
                self.assertEqual(table.unitNumber.nunique().execute(), 48)
                result = table.filter((table.unitNumber == '1') & (table.kind == 'severity')).execute()
                self.assertTrue(len(result) > 0)
                self.assertTrue(all(self.text[r.start:r.end] == r.exactText for r in result.itertuples()))
            finally:
                con.disconnect()

    def test_compendium_boundary(self):
        import subprocess
        with self.assertRaises(subprocess.CalledProcessError):
            sources.spans.validate(self.index, '#RegulatoryCompendium')


if __name__ == '__main__':
    unittest.main(verbosity=2)
