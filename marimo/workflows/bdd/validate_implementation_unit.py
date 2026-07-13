"""Project-managed Marimo boundary for BDD implementation-unit observations.

This workbook executes only Python-owned nodes selected by the validated command
projection.  It records observations; CUE remains the sole admission authority.
"""

from __future__ import annotations

import argparse
import contextlib
import hashlib
import json
import os
import platform
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable, Sequence

import marimo


app = marimo.App()

RUNNER_PROTOCOL_VERSION = "factory.bdd-python-runner.v1"
OBSERVATION_SCHEMA = "factory.bdd-raw-command-observation.v1"
ARTIFACT_SCHEMA = "factory.bdd-python-artifact.v1"
COMMANDS_PATH = Path("marimo/workflows/bdd/.kb/commands.cue")
WORKBOOK_PATH = Path("marimo/workflows/bdd/validate_implementation_unit.py")
_SAFE_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
_CLAIMANT_KEYS = frozenset(
    {"success", "valid", "complete", "admitted", "admission", "canonicalReady"}
)


class ProtocolError(RuntimeError):
    """A closed execution-protocol boundary rejected its input."""


@dataclass(frozen=True)
class CommandNode:
    workflow_node: str
    consumes: tuple[str, ...]
    produces: tuple[str, ...]


@dataclass(frozen=True)
class Coordinates:
    provider_root: Path
    repo_root: Path
    evidence_root: Path
    execution_id: str


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _digest_bytes(value: bytes) -> str:
    return f"sha256:{hashlib.sha256(value).hexdigest()}"


def _digest_file(path: Path) -> str:
    if not path.is_file():
        raise ProtocolError(f"required regular file is absent: {path}")
    return _digest_bytes(path.read_bytes())


def _absolute_existing_directory(value: str, label: str) -> Path:
    path = Path(value)
    if not path.is_absolute():
        raise ProtocolError(f"{label} must be absolute")
    if not path.is_dir():
        raise ProtocolError(f"{label} must already exist as a directory")
    resolved = path.resolve(strict=True)
    if resolved != path:
        raise ProtocolError(f"{label} must be canonical and must not be a symlink")
    return path


def _validate_coordinates(namespace: argparse.Namespace) -> Coordinates:
    if not _SAFE_ID.fullmatch(namespace.execution_id):
        raise ProtocolError("execution ID contains unsupported characters")

    provider_root = _absolute_existing_directory(namespace.provider_root, "provider root")
    repo_root = _absolute_existing_directory(namespace.repo_root, "repository root")
    evidence_root = _absolute_existing_directory(namespace.evidence_root, "evidence root")

    runtime_base = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "factory-bdd"
    expected_evidence_root = runtime_base / namespace.execution_id
    if evidence_root != expected_evidence_root:
        raise ProtocolError(
            "evidence root must be the preallocated runtime coordinate for the execution ID"
        )

    expected_workbook = provider_root / WORKBOOK_PATH
    if not expected_workbook.is_file() or not expected_workbook.samefile(Path(__file__)):
        raise ProtocolError("provider root does not own the executing workbook")

    return Coordinates(
        provider_root=provider_root,
        repo_root=repo_root,
        evidence_root=evidence_root,
        execution_id=namespace.execution_id,
    )


def _balanced_blocks(source: str, marker: str) -> list[str]:
    blocks: list[str] = []
    cursor = 0
    while True:
        start = source.find(marker, cursor)
        if start < 0:
            return blocks
        brace = source.find("{", start + len(marker))
        if brace < 0:
            raise ProtocolError("command projection contains an unterminated step")
        depth = 0
        in_string = False
        escaped = False
        for index in range(brace, len(source)):
            char = source[index]
            if in_string:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    in_string = False
                continue
            if char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    blocks.append(source[brace + 1 : index])
                    cursor = index + 1
                    break
        else:
            raise ProtocolError("command projection contains an unterminated step")


def _cue_string(block: str, field: str) -> str:
    match = re.search(rf"(?m)^\s*{re.escape(field)}:\s*(\"(?:[^\"\\]|\\.)*\")", block)
    if match is None:
        raise ProtocolError(f"command step omits {field}")
    value = json.loads(match.group(1))
    if not value:
        raise ProtocolError(f"command step has an empty {field}")
    return value


