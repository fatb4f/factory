import copy
from dataclasses import replace
import subprocess
import unittest

from ivac_legal_units import Schedule, Scope, Snapshot, sources


class LegalUnitTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.schedule = Schedule.load()
        cls.unit = cls.schedule.unit("4.1")

    def setUp(self):
        self.scope = Scope(
            "invented-case",
            "initial",
            *[frozenset({key}) for key in ("rel", "obs", "source", "subject")]
        )
        self.data = {
            "sourceVersion": self.schedule.version,
            "snapshot": {
                "id": "initial",
                "caseID": "invented-case",
                "stage": "initial",
                "ordinal": 0,
                "recordedAt": "2021-01-01T00:00:00Z",
            },
            "observations": {
                "obs": {
                    "id": "obs",
                    "kind": "clinical-observation",
                    "observationKind": "context",
                    "subject": {"id": "subject"},
                    "concept": "invented-marker",
                    "value": {"kind": "boolean", "value": True},
                    "temporal": {"status": "unknown"},
                    "provenance": {
                        "basis": "patient-reported",
                        "evidence": [{"id": "source"}],
                    },
                }
            },
            "relationships": {
                "rel": {
                    "id": "rel",
                    "kind": "linked-observation",
                    "snapshotID": "initial",
                    "unitNumber": "4.1",
                    "observationID": "obs",
                }
            },
        }
        self.rule = {
            "id": "invented-review",
            "version": "1.0.0",
            "sourceVersion": self.schedule.version,
            "from": "4.1",
            "target": "1",
            "concept": "invented-marker",
            "status": "test-only",
            "basis": {"kind": "synthetic", "citation": "Invented fixture only"},
            "unresolvedConditions": ["Independent review pending"],
        }

    def bound(self):
        return self.unit.in_snapshot(
            Snapshot(
                self.data, lambda *_: self.scope, rules=[self.rule], synthetic=True
            )
        )

    def test_leaf_and_flag(self):
        index = sources.read_json(sources.DATA / "annex-i-2021.schedule-index.json")
        original = next(u for u in index["units"] if u["number"] == "4.1")
        self.assertEqual(original, self.unit.to_record())
        self.assertEqual(
            original["pieceIDs"], [p["id"] for p in self.unit.source_pieces]
        )
        self.assertEqual(self.unit.parent["number"], "4")
        self.assertEqual(self.schedule.applicability, "unresolved")
        bound = self.bound()
        (link,) = bound.linked_objects()
        self.assertEqual(link["object"], self.data["observations"]["obs"])
        self.assertEqual(link["relationship"], self.data["relationships"]["rel"])
        self.assertEqual(link["provenance"], link["object"]["provenance"])
        (flag,) = bound.evaluate_cross_unit_rules()
        self.assertEqual(flag["matches"], [link])
        self.assertEqual(flag["target"]["number"], "1")
        for field in ("version", "basis", "unresolvedConditions"):
            self.assertEqual(flag[field], self.rule[field])

    def test_restricted_and_missing_scopes(self):
        full = self.scope
        bound = self.bound()
        for field in ("observations", "relationships", "evidence", "actors"):
            self.scope = replace(full, **{field: frozenset()})
            self.assertEqual(bound.linked_objects(), [])
            self.assertEqual(bound.evaluate_cross_unit_rules(), [])
        for self.scope in (None, replace(full, snapshot_id="another")):
            with self.assertRaises(PermissionError):
                bound.evaluate_cross_unit_rules()

    def test_invalid_inputs(self):
        with self.assertRaises(ValueError):
            Snapshot(self.data, None, rules=[self.rule])
        self.data["relationships"]["rel"]["snapshotID"] = "another"
        with self.assertRaises(subprocess.CalledProcessError):
            self.bound()

    def test_production_basis_and_incompatible_versions(self):
        candidate = dict(
            self.rule,
            status="candidate",
            basis={"kind": "published", "citation": "invented test reference"},
        )
        with self.assertRaisesRegex(ValueError, "unverified clinical basis"):
            Snapshot(self.data, None, rules=[candidate])
        self.data["sourceVersion"] = "other-enactment"
        with self.assertRaisesRegex(ValueError, "incompatible schedule version"):
            self.unit.in_snapshot(Snapshot(self.data, None))

    def test_invalid_source_and_parent(self):
        index = sources.read_json(sources.DATA / "annex-i-2021.schedule-index.json")
        candidate = sources.read_json(sources.DATA / "annex-i-2021.candidate.json")
        for field, value in [
            ("section", "missing"),
            ("label", dict(self.unit.leaf.label.model_dump(), start=0)),
        ]:
            altered = copy.deepcopy(index)
            next(u for u in altered["units"] if u["number"] == "4.1")[field] = value
            with self.assertRaises(ValueError):
                Schedule(altered, candidate)


if __name__ == "__main__":
    unittest.main(verbosity=2)
