from __future__ import annotations

from uuid import uuid4

from .fixtures import get
from .models import (
    BackendAssertion,
    ExecutionState,
    ExpectedFacts,
    Operation,
    ProbeRequest,
    QualificationLevel,
)


def _id() -> str:
    return str(uuid4())


def _unify(assertion_id: str, fixture_id: str, *, bottom: bool) -> BackendAssertion:
    pattern = get("bounded-int.pattern")
    fixture = get(fixture_id)
    return BackendAssertion(
        id=assertion_id,
        family="S",
        qualification=QualificationLevel.Q1,
        fixture_ids=(pattern.id, fixture.id),
        request=ProbeRequest(
            request_id=_id(),
            operation=Operation.UNIFY,
            payload={
                "left_source": pattern.source(),
                "left_filename": str(pattern.path),
                "left_path": pattern.value_path,
                "right_source": fixture.source(),
                "right_filename": str(fixture.path),
                "right_path": fixture.value_path,
            },
        ),
        expected=ExpectedFacts(
            execution_state=ExecutionState.CUE_REJECTION if bottom else ExecutionState.COMPLETED,
            semantic_bottom=bottom,
        ),
    )


def _subsume(
    assertion_id: str,
    general_id: str,
    specific_id: str,
    *,
    subsumes: bool,
) -> BackendAssertion:
    general = get(general_id)
    specific = get(specific_id)
    return BackendAssertion(
        id=assertion_id,
        family="S",
        qualification=QualificationLevel.Q2,
        fixture_ids=(general.id, specific.id),
        request=ProbeRequest(
            request_id=_id(),
            operation=Operation.SUBSUME,
            payload={
                "general_source": general.source(),
                "general_filename": str(general.path),
                "general_path": general.value_path,
                "specific_source": specific.source(),
                "specific_filename": str(specific.path),
                "specific_path": specific.value_path,
            },
        ),
        expected=ExpectedFacts(
            execution_state=ExecutionState.COMPLETED if subsumes else ExecutionState.CUE_REJECTION,
            subsumes=subsumes,
        ),
    )


def pilot_assertions() -> tuple[BackendAssertion, ...]:
    return (
        _unify("S-BOUND-001", "bounded-int.positive.min", bottom=False),
        _unify("S-BOUND-002", "bounded-int.positive.mid", bottom=False),
        _unify("S-BOUND-003", "bounded-int.positive.max", bottom=False),
        _unify("S-BOUND-004", "bounded-int.negative.below", bottom=True),
        _unify("S-BOUND-005", "bounded-int.negative.above", bottom=True),
        _unify("S-BOUND-006", "bounded-int.negative.wrong-type", bottom=True),
        _subsume(
            "S-DIR-001",
            "bounded-int.directional.general",
            "bounded-int.directional.bounded",
            subsumes=True,
        ),
        _subsume(
            "S-DIR-002",
            "bounded-int.directional.bounded",
            "bounded-int.directional.specific",
            subsumes=True,
        ),
        _subsume(
            "S-DIR-003",
            "bounded-int.directional.specific",
            "bounded-int.directional.bounded",
            subsumes=False,
        ),
    )
