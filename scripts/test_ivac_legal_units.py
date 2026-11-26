import copy
from dataclasses import replace
import json
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

    def test_serialized_leaf_uses_same_authorized_navigation(self):
        native = self.bound()
        payload = json.dumps(self.unit.to_record())
        restored = LegalUnit.from_json(self.schedule, payload)
        serialized = restored.in_snapshot(native.snapshot)
        self.assertEqual(restored.to_record(), self.unit.to_record())
        self.assertEqual(serialized.linked_objects(), native.linked_objects())
        self.assertEqual(serialized.evaluate_cross_unit_rules(), native.evaluate_cross_unit_rules())
        self.assertTrue(serialized.linked_objects())

        self.scope = None
        for bound in (native, serialized):
            with self.assertRaises(PermissionError):
                bound.linked_objects()

        altered = self.unit.to_record()
        altered["label"]["exactText"] = "not in the verified schedule"
        with self.assertRaisesRegex(ValueError, "verified schedule"):
            LegalUnit.from_json(self.schedule, json.dumps(altered))

    def test_installed_review_extension_and_historical_replay(self):
        import sys

        from ivac_review_transform import (
            CONTRACT_VERSION, PACKAGE, TRANSFORM, ReviewDeskTransforms, validate_links,
        )
        from runtime.transform_discovery import discover, installed_entry_digest
        from runtime.transform_execution import TransformSpec
        from runtime.typed_transform import TransformRejected, TransformResult

        extra = copy.deepcopy(self.data["relationships"]["rel"])
        extra["id"] = "rel-extra"
        self.data["relationships"]["rel-extra"] = extra
        snapshot = self.bound().snapshot
        with self.assertRaisesRegex(TransformRejected, "snapshot"):
            ReviewDeskTransforms(self.schedule, None, policy_version="pilot-v1")
        desk = ReviewDeskTransforms(self.schedule, snapshot, policy_version="pilot-v1")
        (entry,) = discover(PACKAGE)
        self.assertEqual(entry.name, TRANSFORM)
        self.assertNotIn(entry.module, sys.modules)
        version, identity, _, _ = installed_entry_digest(PACKAGE, TRANSFORM)
        with self.assertRaises(TransformRejected):
            desk.run(self.unit, version=version)
        with self.assertRaises(TransformRejected):
            desk.enable_installed(version=version, approved_digest="not-approved")
        self.assertNotIn(entry.module, sys.modules)
        desk.enable_installed(version=version, approved_digest=identity)
        self.assertIn(entry.module, sys.modules)

        # Synthetic defect: an older approved implementation dropped visible links.
        def omitted_links(view, *, context):
            return TransformResult([], (), context.input_digests)

        desk._executor.enable(TransformSpec(
            TRANSFORM, "0.0.1", "sha256:" + "b" * 64, CONTRACT_VERSION,
            omitted_links, validate_links,
        ))
        historical = desk.run(self.unit, version="0.0.1")
        invocation = historical.receipt["invocationID"]
        self.assertEqual(historical.receipt["outcome"], "empty")
        self.assertEqual(desk.replay(invocation).semantic_output, historical.semantic_output)

        def fabricated_link(view, *, context):
            links = view.links
            links[0]["relationship"]["id"] = "fabricated"
            return TransformResult(links, (), context.input_digests)

        desk._executor.enable(TransformSpec(
            TRANSFORM, "0.0.2", "sha256:" + "d" * 64, CONTRACT_VERSION,
            fabricated_link, validate_links,
        ))
        with self.assertRaisesRegex(TransformRejected, "source-backed"):
            desk.run(self.unit, version="0.0.2")

        native = desk.run(self.unit, version=version)
        wire = desk.run_json(json.dumps(self.unit.to_record()), version=version)
        self.assertEqual(wire.semantic_output, native.semantic_output)
        self.assertNotEqual(wire.receipt["invocationID"], native.receipt["invocationID"])
        self.assertEqual(native.receipt["outputDigest"], wire.receipt["outputDigest"])
        self.assertIn("evidence:source", native.receipt["provenanceRefs"])
        self.assertEqual(json.loads(native.semantic_output)[0]["relationship"]["id"], "rel")

        original = self.scope
        self.scope = replace(original, relationships=frozenset({"rel", "rel-extra"}))
        corrected = desk.replay(invocation, candidate_version=version)
        self.assertEqual(corrected.semantic_output, native.semantic_output)
        self.assertNotEqual(corrected.semantic_output, historical.semantic_output)
        self.assertEqual(corrected.receipt["snapshotRef"], historical.receipt["snapshotRef"])
        self.assertEqual(len(json.loads(desk.run(self.unit, version=version).semantic_output)), 2)

        self.scope = replace(original, evidence=frozenset())
        with self.assertRaises(PermissionError):
            desk.replay(invocation, candidate_version=version)
        desk.disable(version=version)
        with self.assertRaises(TransformRejected):
            desk.run(self.unit, version=version)
        with self.assertRaisesRegex(TransformRejected, "already bound"):
            desk._executor.enable(TransformSpec(
                TRANSFORM, version, "sha256:" + "c" * 64, CONTRACT_VERSION,
                omitted_links, validate_links,
            ))
        with self.assertRaisesRegex(TransformRejected, "incompatible"):
            desk._executor.enable(TransformSpec(
                TRANSFORM, "next", identity, "future-contract",
                omitted_links, validate_links,
            ))

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
