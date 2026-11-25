"""Behavioral checks for the evidence-only replay projection."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import unittest

from replay import ProjectionError, project

HERE = Path(__file__).resolve().parent
CUTOFF = "2026-01-04T12:00:00Z"


class ReplayTests(unittest.TestCase):
    def setUp(self):
        self.bundle = json.loads((HERE / "global-major-cyber/replay.json").read_text())

    def test_selected_evidence_and_allowlist(self):
        self.bundle["incident"]["title"] = "LATER TITLE"
        self.bundle["incident"]["openQuestions"]["detection"]["reason"] = "LATER QUESTION"
        self.bundle["incident"]["hypotheses"]["objective"]["proposition"] = "LATER HYPOTHESIS"
        result = project(self.bundle, CUTOFF, ["outage-report"])
        self.assertEqual([a["id"] for a in result["assertions"]], ["outage-report"])
        self.assertEqual(result["assertions"][0]["citations"][0], {
            "captureID": "dispatch", "selector": "paragraph 1", "revision": "original",
            "contentSHA256": "a" * 64,
        })
        encoded = json.dumps(result)
        for value in ("LATER TITLE", "LATER QUESTION", "LATER HYPOTHESIS", "bulletin", "locator"):
            self.assertNotIn(value, encoded)

    def test_cutoff_equality_multiple_citations_and_order(self):
        claim = self.bundle["incident"]["publicClaims"]["outage-report"]
        claim["knownAt"] = CUTOFF
        claim["citations"].append({"captureID": "bulletin", "selector": "section 2"})
        result = project(self.bundle, CUTOFF, ["outage-report"], ["isolation"])
        self.assertEqual(len(result["assertions"][0]["citations"]), 2)
        self.assertEqual(result, project(copy.deepcopy(self.bundle), CUTOFF, ["outage-report"], ["isolation"]))

    def test_unselected_future_evidence_does_not_block(self):
        self.bundle["incident"]["technicalObservations"]["isolation"]["knownAt"] = "2027-01-01T00:00:00Z"
        self.bundle["incident"]["hypotheses"]["objective"]["assessedAt"] = "2027-01-02T00:00:00Z"
        self.bundle["acquisition"]["captures"]["bulletin"]["availability"] = {
            "state": "unknown", "reason": "unselected revision"
        }
        result = project(self.bundle, CUTOFF, ["outage-report"])
        self.assertEqual(len(result["assertions"]), 1)

    def test_selection_order_does_not_change_output(self):
        claims = self.bundle["incident"]["publicClaims"]
        claims["another-report"] = copy.deepcopy(claims["outage-report"])
        first = project(self.bundle, CUTOFF, ["outage-report", "another-report"])
        second = project(self.bundle, CUTOFF, ["another-report", "outage-report"])
        self.assertEqual(first, second)

    def test_invalid_selections(self):
        for ids in (["missing"], ["outage-report", "outage-report"]):
            with self.subTest(ids=ids), self.assertRaises(ProjectionError):
                project(self.bundle, CUTOFF, ids)
        with self.assertRaises(ProjectionError):
            project(self.bundle, "not-a-date", ["outage-report"])

    def test_ineligible_selected_assertion_and_revision(self):
        with self.assertRaises(ProjectionError):
            project(self.bundle, "2026-01-02T11:59:59Z", ["outage-report"])
        capture = self.bundle["acquisition"]["captures"]["dispatch"]
        capture["availability"] = {"state": "unknown", "reason": "unknown date"}
        with self.assertRaises(ProjectionError):
            project(self.bundle, CUTOFF, ["outage-report"])
        capture["availability"] = {"state": "documented", "at": "2026-01-05T12:00:00Z", "basis": "later"}
        self.bundle["incident"]["publicClaims"]["outage-report"]["knownAt"] = "2026-01-05T12:00:00Z"
        with self.assertRaises(ProjectionError):
            project(self.bundle, CUTOFF, ["outage-report"])

    def test_cli_failure_does_not_emit_json(self):
        result = subprocess.run([sys.executable, str(HERE / "replay.py"),
            str(HERE / "global-major-cyber/replay.json"), "--as-of", CUTOFF,
            "--public", "missing"], capture_output=True, text=True, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
