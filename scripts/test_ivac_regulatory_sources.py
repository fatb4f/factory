#!/usr/bin/env python3
"""Offline source, completeness, history and candidate-boundary regressions."""
import copy
import subprocess
import tempfile
import unittest
from pathlib import Path

import ivac_regulatory_sources as sources


class SourceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.value = sources.read_json(sources.DATA / "annex-i-2021.candidate.json")
        cls.text = sources.local(cls.value["acquisition"]["textPath"]).read_bytes().decode("utf-8")

    def test_preserved_artifacts_and_exact_conversion(self):
        for identity, *_ in sources.CATALOG:
            with self.subTest(identity=identity):
                record = sources.read_json(sources.SOURCES / f"{identity}.json")
                sources.verify_acquisition(record, reconvert=True)

    def test_full_annex_partition_and_leaf_coverage(self):
        sources.verify_candidate(self.value, self.text)
        self.assertEqual(len(self.value["units"]), 48)
        self.assertEqual(sum(u["kind"] == "functional" for u in self.value["units"]), 40)
        self.assertEqual(sum(u["kind"] == "aesthetic" for u in self.value["units"]), 8)
        self.assertEqual([s["number"] for s in self.value["sections"]], [str(i) for i in range(1, 26)])
        joined = self.value["contents"]["exactText"] + "".join(s["text"]["exactText"] for s in self.value["sections"])
        self.assertEqual(joined, self.value["annex"]["exactText"])
        self.assertEqual(len(self.value["markers"]), 1076)

    def test_missing_or_altered_source_content_rejected(self):
        for mutation in [
            lambda v: v["units"].pop(),
            lambda v: v["sections"].pop(4),
            lambda v: v["markers"].pop(),
            lambda v: v["globalRules"].clear(),
            lambda v: v["units"].append(v["units"][0]),
            lambda v: v["sections"][0]["text"].update(exactText="altered criterion"),
            lambda v: v["coverage"].update(semantics="complete"),
            lambda v: v.update(status="reviewed"),
        ]:
            value = copy.deepcopy(self.value)
            mutation(value)
            with self.assertRaisesRegex(ValueError, "source-derived inventory"):
                sources.verify_candidate(value, self.text)

    def test_original_and_text_tampering_rejected(self):
        with tempfile.TemporaryDirectory(dir=sources.SOURCES) as directory:
            directory = Path(directory)
            record = copy.deepcopy(self.value["acquisition"])
            original = directory / "original.pdf"
            original.write_bytes(b"%PDF-tampered")
            record["artifactPath"] = str(original.relative_to(sources.ROOT))
            with self.assertRaisesRegex(ValueError, "artifact integrity"):
                sources.verify_acquisition(record)
            record = copy.deepcopy(self.value["acquisition"])
            text = directory / "text.txt"
            text.write_text(self.text + "tampered", encoding="utf-8")
            record["textPath"] = str(text.relative_to(sources.ROOT))
            with self.assertRaisesRegex(ValueError, "text integrity"):
                sources.verify_acquisition(record)

    def test_history_and_proposal_boundary(self):
        audit = sources.read_json(sources.DATA / "history-audit.json")
        sources.verify_audit(audit)
        proposal = copy.deepcopy(audit["artifacts"]["gazette-2026-04"])
        proposal["legalEffect"] = "initial-enactment"
        with self.assertRaises(subprocess.CalledProcessError):
            sources.spans.validate(proposal, "#RegulatoryAcquisition")
        changed = copy.deepcopy(audit)
        changed["findings"][0]["citation"]["exactText"] = "invented history"
        with self.assertRaisesRegex(ValueError, "text mismatch"):
            sources.verify_audit(changed)

    def test_candidate_cannot_impersonate_a_compendium(self):
        with self.assertRaises(subprocess.CalledProcessError):
            sources.spans.validate(self.value, "#RegulatoryCompendium")
        value = copy.deepcopy(self.value)
        value["status"] = "reviewed"
        with self.assertRaises(subprocess.CalledProcessError):
            sources.spans.validate(value, "#RegulatorySerializationCandidate")

    def test_comparison_is_explicitly_non_authoritative(self):
        unchanged = sources.compare(self.value, self.value)
        self.assertEqual(unchanged["changed"], [])
        after = copy.deepcopy(self.value)
        after["acquisition"]["id"] = "synthetic-revision-for-diff-test"
        after["sections"][0]["text"]["exactText"] += " synthetic amendment"
        after["sections"].pop()
        difference = sources.compare(self.value, after)
        self.assertEqual(difference["changed"], ["1"])
        self.assertEqual(difference["removed"], ["25"])
        self.assertEqual(difference["authority"], "none")
        self.assertEqual(difference["legalEffect"], "not-determined")

    def test_reproduction_and_path_boundary(self):
        again = sources.build(self.value["acquisition"], self.text)
        self.assertEqual(sources.encoded(again), sources.encoded(self.value))
        with self.assertRaisesRegex(ValueError, "outside sources"):
            sources.local("../../outside.pdf")


if __name__ == "__main__":
    unittest.main(verbosity=2)
