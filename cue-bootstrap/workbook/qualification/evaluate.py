from __future__ import annotations

from .models import AssertionResult, BackendAssertion, ProcessObservation


def evaluate(assertion: BackendAssertion, observation: ProcessObservation) -> AssertionResult:
    mismatches: list[str] = []
    expected = assertion.expected
    if observation.execution_state != expected.execution_state:
        mismatches.append(
            f"execution_state: expected {expected.execution_state}, got {observation.execution_state}"
        )
    if expected.semantic_bottom is not None and observation.facts.semantic_bottom != expected.semantic_bottom:
        mismatches.append(
            f"semantic_bottom: expected {expected.semantic_bottom}, got {observation.facts.semantic_bottom}"
        )
    if expected.valid is not None and observation.facts.valid != expected.valid:
        mismatches.append(f"valid: expected {expected.valid}, got {observation.facts.valid}")
    if expected.subsumes is not None and observation.facts.subsumes != expected.subsumes:
        mismatches.append(f"subsumes: expected {expected.subsumes}, got {observation.facts.subsumes}")
    return AssertionResult(
        assertion_id=assertion.id,
        backend=observation.backend.id,
        passed=not mismatches,
        mismatches=tuple(mismatches),
        observation=observation,
    )


def parity(left: ProcessObservation, right: ProcessObservation) -> tuple[str, ...]:
    mismatches: list[str] = []
    if left.execution_state != right.execution_state:
        mismatches.append("execution_state")
    if left.facts != right.facts:
        mismatches.append("facts")
    return tuple(mismatches)
