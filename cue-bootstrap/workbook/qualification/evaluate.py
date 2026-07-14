from __future__ import annotations

from .models import (
    AssertionResult,
    BackendAssertion,
    ProcessObservation,
    TARGET_CUE_MODULE_VERSION,
    TARGET_CUE_REVISION,
)


def evaluate(assertion: BackendAssertion, observation: ProcessObservation) -> AssertionResult:
    mismatches: list[str] = []
    expected = assertion.expected
    if observation.execution_state != expected.execution_state:
        mismatches.append(
            f"execution_state: expected {expected.execution_state}, got {observation.execution_state}"
        )
    if (
        expected.semantic_bottom is not None
        and observation.facts.semantic_bottom != expected.semantic_bottom
    ):
        mismatches.append(
            "semantic_bottom: "
            f"expected {expected.semantic_bottom}, got {observation.facts.semantic_bottom}"
        )
    if expected.valid is not None and observation.facts.valid != expected.valid:
        mismatches.append(f"valid: expected {expected.valid}, got {observation.facts.valid}")
    if expected.subsumes is not None and observation.facts.subsumes != expected.subsumes:
        mismatches.append(
            f"subsumes: expected {expected.subsumes}, got {observation.facts.subsumes}"
        )
    if observation.backend.engine_revision not in {None, TARGET_CUE_REVISION}:
        mismatches.append(
            "engine_revision: "
            f"expected {TARGET_CUE_REVISION}, got {observation.backend.engine_revision}"
        )
    if observation.backend.cue_module_version not in {None, TARGET_CUE_MODULE_VERSION}:
        mismatches.append(
            "cue_module_version: "
            f"expected {TARGET_CUE_MODULE_VERSION}, got {observation.backend.cue_module_version}"
        )
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

    comparable_facts = (
        "semantic_bottom",
        "valid",
        "subsumes",
        "equal",
        "projection_json",
    )
    for field in comparable_facts:
        left_value = getattr(left.facts, field)
        right_value = getattr(right.facts, field)
        if left_value != right_value:
            mismatches.append(f"facts.{field}")

    if (
        left.backend.engine_revision
        and right.backend.engine_revision
        and left.backend.engine_revision != right.backend.engine_revision
    ):
        mismatches.append("backend.engine_revision")
    if (
        left.backend.cue_module_version
        and right.backend.cue_module_version
        and left.backend.cue_module_version != right.backend.cue_module_version
    ):
        mismatches.append("backend.cue_module_version")
    return tuple(mismatches)
