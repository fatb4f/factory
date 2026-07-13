from __future__ import annotations

from enum import StrEnum
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, model_validator

PROTOCOL = "cue-workbook/v0"


class Operation(StrEnum):
    COMPILE = "compile"
    LOOKUP = "lookup"
    UNIFY = "unify"
    VALIDATE = "validate"
    SUBSUME = "subsume"
    PROJECT_JSON = "project-json"


class ExecutionState(StrEnum):
    COMPLETED = "completed"
    CUE_REJECTION = "cue-rejection"
    UNSUPPORTED = "unsupported"
    BACKEND_ERROR = "backend-error"
    BACKEND_CRASH = "backend-crash"
    TIMEOUT = "timeout"
    PROTOCOL_ERROR = "protocol-error"


class QualificationLevel(StrEnum):
    Q0 = "Q0"
    Q1 = "Q1"
    Q2 = "Q2"
    Q3 = "Q3"


class Limits(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    timeout_ms: int = Field(default=2_000, gt=0, le=120_000)
    max_output_bytes: int = Field(default=1_048_576, gt=0, le=16_777_216)


class ProbeRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    protocol: Literal["cue-workbook/v0"] = PROTOCOL
    request_id: str = Field(min_length=1)
    operation: Operation
    payload: dict[str, Any]
    limits: Limits = Limits()

    @model_validator(mode="after")
    def validate_payload(self) -> "ProbeRequest":
        required: dict[Operation, tuple[str, ...]] = {
            Operation.COMPILE: ("source",),
            Operation.LOOKUP: ("source", "path"),
            Operation.UNIFY: ("left_source", "right_source"),
            Operation.VALIDATE: ("source",),
            Operation.SUBSUME: ("general_source", "specific_source"),
            Operation.PROJECT_JSON: ("source",),
        }
        missing = [key for key in required[self.operation] if key not in self.payload]
        if missing:
            raise ValueError(f"missing payload keys for {self.operation}: {missing}")
        return self


class CueDiagnostic(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    phase: Literal[
        "compile",
        "compile-left",
        "compile-right",
        "compile-general",
        "compile-specific",
        "lookup",
        "lookup-left",
        "lookup-right",
        "lookup-general",
        "lookup-specific",
        "unify",
        "subsume",
        "validate",
        "project-json",
        "backend",
        "transport",
    ]
    raw: str
    message: str
    filename: str | None = None
    line: int | None = None
    column: int | None = None
    cue_path: str | None = None
    provenance: Literal["native", "operation-boundary", "parsed"]


class BackendIdentity(BaseModel):
    model_config = ConfigDict(extra="allow", frozen=True)

    id: str
    revision: str | None = None
    engine_revision: str | None = None
    cue_module_version: str | None = None
    python_version: str | None = None
    go_version: str | None = None
    platform: str | None = None


class SemanticFacts(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    semantic_bottom: bool | None = None
    concrete: bool | None = None
    valid: bool | None = None
    subsumes: bool | None = None
    equal: bool | None = None
    projection_json: str | None = None


class ProcessMetrics(BaseModel):
    model_config = ConfigDict(extra="allow", frozen=True)

    duration_ms: float = Field(default=0, ge=0)
    rss_before: int | None = Field(default=None, ge=0)
    rss_after: int | None = Field(default=None, ge=0)
    peak_rss: int | None = Field(default=None, ge=0)
    pid: int | None = Field(default=None, ge=0)
    exit_code: int | None = None
    signal: int | None = None


class ProcessObservation(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    protocol: Literal["cue-workbook/v0"] = PROTOCOL
    request_id: str
    execution_state: ExecutionState
    backend: BackendIdentity
    stages: dict[str, str] = Field(default_factory=dict)
    facts: SemanticFacts = SemanticFacts()
    diagnostics: tuple[CueDiagnostic, ...] = ()
    metrics: ProcessMetrics = ProcessMetrics()
    stderr: str = ""


class ExpectedFacts(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    execution_state: ExecutionState
    semantic_bottom: bool | None = None
    valid: bool | None = None
    subsumes: bool | None = None


class BackendAssertion(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    id: str
    family: Literal["D", "L", "S", "R", "F"]
    qualification: QualificationLevel
    fixture_ids: tuple[str, ...]
    request: ProbeRequest
    expected: ExpectedFacts


class AssertionResult(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    assertion_id: str
    backend: str
    passed: bool
    mismatches: tuple[str, ...] = ()
    observation: ProcessObservation
