"""Ephemeral, shadow-only CUE implementation transaction for issue 105.

The workbook observes and constructs a candidate in a disposable shadow copy.
It never writes to the live repository and never applies its generated patch.
"""

from __future__ import annotations

import argparse
import dataclasses
import difflib
import hashlib
import importlib.metadata
import json
import os
import platform
import re
import selectors
import shutil
import subprocess
import sys
import tempfile
import time
import traceback
from datetime import datetime, timezone
from enum import StrEnum
from pathlib import Path, PurePosixPath
from typing import Mapping, Sequence

import marimo


app = marimo.App()

RESULT_SCHEMA = "factory.cue-emergency-transaction-result.v1"
REQUEST_SCHEMA = "factory.cue-emergency-transaction-request.v1"
PATCH_SCHEMA = "factory.cue-candidate-patch-manifest.v1"
WORKER_SCHEMA = "factory.cue-py-worker-request.v1"
WORKBOOK_PATH = Path("marimo/workflows/cue/cue_workbook.py")
REPOSITORY_ID = "fatb4f/factory"
CUE_PY_COMMIT = "81e6fb15247ed7050e5bd987db032f757e06c8f0"
LIBCUE_COMMIT = "96d0572450429fa28d7a2345c04a8c47c85b47e4"
KERNEL_REPOSITORY = "https://github.com/fatb4f/lattice"
KERNEL_COMMIT = "4148dc1a2d1adfa0782e93e89ea402ce41c56d35"
KERNEL_RELATIVE_PATH = PurePosixPath("meta/kernel.cue")
KERNEL_BLOB = "f2570c424de2d4cb5b4603a265b7a6fc9dd7a0dd"
_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
_SELECTOR = re.compile(r"^[_#A-Za-z][_A-Za-z0-9]*(\.[_A-Za-z][_A-Za-z0-9]*)*$")


class TransactionError(RuntimeError):
    """A bounded protocol or infrastructure failure."""

    def __init__(self, category: str, message: str) -> None:
        super().__init__(message)
        self.category = category


class Outcome(StrEnum):
    ACCEPT = "accept"
    REJECT = "reject"
    INCOMPLETE = "incomplete"
    INFRASTRUCTURE_FAILURE = "infrastructure-failure"


@dataclasses.dataclass(frozen=True)
class Coordinates:
    repo_root: Path
    transient_root: Path
    shadow_root: Path
    promotion_root: Path
    request_path: Path
    kernel_path: Path
    cue_py_root: Path
    libcue_root: Path
    libcue_library: Path
    cue_bin: Path
    go_bin: Path
    uv_bin: Path


@dataclasses.dataclass(frozen=True)
class CandidateFile:
    path: PurePosixPath
    content: str | None


@dataclasses.dataclass(frozen=True)
class PackageGate:
    id: str
    module_root: PurePosixPath
    package: str
    files: tuple[PurePosixPath, ...]


@dataclasses.dataclass(frozen=True)
class Probe:
    id: str
    polarity: str
    source: str
    expression: str
    expected_state: str
    concrete_input: object
    unify_source: str | None
    schema_source: str | None


@dataclasses.dataclass(frozen=True)
class Request:
    base_revision: str
    allowed_paths: tuple[PurePosixPath, ...]
    candidates: tuple[CandidateFile, ...]
    gates: tuple[PackageGate, ...]
    probes: tuple[Probe, ...]
    lsp_argv: tuple[str, ...]


