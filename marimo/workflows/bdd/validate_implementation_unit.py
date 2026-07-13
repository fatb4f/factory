"""Manifest-driven Marimo boundary for raw BDD observations.

The CLI executes one Python-owned node. CUE evaluates the emitted facts.
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
from enum import StrEnum
from pathlib import Path
from typing import Any, Callable, Mapping, Sequence

import marimo


app = marimo.App()

RUNNER_PROTOCOL = "factory.bdd-python-runner.v2"
OBSERVATION_SCHEMA = "factory.bdd-workbook-node-observation.v1"
RESULT_SCHEMA = "factory.bdd-workbook-result.v1"
ARTIFACT_SCHEMA = "factory.bdd-python-observation-artifact.v1"
COMMAND_MANIFEST_SCHEMA = "factory.bdd-workbook-command-manifest.v1"
SCENARIO_MANIFEST_SCHEMA = "factory.bdd-workbook-scenario-manifest.v1"
FIXTURE_SCHEMA = "factory.bdd-scenario-fixture.v1"
WORKBOOK_PATH = Path("marimo/workflows/bdd/validate_implementation_unit.py")
_SAFE_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
_CLAIMANT_KEYS = frozenset(
    {"success", "valid", "complete", "admitted", "admission", "canonicalReady"}
)


class FailureCode(StrEnum):
    INVALID_COORDINATES = "invalid-coordinates"
    MANIFEST_DIGEST_MISMATCH = "manifest-digest-mismatch"
    UNKNOWN_WORKFLOW_NODE = "unknown-workflow-node"
    MISSING_CONSUMED_ARTIFACT = "missing-consumed-artifact"
    FIXTURE_PROTOCOL_MISMATCH = "fixture-protocol-mismatch"
    OUTPUT_ALREADY_EXISTS = "output-already-exists"
    CLAIMANT_FIELD_PRESENT = "claimant-field-present"
    PROCESS_FAILED = "process-failed"
    INTERNAL_PROTOCOL_ERROR = "internal-protocol-error"


class ProtocolError(RuntimeError):
    def __init__(
        self,
        code: FailureCode,
        message: str,
        *,
        scenario_id: str | None = None,
        artifact_id: str | None = None,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.scenario_id = scenario_id
        self.artifact_id = artifact_id

    def encode(self) -> dict[str, object]:
        result: dict[str, object] = {"code": self.code.value, "message": str(self)[:240]}
        if self.scenario_id is not None:
            result["scenarioID"] = self.scenario_id
        if self.artifact_id is not None:
            result["artifactID"] = self.artifact_id
        return result


@dataclass(frozen=True)
class CommandNode:
    workflow_node: str
    consumes: tuple[str, ...]
    produces: tuple[str, ...]


@dataclass(frozen=True)
class ExecutionSpec:
    execution_id: str
    workflow_node: str
    provider_root: Path
    consumer_root: Path
    evidence_root: Path
    environment_root: Path
    command_manifest_digest: str
    scenario_manifest_digest: str


@dataclass(frozen=True)
class NodeResult:
    facts: tuple[dict[str, object], ...]
    scenario_observations: tuple[dict[str, object], ...]


def _now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _digest_bytes(value: bytes) -> str:
    return f"sha256:{hashlib.sha256(value).hexdigest()}"


def _digest_file(path: Path) -> str:
    if not path.is_file():
        raise ProtocolError(FailureCode.MISSING_CONSUMED_ARTIFACT, f"missing file: {path}")
    return _digest_bytes(path.read_bytes())


def _write_exclusive(path: Path, content: bytes) -> None:
    try:
        with path.open("xb") as stream:
            stream.write(content)
    except FileExistsError as error:
        raise ProtocolError(FailureCode.OUTPUT_ALREADY_EXISTS, f"output exists: {path}") from error


def _write_json(path: Path, value: object) -> None:
    _write_exclusive(path, json.dumps(value, sort_keys=True, indent=2).encode() + b"\n")


def _absolute_directory(value: str, label: str) -> Path:
    path = Path(value)
    if not path.is_absolute() or not path.is_dir() or path.resolve(strict=True) != path:
        raise ProtocolError(FailureCode.INVALID_COORDINATES, f"invalid {label}")
    return path


def _bounded_path(path: Path, roots: Sequence[Path], label: str) -> Path:
    if not path.is_absolute() or not path.exists():
        raise ProtocolError(FailureCode.INVALID_COORDINATES, f"invalid {label}")
    resolved = path.resolve(strict=True)
    if not any(resolved == root or resolved.is_relative_to(root) for root in roots):
        raise ProtocolError(FailureCode.INVALID_COORDINATES, f"unbounded {label}")
    return resolved


def _fixture_coordinate(spec: ExecutionSpec, value: object, label: str) -> Path:
    if not isinstance(value, str):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"invalid {label}")
    coordinates = {
        "$provider_root": spec.provider_root,
        "$consumer_root": spec.consumer_root,
        "$evidence_root": spec.evidence_root,
    }
    for token, root in coordinates.items():
        if value == token:
            return root
        prefix = f"{token}/"
        if value.startswith(prefix):
            return root / value.removeprefix(prefix)
    return Path(value)


def _expand_fixture_value(spec: ExecutionSpec, value: str) -> str:
    replacements = {
        "$provider_root": str(spec.provider_root),
        "$consumer_root": str(spec.consumer_root),
        "$evidence_root": str(spec.evidence_root),
    }
    for token, replacement in replacements.items():
        value = value.replace(token, replacement)
    return value


def _load_manifest(path: Path, digest: str, schema: str) -> Mapping[str, Any]:
    raw = path.read_bytes()
    if _digest_bytes(raw) != digest:
        raise ProtocolError(FailureCode.MANIFEST_DIGEST_MISMATCH, f"digest mismatch: {path.name}")
    try:
        value = json.loads(raw)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ProtocolError(
            FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"invalid JSON: {path.name}"
        ) from error
    if not isinstance(value, dict) or value.get("schema") != schema:
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"schema mismatch: {path.name}")
    _reject_claimant_fields(value, path.name)
    return value


def _reject_claimant_fields(value: object, label: str) -> None:
    if isinstance(value, dict):
        forbidden = _CLAIMANT_KEYS.intersection(value)
        if forbidden:
            field = sorted(forbidden)[0]
            raise ProtocolError(
                FailureCode.CLAIMANT_FIELD_PRESENT, f"claimant field in {label}: {field}"
            )
        for child in value.values():
            _reject_claimant_fields(child, label)
    elif isinstance(value, list):
        for child in value:
            _reject_claimant_fields(child, label)


def _command_nodes(value: Mapping[str, Any]) -> dict[str, CommandNode]:
    if set(value) != {"schema", "nodes"}:
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "command manifest is open")
    raw_nodes = value.get("nodes")
    if not isinstance(raw_nodes, dict):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "command manifest omits nodes")
    nodes: dict[str, CommandNode] = {}
    for name, raw in raw_nodes.items():
        if (
            not isinstance(name, str)
            or not _SAFE_ID.fullmatch(name)
            or not isinstance(raw, dict)
            or set(raw) != {"consumes", "produces"}
        ):
            raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "invalid command node")
        consumes, produces = raw.get("consumes"), raw.get("produces")
        if not isinstance(consumes, list) or not isinstance(produces, list):
            raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"invalid node: {name}")
        nodes[name] = CommandNode(name, tuple(consumes), tuple(produces))
    return nodes


def _fact(name: str, value: str | int | bool) -> dict[str, object]:
    return {"name": name, "value": value}


def _fixture(spec: ExecutionSpec, scenario: Mapping[str, Any]) -> Mapping[str, Any]:
    relative = scenario.get("fixturePath")
    if not isinstance(relative, str):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "fixture path missing")
    fixture_root = (spec.provider_root / "marimo/workflows/bdd/.kb/fixtures").resolve()
    path = fixture_root / relative
    if not path.is_file() or not path.resolve().is_relative_to(fixture_root):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"fixture absent: {relative}")
    try:
        value = json.loads(path.read_bytes())
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ProtocolError(
            FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"invalid fixture JSON: {relative}"
        ) from error
    if not isinstance(value, dict) or value.get("schema") != FIXTURE_SCHEMA:
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"fixture schema: {relative}")
    if value.get("scenarioID") != scenario.get("scenarioID"):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"fixture scenario: {relative}")
    if value.get("executorProtocol") != scenario.get("executorProtocol"):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"fixture executor: {relative}")
    _reject_claimant_fields(value, relative)
    protocol_fields = {
        "project-inspect.v1": {"paths"},
        "process-run.v1": {"process"},
        "artifact-compare.v1": {"sourcePath", "candidatePath"},
        "cue-projection-observe.v1": {"projectionPath"},
    }
    expected_fields = {
        "schema",
        "scenarioID",
        "executorProtocol",
        *protocol_fields[scenario["executorProtocol"]],
    }
    if set(value) != expected_fields:
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"open fixture: {relative}")
    return value


def _project_inspect(spec: ExecutionSpec, fixture: Mapping[str, Any], node_root: Path) -> tuple[int, None, tuple[dict[str, object], ...]]:
    del node_root
    raw_paths = fixture.get("paths")
    if not isinstance(raw_paths, list) or not raw_paths:
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "project inspection omits paths")
    missing = 0
    mismatches = 0
    for item in raw_paths:
        if not isinstance(item, dict) or not isinstance(item.get("path"), str):
            raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "invalid inspection path")
        path = (spec.provider_root / item["path"]).resolve()
        if not path.is_relative_to(spec.provider_root) or not path.is_file():
            missing += 1
        elif item.get("expectedDigest") not in (None, _digest_file(path)):
            mismatches += 1
    return int(missing + mismatches > 0), None, (_fact("missingPathCount", missing), _fact("digestMismatchCount", mismatches))


def _process_run(spec: ExecutionSpec, fixture: Mapping[str, Any], node_root: Path) -> tuple[int, dict[str, object], tuple[dict[str, object], ...]]:
    process = fixture.get("process")
    if not isinstance(process, dict) or not isinstance(process.get("argv"), list):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "process fixture omits argv")
    argv = process["argv"]
    if not argv or not all(isinstance(item, str) and item for item in argv) or Path(argv[0]).name == "cue":
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "process argv is not permitted")
    argv = [_expand_fixture_value(spec, item) for item in argv]
    cwd = _bounded_path(_fixture_coordinate(spec, process.get("cwd"), "process cwd"), (spec.provider_root, spec.consumer_root, spec.evidence_root), "process cwd")
    environment = process.get("environment", {})
    if not isinstance(environment, dict) or not all(isinstance(k, str) and isinstance(v, str) for k, v in environment.items()):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "invalid process environment")
    environment = {key: _expand_fixture_value(spec, value) for key, value in environment.items()}
    started = _now()
    result = subprocess.run(argv, cwd=cwd, env={**os.environ, **environment}, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    finished = _now()
    stdout_path, stderr_path = node_root / "subject.stdout", node_root / "subject.stderr"
    _write_exclusive(stdout_path, result.stdout)
    _write_exclusive(stderr_path, result.stderr)
    subject = {
        "argv": argv,
        "startedAt": started,
        "finishedAt": finished,
        "exitCode": result.returncode,
        "stdoutDigest": _digest_file(stdout_path),
        "stderrDigest": _digest_file(stderr_path),
    }
    return result.returncode, subject, (_fact("subjectExitCode", result.returncode),)


def _artifact_compare(spec: ExecutionSpec, fixture: Mapping[str, Any], node_root: Path) -> tuple[int, None, tuple[dict[str, object], ...]]:
    del node_root
    fixture_root = (spec.provider_root / "marimo/workflows/bdd/.kb/fixtures").resolve()
    source = _bounded_path(_fixture_coordinate(spec, fixture.get("sourcePath"), "comparison source"), (fixture_root, spec.evidence_root), "comparison source")
    candidate = _bounded_path(_fixture_coordinate(spec, fixture.get("candidatePath"), "comparison candidate"), (fixture_root, spec.evidence_root), "comparison candidate")
    before_digest = _digest_file(source)
    after_digest = _digest_file(candidate)
    return 0, None, (_fact("beforeDigest", before_digest), _fact("afterDigest", after_digest))


def _projection_observe(spec: ExecutionSpec, fixture: Mapping[str, Any], node_root: Path) -> tuple[int, None, tuple[dict[str, object], ...]]:
    del node_root
    fixture_root = (spec.provider_root / "marimo/workflows/bdd/.kb/fixtures").resolve()
    path = _bounded_path(_fixture_coordinate(spec, fixture.get("projectionPath"), "projection"), (fixture_root, spec.evidence_root), "projection")
    try:
        json.loads(path.read_bytes())
        parse_code = 0
    except (UnicodeDecodeError, json.JSONDecodeError):
        parse_code = 1
    return parse_code, None, (_fact("projectionParseExitCode", parse_code),)


EXECUTORS: Mapping[str, Callable[[ExecutionSpec, Mapping[str, Any], Path], tuple[int, dict[str, object] | None, tuple[dict[str, object], ...]]]] = {
    "project-inspect.v1": _project_inspect,
    "process-run.v1": _process_run,
    "artifact-compare.v1": _artifact_compare,
    "cue-projection-observe.v1": _projection_observe,
}


def _execute_scenarios(spec: ExecutionSpec, manifest: Mapping[str, Any], node_root: Path) -> tuple[dict[str, object], ...]:
    if set(manifest) != {"schema", "scenarios"}:
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "scenario manifest is open")
    scenarios = manifest.get("scenarios")
    if not isinstance(scenarios, dict):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "scenario manifest omits scenarios")
    declared_protocols = {value.get("executorProtocol") for value in scenarios.values() if isinstance(value, dict)}
    if not declared_protocols.issubset(EXECUTORS):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "undeclared executor protocol")
    observations: list[dict[str, object]] = []
    for scenario_id in sorted(scenarios):
        scenario = scenarios[scenario_id]
        if (
            not isinstance(scenario, dict)
            or set(scenario)
            != {
                "scenarioID",
                "executorProtocol",
                "evaluationProtocol",
                "executionBoundary",
                "evaluationBoundary",
                "fixturePath",
            }
            or scenario.get("scenarioID") != scenario_id
            or scenario.get("executionBoundary") != "python-observe"
            or scenario.get("evaluationBoundary") != "cue-evaluate"
        ):
            raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"scenario boundary: {scenario_id}")
        fixture = _fixture(spec, scenario)
        protocol = scenario["executorProtocol"]
        protocol_code, subject, facts = EXECUTORS[protocol](spec, fixture, node_root)
        observations.append({
            "scenarioID": scenario_id,
            "executorProtocol": protocol,
            "runnerExitCode": 0,
            "protocolExitCode": protocol_code,
            "subject": subject,
            "facts": list(facts),
        })
    return tuple(observations)


def _project_lock(spec: ExecutionSpec, manifest: Mapping[str, Any], node_root: Path) -> NodeResult:
    del manifest, node_root
    project = spec.provider_root / "pyproject.toml"
    lock = spec.provider_root / "uv.lock"
    workbook = spec.provider_root / WORKBOOK_PATH
    if b"# ///" + b" script" in workbook.read_bytes():
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, "inline metadata present")
    return NodeResult(
        facts=(_fact("projectDigest", _digest_file(project)), _fact("lockDigest", _digest_file(lock))),
        scenario_observations=(),
    )


def _fixtures(spec: ExecutionSpec, manifest: Mapping[str, Any], node_root: Path) -> NodeResult:
    return NodeResult(facts=(), scenario_observations=_execute_scenarios(spec, manifest, node_root))


def _self_conformance(spec: ExecutionSpec, manifest: Mapping[str, Any], node_root: Path) -> NodeResult:
    observations = _execute_scenarios(spec, manifest, node_root)
    return NodeResult(
        facts=(_fact("subjectWorkbookDigest", _digest_file(spec.provider_root / WORKBOOK_PATH)),),
        scenario_observations=observations,
    )


NODE_HANDLERS: Mapping[str, Callable[[ExecutionSpec, Mapping[str, Any], Path], NodeResult]] = {
    "project-lock.verify": _project_lock,
    "fixtures.execute": _fixtures,
    "self-conformance.execute": _self_conformance,
}


def _arguments(argv: Sequence[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    for name in ("provider-root", "repo-root", "evidence-root", "execution-id", "node", "command-manifest", "command-manifest-digest", "scenario-manifest", "scenario-manifest-digest"):
        parser.add_argument(f"--{name}", required=True)
    return parser.parse_args(argv)


def _artifact_path(spec: ExecutionSpec, artifact_id: str) -> Path:
    if not _SAFE_ID.fullmatch(artifact_id):
        raise ProtocolError(FailureCode.FIXTURE_PROTOCOL_MISMATCH, f"invalid artifact: {artifact_id}")
    return spec.evidence_root / f"{artifact_id}.json"


def main(argv: Sequence[str] | None = None) -> int:
    args = _arguments(argv)
    provider = _absolute_directory(args.provider_root, "provider root")
    consumer = _absolute_directory(args.repo_root, "consumer root")
    evidence = _absolute_directory(args.evidence_root, "evidence root")
    environment = _absolute_directory(os.environ.get("UV_PROJECT_ENVIRONMENT", ""), "environment root")
    if not _SAFE_ID.fullmatch(args.execution_id) or evidence != Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "factory-bdd" / args.execution_id:
        raise ProtocolError(FailureCode.INVALID_COORDINATES, "execution coordinate mismatch")
    command_path = _bounded_path(Path(args.command_manifest), (evidence,), "command manifest")
    scenario_path = _bounded_path(Path(args.scenario_manifest), (evidence,), "scenario manifest")
    command_manifest = _load_manifest(command_path, args.command_manifest_digest, COMMAND_MANIFEST_SCHEMA)
    scenario_manifest = _load_manifest(scenario_path, args.scenario_manifest_digest, SCENARIO_MANIFEST_SCHEMA)
    nodes = _command_nodes(command_manifest)
    if set(nodes) != set(NODE_HANDLERS):
        raise ProtocolError(FailureCode.UNKNOWN_WORKFLOW_NODE, "workbook handlers do not match manifest")
    if args.node not in nodes:
        raise ProtocolError(FailureCode.UNKNOWN_WORKFLOW_NODE, f"unknown Python node: {args.node}")
    spec = ExecutionSpec(args.execution_id, args.node, provider, consumer, evidence, environment, args.command_manifest_digest, args.scenario_manifest_digest)
    node = nodes[args.node]
    node_parent = evidence / "nodes"
    node_parent.mkdir(exist_ok=True)
    node_root = node_parent / args.node
    try:
        node_root.mkdir()
    except FileExistsError as error:
        raise ProtocolError(FailureCode.OUTPUT_ALREADY_EXISTS, f"node output exists: {args.node}") from error
    stdout_path, stderr_path = node_root / "stdout", node_root / "stderr"
    consumed: list[dict[str, str]] = []
    produced: list[dict[str, str]] = []
    failure: dict[str, object] | None = None
    runner_exit = 0
    started = _now()
    with stdout_path.open("x", encoding="utf-8") as stdout, stderr_path.open("x", encoding="utf-8") as stderr, contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
        try:
            for artifact_id in node.consumes:
                path = _artifact_path(spec, artifact_id)
                consumed.append({"id": artifact_id, "digest": _digest_file(path)})
            result = NODE_HANDLERS[args.node](spec, scenario_manifest, node_root)
            for artifact_id in node.produces:
                path = node_root / f"{artifact_id}.json"
                _write_json(path, {"schema": ARTIFACT_SCHEMA, "executionID": spec.execution_id, "workflowNode": spec.workflow_node, "artifactID": artifact_id, "facts": list(result.facts), "scenarioObservations": list(result.scenario_observations)})
                produced.append({"id": artifact_id, "digest": _digest_file(path)})
        except ProtocolError as error:
            runner_exit = 1
            failure = error.encode()
            result = NodeResult((), ())
            print(json.dumps(failure, sort_keys=True), file=sys.stderr)
        except Exception as error:
            runner_exit = 1
            wrapped = ProtocolError(FailureCode.INTERNAL_PROTOCOL_ERROR, f"{type(error).__name__}: {error}")
            failure = wrapped.encode()
            result = NodeResult((), ())
            print(json.dumps(failure, sort_keys=True), file=sys.stderr)
    finished = _now()
    observation: dict[str, object] = {
        "schema": OBSERVATION_SCHEMA,
        "executionID": spec.execution_id,
        "workflowNode": spec.workflow_node,
        "processArgv": list(getattr(sys, "orig_argv", sys.argv)),
        "runnerExitCode": runner_exit,
        "startedAt": started,
        "finishedAt": finished,
        "python": {"executable": str(Path(sys.executable).resolve()), "implementation": platform.python_implementation(), "version": platform.python_version()},
        "environment": {"providerRoot": str(provider), "consumerRoot": str(consumer), "evidenceRoot": str(evidence), "uvProjectEnvironment": str(environment)},
        "stdout": {"path": str(stdout_path), "digest": _digest_file(stdout_path)},
        "stderr": {"path": str(stderr_path), "digest": _digest_file(stderr_path)},
        "consumedArtifacts": consumed,
        "producedArtifacts": produced,
        "scenarioObservations": list(result.scenario_observations),
        "runnerProtocolVersion": RUNNER_PROTOCOL,
        "workbookDigest": _digest_file(provider / WORKBOOK_PATH),
        "commandManifestDigest": spec.command_manifest_digest,
        "scenarioManifestDigest": spec.scenario_manifest_digest,
    }
    if failure is not None:
        observation["failure"] = failure
    observation_path = node_root / "workbook-observation.json"
    _write_json(observation_path, observation)
    result_payload: dict[str, object] = {"schema": RESULT_SCHEMA, "executionID": spec.execution_id, "workflowNode": spec.workflow_node, "exitCode": runner_exit, "observationPath": str(observation_path), "observationDigest": _digest_file(observation_path)}
    if failure is not None:
        result_payload["failure"] = failure
    print(json.dumps(result_payload, sort_keys=True))
    return runner_exit


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ProtocolError as error:
        print(json.dumps({"schema": RESULT_SCHEMA, "exitCode": 2, "failure": error.encode()}, sort_keys=True))
        raise SystemExit(2) from error