def _cue_string_list(block: str, field: str) -> tuple[str, ...]:
    match = re.search(rf"(?s)\b{re.escape(field)}:\s*\[(.*?)\]", block)
    if match is None:
        raise ProtocolError(f"command step omits {field}")
    return tuple(json.loads(token) for token in re.findall(r'\"(?:[^\"\\]|\\.)*\"', match.group(1)))


def _load_python_nodes(commands_path: Path) -> tuple[dict[str, CommandNode], str]:
    raw = commands_path.read_bytes()
    source = raw.decode("utf-8")
    nodes: dict[str, CommandNode] = {}
    for block in _balanced_blocks(source, "#CommandStep &"):
        if _cue_string(block, "boundary") != "marimo-python":
            continue
        node = CommandNode(
            workflow_node=_cue_string(block, "workflowNode"),
            consumes=_cue_string_list(block, "consumes"),
            produces=_cue_string_list(block, "produces"),
        )
        if node.workflow_node in nodes:
            raise ProtocolError(f"duplicate Python command node: {node.workflow_node}")
        nodes[node.workflow_node] = node
    if not nodes:
        raise ProtocolError("command projection declares no Python-owned nodes")
    return nodes, _digest_bytes(raw)


def _artifact_path(coordinates: Coordinates, artifact_id: str) -> Path:
    if not _SAFE_ID.fullmatch(artifact_id):
        raise ProtocolError(f"unsupported artifact identity: {artifact_id}")
    return coordinates.evidence_root / f"{artifact_id}.json"


def _artifact_identity(path: Path, artifact_id: str) -> dict[str, str]:
    return {"id": artifact_id, "digest": _digest_file(path)}


def _write_json_exclusive(path: Path, value: object) -> None:
    encoded = json.dumps(value, indent=2, sort_keys=True).encode("utf-8") + b"\n"
    try:
        with path.open("xb") as stream:
            stream.write(encoded)
    except FileExistsError as error:
        raise ProtocolError(f"refusing to replace existing transient artifact: {path}") from error