def _now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _json_bytes(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()


def _pretty_json(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, indent=2, ensure_ascii=False).encode() + b"\n"


def _digest_bytes(value: bytes) -> str:
    return f"sha256:{hashlib.sha256(value).hexdigest()}"


def _digest_file(path: Path) -> str:
    return _digest_bytes(path.read_bytes())


def _run(
    argv: Sequence[str],
    *,
    cwd: Path,
    env: Mapping[str, str] | None = None,
    input_bytes: bytes | None = None,
    timeout: float = 120,
) -> dict[str, object]:
    started = _now()
    try:
        result = subprocess.run(
            list(argv),
            cwd=cwd,
            env=dict(env) if env is not None else None,
            input=input_bytes,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
            timeout=timeout,
        )
        return {
            "argv": list(argv),
            "cwd": str(cwd),
            "startedAt": started,
            "finishedAt": _now(),
            "exitCode": result.returncode,
            "stdout": result.stdout.decode("utf-8", "replace")[:20000],
            "stderr": result.stderr.decode("utf-8", "replace")[:20000],
        }
    except (OSError, subprocess.TimeoutExpired) as error:
        return {
            "argv": list(argv),
            "cwd": str(cwd),
            "startedAt": started,
            "finishedAt": _now(),
            "exitCode": None,
            "stdout": "",
            "stderr": f"{type(error).__name__}: {error}"[:20000],
        }


def _absolute_existing(value: str, *, directory: bool, label: str) -> Path:
    path = Path(value)
    if not path.is_absolute():
        raise TransactionError("invalid-coordinate", f"{label} must be absolute")
    try:
        resolved = path.resolve(strict=True)
    except OSError as error:
        raise TransactionError("invalid-coordinate", f"{label} does not resolve") from error
    if (directory and not resolved.is_dir()) or (not directory and not resolved.is_file()):
        raise TransactionError("invalid-coordinate", f"{label} has the wrong kind")
    return resolved


def _safe_relative(value: object, label: str) -> PurePosixPath:
    if not isinstance(value, str) or not value or "\\" in value:
        raise TransactionError("invalid-request", f"invalid {label}")
    path = PurePosixPath(value)
    if path.is_absolute() or any(part in ("", ".", "..") for part in path.parts):
        raise TransactionError("path-escape", f"invalid {label}")
    return path


def _safe_package(value: object) -> str:
    if not isinstance(value, str) or not value.startswith("./"):
        raise TransactionError("invalid-request", "package must be an explicit relative coordinate")
    body = value[2:]
    if body in {".", "..."}:
        return value
    base = body.removesuffix("/...")
    path = _safe_relative(base, "package")
    if not all(re.fullmatch(r"[A-Za-z0-9_.-]+", part) for part in path.parts):
        raise TransactionError("invalid-request", "invalid package coordinate")
    return value


def _git(root: Path, *args: str) -> str:
    result = _run(("git", "-C", str(root), *args), cwd=root)
    if result["exitCode"] != 0:
        raise TransactionError("git-failure", str(result["stderr"]))
    return str(result["stdout"]).strip()


def _verify_git_checkout(root: Path, commit: str, label: str) -> None:
    if _git(root, "rev-parse", "HEAD") != commit:
        raise TransactionError("binding-identity-mismatch", f"{label} commit mismatch")


def _verify_kernel(path: Path) -> dict[str, str]:
    root = Path(_git(path.parent, "rev-parse", "--show-toplevel")).resolve(strict=True)
    _verify_git_checkout(root, KERNEL_COMMIT, "kernel")
    try:
        relative = PurePosixPath(path.relative_to(root).as_posix())
    except ValueError as error:
        raise TransactionError("kernel-identity-mismatch", "kernel is outside checkout") from error
    if relative != KERNEL_RELATIVE_PATH:
        raise TransactionError("kernel-identity-mismatch", "kernel relative path mismatch")
    blob = _git(root, "hash-object", str(path))
    if blob != KERNEL_BLOB:
        raise TransactionError("kernel-identity-mismatch", "kernel blob digest mismatch")
    return {
        "repositoryURI": KERNEL_REPOSITORY,
        "revision": KERNEL_COMMIT,
        "repositoryRelativePath": str(KERNEL_RELATIVE_PATH),
        "gitBlobSHA1": blob,
        "absoluteLocalPath": str(path),
        "mode": "pinned-read-only-input",
        "initialUse": "pattern-only",
    }


def _load_request(path: Path) -> Request:
    try:
        raw = json.loads(path.read_bytes())
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise TransactionError("invalid-request", "request is not valid JSON") from error
    if not isinstance(raw, dict) or set(raw) != {
        "schema",
        "repository",
        "baseRevision",
        "allowedPaths",
        "candidateFiles",
        "packageGates",
        "probes",
        "lsp",
    }:
        raise TransactionError("invalid-request", "request boundary is open or incomplete")
    if raw["schema"] != REQUEST_SCHEMA or raw["repository"] != REPOSITORY_ID:
        raise TransactionError("invalid-request", "request identity mismatch")
    if not isinstance(raw["baseRevision"], str) or not re.fullmatch(r"[0-9a-f]{40}", raw["baseRevision"]):
        raise TransactionError("invalid-request", "invalid base revision")
    if not isinstance(raw["allowedPaths"], list) or not raw["allowedPaths"]:
        raise TransactionError("invalid-request", "allowedPaths must be nonempty")
    allowed = tuple(_safe_relative(item, "allowed path") for item in raw["allowedPaths"])
    if len(set(allowed)) != len(allowed):
        raise TransactionError("invalid-request", "allowedPaths contains duplicates")
    if not isinstance(raw["candidateFiles"], list):
        raise TransactionError("invalid-request", "candidateFiles must be a list")
    candidates: list[CandidateFile] = []
    for item in raw["candidateFiles"]:
        if not isinstance(item, dict) or set(item) != {"path", "content"}:
            raise TransactionError("invalid-request", "invalid candidate file")
        candidate_path = _safe_relative(item["path"], "candidate path")
        if candidate_path not in allowed or (item["content"] is not None and not isinstance(item["content"], str)):
            raise TransactionError("invalid-request", "candidate file exceeds allowance")
        candidates.append(CandidateFile(candidate_path, item["content"]))
    if len({item.path for item in candidates}) != len(candidates):
        raise TransactionError("invalid-request", "duplicate candidate file")
    if not isinstance(raw["packageGates"], list) or not raw["packageGates"]:
        raise TransactionError("invalid-request", "packageGates must be nonempty")
    gates: list[PackageGate] = []
    for item in raw["packageGates"]:
        if not isinstance(item, dict) or set(item) != {"id", "moduleRoot", "package", "files"}:
            raise TransactionError("invalid-request", "invalid package gate")
        if not isinstance(item["id"], str) or not _ID.fullmatch(item["id"]):
            raise TransactionError("invalid-request", "invalid package gate id")
        package = _safe_package(item["package"])
        if not isinstance(item["files"], list) or not item["files"]:
            raise TransactionError("invalid-request", "gate files must be nonempty")
        gates.append(
            PackageGate(
                item["id"],
                _safe_relative(item["moduleRoot"], "module root"),
                package,
                tuple(_safe_relative(value, "gate file") for value in item["files"]),
            )
        )
    if len({item.id for item in gates}) != len(gates):
        raise TransactionError("invalid-request", "duplicate package gate id")
    if not isinstance(raw["probes"], list) or not raw["probes"]:
        raise TransactionError("invalid-request", "probes must be nonempty")
    probes: list[Probe] = []
    for item in raw["probes"]:
        required = {
            "id",
            "polarity",
            "source",
            "expression",
            "expectedState",
            "concreteInput",
            "unifySource",
            "schemaSource",
        }
        if not isinstance(item, dict) or set(item) != required:
            raise TransactionError("invalid-request", "invalid probe boundary")
        if not isinstance(item["id"], str) or not _ID.fullmatch(item["id"]):
            raise TransactionError("invalid-request", "invalid probe id")
        if item["polarity"] not in {"positive", "negative", "adversarial"}:
            raise TransactionError("invalid-request", "invalid probe polarity")
        if item["expectedState"] not in {"accept", "reject", "incomplete"}:
            raise TransactionError("invalid-request", "invalid expected probe state")
        for key in ("source", "expression"):
            if not isinstance(item[key], str) or not item[key]:
                raise TransactionError("invalid-request", f"invalid probe {key}")
        if not _SELECTOR.fullmatch(item["expression"]):
            raise TransactionError("invalid-request", "probe expression must be a CUE selector path")
        for key in ("unifySource", "schemaSource"):
            if item[key] is not None and not isinstance(item[key], str):
                raise TransactionError("invalid-request", f"invalid probe {key}")
        probes.append(
            Probe(
                item["id"], item["polarity"], item["source"], item["expression"],
                item["expectedState"], item["concreteInput"], item["unifySource"],
                item["schemaSource"],
            )
        )
    if len({item.id for item in probes}) != len(probes):
        raise TransactionError("invalid-request", "duplicate probe id")
    if {item.polarity for item in probes}.isdisjoint({"positive"}) or {item.polarity for item in probes}.isdisjoint({"negative"}):
        raise TransactionError("missing-probes", "positive and negative probes are required")
    lsp = raw["lsp"]
    if not isinstance(lsp, dict) or set(lsp) != {"argv"} or not isinstance(lsp["argv"], list):
        raise TransactionError("invalid-request", "invalid lsp declaration")
    if not all(isinstance(value, str) and value for value in lsp["argv"]):
        raise TransactionError("invalid-request", "invalid lsp argv")
    return Request(raw["baseRevision"], allowed, tuple(candidates), tuple(gates), tuple(probes), tuple(lsp["argv"]))


def _tree_digest(root: Path) -> str:
    digest = hashlib.sha256()
    ignored = {".git", ".venv", "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"}
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root)
        if any(part in ignored for part in relative.parts) or not path.is_file() or path.is_symlink():
            continue
        digest.update(relative.as_posix().encode() + b"\0")
        digest.update(hashlib.sha256(path.read_bytes()).digest())
    return f"sha256:{digest.hexdigest()}"


