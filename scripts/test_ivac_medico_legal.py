#!/usr/bin/env python3
"""Synthetic-only medico-legal role, reference and authority boundary tests."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOMAIN = ROOT / "contracts/personal/ivac"
EVAL = DOMAIN / "evaluations"


def export(expression):
    return json.loads(subprocess.check_output(
        ["cue", "export", "./contracts/personal/ivac:ivac", "-e", expression, "--out", "json"], cwd=ROOT))


def vet(value, definition):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "value.json"
        path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        return subprocess.run(["cue", "vet", "-c", str(path), *map(str, EVAL.glob("*.cue")),
                               "-d", definition], cwd=ROOT, capture_output=True, text=True)


class MedicoLegalReviewTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.case = export("mockClinicalCase")
        compendium = json.loads((ROOT / "personal/ivac/regulatory/fixtures/compendium.json").read_text())
        cls.citation = compendium["units"]["unitA"]["citation"]

    def draft(self):
        names = ("medico-legal-analyst", "ivac-legal-analyst", "claimant-advocate",
                 "adversarial-reviewer", "evidence-auditor")
        roles = {name: {"role": name, "state": "pending", "issueIDs": [],
                        "rationale": "No independently performed role execution."} for name in names}
        roles["medico-legal-analyst"].update(
            state="complete", issueIDs=["clinical-q"], rationale="Synthetic opposing functional theories.")
        roles["ivac-legal-analyst"].update(
            state="complete", issueIDs=["legal-q"], rationale="Synthetic legal comparison.")
        return {
            "apiVersion": "ivac.medico-legal-review/v1",
            "kind": "MedicoLegalReviewDraft",
            "id": "synthetic-review",
            "usage": "synthetic-test",
            "case": copy.deepcopy(self.case),
            "profile": {"id": "mock-profile"},
            "roles": roles,
            "issues": {
                "clinical-q": {
                    "id": "clinical-q", "axis": {"id": "primary"},
                    "raisedBy": "medico-legal-analyst", "category": "clinical-function",
                    "question": "Hypothetical functional limitation comparison?",
                    "basis": "arguable", "confidence": "plausible",
                    "sources": {
                        "record": {"id": "record", "kind": "clinical-evidence",
                                   "evidence": {"id": "expertReport"}},
                        "finding": {"id": "finding", "kind": "clinical-finding",
                                    "finding": {"id": "primaryFunctional"}}
                    },
                    "favorable": {"theory": "Hypothetical favorable reading.",
                                  "reasoning": "Synthetic limitation.", "sourceIDs": ["finding"],
                                  "limitations": ["Requires independent review."]},
                    "restrictive": {"theory": "Hypothetical restrictive reading.",
                                    "reasoning": "Synthetic counter-reading.", "sourceIDs": ["record"],
                                    "limitations": []},
                    "coverageGaps": ["No actual individual assessment."],
                    "clinicalQualification": "not-determined",
                    "legalQualification": "not-determined", "adjudication": "not-determined"
                },
                "legal-q": {
                    "id": "legal-q", "axis": {"id": "primary"},
                    "raisedBy": "ivac-legal-analyst", "category": "regulatory-interpretation",
                    "question": "Hypothetical ambiguity of an invented schedule?",
                    "basis": "arguable", "confidence": "speculative",
                    "sources": {"law": {"id": "law", "kind": "legal-citation",
                                        "citation": copy.deepcopy(self.citation)}},
                    "favorable": {"theory": "Hypothetical inclusive reading.",
                                  "reasoning": "Requires legal authority.", "sourceIDs": ["law"],
                                  "limitations": ["Synthetic text is not law."]},
                    "restrictive": {"theory": "Hypothetical narrow reading.",
                                    "reasoning": "Counterargument under identical cited text.",
                                    "sourceIDs": ["law"], "limitations": []},
                    "coverageGaps": ["Official version applicability unavailable."],
                    "clinicalQualification": "not-determined",
                    "legalQualification": "not-determined", "adjudication": "not-determined"
                }
            },
            "workProduct": "internal-analytical-candidate",
            "professionalStatus": "not-reviewed",
            "disclosure": "not-authorized",
            "submission": "not-authorized",
            "adjudication": "not-determined"
        }

    def valid(self, value, kind="#MedicoLegalReviewDraft"):
        result = vet(value, kind)
        self.assertEqual(result.returncode, 0, result.stderr)

    def invalid(self, value, kind="#MedicoLegalReviewDraft"):
        result = vet(value, kind)
        self.assertNotEqual(result.returncode, 0, "Unexpected acceptance")

    def test_candidate_and_professional_links(self):
        draft = self.draft()
        self.valid(draft)
        self.valid({
            "draft": draft, "issueID": "clinical-q", "reviewer": {"id": "independentExpert"},
            "finding": {"id": "primaryFunctional"}, "linkKind": "existing-clinical-finding",
            "professionalVerification": "external-required", "adjudication": "not-determined"
        }, "#MedicoLegalClinicalReviewLink")
        self.valid({
            "draft": draft, "issueID": "legal-q", "reviewer": {"id": "counsel"},
            "ground": {"id": "primaryReassessment"}, "linkKind": "existing-counsel-review-ground",
            "professionalVerification": "external-required", "adjudication": "not-determined"
        }, "#MedicoLegalLegalReviewLink")

    def test_candidate_cannot_claim_authority(self):
        for field, value in [
            ("professionalStatus", "professionally-endorsed"),
            ("adjudication", "recognized"),
            ("submission", "submitted"),
            ("disclosure", "approved"),
            ("workProduct", "clinical-opinion"),
            ("credential", "lawyer"),
        ]:
            with self.subTest(field=field):
                draft = self.draft()
                draft[field] = value
                self.invalid(draft)

    def test_referential_integrity_and_role_identity(self):
        mutants = [
            lambda v: v["profile"].update(id="wrong"),
            lambda v: v["issues"]["clinical-q"].update(axis={"id": "nonexistent"}),
            lambda v: v["issues"]["clinical-q"]["sources"]["finding"]["finding"].update(id="absent"),
            lambda v: v["issues"]["clinical-q"]["sources"]["record"]["evidence"].update(id="absent"),
            lambda v: v["issues"]["clinical-q"]["sources"]["finding"].update(id="wrong"),
            lambda v: v["issues"]["clinical-q"]["favorable"].update(sourceIDs=["absent"]),
            lambda v: v["issues"]["clinical-q"].update(id="wrong"),
            lambda v: v["roles"]["ivac-legal-analyst"].update(issueIDs=["clinical-q"]),
            lambda v: v["roles"]["ivac-legal-analyst"].update(role="adversarial-reviewer"),
            lambda v: v["roles"]["evidence-auditor"].update(issueIDs=["nonexistent"]),
            lambda v: v["issues"]["legal-q"]["sources"]["law"].update(evidence={"id": "expertReport"}),
            lambda v: v["issues"]["clinical-q"].update(
                basis="insufficient-evidence", coverageGaps=[]),
        ]
        for mutation in mutants:
            draft = self.draft()
            mutation(draft)
            with self.subTest(mutation=mutation.__code__.co_firstlineno):
                self.invalid(draft)

    def test_professional_link_mismatch_rejected(self):
        draft = self.draft()
        clinical = {
            "draft": draft, "issueID": "clinical-q", "reviewer": {"id": "independentExpert"},
            "finding": {"id": "primaryFunctional"}, "linkKind": "existing-clinical-finding",
            "professionalVerification": "external-required", "adjudication": "not-determined"
        }
        legal = {
            "draft": draft, "issueID": "legal-q", "reviewer": {"id": "counsel"},
            "ground": {"id": "primaryReassessment"}, "linkKind": "existing-counsel-review-ground",
            "professionalVerification": "external-required", "adjudication": "not-determined"
        }
        for original, kind, changes in [
            (clinical, "#MedicoLegalClinicalReviewLink",
             ({"reviewer": {"id": "counsel"}}, {"finding": {"id": "absent"}},
              {"issueID": "unknown"}, {"professionalVerification": "model-verified"},
              {"issueID": "legal-q"})),
            (legal, "#MedicoLegalLegalReviewLink",
             ({"reviewer": {"id": "independentExpert"}}, {"ground": {"id": "absent"}},
              {"issueID": "unknown"}, {"professionalVerification": "model-verified"},
              {"issueID": "clinical-q"}))
        ]:
            for change in changes:
                with self.subTest(kind=kind, change=change):
                    value = copy.deepcopy(original)
                    value.update(change)
                    self.invalid(value, kind)


if __name__ == "__main__":
    unittest.main(verbosity=2)
