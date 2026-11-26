"""Review Desk's server-side native/wire bridge and pilot replay session."""

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
import json
from pathlib import Path

from ivac_legal_units import LegalUnit, Schedule, Scope, Snapshot
from runtime.transform_discovery import load_approved
from runtime.transform_execution import (
    Executor, Prepared, TransformSpec, digest, semantic_json,
)
from runtime.typed_transform import TransformContext, TransformRejected

ROOT = Path(__file__).resolve().parents[1]
TRANSFORM = "review-desk.links"
PACKAGE = "factory-review-desk-navigation"
CONTRACT_VERSION = "1"
SCOPE_FIELDS = ("relationships", "observations", "evidence", "actors")


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


@dataclass(frozen=True)
class HistoricalRun:
    unit_json: bytes
    scope: Scope
    receipt_json: bytes


class ReviewDeskTransforms:
    """Create per trusted caller context. Replay history is in memory for M1."""

    def __init__(self, schedule: Schedule, snapshot: Snapshot, *, policy_version: str):
        if not isinstance(snapshot, Snapshot):
            raise TransformRejected("a verified snapshot is required")
        self._schedule = schedule
        self._snapshot = snapshot
        self._policy_version = policy_version
        authorities = (
            "contracts/state/transform-invocation.cue",
            "contracts/personal/ivac/workbench/legal_units.cue",
        )
        self._executor = Executor[LegalView](
            contract_version=CONTRACT_VERSION,
            contract_digest=digest(semantic_json({
                path: digest((ROOT / path).read_bytes()) for path in authorities
            })),
        )
        self._history: dict[str, HistoricalRun] = {}

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
        prior = self._history.get(invocation_id)
        if prior is None:
            raise PermissionError("historical invocation unavailable")
        receipt = json.loads(prior.receipt_json)
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
                previous = history.scope
                if ((previous.case_id, previous.snapshot_id) != (current.case_id, current.snapshot_id)
                    or any(not getattr(previous, field) <= getattr(current, field)
                           for field in SCOPE_FIELDS)):
                    raise PermissionError("historical scope is not currently authorized")
                selected_scope = previous
            bound = unit.in_snapshot(self._snapshot)
            spec = self._snapshot._data["snapshot"]
            cutoff = spec["recordedAt"]
            elapsed = datetime.fromisoformat(cutoff) - datetime(1970, 1, 1, tzinfo=timezone.utc)
            cutoff_time = (elapsed.days * 86_400 + elapsed.seconds) * 1_000_000 + elapsed.microseconds
            snapshot_digest = digest(semantic_json(self._snapshot._data))
            unit_digest = digest(semantic_json(unit.to_record()))
            refs = tuple(f"{unit.schedule.version}:{piece['id']}" for piece in unit.source_pieces)
            if historical_receipt is not None and (
                snapshot_digest != historical_receipt["snapshotRef"]["digest"]
                or unit.schedule.revision_digest not in historical_receipt["snapshotRef"]["sourceRevisionRefs"]
                or cutoff != historical_receipt["knowledgeCutoff"]
                or self._executor.contract_digest != historical_receipt["contractDigest"]
            ):
                raise TransformRejected("historical snapshot or contract drift")
            scope_data = asdict(selected_scope)
            for field in SCOPE_FIELDS:
                scope_data[field] = sorted(scope_data[field])
            return Prepared(
                LegalView(semantic_json(bound._linked_objects(selected_scope)), refs),
                spec["id"], snapshot_digest, (unit.schedule.revision_digest,),
                "ivac-legal-unit-snapshot/v1", cutoff, digest(semantic_json(scope_data)),
                self._policy_version, (f"schedule:{unit.schedule.version}:{unit.leaf.number}",),
                TransformContext((snapshot_digest, unit.schedule.revision_digest, unit_digest),
                                 cutoff_time, cutoff_time),
            )

        selected_scope = None
        execution = self._executor.run(
            TRANSFORM, version, prepare,
            expected_extension_digest=historical_receipt["extensionDigest"] if exact else None,
        )
        self._history[execution.receipt["invocationID"]] = HistoricalRun(
            semantic_json(unit.to_record()), selected_scope, execution.receipt_json,
        )
        return execution