def _copy_shadow(repo_root: Path, shadow_root: Path) -> None:
    if shadow_root.exists():
        raise TransactionError("shadow-exists", "shadow root must not exist")
    shutil.copytree(
        repo_root,
        shadow_root,
        symlinks=True,
        ignore=shutil.ignore_patterns(".git", ".venv", "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"),
    )


def _apply_candidates(shadow: Path, request: Request) -> None:
    for candidate in request.candidates:
        path = shadow.joinpath(*candidate.path.parts)
        resolved = path.resolve(strict=False)
        if not resolved.is_relative_to(shadow):
            raise TransactionError("path-escape", f"candidate path escapes: {candidate.path}")
        if candidate.content is None:
            if path.exists():
                if not path.is_file() or path.is_symlink():
                    raise TransactionError("unsafe-candidate", f"cannot remove: {candidate.path}")
                path.unlink()
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(candidate.content, encoding="utf-8", newline="")


def _gate_observation(gate: PackageGate, shadow: Path, cue_bin: Path) -> dict[str, object]:
    module = shadow.joinpath(*gate.module_root.parts).resolve(strict=True)
    if not module.is_relative_to(shadow) or not (module / "cue.mod/module.cue").is_file():
        raise TransactionError("invalid-module-coordinate", f"invalid module root: {gate.id}")
    files: list[str] = []
    for relative in gate.files:
        path = module.joinpath(*relative.parts).resolve(strict=True)
        if not path.is_relative_to(module) or not path.is_file():
            raise TransactionError("invalid-file-coordinate", f"invalid gate file: {relative}")
        files.append(relative.as_posix())
    commands = [
        _run((str(cue_bin), "fmt", "--check", "--files", *files), cwd=module),
        _run((str(cue_bin), "vet", gate.package), cwd=module),
        _run((str(cue_bin), "vet", "-c", gate.package), cwd=module),
    ]
    state = Outcome.ACCEPT if all(item["exitCode"] == 0 for item in commands) else Outcome.REJECT
    if any(item["exitCode"] is None for item in commands):
        state = Outcome.INFRASTRUCTURE_FAILURE
    return {
        "id": gate.id,
        "moduleRoot": gate.module_root.as_posix(),
        "package": gate.package,
        "files": files,
        "semanticOutcome": {"state": state.value, "category": "package-gates"},
        "commands": commands,
    }


def _subject(probe: Probe, filename: str) -> dict[str, str]:
    build_options = {
        "filename": filename,
        "importPath": "",
        "unifySourceDigest": None if probe.unify_source is None else _digest_bytes(probe.unify_source.encode()),
        "schemaSourceDigest": None if probe.schema_source is None else _digest_bytes(probe.schema_source.encode()),
    }
    return {
        "candidateOrProbeDigest": _digest_bytes(probe.source.encode()),
        "selectedExpression": probe.expression,
        "cueBuildOptionsDigest": _digest_bytes(_json_bytes(build_options)),
        "concreteInputDigest": _digest_bytes(_json_bytes(probe.concrete_input)),
    }


def _cli_probe_source(probe: Probe) -> str:
    parts = [probe.source.rstrip(), ""]
    if probe.unify_source is not None:
        parts.extend(("// Workbook-constructed equivalent unify conjunct.", probe.unify_source.rstrip(), ""))
    if probe.schema_source is not None:
        parts.extend(
            (
                "// Workbook-constructed concrete schema-conformance proof.",
                f"_factoryProbeSchemaProof: ({probe.expression}) & ({probe.schema_source})",
                "",
            )
        )
    return "\n".join(parts)


def _cue_py_worker_request(probes: Sequence[Probe], probe_files: Mapping[str, str], cue_py_root: Path) -> dict[str, object]:
    return {
        "schema": WORKER_SCHEMA,
        "cuePyRoot": str(cue_py_root),
        "probes": [
            {
                "id": probe.id,
                "source": probe.source,
                "filename": probe_files[probe.id],
                "expression": probe.expression,
                "unifySource": probe.unify_source,
                "schemaSource": probe.schema_source,
                "subject": _subject(probe, probe_files[probe.id]),
            }
            for probe in probes
        ],
    }


