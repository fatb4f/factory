from __future__ import annotations

import sys
import tempfile
from pathlib import Path
from uuid import uuid4

from pydantic import ValidationError

from .models import ExecutionState, Operation, ProbeRequest
from .orchestrator import run_process


def check_request_validation() -> None:
    try:
        ProbeRequest(request_id="bad", operation=Operation.UNIFY, payload={"left_source": "1"})
    except ValidationError:
        return
    raise AssertionError("missing right_source was accepted")


def check_worker_protocol() -> None:
    request = ProbeRequest(
        request_id=str(uuid4()),
        operation=Operation.COMPILE,
        payload={"source": "x: 1", "filename": "selftest.cue"},
    )
    workbook = Path(__file__).resolve().parents[1]
    observation = run_process(
        request,
        [sys.executable, "-m", "qualification.worker"],
        backend_id="cue-py-worker",
        cwd=workbook,
    )
    # Without bootstrapped native deps the worker must fail as a typed backend
    # error, never crash the orchestrating process or corrupt the protocol.
    if observation.execution_state not in {
        ExecutionState.COMPLETED,
        ExecutionState.BACKEND_ERROR,
        ExecutionState.CUE_REJECTION,
    }:
        raise AssertionError(observation)


def check_timeout_classification() -> None:
    request = ProbeRequest(
        request_id=str(uuid4()),
        operation=Operation.COMPILE,
        payload={"source": "x: 1"},
        limits={"timeout_ms": 50, "max_output_bytes": 1024},
    )
    observation = run_process(
        request,
        [sys.executable, "-c", "import time; time.sleep(2)"],
        backend_id="sleep-test",
    )
    if observation.execution_state is not ExecutionState.TIMEOUT:
        raise AssertionError(observation)


def main() -> int:
    check_request_validation()
    check_worker_protocol()
    check_timeout_classification()
    print("qualification selftest: pass")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
