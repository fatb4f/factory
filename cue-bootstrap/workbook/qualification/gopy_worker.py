from __future__ import annotations

import json
import os
import platform
import sys
import time
import traceback
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
    SourcePosition,
    TARGET_CUE_MODULE_VERSION,
    TARGET_CUE_REVISION,
)
from .native import NativeBindingUnavailable, binding_identity, build_manifest, import_bindings
from .protocol import decode_request

GOPY_REVISION = "72557f647208599c726c14dc9721a6c850d2e6d9"


def _backend_identity(raw: dict[str, Any] | None = None) -> BackendIdentity:
    raw = raw or {}
    manifest = build_manifest() or {}
    extension = manifest.get("gopy_extension", {})
    return BackendIdentity(
        id="gopy-worker",
        mode="worker",
        binding_revision=GOPY_REVISION,
        engine_revision=raw.get("cue_revision", TARGET_CUE_REVISION),
        cue_module_version=raw.get("cue_module_version", TARGET_CUE_MODULE_VERSION),
        observed_cue_module_version=raw.get("observed_cue_module_version"),
        python_version=platform.python_version(),
        python_abi=getattr(sys.implementation, "cache_tag", None),
        go_version=raw.get("go_version"),
        platform=platform.platform(),
        extension_digest=extension.get("combined_digest"),
    )


def _diagnostics(
    phase: str,
    items: list[dict[str, Any]] | None,
    *,
    fallback: str = "",
    provenance: str = "native",
) -> tuple[CueDiagnostic, ...]:
    items = items or []
    if not items and fallback:
        items = [{"message": fallback, "raw": fallback, "path": "", "positions": []}]
    result: list[CueDiagnostic] = []
    for item in items:
        positions = tuple(
            SourcePosition(
                filename=position.get("filename") or None,
                offset=position.get("offset"),
                line=position.get("line") or None,
                column=position.get("column") or None,
            )
            for position in item.get("positions", [])
        )
        primary = positions[0] if positions else None
        result.append(
            CueDiagnostic(
                phase=phase,  # type: ignore[arg-type]
                raw=item.get("raw") or item.get("message") or fallback,
                message=item.get("message") or fallback,
                filename=primary.filename if primary else None,
                line=primary.line if primary else None,
                column=primary.column if primary else None,
                cue_path=item.get("path") or None,
                positions=positions,
                provenance=provenance,  # type: ignore[arg-type]
            )
        )
    return tuple(result)


def _value_diagnostics(value: Any, phase: str) -> tuple[CueDiagnostic, ...]:
    return _diagnostics(phase, json.loads(value.DiagnosticsJSON()), fallback=value.Error())


