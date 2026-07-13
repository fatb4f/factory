from __future__ import annotations

import os
import platform
import sys
import time
import traceback
from pathlib import Path
from typing import Any

import psutil

from .models import (
    BackendIdentity,
    CueDiagnostic,
    ExecutionState,
    Operation,
    ProcessMetrics,
    ProcessObservation,
    ProbeRequest,
    SemanticFacts,
)
from .protocol import decode_request

CUE_PY_REVISION = "81e6fb15247ed7050e5bd987db032f757e06c8f0"
LIBCUE_REVISION = "96d0572450429fa28d7a2345c04a8c47c85b47e4"
CUE_MODULE_VERSION = "v0.15.3"


def _native_paths() -> tuple[Path, Path]:
    workbook = Path(__file__).resolve().parents[1]
    return workbook / ".deps" / "cue-py", workbook / ".deps" / "libcue"


def _load_cue() -> Any:
    cue_py, _ = _native_paths()
    if cue_py.exists():
        sys.path.insert(0, str(cue_py))
    import cue  # type: ignore[import-not-found]

    return cue


def _diagnostic(phase: str, exc: BaseException, provenance: str = "native") -> CueDiagnostic:
    raw = str(exc)
    return CueDiagnostic(
        phase=phase,  # type: ignore[arg-type]
        raw=raw,
        message=raw,
        provenance=provenance,  # type: ignore[arg-type]
    )


def _value_error(cue: Any, value: Any) -> str | None:
    result = value.error()
    if isinstance(result, cue.Err):
        return str(result.err)
    return None


def _compile(cue: Any, ctx: Any, source: str, filename: str) -> Any:
    return ctx.compile(source, cue.FileName(filename))


def _lookup(value: Any, path: str | None) -> Any:
    return value.lookup(path) if path else value


