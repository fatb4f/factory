#!/usr/bin/env python3
"""Synthetic boundary and provenance regressions; requires CUE v0.16.1."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

import ivac_regulatory as adapter

ROOT = adapter.ROOT
FIXTURES = ROOT / "personal/ivac/regulatory/fixtures"


def export(package, expression):
    return json.loads(subprocess.check_output(
        ["cue", "export", package, "-e", expression, "--out", "json"], cwd=ROOT))


def vet(value, definition, evaluation=False):
    directory = ROOT / "contracts/personal/ivac"
    if evaluation:
        directory /= "evaluations"
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "test.json"
        path.write_text(json.dumps(value), encoding="utf-8")
        return subprocess.run(["cue", "vet", "-c", str(path),
                               *map(str, directory.glob("*.cue")), "-d", definition],
                              cwd=ROOT, capture_output=True, text=True)


class RegulatoryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.compendium = json.loads((FIXTURES / "compendium.json").read_text())
        cls.case = export("./contracts/personal/ivac:ivac", "mockClinicalCase")
        cls.case["review"]["findings"]["syntheticCause"] = {
            "id": "syntheticCause", "kind": "causal-opinion", "axis": {"id": "primary"},
            "producer": {"id": "independentExpert"}, "evidence": [{"id": "expertReport"}],
            "assertion": "Entirely invented causal finding for a structural test."}

    def qualification(self):
        return {"usage": "synthetic-test", "case": copy.deepcopy(self.case),
                "compendium": copy.deepcopy(self.compendium),
                "instance": {"id": "synthetic-evaluation", "contract": {
                    "id": "permanent-sequela", "version": "1.0.0"},
                    "evaluator": {"id": "independentExpert"},
                    "profile": {"id": "mock-profile"}, "parameters": {}},
                "axis": {"id": "primary"}, "unitID": "unitA", "classID": "classA",
                "alternativeID": "pathB", "applicability": {"state": "selected",
                    "asOf": "2026-01-01", "selectedBy": {"id": "counsel"},
                    "rationale": "Synthetic legal selection only."},
                "causation": {"state": "supported", "findings": [{"id": "syntheticCause"}],
                              "rationale": "Synthetic causal opinion only."},
                "assessments": {"gamma": {"criterionID": "gamma", "disposition": "supported",
                    "observations": [{"id": "functionalFailure"}],
                    "findings": [{"id": "primaryFunctional"}],
                    "evidence": [{"id": "expertReport"}], "missingEvidence": [],
                    "rationale": "Explicit synthetic assessment, not an inferred match."}},
                "status": "qualified-candidate", "adjudication": "not-determined", "coverageGaps": []}

    def assertValid(self, value, definition="#RegulatoryQualification", evaluation=True):
        result = vet(value, definition, evaluation)
        self.assertEqual(result.returncode, 0, result.stderr)

    def assertInvalid(self, value, needle, definition="#RegulatoryQualification", evaluation=True):
        result = vet(value, definition, evaluation)
        self.assertNotEqual(result.returncode, 0, "unexpected acceptance")
        self.assertIn(needle, result.stderr, result.stderr)

    def test_positive_and_explicit_unknowns(self):
        self.assertValid(self.qualification())
        value = self.qualification()
        value["status"] = "incomplete"
        value["coverageGaps"] = ["Synthetic unresolved evaluation coverage."]
        value["applicability"] = {"state": "unresolved", "asOf": "2026-01-01", "rationale": "Regime unresolved."}
        value["causation"] = {"state": "unresolved", "findings": [], "rationale": "Attribution missing."}
        value["assessments"]["gamma"].update(disposition="insufficient-evidence", findings=[],
                                             evidence=[], missingEvidence=["Independent assessment needed."])
        self.assertValid(value)

    def test_all_of_and_alternative_paths(self):
        value = self.qualification()
        value["alternativeID"] = "pathA"
        value["assessments"] = {"alpha": dict(value["assessments"]["gamma"], criterionID="alpha")}
        self.assertInvalid(value, "_complete")
        value["assessments"]["beta"] = dict(value["assessments"]["alpha"], criterionID="beta")
        self.assertValid(value)  # gamma is an alternative, not another requirement

    def test_qualification_rejections(self):
        cases = [
            (["unitID"], "missing", "_units"),
            (["classID"], "missing", "_classes"),
            (["alternativeID"], "missing", "_alternatives"),
            (["instance", "profile", "id"], "other", "_profile"),
            (["instance", "evaluator", "id"], "claimant", "_evaluator"),
            (["applicability", "selectedBy", "id"], "claimant", "_selector"),
            (["applicability", "asOf"], "2021-10-12", "_start"),
            (["applicability", "asOf"], "2027-01-01", "_end"),
            (["causation", "state"], "unresolved", "causation.state"),
            (["causation", "findings"], [{"id": "primaryFunctional"}], "_causalFindings"),
            (["assessments", "gamma", "findings"], [], "findings"),
            (["assessments", "gamma", "findings"], [{"id": "absent"}], "_findings"),
            (["assessments", "gamma", "evidence"], [{"id": "absent"}], "_evidence"),
            (["assessments", "gamma", "observations"], [{"id": "absent"}], "_observations"),
            (["assessments", "gamma", "disposition"], "contradicted", "disposition"),
            (["assessments", "gamma", "missingEvidence"], ["missing"], "missingEvidence"),
            (["compendium", "review", "state"], "candidate", "review.state"),
            (["adjudication"], "recognized", "adjudication"),
            (["usage"], "case-assessment", "contentKind"),
        ]
        for path, replacement, needle in cases:
            with self.subTest(path=path):
                value = self.qualification()
                target = value
                for part in path[:-1]:
                    target = target[part]
                target[path[-1]] = replacement
                self.assertInvalid(value, needle)
        value = self.qualification()
        value["assessments"] = {}
        self.assertInvalid(value, "_complete")
        value = self.qualification()
        value["assessments"]["gamma"]["automaticallySatisfied"] = True
        self.assertInvalid(value, "automaticallySatisfied")

    def test_compendium_rejections(self):
        for mutation, needle in [
            (lambda c: c["source"]["effective"].update(until="2020-01-01"), "until"),
            (lambda c: c["source"].update(snapshotDigest="sha256:bad"), "snapshotDigest"),
            (lambda c: c["units"]["unitA"].update(id="wrong"), "_identity"),
            (lambda c: c["units"]["unitA"]["citation"].update(sourceVersion="other"), "_citation"),
            (lambda c: c["units"]["unitA"]["classes"]["classA"]["percentage"].update(value=101), "percentage"),
            (lambda c: c["units"]["unitA"]["classes"]["classA"]["qualification"]["alternatives"].append(
                c["units"]["unitA"]["classes"]["classA"]["qualification"]["alternatives"][0]), "_unique"),
        ]:
            value = copy.deepcopy(self.compendium)
            mutation(value)
            with self.subTest(needle=needle):
                self.assertInvalid(value, needle, "#RegulatoryCompendium", False)

    def test_versions_and_percentage_variants(self):
        value = copy.deepcopy(self.compendium)
        value["source"]["id"] = "synthetic-2026"
        value["source"]["consolidatedAsOf"] = "2026-01-01"
        self.assertInvalid(value, "_citation", "#RegulatoryCompendium", False)
        for citation in adapter.citations(value["units"]):
            citation["sourceVersion"] = "synthetic-2026"
        self.assertValid(value, "#RegulatoryCompendium", False)
        self.assertEqual(self.compendium["source"]["id"], "synthetic-2021")
        for percentage in [{"kind": "fixed", "value": 0},
                           {"kind": "range", "minimum": 0.5, "maximum": 2.5},
                           {"kind": "not-specified", "reason": "Synthetic below-threshold category."}]:
            value["units"]["unitA"]["classes"]["classA"]["percentage"] = percentage
            self.assertValid(value, "#RegulatoryCompendium", False)
        value["units"]["unitA"]["classes"]["classA"]["percentage"] = {
            "kind": "range", "minimum": 10, "maximum": 5}
        self.assertInvalid(value, "percentage", "#RegulatoryCompendium", False)

    def test_dates_and_gaps(self):
        for path in [("consolidatedAsOf",), ("effective", "from"), ("effective", "until")]:
            value = copy.deepcopy(self.compendium)
            target = value["source"]
            for part in path[:-1]:
                target = target[part]
            target[path[-1]] = "2026-02-30"
            self.assertInvalid(value, "time.Parse", "#RegulatoryCompendium", False)
        value = self.qualification()
        value["applicability"]["asOf"] = "2026-02-30"
        self.assertInvalid(value, "time.Parse")
        value = self.qualification()
        value["status"] = "incomplete"
        value["coverageGaps"] = ["Synthetic unresolved evaluation coverage."]
        value["assessments"]["gamma"].update(disposition="insufficient-evidence")
        self.assertInvalid(value, "missingEvidence")

    def test_provenance_and_reproducibility(self):
        snapshot = FIXTURES / "synthetic.txt"
        source = self.compendium["source"]
        plan = json.loads((FIXTURES / "plan.json").read_text())
        a = adapter.extract(source, plan, snapshot, snapshot)
        self.assertEqual(a, adapter.extract(source, plan, snapshot, snapshot))
        self.assertEqual(a["status"], "candidate")
        adapter.verify(self.compendium, snapshot, snapshot)
        for field, replacement, message in [("exactText", "tampered", "text mismatch"),
                                             ("end", 999999, "outside snapshot")]:
            changed = copy.deepcopy(self.compendium)
            changed["units"]["unitA"]["citation"][field] = replacement
            with self.assertRaisesRegex(ValueError, message):
                adapter.verify(changed, snapshot, snapshot)
        with tempfile.TemporaryDirectory() as directory:
            altered = Path(directory) / "altered.txt"
            altered.write_bytes(snapshot.read_bytes() + b" ")
            with self.assertRaisesRegex(ValueError, "snapshot digest mismatch"):
                adapter.verify(self.compendium, altered, snapshot)
            with self.assertRaisesRegex(ValueError, "origin digest mismatch"):
                adapter.verify(self.compendium, snapshot, altered)


if __name__ == "__main__":
    unittest.main(verbosity=2)
