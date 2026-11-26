"""Review Desk's server-side native/wire bridge and pilot replay session."""

from dataclasses import dataclass
from datetime import datetime, timezone
import json
from pathlib import Path
from uuid import uuid4

from ivac_legal_units import LegalUnit, Schedule, Scope, Snapshot
from ivac_review_history import ReviewHistory, SCOPE_FIELDS, scope_record
from ivac_workbench import cue_validate
from runtime.transform_discovery import load_approved
from runtime.transform_execution import (
    CUE_ROOT, Executor, Prepared, TransformSpec, digest, semantic_json,
)
from runtime.typed_transform import TransformContext, TransformRejected

ROOT = Path(__file__).resolve().parents[1]
TRANSFORM = "review-desk.links"
PACKAGE = "factory-review-desk-navigation"
CONTRACT_VERSION = "1"


@dataclass(frozen=True)
class LegalView:
    links_json: bytes
    source_refs: tuple[str, ...]

    @property
    def links(self):
        return json.loads(self.links_json)


def validate_links(view: LegalView, output: list) -> tuple[str, ...]:
    if type(output) is not list:
        raise TransformRejected("legal relationship output must be a list")
    authorized = {semantic_json(row) for row in view.links}
    returned = [semantic_json(row) for row in output]
    if len(set(returned)) != len(returned) or any(row not in authorized for row in returned):
        raise TransformRejected("output must contain distinct source-backed relationships")
    evidence = {entry["id"] for row in output for entry in row["provenance"]["evidence"]}
    return view.source_refs + tuple("evidence:" + ref for ref in sorted(evidence))