def execute(request: ProbeRequest) -> ProcessObservation:
    started = time.perf_counter()
    process = psutil.Process()
    rss_before = process.memory_info().rss
    stages: dict[str, str] = {}
    diagnostics: list[CueDiagnostic] = []
    facts = SemanticFacts()
    state = ExecutionState.COMPLETED
    identity_raw: dict[str, Any] = {}

    try:
        bindings = import_bindings()
        identity_raw = binding_identity(bindings)
        if identity_raw.get("cue_revision") != TARGET_CUE_REVISION:
            raise RuntimeError(
                "binding engine revision mismatch: "
                f"{identity_raw.get('cue_revision')} != {TARGET_CUE_REVISION}"
            )
        if identity_raw.get("cue_module_version") != TARGET_CUE_MODULE_VERSION:
            raise RuntimeError(
                "binding module target mismatch: "
                f"{identity_raw.get('cue_module_version')} != {TARGET_CUE_MODULE_VERSION}"
            )
        if identity_raw.get("observed_cue_module_version") != TARGET_CUE_MODULE_VERSION:
            raise RuntimeError(
                "compiled CUE module mismatch: "
                f"{identity_raw.get('observed_cue_module_version')} != {TARGET_CUE_MODULE_VERSION}"
            )

        ctx = bindings.NewContext()
        payload = request.payload

        def compile_value(source_key: str, filename_key: str, phase: str) -> Any:
            nonlocal state, facts
            value = ctx.CompileString(
                payload[source_key],
                payload.get(filename_key, f"{source_key}.cue"),
            )
            stages[phase] = "completed"
            if value.IsBottom():
                state = ExecutionState.CUE_REJECTION
                diagnostics.extend(_value_diagnostics(value, phase))
                facts = facts.model_copy(update={"semantic_bottom": True})
            return value

        def lookup_value(value: Any, path_key: str, phase: str) -> Any:
            nonlocal state, facts
            path = payload.get(path_key)
            if not path:
                return value
            found = value.Lookup(path)
            stages[phase] = "completed"
            if found.IsBottom():
                state = ExecutionState.CUE_REJECTION
                diagnostics.extend(_value_diagnostics(found, phase))
                facts = facts.model_copy(update={"semantic_bottom": True})
            return found

        if request.operation is Operation.COMPILE:
            value = compile_value("source", "filename", "compile")
            if state is ExecutionState.COMPLETED:
                facts = facts.model_copy(
                    update={
                        "semantic_bottom": False,
                        "exists": bool(value.Exists()),
                        "kind": value.Kind(),
                        "incomplete_kind": value.IncompleteKind(),
                    }
                )

        elif request.operation is Operation.LOOKUP:
            value = compile_value("source", "filename", "compile")
            if state is ExecutionState.COMPLETED:
                value = lookup_value(value, "path", "lookup")
            if state is ExecutionState.COMPLETED:
                facts = facts.model_copy(
                    update={
                        "semantic_bottom": False,
                        "exists": bool(value.Exists()),
                        "kind": value.Kind(),
                        "incomplete_kind": value.IncompleteKind(),
                    }
                )

        elif request.operation is Operation.UNIFY:
            left = compile_value("left_source", "left_filename", "compile-left")
            if state is ExecutionState.COMPLETED:
                left = lookup_value(left, "left_path", "lookup-left")
            if state is ExecutionState.COMPLETED:
                right = compile_value("right_source", "right_filename", "compile-right")
            else:
                right = None
            if state is ExecutionState.COMPLETED:
                right = lookup_value(right, "right_path", "lookup-right")
            if state is ExecutionState.COMPLETED:
                unified = left.Unify(right)
                stages["unify"] = "completed"
                if unified.IsBottom():
                    state = ExecutionState.CUE_REJECTION
                    diagnostics.extend(_value_diagnostics(unified, "unify"))
                    facts = facts.model_copy(update={"semantic_bottom": True})
                else:
                    facts = facts.model_copy(
                        update={
                            "semantic_bottom": False,
                            "exists": bool(unified.Exists()),
                            "kind": unified.Kind(),
                            "incomplete_kind": unified.IncompleteKind(),
                        }
                    )

        elif request.operation is Operation.VALIDATE:
            value = compile_value("source", "filename", "compile")
            if state is ExecutionState.COMPLETED:
                options = payload.get("options", {})
                result = json.loads(
                    value.CheckValidate(
                        bool(options.get("concrete")),
                        bool(options.get("disallow_cycles")),
                    ).JSON()
                )
                stages["validate"] = "completed"
                if result["ok"]:
                    facts = facts.model_copy(update={"valid": True})
                else:
                    state = ExecutionState.CUE_REJECTION
                    facts = facts.model_copy(update={"valid": False})
                    diagnostics.extend(
                        _diagnostics(
                            "validate",
                            result.get("diagnostics"),
                            fallback=result.get("message", ""),
                        )
                    )

        elif request.operation is Operation.SUBSUME:
            general = compile_value("general_source", "general_filename", "compile-general")
            if state is ExecutionState.COMPLETED:
                general = lookup_value(general, "general_path", "lookup-general")
            if state is ExecutionState.COMPLETED:
                specific = compile_value("specific_source", "specific_filename", "compile-specific")
            else:
                specific = None
            if state is ExecutionState.COMPLETED:
                specific = lookup_value(specific, "specific_path", "lookup-specific")
            if state is ExecutionState.COMPLETED:
                result = json.loads(general.CheckSubsume(specific).JSON())
                stages["subsume"] = "completed"
                if result["ok"]:
                    facts = facts.model_copy(update={"subsumes": True})
                else:
                    state = ExecutionState.CUE_REJECTION
                    facts = facts.model_copy(update={"subsumes": False})
                    diagnostics.extend(
                        _diagnostics(
                            "subsume",
                            result.get("diagnostics"),
                            fallback=result.get("message", ""),
                        )
                    )

        elif request.operation is Operation.PROJECT_JSON:
            value = compile_value("source", "filename", "compile")
            if state is ExecutionState.COMPLETED:
                value = lookup_value(value, "path", "lookup")
            if state is ExecutionState.COMPLETED:
                result = json.loads(value.ProjectJSON().JSON())
                stages["project-json"] = "completed"
                if result["ok"]:
                    facts = facts.model_copy(update={"projection_json": result["json_value"]})
                else:
                    state = ExecutionState.CUE_REJECTION
                    diagnostics.extend(
                        _diagnostics(
                            "project-json",
                            result.get("diagnostics"),
                            fallback=result.get("message", ""),
                        )
                    )
        else:
            state = ExecutionState.UNSUPPORTED
            diagnostics.extend(
                _diagnostics(
                    "backend",
                    [],
                    fallback=f"unsupported operation: {request.operation}",
                    provenance="operation-boundary",
                )
            )

    except NativeBindingUnavailable as exc:
        state = ExecutionState.BACKEND_ERROR
        diagnostics.extend(
            _diagnostics(
                "backend", [], fallback=str(exc), provenance="operation-boundary"
            )
        )
    except Exception as exc:
        state = ExecutionState.BACKEND_ERROR
        diagnostics.extend(
            _diagnostics(
                "backend", [], fallback=str(exc), provenance="operation-boundary"
            )
        )
        diagnostics.append(
            CueDiagnostic(
                phase="backend",
                raw=traceback.format_exc(),
                message=str(exc),
                provenance="operation-boundary",
            )
        )

    rss_after = process.memory_info().rss
    return ProcessObservation(
        request_id=request.request_id,
        execution_state=state,
        backend=_backend_identity(identity_raw),
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
            backend=_backend_identity(),
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