def _uv_version() -> str:
    result = subprocess.run(
        ["uv", "--version"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise ProtocolError("unable to observe the uv version")
    return result.stdout.strip()


def _platform_identity() -> dict[str, str]:
    return {
        "os": platform.system(),
        "architecture": platform.machine(),
        "interpreterImplementation": platform.python_implementation(),
        "interpreterVersion": platform.python_version(),
        "uvVersion": _uv_version(),
    }


def _project_lock_details(coordinates: Coordinates) -> dict[str, object]:
    project = coordinates.provider_root / "pyproject.toml"
    lock = coordinates.provider_root / "uv.lock"
    workbook = coordinates.provider_root / WORKBOOK_PATH
    inline_metadata_marker = b"# ///" + b" script"
    if inline_metadata_marker in workbook.read_bytes():
        raise ProtocolError("project-managed workbook contains inline dependency metadata")
    return {
        "project": {"path": str(project), "digest": _digest_file(project)},
        "lock": {"path": str(lock), "digest": _digest_file(lock)},
        "workbook": {"path": str(workbook), "digest": _digest_file(workbook)},
    }


def _fixture_details(coordinates: Coordinates) -> dict[str, object]:
    fixture_root = coordinates.provider_root / "marimo/workflows/bdd/.kb/fixtures"
    observations: dict[str, list[dict[str, str]]] = {}
    for fixture_class in ("positive", "negative"):
        class_root = fixture_root / fixture_class
        if not class_root.is_dir():
            raise ProtocolError(f"fixture root is absent: {class_root}")
        files = sorted(path for path in class_root.rglob("*") if path.is_file())
        if not files:
            raise ProtocolError(f"fixture root contains no files: {class_root}")
        observations[fixture_class] = [
            {
                "path": path.relative_to(coordinates.provider_root).as_posix(),
                "digest": _digest_file(path),
            }
            for path in files
        ]
    return {"fixtureFiles": observations}


def _self_conformance_details(
    coordinates: Coordinates, consumed: Sequence[dict[str, str]]
) -> dict[str, object]:
    return {
        "subjectWorkbook": _digest_file(coordinates.provider_root / WORKBOOK_PATH),
        "observedInputs": list(consumed),
    }


def _execute_node(
    node: CommandNode,
    coordinates: Coordinates,
    consumed: Sequence[dict[str, str]],
) -> dict[str, object]:
    handlers: dict[str, Callable[[], dict[str, object]]] = {
        "project-lock.verify": lambda: _project_lock_details(coordinates),
        "fixtures.execute": lambda: _fixture_details(coordinates),
        "self-conformance.execute": lambda: _self_conformance_details(coordinates, consumed),
    }
    try:
        handler = handlers[node.workflow_node]
    except KeyError as error:
        raise ProtocolError(
            f"Python-owned node has no workbook implementation: {node.workflow_node}"
        ) from error
    return handler()


def _parse_arguments(argv: Sequence[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--provider-root", required=True)
    parser.add_argument("--repo-root", required=True)
    parser.add_argument("--evidence-root", required=True)
    parser.add_argument("--execution-id", required=True)
    parser.add_argument("--node", required=True)
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    namespace = _parse_arguments(argv)
    coordinates = _validate_coordinates(namespace)
    commands_path = coordinates.provider_root / COMMANDS_PATH
    nodes, command_projection_digest = _load_python_nodes(commands_path)
    if namespace.node not in nodes:
        choices = ", ".join(sorted(nodes))
        raise ProtocolError(f"node is not Python-owned by the command projection; expected one of: {choices}")
    node = nodes[namespace.node]

    uv_environment = _absolute_existing_directory(
        os.environ.get("UV_PROJECT_ENVIRONMENT", ""), "UV project environment"
    )
    stem = f"{coordinates.execution_id}.{node.workflow_node}"
    stdout_path = coordinates.evidence_root / f"{stem}.stdout"
    stderr_path = coordinates.evidence_root / f"{stem}.stderr"
    observation_path = coordinates.evidence_root / f"{stem}.observation.json"
    for path in (stdout_path, stderr_path, observation_path):
        if path.exists():
            raise ProtocolError(f"refusing to replace existing transient output: {path}")

    consumed: list[dict[str, str]] = []
    produced: list[dict[str, str]] = []
    exit_code = 0
    started_at = _utc_now()
    with stdout_path.open("x", encoding="utf-8") as stdout_stream, stderr_path.open(
        "x", encoding="utf-8"
    ) as stderr_stream, contextlib.redirect_stdout(stdout_stream), contextlib.redirect_stderr(
        stderr_stream
    ):
        try:
            consumed = [
                _artifact_identity(_artifact_path(coordinates, artifact_id), artifact_id)
                for artifact_id in node.consumes
            ]
            details = _execute_node(node, coordinates, consumed)
            if _CLAIMANT_KEYS.intersection(details):
                raise ProtocolError("node details contain a claimant-style status field")
            for artifact_id in node.produces:
                path = _artifact_path(coordinates, artifact_id)
                _write_json_exclusive(
                    path,
                    {
                        "schema": ARTIFACT_SCHEMA,
                        "executionID": coordinates.execution_id,
                        "workflowNode": node.workflow_node,
                        "artifactID": artifact_id,
                        "recordedAt": _utc_now(),
                        "details": details,
                    },
                )
                produced.append(_artifact_identity(path, artifact_id))
        except Exception as error:  # observation boundary records fail-closed execution
            exit_code = 1
            print(f"{type(error).__name__}: {error}", file=sys.stderr)
    finished_at = _utc_now()

    observation = {
        "schema": OBSERVATION_SCHEMA,
        "executionID": coordinates.execution_id,
        "workflowNode": node.workflow_node,
        "argv": list(getattr(sys, "orig_argv", sys.argv)),
        "exitCode": exit_code,
        "startedAt": started_at,
        "finishedAt": finished_at,
        "environment": {
            "providerRoot": str(coordinates.provider_root),
            "consumerRoot": str(coordinates.repo_root),
            "evidenceRoot": str(coordinates.evidence_root),
            "uvProjectEnvironment": str(uv_environment),
            "platform": _platform_identity(),
        },
        "stdout": {"path": str(stdout_path), "digest": _digest_file(stdout_path)},
        "stderr": {"path": str(stderr_path), "digest": _digest_file(stderr_path)},
        "consumedArtifacts": consumed,
        "producedArtifacts": produced,
        "runnerProtocolVersion": RUNNER_PROTOCOL_VERSION,
        "workbookDigest": _digest_file(coordinates.provider_root / WORKBOOK_PATH),
        "commandProjectionDigest": command_projection_digest,
    }
    _write_json_exclusive(observation_path, observation)
    print(observation_path)
    return exit_code


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ProtocolError as error:
        print(f"ProtocolError: {error}", file=sys.stderr)
        raise SystemExit(2) from error