def execute(request: ProbeRequest) -> ProcessObservation:
    started = time.perf_counter()
    process = psutil.Process()
    rss_before = process.memory_info().rss
    stages: dict[str, str] = {}
    diagnostics: list[CueDiagnostic] = []
    facts = SemanticFacts()
    state = ExecutionState.COMPLETED

    try:
        cue = _load_cue()
        ctx = cue.Context()
        payload = request.payload

        if request.operation is Operation.COMPILE:
            value = _compile(cue, ctx, payload["source"], payload.get("filename", "unit.cue"))
            stages["compile"] = "completed"
            err = _value_error(cue, value)
            if err:
                state = ExecutionState.CUE_REJECTION
                diagnostics.append(_diagnostic("compile", RuntimeError(err)))
                facts = facts.model_copy(update={"semantic_bottom": True})
            else:
                facts = facts.model_copy(update={"semantic_bottom": False})

        elif request.operation is Operation.LOOKUP:
            value = _compile(cue, ctx, payload["source"], payload.get("filename", "unit.cue"))
            stages["compile"] = "completed"
            value = _lookup(value, payload["path"])
            stages["lookup"] = "completed"
            err = _value_error(cue, value)
            if err:
                state = ExecutionState.CUE_REJECTION
                diagnostics.append(_diagnostic("lookup", RuntimeError(err)))
                facts = facts.model_copy(update={"semantic_bottom": True})
            else:
                facts = facts.model_copy(update={"semantic_bottom": False})

        elif request.operation is Operation.UNIFY:
            left = _lookup(
                _compile(
                    cue,
                    ctx,
                    payload["left_source"],
                    payload.get("left_filename", "left.cue"),
                ),
                payload.get("left_path"),
            )
            right = _lookup(
                _compile(
                    cue,
                    ctx,
                    payload["right_source"],
                    payload.get("right_filename", "right.cue"),
                ),
                payload.get("right_path"),
            )
            stages.update({"compile-left": "completed", "compile-right": "completed"})
            unified = left.unify(right)
            stages["unify"] = "completed"
            err = _value_error(cue, unified)
            if err:
                state = ExecutionState.CUE_REJECTION
                diagnostics.append(_diagnostic("unify", RuntimeError(err)))
                facts = facts.model_copy(update={"semantic_bottom": True})
            else:
                facts = facts.model_copy(update={"semantic_bottom": False})

        elif request.operation is Operation.VALIDATE:
            value = _compile(cue, ctx, payload["source"], payload.get("filename", "unit.cue"))
            stages["compile"] = "completed"
            options = payload.get("options", {})
            opts: list[Any] = []
            if options.get("concrete"):
                opts.append(cue.Concrete(True))
            if options.get("disallow_cycles"):
                opts.append(cue.DisallowCycles(True))
            value.validate(*opts)
            stages["validate"] = "completed"
            facts = facts.model_copy(update={"valid": True})

        elif request.operation is Operation.SUBSUME:
            general = _lookup(
                _compile(
                    cue,
                    ctx,
                    payload["general_source"],
                    payload.get("general_filename", "general.cue"),
                ),
                payload.get("general_path"),
            )
            specific = _lookup(
                _compile(
                    cue,
                    ctx,
                    payload["specific_source"],
                    payload.get("specific_filename", "specific.cue"),
                ),
                payload.get("specific_path"),
            )
            stages.update({"compile-general": "completed", "compile-specific": "completed"})
            try:
                specific.check_schema(general)
                facts = facts.model_copy(update={"subsumes": True})
            except cue.Error as exc:
                state = ExecutionState.CUE_REJECTION
                diagnostics.append(_diagnostic("subsume", exc))
                facts = facts.model_copy(update={"subsumes": False})
            stages["subsume"] = "completed"

        elif request.operation is Operation.PROJECT_JSON:
            value = _lookup(
                _compile(cue, ctx, payload["source"], payload.get("filename", "unit.cue")),
                payload.get("path"),
            )
            stages["compile"] = "completed"
            projection = value.to_json()
            stages["project-json"] = "completed"
            facts = facts.model_copy(update={"projection_json": projection})

        else:
            state = ExecutionState.UNSUPPORTED
            diagnostics.append(
                CueDiagnostic(
                    phase="backend",
                    raw=f"unsupported operation: {request.operation}",
                    message=str(request.operation),
                    provenance="operation-boundary",
                )
            )

    except Exception as exc:
        raw = str(exc)
        cue_error = exc.__class__.__module__.startswith("cue")
        state = ExecutionState.CUE_REJECTION if cue_error else ExecutionState.BACKEND_ERROR
        phase = (
            "compile"
            if request.operation in {Operation.COMPILE, Operation.LOOKUP}
            else request.operation.value
        )
        diagnostics.append(
            _diagnostic(phase, exc, "native" if cue_error else "operation-boundary")
        )
        if not cue_error:
            diagnostics.append(
                CueDiagnostic(
                    phase="backend",
                    raw=traceback.format_exc(),
                    message=raw,
                    provenance="operation-boundary",
                )
            )

    rss_after = process.memory_info().rss
    return ProcessObservation(
        request_id=request.request_id,
        execution_state=state,
        backend=BackendIdentity(
            id="cue-py-worker",
            revision=CUE_PY_REVISION,
            engine_revision=LIBCUE_REVISION,
            cue_module_version=CUE_MODULE_VERSION,
            python_version=platform.python_version(),
            platform=platform.platform(),
        ),
        stages=stages,
        facts=facts,
        diagnostics=tuple(diagnostics),
        metrics=ProcessMetrics(
            duration_ms=(time.perf_counter() - started) * 1000,
            rss_before=rss_before,
            rss_after=rss_after,
            pid=os.getpid(),
        ),
    )


def main() -> int:
    line = sys.stdin.buffer.readline()
    try:
        request = decode_request(line)
        observation = execute(request)
    except Exception as exc:
        observation = ProcessObservation(
            request_id="unknown",
            execution_state=ExecutionState.PROTOCOL_ERROR,
            backend=BackendIdentity(
                id="cue-py-worker",
                revision=CUE_PY_REVISION,
                engine_revision=LIBCUE_REVISION,
                cue_module_version=CUE_MODULE_VERSION,
            ),
            diagnostics=(
                CueDiagnostic(
                    phase="transport",
                    raw=str(exc),
                    message=str(exc),
                    provenance="operation-boundary",
                ),
            ),
        )
    sys.stdout.write(observation.model_dump_json(exclude_none=True) + "\n")
    sys.stdout.flush()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