class ReviewDeskTransforms:
    """Create with a trusted caller-bound snapshot and optional private history file."""

    def __init__(self, schedule: Schedule, snapshot: Snapshot, *, policy_version: str,
                 history_path=None, caller_id=None):
        if not isinstance(snapshot, Snapshot):
            raise TransformRejected("a verified snapshot is required")
        self._schedule = schedule
        self._snapshot = snapshot
        self._policy_version = policy_version
        authorities = {
            "contracts/state/transform-invocation.cue": CUE_ROOT,
            "contracts/personal/ivac/workbench/legal_units.cue": ROOT,
        }
        self._executor = Executor[LegalView](
            contract_version=CONTRACT_VERSION,
            contract_digest=digest(semantic_json({
                path: digest((root / path).read_bytes()) for path, root in authorities.items()
            })),
        )
        binding = snapshot._data["snapshot"]
        self._snapshot_digest = digest(semantic_json(snapshot._data))
        self._history = ReviewHistory(history_path, caller_id, binding["caseID"], binding["id"])

    def close(self):
        self._history.close()

    def _authorized(self, prior, current):
        previous = prior.scope
        return (
            prior.receipt["snapshotRef"]["digest"] == self._snapshot_digest
            and prior.receipt["authorizationReceipt"]["scopeDigest"] == digest(semantic_json(scope_record(previous)))
            and (previous.case_id, previous.snapshot_id) == (current.case_id, current.snapshot_id)
            and all(getattr(previous, field) <= getattr(current, field) for field in SCOPE_FIELDS)
        )

    def _historical(self, invocation_id):
        current = self._snapshot._scope()
        if not isinstance(invocation_id, str) or not invocation_id:
            raise PermissionError("historical invocation unavailable")
        rows = self._history.runs(invocation_id)
        if not rows or not self._authorized(rows[0], current):
            raise PermissionError("historical invocation unavailable")
        return rows[0]

    def get_receipt(self, invocation_id):
        return self._historical(invocation_id).receipt

    def list_receipts(self):
        current = self._snapshot._scope()
        return [row.receipt for row in self._history.runs() if self._authorized(row, current)]

    @staticmethod
    def _require_output(receipt):
        if receipt["outcome"] not in ("success", "empty"):
            raise TransformRejected("the historical invocation has no semantic output to compare")

    def report_feedback(self, invocation_id, note):
        self._require_output(self.get_receipt(invocation_id))
        if not isinstance(note, str) or not note.strip() or len(note) > 2000:
            raise ValueError("provide a feedback note of 1 to 2000 characters")
        record = {"feedbackID": str(uuid4()), "invocationID": invocation_id,
                  "note": note, "verification": None}
        cue_validate(record, "#ReviewDeskFeedback")
        self._history.report(record)
        return record

    def get_feedback(self, feedback_id):
        self._snapshot._scope()
        if not isinstance(feedback_id, str) or not feedback_id:
            raise PermissionError("feedback unavailable")
        rows = self._history.feedback(feedback_id)
        if not rows:
            raise PermissionError("feedback unavailable")
        self.get_receipt(rows[0]["invocationID"])
        return rows[0]

    def list_feedback(self):
        visible = {r["invocationID"] for r in self.list_receipts()}
        return [f for f in self._history.feedback() if f["invocationID"] in visible]

    def verify_feedback(self, feedback_id, *, candidate_version):
        if not isinstance(candidate_version, str) or not candidate_version:
            raise ValueError("an enabled candidate version is required")
        record = self.get_feedback(feedback_id)
        original = self.get_receipt(record["invocationID"])
        self._require_output(original)
        replay = self.replay(original["invocationID"]).receipt
        candidate = self.replay(original["invocationID"], candidate_version=candidate_version).receipt
        verification = {
            "replayInvocationID": replay["invocationID"],
            "candidateInvocationID": candidate["invocationID"],
            "candidateVersion": candidate["transformVersion"],
            "originalOutputDigest": original["outputDigest"],
            "candidateOutputDigest": candidate["outputDigest"],
            "changed": candidate["outputDigest"] != original["outputDigest"],
        }
        record["verification"] = verification
        cue_validate(record, "#ReviewDeskFeedback")
        self._history.compare(feedback_id, verification)
        return record

    def enable_installed(self, *, version, approved_digest):
        extension = load_approved(PACKAGE, TRANSFORM, version=version,
                                  approved_digest=approved_digest)
        self._executor.enable(TransformSpec(
            TRANSFORM, version, approved_digest, CONTRACT_VERSION, extension, validate_links,
        ))

    def disable(self, *, version):
        self._executor.disable(TRANSFORM, version)

    def run_json(self, payload, *, version):
        return self.run(LegalUnit.from_json(self._schedule, payload), version=version)

    def run(self, unit, *, version):
        return self._run(unit, version)

    def replay(self, invocation_id, *, candidate_version=None):
        prior = self._historical(invocation_id)
        receipt = prior.receipt
        self._require_output(receipt)
        unit = LegalUnit.from_json(self._schedule, prior.unit_json)
        historical_version = receipt["transformVersion"]
        version = historical_version if candidate_version is None else candidate_version
        return self._run(unit, version, history=prior, historical_receipt=receipt,
                         exact=version == historical_version)

    def _run(self, unit, version, *, history=None, historical_receipt=None, exact=False):
        if not isinstance(unit, LegalUnit) or unit.schedule is not self._schedule:
            raise TransformRejected("unit belongs to another verified schedule")

        def prepare():
            nonlocal selected_scope
            grant = self._snapshot._scope()
            current = Scope(grant.case_id, grant.snapshot_id,
                            *(frozenset(getattr(grant, field)) for field in SCOPE_FIELDS))
            selected_scope = current
            if history is not None:
                if not self._authorized(history, current):
                    raise PermissionError("historical scope is not currently authorized")
                selected_scope = history.scope
            bound = unit.in_snapshot(self._snapshot)
            spec = self._snapshot._data["snapshot"]
            cutoff = spec["recordedAt"]
            elapsed = datetime.fromisoformat(cutoff) - datetime(1970, 1, 1, tzinfo=timezone.utc)
            cutoff_time = (elapsed.days * 86_400 + elapsed.seconds) * 1_000_000 + elapsed.microseconds
            snapshot_digest = digest(semantic_json(self._snapshot._data))
            unit_digest = digest(semantic_json(unit.to_record()))
            refs = tuple(f"{unit.schedule.version}:{piece['id']}" for piece in unit.source_pieces)
            scope_digest = digest(semantic_json(scope_record(selected_scope)))
            input_ref = f"schedule:{unit.schedule.version}:{unit.leaf.number}"
            if historical_receipt is not None and (
                snapshot_digest != historical_receipt["snapshotRef"]["digest"]
                or [unit.schedule.revision_digest] != historical_receipt["snapshotRef"]["sourceRevisionRefs"]
                or [input_ref] != historical_receipt["inputRefs"]
                or scope_digest != historical_receipt["authorizationReceipt"]["scopeDigest"]
                or cutoff != historical_receipt["knowledgeCutoff"]
                or self._executor.contract_digest != historical_receipt["contractDigest"]
            ):
                raise TransformRejected("historical input, snapshot, scope, or contract drift")
            return Prepared(
                LegalView(semantic_json(bound._linked_objects(selected_scope)), refs),
                spec["id"], snapshot_digest, (unit.schedule.revision_digest,),
                "ivac-legal-unit-snapshot/v1", cutoff, scope_digest,
                self._policy_version, (input_ref,),
                TransformContext((snapshot_digest, unit.schedule.revision_digest, unit_digest),
                                 cutoff_time, cutoff_time),
            )

        selected_scope = None
        return self._executor.run(
            TRANSFORM, version, prepare,
            expected_extension_digest=historical_receipt["extensionDigest"] if exact else None,
            expected_output_digest=historical_receipt["outputDigest"] if exact else None,
            record_receipt=lambda receipt: self._history.save(unit, selected_scope, receipt),
        )
