from __future__ import annotations

import os
import subprocess
import sys
import time
from pathlib import Path

from .models import (
    BackendIdentity,
    CueDiagnostic,
    ExecutionState,
    ProcessMetrics,
    ProcessObservation,
    ProbeRequest,
)
from .protocol import decode_observation, encode_request


def _failure(
    request: ProbeRequest,
    *,
    state: ExecutionState,
    backend_id: str,
    message: str,
    stderr: str = "",
    started: float,
    exit_code: int | None = None,
) -> ProcessObservation:
    signal_number = -exit_code if exit_code is not None and exit_code < 0 else None
    return ProcessObservation(
        request_id=request.request_id,
        execution_state=state,
        backend=BackendIdentity(id=backend_id),
        diagnostics=(
            CueDiagnostic(
                phase="transport",
                raw=message,
                message=message,
                provenance="operation-boundary",
            ),
        ),
        metrics=ProcessMetrics(
            duration_ms=(time.perf_counter() - started) * 1000,
            exit_code=exit_code,
            signal=signal_number,
        ),
        stderr=stderr,
    )


def run_process(
    request: ProbeRequest,
    command: list[str],
    *,
    backend_id: str,
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
) -> ProcessObservation:
    started = time.perf_counter()
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    try:
        completed = subprocess.run(
            command,
            input=encode_request(request),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=cwd,
            env=merged_env,
            timeout=request.limits.timeout_ms / 1000,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        stderr = (exc.stderr or b"").decode("utf-8", errors="replace")
        return _failure(
            request,
            state=ExecutionState.TIMEOUT,
            backend_id=backend_id,
            message="backend exceeded request timeout",
            stderr=stderr,
            started=started,
        )

    stderr = completed.stderr.decode("utf-8", errors="replace")
    if completed.returncode != 0 and not completed.stdout.strip():
        return _failure(
            request,
            state=ExecutionState.BACKEND_CRASH,
            backend_id=backend_id,
            message=f"backend exited without a protocol response: {completed.returncode}",
            stderr=stderr,
            started=started,
            exit_code=completed.returncode,
        )

    try:
        observation = decode_observation(completed.stdout, request=request)
    except Exception as exc:
        return _failure(
            request,
            state=ExecutionState.PROTOCOL_ERROR,
            backend_id=backend_id,
            message=str(exc),
            stderr=stderr,
            started=started,
            exit_code=completed.returncode,
        )

    metrics = observation.metrics.model_copy(
        update={
            "duration_ms": (time.perf_counter() - started) * 1000,
            "exit_code": completed.returncode,
            "signal": -completed.returncode if completed.returncode < 0 else None,
        }
    )
    return observation.model_copy(update={"metrics": metrics, "stderr": stderr})


def run_cue_py(request: ProbeRequest) -> ProcessObservation:
    workbook = Path(__file__).resolve().parents[1]
    cue_py = workbook / ".deps" / "cue-py"
    libcue = workbook / ".deps" / "libcue"
    env: dict[str, str] = {}
    if cue_py.exists():
        env["PYTHONPATH"] = (
            str(cue_py) + os.pathsep + os.environ.get("PYTHONPATH", "")
        )
    if libcue.exists():
        if sys.platform == "darwin":
            env["DYLD_LIBRARY_PATH"] = (
                str(libcue) + os.pathsep + os.environ.get("DYLD_LIBRARY_PATH", "")
            )
        elif sys.platform == "win32":
            env["PATH"] = str(libcue) + os.pathsep + os.environ.get("PATH", "")
        else:
            env["LD_LIBRARY_PATH"] = (
                str(libcue) + os.pathsep + os.environ.get("LD_LIBRARY_PATH", "")
            )
    return run_process(
        request,
        [sys.executable, "-m", "qualification.worker"],
        backend_id="cue-py-worker",
        cwd=workbook,
        env=env,
    )


def run_go(request: ProbeRequest, binary: Path | None = None) -> ProcessObservation:
    root = Path(__file__).resolve().parents[2]
    binary = binary or root / "runner" / "bin" / "cueprobe"
    if not binary.exists():
        return _failure(
            request,
            state=ExecutionState.BACKEND_ERROR,
            backend_id="go-runner",
            message=f"Go runner not built: {binary}",
            started=time.perf_counter(),
        )
    return run_process(request, [str(binary)], backend_id="go-runner", cwd=root)
