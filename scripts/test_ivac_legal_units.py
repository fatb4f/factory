import copy
from dataclasses import replace
import json
import os
from pathlib import Path
import tempfile
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

    def test_persisted_feedback_reauthorizes_after_restart(self):
        from ivac_review_transform import CONTRACT_VERSION, TRANSFORM, ReviewDeskTransforms, validate_links
        from runtime.transform_execution import TransformSpec
        from runtime.typed_transform import TransformResult

        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        db = Path(temporary.name) / "history.sqlite"
        original_scope = self.scope
        snapshot = self.bound().snapshot

        def open_desk(caller, bound_snapshot=snapshot):
            desk = ReviewDeskTransforms(self.schedule, bound_snapshot, policy_version="review-policy",
                                        history_path=db, caller_id=caller)
            self.addCleanup(desk.close)
            return desk

        def omit(view, *, context):
            return TransformResult([], (), context.input_digests)

        def include(view, *, context):
            return TransformResult(view.links, (), context.input_digests)

        old = TransformSpec(TRANSFORM, "old", "sha256:" + "1" * 64, CONTRACT_VERSION, omit, validate_links)
        new = TransformSpec(TRANSFORM, "new", "sha256:" + "2" * 64, CONTRACT_VERSION, include, validate_links)
        with self.assertRaisesRegex(ValueError, "caller ID"):
            open_desk(None)
        if os.name == "posix":
            db.touch()
            db.chmod(0o644)
            with self.assertRaisesRegex(PermissionError, "owner"):
                open_desk("invented-reviewer")
            db.unlink()
        first = open_desk("invented-reviewer")
        first._executor.enable(old)
        original = first.run(self.unit, version="old").receipt
        invocation = original["invocationID"]
        feedback = first.report_feedback(invocation, "Invented relationship missing.")
        first.close()
        if os.name == "posix":
            self.assertEqual(db.stat().st_mode & 0o077, 0)

        restored = open_desk("invented-reviewer")
        restored._executor.enable(old)
        restored._executor.enable(new)
        self.assertEqual(restored.get_receipt(invocation), original)
        self.assertEqual(restored.list_feedback(), [feedback])
        checked = restored.verify_feedback(feedback["feedbackID"], candidate_version="new")
        comparison = checked["verification"]
        self.assertTrue(comparison["changed"])
        replay = restored.get_receipt(comparison["replayInvocationID"])
        candidate = restored.get_receipt(comparison["candidateInvocationID"])
        self.assertEqual(replay["outputDigest"], original["outputDigest"])
        self.assertEqual(candidate["outputDigest"], comparison["candidateOutputDigest"])
        self.assertEqual(replay["authorizationReceipt"], candidate["authorizationReceipt"])
        self.assertEqual(candidate["snapshotRef"], original["snapshotRef"])
        self.assertEqual(restored.list_receipts(), [candidate, replay, original])
        self.assertEqual(open_desk("invented-reviewer").get_feedback(feedback["feedbackID"]), checked)

        def assert_unavailable(desk):
            self.assertEqual(desk.list_receipts(), [])
            self.assertEqual(desk.list_feedback(), [])
            with self.assertRaises(PermissionError):
                desk.get_receipt(invocation)
            with self.assertRaises(PermissionError):
                desk.replay(invocation, candidate_version="new")
            with self.assertRaises(PermissionError):
                desk.report_feedback(invocation, "Unauthorized")
            with self.assertRaises(PermissionError):
                desk.get_feedback(feedback["feedbackID"])
            with self.assertRaises(PermissionError):
                desk.verify_feedback(feedback["feedbackID"], candidate_version="new")

        assert_unavailable(open_desk("another-reviewer"))
        self.scope = replace(original_scope, evidence=frozenset())
        assert_unavailable(restored)
        self.scope = original_scope
        self.data["observations"]["obs"]["value"]["value"] = False
        assert_unavailable(open_desk("invented-reviewer", self.bound().snapshot))
        self.data["snapshot"]["id"] = "other-snapshot"
        self.data["relationships"]["rel"]["snapshotID"] = "other-snapshot"
        self.scope = replace(original_scope, snapshot_id="other-snapshot")
        assert_unavailable(open_desk("invented-reviewer", self.bound().snapshot))

    def test_unreproducible_output_cannot_verify_feedback(self):
        from ivac_review_transform import CONTRACT_VERSION, TRANSFORM, ReviewDeskTransforms, validate_links
        from runtime.transform_execution import TransformSpec
        from runtime.typed_transform import TransformRejected, TransformResult

        desk = ReviewDeskTransforms(self.schedule, self.bound().snapshot, policy_version="review-policy")
        self.addCleanup(desk.close)
        omit = True

        def unstable(view, *, context):
            return TransformResult([] if omit else view.links, (), context.input_digests)

        desk._executor.enable(TransformSpec(TRANSFORM, "test", "sha256:" + "1" * 64,
                                           CONTRACT_VERSION, unstable, validate_links))
        original = desk.run(self.unit, version="test").receipt
        feedback = desk.report_feedback(original["invocationID"], "Recheck the missing link")
        omit = False
        with self.assertRaisesRegex(TransformRejected, "semantic output"):
            desk.verify_feedback(feedback["feedbackID"], candidate_version="test")
        self.assertEqual(desk.get_feedback(feedback["feedbackID"]), feedback)
        failed, previous = desk.list_receipts()
        self.assertEqual(previous, original)
        self.assertEqual(failed["outcome"], "failed")
        self.assertNotIn("outputDigest", failed)
        self.assertNotIn("provenanceRefs", failed)
        with self.assertRaisesRegex(TransformRejected, "no semantic output"):
            desk.replay(failed["invocationID"])
        with self.assertRaisesRegex(TransformRejected, "no semantic output"):
            desk.report_feedback(failed["invocationID"], "Compare this failed output")

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