def _run_cue_py(
    probes: Sequence[Probe],
    probe_files: Mapping[str, str],
    coordinates: Coordinates,
    workbook: Path,
) -> tuple[list[dict[str, object]], dict[str, object]]:
    request_path = coordinates.transient_root / "cue-py-worker-request.json"
    request_path.write_bytes(_pretty_json(_cue_py_worker_request(probes, probe_files, coordinates.cue_py_root)))
    environment = dict(os.environ)
    library_variable = "PATH" if sys.platform == "win32" else ("DYLD_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH")
    environment[library_variable] = str(coordinates.libcue_library.parent) + os.pathsep + environment.get(library_variable, "")
    result = _run(
        (sys.executable, str(workbook), "--cue-py-worker", str(request_path)),
        cwd=coordinates.shadow_root,
        env=environment,
    )
    if result["exitCode"] != 0:
        observations = [
            {
                "probeID": probe.id,
                "evaluator": "cue-py/libcue",
                "stage": "compile",
                "semanticOutcome": {"state": "infrastructure-failure", "category": "worker-failure"},
                "subject": _subject(probe, probe_files[probe.id]),
                "rawDiagnostic": str(result["stderr"]),
            }
            for probe in probes
        ]
        return observations, result
    try:
        payload = json.loads(str(result["stdout"]))
    except json.JSONDecodeError as error:
        raise TransactionError("cue-py-worker-protocol", "cue-py worker returned invalid JSON") from error
    if not isinstance(payload, dict) or not isinstance(payload.get("observations"), list):
        raise TransactionError("cue-py-worker-protocol", "cue-py worker response mismatch")
    return payload["observations"], result


def _cli_probe(probe: Probe, filename: str, module: Path, cue_bin: Path) -> dict[str, object]:
    subject = _subject(probe, filename)
    eval_result = _run((str(cue_bin), "eval", "-e", probe.expression, filename), cwd=module)
    if eval_result["exitCode"] is None:
        outcome = {"state": "infrastructure-failure", "category": "cli-unavailable"}
        stage = "compile"
        concrete_result: dict[str, object] | None = None
    elif eval_result["exitCode"] != 0:
        outcome = {"state": "reject", "category": "bottom"}
        stage = "validate"
        concrete_result = None
    else:
        concrete_result = _run((str(cue_bin), "export", "--out", "json", "-e", probe.expression, filename), cwd=module)
        if concrete_result["exitCode"] is None:
            outcome = {"state": "infrastructure-failure", "category": "cli-unavailable"}
            stage = "project"
        elif concrete_result["exitCode"] != 0:
            outcome = {"state": "incomplete", "category": "incomplete"}
            stage = "project"
        else:
            try:
                value = json.loads(str(concrete_result["stdout"]))
                outcome = {
                    "state": "accept",
                    "category": "concrete",
                    "concreteValueDigest": _digest_bytes(_json_bytes(value)),
                }
                stage = "project"
            except json.JSONDecodeError:
                outcome = {"state": "infrastructure-failure", "category": "invalid-cli-json"}
                stage = "project"
    return {
        "probeID": probe.id,
        "evaluator": "cue-cli",
        "stage": stage,
        "semanticOutcome": outcome,
        "subject": subject,
        "harnessDigest": _digest_bytes((module / filename).read_bytes()),
        "commands": [item for item in (eval_result, concrete_result) if item is not None],
    }


def _compare(
    probes: Sequence[Probe],
    cue_py: Sequence[Mapping[str, object]],
    cli: Sequence[Mapping[str, object]],
) -> list[dict[str, object]]:
    py_by_id = {str(item["probeID"]): item for item in cue_py}
    cli_by_id = {str(item["probeID"]): item for item in cli}
    comparisons: list[dict[str, object]] = []
    for probe in probes:
        left, right = py_by_id[probe.id], cli_by_id[probe.id]
        equivalent = left.get("subject") == right.get("subject")
        left_outcome = left.get("semanticOutcome")
        right_outcome = right.get("semanticOutcome")
        agrees = equivalent and left_outcome == right_outcome
        comparisons.append(
            {
                "probeID": probe.id,
                "equivalentInputs": equivalent,
                "agrees": agrees,
                "expectedState": probe.expected_state,
                "expectationSatisfied": agrees
                and isinstance(left_outcome, dict)
                and left_outcome.get("state") == probe.expected_state,
                "cuePyOutcome": left_outcome,
                "cueCLIOutcome": right_outcome,
            }
        )
    return comparisons


def _lsp_observation(argv: Sequence[str], shadow: Path, files: Sequence[Path]) -> dict[str, object]:
    if not argv:
        return {"availability": "unavailable", "reason": "no LSP command declared", "diagnostics": []}
    started = _now()
    process: subprocess.Popen[bytes] | None = None
    messages: list[object] = []
    stderr = b""
    try:
        process = subprocess.Popen(
            list(argv), cwd=shadow, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        assert process.stdin is not None and process.stdout is not None

        def send(message: object) -> None:
            body = _json_bytes(message)
            process.stdin.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
            process.stdin.flush()

        send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"processId": os.getpid(), "rootUri": shadow.as_uri(), "capabilities": {}}})
        send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
        for path in files:
            if path.is_file():
                send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {"textDocument": {"uri": path.as_uri(), "languageId": "cue", "version": 1, "text": path.read_text(encoding="utf-8")}}})
        selector = selectors.DefaultSelector()
        selector.register(process.stdout, selectors.EVENT_READ)
        buffer = bytearray()
        deadline = time.monotonic() + 2.0
        while time.monotonic() < deadline and len(messages) < 200:
            ready = selector.select(timeout=0.1)
            if not ready:
                continue
            chunk = os.read(process.stdout.fileno(), 65536)
            if not chunk:
                break
            buffer.extend(chunk)
            while b"\r\n\r\n" in buffer:
                header, rest = buffer.split(b"\r\n\r\n", 1)
                match = re.search(br"(?i)Content-Length:\s*(\d+)", header)
                if match is None or len(rest) < int(match.group(1)):
                    break
                length = int(match.group(1))
                body, remainder = rest[:length], rest[length:]
                buffer = bytearray(remainder)
                try:
                    messages.append(json.loads(body))
                except json.JSONDecodeError:
                    messages.append({"invalidMessage": body.decode("utf-8", "replace")[:2000]})
        send({"jsonrpc": "2.0", "id": 2, "method": "shutdown", "params": None})
        send({"jsonrpc": "2.0", "method": "exit", "params": {}})
        try:
            _, stderr = process.communicate(timeout=2)
        except subprocess.TimeoutExpired:
            process.terminate()
            _, stderr = process.communicate(timeout=2)
        diagnostics = [item for item in messages if isinstance(item, dict) and item.get("method") == "textDocument/publishDiagnostics"]
        return {
            "availability": "available",
            "argv": list(argv),
            "startedAt": started,
            "finishedAt": _now(),
            "diagnostics": diagnostics,
            "observations": messages,
            "stderr": stderr.decode("utf-8", "replace")[:20000],
            "authoritative": False,
        }
    except (OSError, BrokenPipeError, ValueError) as error:
        if process is not None and process.poll() is None:
            process.kill()
            process.wait()
        return {
            "availability": "unavailable",
            "argv": list(argv),
            "startedAt": started,
            "finishedAt": _now(),
            "reason": f"{type(error).__name__}: {error}"[:2000],
            "diagnostics": [],
            "authoritative": False,
        }


