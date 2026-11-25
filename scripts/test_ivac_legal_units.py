import copy
from dataclasses import replace
import subprocess
import unittest

from ivac_legal_units import LegalUnit, Schedule, Scope, Snapshot, sources


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
            "expectedValue": {"kind": "boolean", "value": True},
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

    def test_leaf_view_is_detached(self):
        original = self.unit.to_record()
        leaf = self.unit.leaf
        leaf.number = "1"
        leaf.label.exactText = "altered"
        leaf.pieceIDs.clear()
        self.assertEqual(self.unit.to_record(), original)
        self.assertEqual(self.unit.parent["number"], "4")
        with self.assertRaisesRegex(ValueError, "verified schedule"):
            LegalUnit(self.schedule, leaf)

    def test_values_and_conflicts(self):
        self.data["observations"]["obs"]["value"]["value"] = False
        self.assertEqual(self.bound().evaluate_cross_unit_rules(), [])
        self.data["observations"]["obs"]["value"] = {"kind": "categorical", "value": "true"}
        self.assertEqual(self.bound().evaluate_cross_unit_rules(), [])
        self.data["observations"]["other"] = copy.deepcopy(self.data["observations"]["obs"])
        self.data["observations"]["other"]["id"] = "other"
        self.data["observations"]["other"]["value"] = {"kind": "boolean", "value": True}
        self.data["relationships"]["other-rel"] = dict(self.data["relationships"]["rel"], id="other-rel", observationID="other")
        self.scope = replace(self.scope, relationships=frozenset({"rel", "other-rel"}), observations=frozenset({"obs", "other"}))
        (flag,) = self.bound().evaluate_cross_unit_rules()
        self.assertEqual([m["object"]["id"] for m in flag["matches"]], ["other"])
        self.assertIn("different values", flag["unresolvedConditions"][-1])
        self.scope = replace(self.scope, observations=frozenset({"other"}))
        (flag,) = self.bound().evaluate_cross_unit_rules()
        self.assertEqual(flag["unresolvedConditions"], self.rule["unresolvedConditions"])

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
        with self.assertRaisesRegex(ValueError, "candidate rules require a synthetic snapshot"):
            Snapshot(self.data, None, rules=[candidate], verify_basis=lambda _: True)
        self.data["sourceVersion"] = "other-enactment"
        with self.assertRaisesRegex(ValueError, "incompatible schedule version"):
            self.unit.in_snapshot(Snapshot(self.data, None))

    def test_reviewed_rule_requires_verified_basis_and_both_reviews(self):
        reviewed = dict(
            self.rule,
            status="reviewed",
            basis={"kind": "published", "citation": "invented source",
                   "url": "https://example.invalid/study", "digest": "sha256:" + "a" * 64},
            reviews={"clinical": {"id": "clinical-review", "digest": "sha256:" + "b" * 64},
                     "legal": {"id": "legal-review", "digest": "sha256:" + "c" * 64}},
        )
        with self.assertRaisesRegex(ValueError, "unverified clinical basis"):
            Snapshot(self.data, lambda *_: self.scope, rules=[reviewed])
        with self.assertRaisesRegex(ValueError, "unverified professional reviews"):
            Snapshot(self.data, lambda *_: self.scope, rules=[reviewed], verify_basis=lambda _: True)
        with self.assertRaisesRegex(ValueError, "unverified professional reviews"):
            Snapshot(self.data, lambda *_: self.scope, rules=[reviewed], verify_basis=lambda _: True,
                     verify_reviews=lambda _: False)
        with self.assertRaises(subprocess.CalledProcessError):
            missing_legal = copy.deepcopy(reviewed)
            del missing_legal["reviews"]["legal"]
            Snapshot(self.data, lambda *_: self.scope, rules=[missing_legal],
                     verify_basis=lambda _: True, verify_reviews=lambda _: True)
        with self.assertRaises(subprocess.CalledProcessError):
            same_receipt = copy.deepcopy(reviewed)
            same_receipt["reviews"]["legal"]["id"] = same_receipt["reviews"]["clinical"]["id"]
            Snapshot(self.data, lambda *_: self.scope, rules=[same_receipt],
                     verify_basis=lambda _: True, verify_reviews=lambda _: True)
        snapshot = Snapshot(self.data, lambda *_: self.scope, rules=[reviewed],
                            verify_basis=lambda _: True, verify_reviews=lambda _: True)
        (flag,) = self.unit.in_snapshot(snapshot).evaluate_cross_unit_rules()
        self.assertEqual(flag["basis"], reviewed["basis"])
        self.assertEqual(flag["status"], "reviewed")
        self.scope = replace(self.scope, evidence=frozenset())
        self.assertEqual(self.unit.in_snapshot(snapshot).evaluate_cross_unit_rules(), [])

    def test_all_conditions_and_rule_version_identity(self):
        self.data["observations"]["second"] = copy.deepcopy(self.data["observations"]["obs"])
        self.data["observations"]["second"].update(id="second", concept="second-marker")
        self.data["relationships"]["rel2"] = dict(self.data["relationships"]["rel"],
                                                  id="rel2", observationID="second")
        self.scope = replace(self.scope, relationships=frozenset({"rel", "rel2"}),
                             observations=frozenset({"obs", "second"}))
        self.rule["conditions"] = [{"concept": "second-marker", "expectedValue": {"kind": "boolean", "value": True}}]
        other = dict(self.rule, version="2.0.0")
        snapshot = Snapshot(self.data, lambda *_: self.scope, rules=[self.rule, other], synthetic=True)
        flags = self.unit.in_snapshot(snapshot).evaluate_cross_unit_rules()
        self.assertEqual([flag["version"] for flag in flags], ["1.0.0", "2.0.0"])
        self.assertEqual({m["object"]["id"] for m in flags[0]["matches"]}, {"obs", "second"})
        self.scope = replace(self.scope, observations=frozenset({"obs"}))
        self.assertEqual(self.unit.in_snapshot(snapshot).evaluate_cross_unit_rules(), [])
        with self.assertRaisesRegex(ValueError, "duplicate rule"):
            Snapshot(self.data, lambda *_: self.scope, rules=[self.rule, self.rule], synthetic=True)

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