def _file_bytes(root: Path, relative: PurePosixPath) -> bytes | None:
    path = root.joinpath(*relative.parts)
    if not path.resolve(strict=False).is_relative_to(root):
        raise TransactionError("unsafe-patch-path", f"path escapes root: {relative}")
    if not path.exists():
        return None
    if not path.is_file() or path.is_symlink():
        raise TransactionError("unsafe-patch-path", f"not a regular file: {relative}")
    return path.read_bytes()


def _base_file_bytes(repo: Path, base_revision: str, relative: PurePosixPath) -> bytes | None:
    coordinate = f"{base_revision}:{relative.as_posix()}"
    exists = subprocess.run(
        ["git", "-C", str(repo), "cat-file", "-e", coordinate],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if exists.returncode != 0:
        return None
    result = subprocess.run(
        ["git", "-C", str(repo), "show", coordinate],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise TransactionError("base-read-failure", result.stderr.decode("utf-8", "replace")[:2000])
    return result.stdout


def _candidate_patch(repo: Path, shadow: Path, request: Request, base_revision: str) -> tuple[bytes, dict[str, object]] | None:
    chunks: list[str] = []
    preimages: dict[str, str] = {}
    postimages: dict[str, str] = {}
    changed: list[str] = []
    for relative in request.allowed_paths:
        before = _file_bytes(repo, relative)
        if before != _base_file_bytes(repo, base_revision, relative):
            raise TransactionError("dirty-patch-preimage", f"allowed path differs from base revision: {relative}")
        after = _file_bytes(shadow, relative)
        if before == after:
            continue
        path = relative.as_posix()
        changed.append(path)
        preimages[path] = "absent" if before is None else _digest_bytes(before)
        postimages[path] = "absent" if after is None else _digest_bytes(after)
        before_text = [] if before is None else before.decode("utf-8").splitlines(keepends=True)
        after_text = [] if after is None else after.decode("utf-8").splitlines(keepends=True)
        chunks.extend(
            difflib.unified_diff(
                before_text,
                after_text,
                fromfile="/dev/null" if before is None else f"a/{path}",
                tofile="/dev/null" if after is None else f"b/{path}",
                lineterm="\n",
            )
        )
    if not changed:
        return None
    patch = "".join(chunks).encode()
    if not patch.endswith(b"\n"):
        patch += b"\n"
    manifest: dict[str, object] = {
        "schema": PATCH_SCHEMA,
        "patchSafety": {
            "repository": REPOSITORY_ID,
            "baseRevision": base_revision,
            "allowedPaths": [path.as_posix() for path in request.allowed_paths],
            "changedPaths": changed,
            "preimageDigests": preimages,
            "postimageDigests": postimages,
            "patchDigest": _digest_bytes(patch),
        },
    }
    _validate_patch_pair(patch, manifest, repo, shadow, request, base_revision)
    return patch, manifest


def _validate_patch_pair(
    patch: bytes,
    manifest: Mapping[str, object],
    repo: Path,
    shadow: Path,
    request: Request,
    base_revision: str,
) -> None:
    safety = manifest.get("patchSafety")
    if not isinstance(safety, dict) or safety.get("repository") != REPOSITORY_ID or safety.get("baseRevision") != base_revision:
        raise TransactionError("unsafe-patch", "patch identity mismatch")
    if safety.get("patchDigest") != _digest_bytes(patch):
        raise TransactionError("unsafe-patch", "patch digest mismatch")
    allowed = {path.as_posix() for path in request.allowed_paths}
    changed = safety.get("changedPaths")
    if not isinstance(changed, list) or not changed or not set(changed).issubset(allowed):
        raise TransactionError("unsafe-patch", "patch scope mismatch")
    headers = set()
    for line in patch.decode("utf-8").splitlines():
        if line.startswith(("--- ", "+++ ")):
            value = line[4:]
            if value != "/dev/null":
                if not value.startswith(("a/", "b/")):
                    raise TransactionError("unsafe-patch", "ambiguous patch header")
                headers.add(value[2:])
    if headers != set(changed):
        raise TransactionError("unsafe-patch", "patch paths do not match manifest")
    preimages, postimages = safety.get("preimageDigests"), safety.get("postimageDigests")
    if not isinstance(preimages, dict) or not isinstance(postimages, dict):
        raise TransactionError("unsafe-patch", "patch digests missing")
    for value in changed:
        relative = _safe_relative(value, "changed path")
        before, after = _file_bytes(repo, relative), _file_bytes(shadow, relative)
        expected_before = "absent" if before is None else _digest_bytes(before)
        expected_after = "absent" if after is None else _digest_bytes(after)
        if preimages.get(value) != expected_before or postimages.get(value) != expected_after:
            raise TransactionError("unsafe-patch", "patch preimage or postimage mismatch")


def _atomic_promote(root: Path, artifacts: Mapping[str, bytes]) -> None:
    if root.exists():
        raise TransactionError("promotion-exists", "promotion root already exists")
    root.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=f".{root.name}.", suffix=".staging", dir=root.parent))
    try:
        for name, content in artifacts.items():
            path = staging / name
            with path.open("xb") as stream:
                stream.write(content)
                stream.flush()
                os.fsync(stream.fileno())
        directory_fd = os.open(staging, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
        os.replace(staging, root)
    except Exception:
        shutil.rmtree(staging, ignore_errors=True)
        raise


def _binding_identity(coordinates: Coordinates) -> dict[str, object]:
    _verify_git_checkout(coordinates.cue_py_root, CUE_PY_COMMIT, "cue-py")
    _verify_git_checkout(coordinates.libcue_root, LIBCUE_COMMIT, "libcue")
    canonical_library = "cue.dll" if sys.platform == "win32" else ("libcue.dylib" if sys.platform == "darwin" else "libcue.so")
    if coordinates.libcue_library.name != canonical_library or not coordinates.libcue_library.is_relative_to(coordinates.libcue_root):
        raise TransactionError("binding-identity-mismatch", "libcue library coordinate mismatch")
    go_version = _run((str(coordinates.go_bin), "version"), cwd=coordinates.repo_root)
    if go_version["exitCode"] != 0:
        raise TransactionError("binding-identity-mismatch", "go version unavailable")
    try:
        cffi_version = importlib.metadata.version("cffi")
    except importlib.metadata.PackageNotFoundError as error:
        raise TransactionError("binding-identity-mismatch", "cffi is unavailable") from error
    return {
        "cuePyCommit": CUE_PY_COMMIT,
        "libcueCommit": LIBCUE_COMMIT,
        "libcueSharedLibraryDigest": _digest_file(coordinates.libcue_library),
        "cffiVersion": cffi_version,
        "goVersion": str(go_version["stdout"]).strip(),
        "pythonVersion": platform.python_version(),
        "platformIdentity": platform.platform(),
    }


def _environment_identity(coordinates: Coordinates) -> dict[str, object]:
    environment = os.environ.get("UV_PROJECT_ENVIRONMENT")
    if not environment:
        raise TransactionError("unlocked-environment", "UV_PROJECT_ENVIRONMENT is required")
    environment_path = Path(environment)
    if not environment_path.is_absolute() or not Path(sys.prefix).resolve().is_relative_to(environment_path.resolve()):
        raise TransactionError("unlocked-environment", "interpreter is outside declared disposable environment")
    if environment_path.resolve().is_relative_to(coordinates.repo_root):
        raise TransactionError("unsafe-environment", "environment must be outside the live repository")
    if environment_path.resolve().is_relative_to(coordinates.transient_root):
        raise TransactionError("unsafe-environment", "environment must be outside the transient root")
    lock_check = _run((str(coordinates.uv_bin), "lock", "--check", "--project", str(coordinates.repo_root)), cwd=coordinates.repo_root)
    if lock_check["exitCode"] != 0:
        raise TransactionError("lock-check-failure", str(lock_check["stderr"]))
    return {
        "uvProjectEnvironment": str(environment_path.resolve()),
        "pythonExecutable": str(Path(sys.executable).resolve()),
        "projectDigest": _digest_file(coordinates.repo_root / "pyproject.toml"),
        "lockDigest": _digest_file(coordinates.repo_root / "uv.lock"),
        "lockCheck": lock_check,
    }


def _transaction(coordinates: Coordinates) -> tuple[dict[str, object], bytes | None, dict[str, object] | None]:
    started = _now()
    workbook = coordinates.repo_root / WORKBOOK_PATH
    workbook_digest = _digest_file(workbook)
    kernel_identity = _verify_kernel(coordinates.kernel_path)
    binding_identity = _binding_identity(coordinates)
    environment_identity = _environment_identity(coordinates)
    request = _load_request(coordinates.request_path)
    base_revision = _git(coordinates.repo_root, "rev-parse", "HEAD")
    if request.base_revision != base_revision:
        raise TransactionError("base-revision-mismatch", "request base revision does not match repository")
    before_digest = _tree_digest(coordinates.repo_root)
    _copy_shadow(coordinates.repo_root, coordinates.shadow_root)
    _apply_candidates(coordinates.shadow_root, request)

    gate_observations = [_gate_observation(gate, coordinates.shadow_root, coordinates.cue_bin) for gate in request.gates]
    first_module = coordinates.shadow_root.joinpath(*request.gates[0].module_root.parts).resolve(strict=True)
    probe_root = first_module / ".factory-cue-probes"
    probe_root.mkdir()
    probe_files: dict[str, str] = {}
    for probe in request.probes:
        relative = Path(".factory-cue-probes") / f"{probe.id}.cue"
        (first_module / relative).write_text(_cli_probe_source(probe), encoding="utf-8", newline="")
        probe_files[probe.id] = relative.as_posix()
    cue_py_observations, cue_py_process = _run_cue_py(request.probes, probe_files, coordinates, workbook)
    cli_observations = [_cli_probe(probe, probe_files[probe.id], first_module, coordinates.cue_bin) for probe in request.probes]
    comparisons = _compare(request.probes, cue_py_observations, cli_observations)
    lsp_files = [coordinates.shadow_root.joinpath(*candidate.path.parts) for candidate in request.candidates if candidate.content is not None]
    lsp = _lsp_observation(request.lsp_argv, coordinates.shadow_root, lsp_files)

    package_infrastructure = any(item["semanticOutcome"]["state"] == "infrastructure-failure" for item in gate_observations)  # type: ignore[index]
    probe_infrastructure = any(
        item.get("semanticOutcome", {}).get("state") == "infrastructure-failure"  # type: ignore[union-attr]
        for item in (*cue_py_observations, *cli_observations)
    )
    disagreement = any(not item["equivalentInputs"] or not item["agrees"] for item in comparisons)
    package_rejection = any(item["semanticOutcome"]["state"] != "accept" for item in gate_observations)  # type: ignore[index]
    expectation_failure = any(not item["expectationSatisfied"] for item in comparisons)
    if package_infrastructure or probe_infrastructure:
        state = "exceptional"
    elif disagreement:
        state = "incomplete"
    elif package_rejection or expectation_failure:
        state = "rejected"
    else:
        state = "accepted"
    pair = _candidate_patch(coordinates.repo_root, coordinates.shadow_root, request, base_revision) if state == "accepted" else None
    after_digest = _tree_digest(coordinates.repo_root)
    if before_digest != after_digest:
        raise TransactionError("live-repository-mutated", "live repository identity changed during transaction")
    result: dict[str, object] = {
        "schema": RESULT_SCHEMA,
        "transactionState": state,
        "startedAt": started,
        "finishedAt": _now(),
        "authority": {
            "classification": "emergency-control-plane-recovery",
            "status": "active",
            "issue": 105,
            "blockedBy104": False,
            "ordinaryImplementationUnitAdmissionClaimed": False,
            "selfAdmissionClaimed": False,
        },
        "repository": {
            "identity": REPOSITORY_ID,
            "baseRevision": base_revision,
            "root": str(coordinates.repo_root),
            "liveTreeDigestBefore": before_digest,
            "liveTreeDigestAfter": after_digest,
            "readOnlyByWorkbook": True,
        },
        "transaction": {
            "transientRoot": str(coordinates.transient_root),
            "shadowRoot": str(coordinates.shadow_root),
            "promotionRoot": str(coordinates.promotion_root),
            "requestDigest": _digest_file(coordinates.request_path),
            "workbookDigest": workbook_digest,
            "kernelIdentity": kernel_identity,
            "bindingIdentity": binding_identity,
            "environmentIdentity": environment_identity,
        },
        "packageGateObservations": gate_observations,
        "cuePyObservations": cue_py_observations,
        "cuePyWorkerProcess": cue_py_process,
        "cueCLIObservations": cli_observations,
        "semanticComparisons": comparisons,
        "lspObservation": lsp,
        "patchProjected": pair is not None,
        "patchApplied": False,
        "admissionComputed": False,
    }
    return result, None if pair is None else pair[0], None if pair is None else pair[1]


def _exception_result(error: BaseException, coordinates: Coordinates | None) -> dict[str, object]:
    category = error.category if isinstance(error, TransactionError) else "unexpected-exception"
    return {
        "schema": RESULT_SCHEMA,
        "transactionState": "exceptional",
        "finishedAt": _now(),
        "authority": {
            "classification": "emergency-control-plane-recovery",
            "status": "active",
            "issue": 105,
            "ordinaryImplementationUnitAdmissionClaimed": False,
            "selfAdmissionClaimed": False,
        },
        "failure": {
            "category": category,
            "type": type(error).__name__,
            "message": str(error)[:4000],
            "traceback": traceback.format_exc(limit=12)[:12000],
        },
        "transaction": None if coordinates is None else {
            "transientRoot": str(coordinates.transient_root),
            "shadowRoot": str(coordinates.shadow_root),
            "promotionRoot": str(coordinates.promotion_root),
        },
        "patchProjected": False,
        "patchApplied": False,
        "admissionComputed": False,
    }


def _coordinates(args: argparse.Namespace) -> Coordinates:
    repo = _absolute_existing(args.repo_root, directory=True, label="repository root")
    transient = _absolute_existing(args.transient_root, directory=True, label="transient root")
    request = _absolute_existing(args.request, directory=False, label="request")
    kernel = _absolute_existing(args.kernel_path, directory=False, label="kernel")
    cue_py = _absolute_existing(args.cue_py_root, directory=True, label="cue-py root")
    libcue = _absolute_existing(args.libcue_root, directory=True, label="libcue root")
    library = _absolute_existing(args.libcue_library, directory=False, label="libcue library")
    cue_bin = _absolute_existing(args.cue_bin, directory=False, label="cue binary")
    go_bin = _absolute_existing(args.go_bin, directory=False, label="go binary")
    uv_bin = _absolute_existing(args.uv_bin, directory=False, label="uv binary")
    shadow = Path(args.shadow_root)
    promotion = Path(args.promotion_root)
    if not shadow.is_absolute() or not promotion.is_absolute():
        raise TransactionError("invalid-coordinate", "shadow and promotion roots must be absolute")
    shadow = shadow.resolve(strict=False)
    promotion = promotion.resolve(strict=False)
    if shadow.parent != transient or shadow.name != "shadow":
        raise TransactionError("invalid-coordinate", "shadow root must be <transient-root>/shadow")
    if promotion == transient or promotion.is_relative_to(transient) or transient.is_relative_to(promotion):
        raise TransactionError("invalid-coordinate", "promotion root must be outside transient root")
    if any(path == repo or path.is_relative_to(repo) for path in (transient, promotion)):
        raise TransactionError("invalid-coordinate", "runtime roots must be outside live repository")
    external_inputs = (kernel, cue_py, libcue, library, cue_bin, go_bin, uv_bin)
    if any(path == transient or path.is_relative_to(transient) for path in external_inputs):
        raise TransactionError("invalid-coordinate", "pinned inputs and tools must be outside transient root")
    permitted_entries = {request} if request.parent == transient else set()
    if set(transient.iterdir()) != permitted_entries:
        raise TransactionError("invalid-coordinate", "transient root is not a dedicated execution root")
    return Coordinates(repo, transient, shadow, promotion, request, kernel, cue_py, libcue, library, cue_bin, go_bin, uv_bin)


def _worker(argv: Sequence[str]) -> int:
    request_path = Path(argv[0]).resolve(strict=True)
    raw = json.loads(request_path.read_bytes())
    if not isinstance(raw, dict) or set(raw) != {"schema", "cuePyRoot", "probes"} or raw["schema"] != WORKER_SCHEMA:
        raise TransactionError("cue-py-worker-protocol", "invalid worker request")
    cue_py_root = Path(raw["cuePyRoot"]).resolve(strict=True)
    sys.path.insert(0, str(cue_py_root))
    import cue  # type: ignore[import-not-found]  # Pinned, verified external binding.

    observations: list[dict[str, object]] = []
    for probe in raw["probes"]:
        stage = "compile"
        outcome: dict[str, object]
        diagnostic: str | None = None
        path: str | None = None
        try:
            context = cue.Context()
            value = context.compile(probe["source"], cue.FileName(probe["filename"]))
            error = value.error()
            if isinstance(error, cue.Err):
                outcome = {"state": "reject", "category": "bottom"}
                diagnostic = error.err
            else:
                if probe["unifySource"] is not None:
                    stage = "unify"
                    value = value.unify(context.compile(probe["unifySource"]))
                    unified_error = value.error()
                    if isinstance(unified_error, cue.Err):
                        raise TransactionError("bottom", unified_error.err)
                stage = "lookup"
                path = probe["expression"]
                value = value.lookup(path)
                looked_up_error = value.error()
                if isinstance(looked_up_error, cue.Err):
                    raise TransactionError("bottom", looked_up_error.err)
                if probe["schemaSource"] is not None:
                    stage = "schema"
                    value.check_schema(context.compile(probe["schemaSource"]))
                stage = "validate"
                value.validate()
                if value.incomplete_kind() == cue.Kind.BOTTOM:
                    outcome = {"state": "reject", "category": "bottom"}
                else:
                    stage = "project"
                    try:
                        projected = json.loads(value.to_json())
                        outcome = {
                            "state": "accept",
                            "category": "concrete",
                            "concreteValueDigest": _digest_bytes(_json_bytes(projected)),
                        }
                    except cue.Error as error:
                        outcome = {"state": "incomplete", "category": "incomplete"}
                        diagnostic = str(error)
        except TransactionError as error:
            outcome = {"state": "reject", "category": "bottom"}
            diagnostic = str(error)
        except cue.Error as error:
            outcome = {"state": "reject", "category": "bottom"}
            diagnostic = str(error)
        except Exception as error:
            outcome = {"state": "infrastructure-failure", "category": "cue-py-exception"}
            diagnostic = f"{type(error).__name__}: {error}"
        observation: dict[str, object] = {
            "probeID": probe["id"],
            "evaluator": "cue-py/libcue",
            "stage": stage,
            "semanticOutcome": outcome,
            "subject": probe["subject"],
        }
        if path is not None:
            observation["path"] = path
        if diagnostic is not None:
            observation["rawDiagnostic"] = diagnostic[:20000]
        observations.append(observation)
    print(json.dumps({"observations": observations}, sort_keys=True))
    return 0


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--cue-py-worker", nargs=1)
    for name in (
        "repo-root", "transient-root", "shadow-root", "promotion-root", "request",
        "kernel-path", "cue-py-root", "libcue-root", "libcue-library", "cue-bin",
        "go-bin", "uv-bin",
    ):
        parser.add_argument(f"--{name}")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.cue_py_worker is not None:
        return _worker(args.cue_py_worker)
    required = (
        "repo_root", "transient_root", "shadow_root", "promotion_root", "request",
        "kernel_path", "cue_py_root", "libcue_root", "libcue_library", "cue_bin",
        "go_bin", "uv_bin",
    )
    missing = [name.replace("_", "-") for name in required if getattr(args, name) is None]
    if missing:
        raise TransactionError("invalid-coordinate", f"missing arguments: {', '.join(missing)}")
    coordinates: Coordinates | None = None
    promoted = False
    result: dict[str, object]
    patch: bytes | None = None
    manifest: dict[str, object] | None = None
    try:
        coordinates = _coordinates(args)
        result, patch, manifest = _transaction(coordinates)
    except BaseException as error:
        result = _exception_result(error, coordinates)
    result_bytes = _pretty_json(result)
    if coordinates is None:
        print(result_bytes.decode(), file=sys.stderr, end="")
        return 2
    artifacts = {"bounded-result.json": result_bytes}
    if patch is not None and manifest is not None:
        artifacts["candidate.patch"] = patch
        artifacts["candidate-patch-manifest.json"] = _pretty_json(manifest)
    try:
        _atomic_promote(coordinates.promotion_root, artifacts)
        promoted = True
    except BaseException as error:
        fallback = _exception_result(error, coordinates)
        fallback["priorResult"] = result
        (coordinates.transient_root / "bounded-result.json").write_bytes(_pretty_json(fallback))
        print(json.dumps(fallback, sort_keys=True), file=sys.stderr)
        return 2
    finally:
        if promoted and coordinates.transient_root.exists():
            shutil.rmtree(coordinates.transient_root)
    print(json.dumps({"transactionState": result["transactionState"], "promotionRoot": str(coordinates.promotion_root)}, sort_keys=True))
    return 0 if result["transactionState"] == "accepted" else 1


@app.cell
def _():
    import marimo as mo
    mo.md(
        """
        # Emergency CUE transaction

        This workbook constructs and evaluates a candidate only in a disposable
        shadow workspace. LSP observations are advisory; cue-py/libcue probes and
        explicit module-aware CUE CLI gates remain visible as separate evidence.
        The workbook emits a bounded result and never applies its candidate patch.
        """
    )
    return (mo,)


@app.cell
def _(mo):
    mo.callout(
        "Run the CLI with explicit repository, transient, promotion, kernel, binding, module, package, and file coordinates.",
        kind="info",
    )
    return


if __name__ == "__main__":
    if len(sys.argv) == 1:
        app.run()
    else:
        raise SystemExit(main())
