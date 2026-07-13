"""Ephemeral, shadow-only CUE implementation transaction for issue 105.

The workbook observes and constructs a candidate in a disposable shadow copy.
It never writes to the live repository and never applies its generated patch.
"""

from __future__ import annotations

import argparse
import copy
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
import tarfile
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
REQUEST_SCHEMA = "factory.cue-emergency-transaction-request.v3"
PATCH_SCHEMA = "factory.cue-candidate-patch-manifest.v1"
WORKER_SCHEMA = "factory.cue-py-worker-request.v1"
WORKBOOK_PATH = Path("marimo/workflows/cue/cue_workbook.py")
REPOSITORY_ID = "fatb4f/factory"
CUE_PY_REPOSITORY = "https://github.com/cue-lang/cue-py"
CUE_PY_COMMIT = "81e6fb15247ed7050e5bd987db032f757e06c8f0"
LIBCUE_REPOSITORY = "https://github.com/cue-lang/libcue"
LIBCUE_COMMIT = "96d0572450429fa28d7a2345c04a8c47c85b47e4"
KERNEL_REPOSITORY = "https://github.com/fatb4f/lattice"
KERNEL_COMMIT = "4148dc1a2d1adfa0782e93e89ea402ce41c56d35"
KERNEL_RELATIVE_PATH = PurePosixPath("meta/kernel.cue")
KERNEL_BLOB = "f2570c424de2d4cb5b4603a265b7a6fc9dd7a0dd"
_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
_SELECTOR = re.compile(r"^[_#A-Za-z][_A-Za-z0-9]*(\.[_A-Za-z][_A-Za-z0-9]*)*$")
_DECLARATION = re.compile(r"^[#_]?[A-Za-z][A-Za-z0-9_]*$")
_PACKAGE_NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
_KERNEL_FORM_FOR_INTENT = {
    "closed-ingress": "#Resource",
    "exact-cardinality": "#StateKeySet",
    "preservation": "#NoWideningProof",
    "wiring": "#MakeClosedObligationState",
    "value": "#ClosedObligationState",
}
_REQUIRED_KERNEL_FORMS = frozenset((*_KERNEL_FORM_FOR_INTENT.values(), "#NegativeFixtureConflictProbe"))
_CUE_PY_OPERATIONS = (
    "compile",
    "lookup",
    "unify-concrete-input",
    "unify",
    "unify-schema-constraint",
    "validate",
    "project",
)


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
class CandidateIntent:
    path: PurePosixPath
    operation: str
    package: str | None
    selected_kernel_forms: tuple[str, ...]
    declarations: tuple[Mapping[str, object], ...]


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
    module_root: PurePosixPath
    package: str
    files: tuple[PurePosixPath, ...]
    expression: str
    expected_state: str
    concrete_input: object
    unify_intent: object | None
    schema_intent: object | None
    selected_kernel_forms: tuple[str, ...]
    build_options: Mapping[str, object]


@dataclasses.dataclass(frozen=True)
class Request:
    base_revision: str
    allowed_paths: tuple[PurePosixPath, ...]
    candidates: tuple[CandidateIntent, ...]
    gates: tuple[PackageGate, ...]
    probes: tuple[Probe, ...]


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
    checkout_root = Path(_git(root, "rev-parse", "--show-toplevel")).resolve(strict=True)
    if checkout_root != root.resolve(strict=True):
        raise TransactionError("binding-identity-mismatch", f"{label} coordinate is not its checkout root")
    if _git(root, "rev-parse", "HEAD") != commit:
        raise TransactionError("binding-identity-mismatch", f"{label} commit mismatch")
    if _git(root, "status", "--porcelain=v1", "--untracked-files=all"):
        raise TransactionError("binding-identity-mismatch", f"{label} checkout is dirty")


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


def _kernel_form_names(path: Path, cue_bin: Path) -> frozenset[str]:
    """Resolve the selected forms from the verified kernel, not a name whitelist."""
    available = {
        form
        for form in _REQUIRED_KERNEL_FORMS
        if _run((str(cue_bin), "eval", str(path), "-e", form), cwd=path.parent)["exitCode"] == 0
    }
    missing = sorted(_REQUIRED_KERNEL_FORMS - available)
    if missing:
        raise TransactionError(
            "kernel-form-unavailable",
            f"verified kernel does not export required forms: {', '.join(missing)}",
        )
    return frozenset(available)


def _selected_kernel_forms(value: object, available: frozenset[str], label: str) -> tuple[str, ...]:
    if not isinstance(value, list) or not value or not all(isinstance(item, str) for item in value):
        raise TransactionError("invalid-request", f"{label} must select kernel forms")
    selected = tuple(value)
    if len(set(selected)) != len(selected) or not set(selected).issubset(available):
        raise TransactionError("invalid-request", f"{label} contains an unavailable kernel form")
    return selected


def _cue_label(value: object, label: str) -> str:
    if not isinstance(value, str) or not _DECLARATION.fullmatch(value):
        raise TransactionError("invalid-request", f"invalid {label}")
    if value.startswith(("_factory", "#FactoryKernel")):
        raise TransactionError("invalid-request", f"{label} uses a reserved workbook prefix")
    return value


def _cue_expr(value: object) -> str:
    if value is None or isinstance(value, (bool, int, float, str)):
        try:
            return json.dumps(value, ensure_ascii=False, allow_nan=False)
        except ValueError as error:
            raise TransactionError("invalid-request", "CUE literal is not finite") from error
    if isinstance(value, list):
        return "[" + ", ".join(_cue_expr(item) for item in value) + "]"
    if not isinstance(value, dict):
        raise TransactionError("invalid-request", "CUE intent contains an unsupported value")
    special = [key for key in value if isinstance(key, str) and key.startswith("$")]
    if special:
        if len(value) != 1:
            raise TransactionError("invalid-request", "CUE expression operator must be the sole field")
        operator = special[0]
        operand = value[operator]
        if operator == "$ref":
            if not isinstance(operand, str) or not _SELECTOR.fullmatch(operand):
                raise TransactionError("invalid-request", "invalid CUE reference intent")
            return operand
        if operator in {"$and", "$or"}:
            if not isinstance(operand, list) or len(operand) < 2:
                raise TransactionError("invalid-request", f"{operator} requires at least two operands")
            separator = " & " if operator == "$and" else " | "
            return "(" + separator.join(_cue_expr(item) for item in operand) + ")"
        if operator == "$eq":
            if not isinstance(operand, list) or len(operand) != 2:
                raise TransactionError("invalid-request", "$eq requires two operands")
            return f"({_cue_expr(operand[0])} == {_cue_expr(operand[1])})"
        if operator == "$len":
            return f"len({_cue_expr(operand)})"
        if operator == "$close":
            if not isinstance(operand, dict):
                raise TransactionError("invalid-request", "$close requires a struct")
            return f"close({_cue_expr(operand)})"
        raise TransactionError("invalid-request", f"unsupported CUE expression operator: {operator}")
    fields: list[str] = []
    for key, item in value.items():
        label = _cue_label(key, "CUE field")
        fields.append(f"{label}: {_cue_expr(item)}")
    return "{" + ", ".join(fields) + "}"


_RESOURCE_PATTERN_PROJECTION = r'''#FactoryKernelResource: close({
	id:         string & !="" & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
	path:       string & !=""
	role:       string & !=""
	visibility: "public" | "internal" | "restricted" | *"internal"
})'''

_KERNEL_PATTERN_PROJECTION = r'''#FactoryKernelResource: close({
	id:         string & !="" & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
	path:       string & !=""
	role:       string & !=""
	visibility: "public" | "internal" | "restricted" | *"internal"
})

#FactoryKernelRefSet: {[string]: true}

#FactoryKernelOperation: close({
	id:                string & !="" & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
	kind:              string & !=""
	description:       string & !=""
	reads:             #FactoryKernelRefSet
	writes:            #FactoryKernelRefSet
	creates:           #FactoryKernelRefSet
	requiresGates:     #FactoryKernelRefSet
	requiresWitnesses: #FactoryKernelRefSet
})

#FactoryKernelGate: close({
	id:          string & !="" & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
	description: string & !=""
	required:    bool | *true
})

#FactoryKernelWitness: #FactoryKernelGate

#FactoryKernelClosedObligationState: close({
	id: string & !="" & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
	resources: [ID=string]: #FactoryKernelResource & {id: ID}
	operations: [ID=string]: #FactoryKernelOperation & {id: ID}
	gates: [ID=string]: #FactoryKernelGate & {id: ID}
	witnesses: [ID=string]: #FactoryKernelWitness & {id: ID}

	_operationRefProof: {
		for operationID, operation in operations {
			for resourceID, _ in operation.reads {
				"\(operationID)-reads-\(resourceID)-exists": list.Contains(list.SortStrings([for key, _ in resources {key}]), resourceID) & true
			}
			for resourceID, _ in operation.writes {
				"\(operationID)-writes-\(resourceID)-exists": list.Contains(list.SortStrings([for key, _ in resources {key}]), resourceID) & true
			}
			for resourceID, _ in operation.creates {
				"\(operationID)-creates-\(resourceID)-exists": list.Contains(list.SortStrings([for key, _ in resources {key}]), resourceID) & true
				"\(operationID)-creates-\(resourceID)-role": resources[resourceID] & {role: "generated-output"}
			}
			for gateID, _ in operation.requiresGates {
				"\(operationID)-requires-gate-\(gateID)-exists": list.Contains(list.SortStrings([for key, _ in gates {key}]), gateID) & true
			}
			for witnessID, _ in operation.requiresWitnesses {
				"\(operationID)-requires-witness-\(witnessID)-exists": list.Contains(list.SortStrings([for key, _ in witnesses {key}]), witnessID) & true
			}
		}
	}
})

#FactoryKernelStateKeySet: close({
	state:      #FactoryKernelClosedObligationState
	resources:  list.SortStrings([for key, _ in state.resources {key}])
	operations: list.SortStrings([for key, _ in state.operations {key}])
	gates:      list.SortStrings([for key, _ in state.gates {key}])
	witnesses:  list.SortStrings([for key, _ in state.witnesses {key}])
})

#FactoryKernelOperationRefKeySet: close({
	operation:        #FactoryKernelOperation
	reads:             list.SortStrings([for key, _ in operation.reads {key}])
	writes:            list.SortStrings([for key, _ in operation.writes {key}])
	creates:           list.SortStrings([for key, _ in operation.creates {key}])
	requiresGates:     list.SortStrings([for key, _ in operation.requiresGates {key}])
	requiresWitnesses: list.SortStrings([for key, _ in operation.requiresWitnesses {key}])
})

#FactoryKernelNoWideningProof: close({
	authority: #FactoryKernelClosedObligationState
	target:    #FactoryKernelClosedObligationState
	let authorityKeys = (#FactoryKernelStateKeySet & {state: authority})
	let targetKeys = (#FactoryKernelStateKeySet & {state: target})
	keyEquality: {
		resources:  authorityKeys.resources & targetKeys.resources
		operations: authorityKeys.operations & targetKeys.operations
		gates:      authorityKeys.gates & targetKeys.gates
		witnesses:  authorityKeys.witnesses & targetKeys.witnesses
	}
	operationRefEquality: {
		for operationID, _ in authority.operations {
			"\(operationID)": {
				let authorityRefs = (#FactoryKernelOperationRefKeySet & {operation: authority.operations[operationID]})
				let targetRefs = (#FactoryKernelOperationRefKeySet & {operation: target.operations[operationID]})
				reads:             authorityRefs.reads & targetRefs.reads
				writes:            authorityRefs.writes & targetRefs.writes
				creates:           authorityRefs.creates & targetRefs.creates
				requiresGates:     authorityRefs.requiresGates & targetRefs.requiresGates
				requiresWitnesses: authorityRefs.requiresWitnesses & targetRefs.requiresWitnesses
			}
		}
	}
	compatibility: authority & target
})

#FactoryKernelMakeClosedObligationState: {
	in: {
		id: string
		resources: [string]: {...}
		operations: [string]: {...}
		gates: [string]: {...}
		witnesses: [string]: {...}
	}
	out: #FactoryKernelClosedObligationState & {
		id: in.id
		resources: {for resourceID, resource in in.resources {"\(resourceID)": resource & {id: resourceID}}}
		operations: {for operationID, operation in in.operations {"\(operationID)": operation & {id: operationID}}}
		gates: {for gateID, gate in in.gates {"\(gateID)": gate & {id: gateID}}}
		witnesses: {for witnessID, witness in in.witnesses {"\(witnessID)": witness & {id: witnessID}}}
	}
}'''


def _render_declaration(declaration: Mapping[str, object], selected: frozenset[str]) -> str:
    form = declaration.get("form")
    required = _KERNEL_FORM_FOR_INTENT.get(str(form))
    if required is None or required not in selected:
        raise TransactionError("invalid-request", f"declaration form {form!r} lacks its selected kernel form")
    name = _cue_label(declaration.get("name"), "declaration name")
    if form == "closed-ingress":
        if set(declaration) != {"form", "name", "fields"} or not isinstance(declaration["fields"], dict):
            raise TransactionError("invalid-request", "invalid closed-ingress intent")
        return f"{name}: #FactoryKernelResource & {_cue_expr(declaration['fields'])}"
    if form == "exact-cardinality":
        if set(declaration) != {"form", "name", "collection", "count"}:
            raise TransactionError("invalid-request", "invalid exact-cardinality intent")
        count = declaration["count"]
        if not isinstance(count, int) or isinstance(count, bool) or count < 0:
            raise TransactionError("invalid-request", "exact cardinality must be a nonnegative integer")
        collection = _cue_expr(declaration["collection"])
        return (
            f"let _factoryCollection{name.lstrip('#_')} = {collection}\n"
            f"{name}: close({{\n"
            f"\tkeys: list.SortStrings([for key, _ in _factoryCollection{name.lstrip('#_')} {{key}}])\n"
            f"\tcount: len(keys) & {count}\n"
            f"}})"
        )
    if form == "preservation":
        if set(declaration) != {"form", "name", "authority", "target"}:
            raise TransactionError("invalid-request", "invalid preservation intent")
        return (
            f"{name}: #FactoryKernelNoWideningProof & {{\n"
            f"\tauthority: {_cue_expr(declaration['authority'])}\n"
            f"\ttarget: {_cue_expr(declaration['target'])}\n"
            f"}}"
        )
    if form == "wiring":
        if set(declaration) != {"form", "name", "target"}:
            raise TransactionError("invalid-request", "invalid wiring intent")
        return (
            f"{name}: (#FactoryKernelMakeClosedObligationState & "
            f"{{\"in\": {_cue_expr(declaration['target'])}}}).out"
        )
    if form == "value":
        if set(declaration) != {"form", "name", "value"}:
            raise TransactionError("invalid-request", "invalid value intent")
        return f"{name}: #FactoryKernelClosedObligationState & {_cue_expr(declaration['value'])}"
    raise TransactionError("invalid-request", "unsupported declaration intent")


def _candidate_source(candidate: CandidateIntent) -> str:
    if candidate.operation != "construct" or candidate.package is None:
        raise TransactionError("invalid-request", "cannot render a deletion intent")
    selected = frozenset(candidate.selected_kernel_forms)
    declarations = "\n\n".join(_render_declaration(item, selected) for item in candidate.declarations)
    resource_only = selected == {"#Resource"}
    imports = "" if resource_only else 'import "list"\n\n'
    projection = _RESOURCE_PATTERN_PROJECTION if resource_only else _KERNEL_PATTERN_PROJECTION
    return f"package {candidate.package}\n\n{imports}{projection}\n\n{declarations}\n"


def _load_request(path: Path, kernel_path: Path, cue_bin: Path) -> Request:
    try:
        raw = json.loads(path.read_bytes())
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise TransactionError("invalid-request", "request is not valid JSON") from error
    if not isinstance(raw, dict) or set(raw) != {
        "schema",
        "repository",
        "baseRevision",
        "allowedPaths",
        "candidateIntents",
        "packageGates",
        "probes",
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
    available_forms = _kernel_form_names(kernel_path, cue_bin)
    if not isinstance(raw["candidateIntents"], list) or not raw["candidateIntents"]:
        raise TransactionError("invalid-request", "candidateIntents must be nonempty")
    candidates: list[CandidateIntent] = []
    for item in raw["candidateIntents"]:
        if not isinstance(item, dict) or set(item) != {"path", "operation", "package", "selectedKernelForms", "declarations"}:
            raise TransactionError("invalid-request", "invalid candidate intent")
        candidate_path = _safe_relative(item["path"], "candidate path")
        if candidate_path not in allowed or item["operation"] not in {"construct", "delete"}:
            raise TransactionError("invalid-request", "candidate intent exceeds allowance")
        selected = _selected_kernel_forms(item["selectedKernelForms"], available_forms, "candidate intent")
        declarations = item["declarations"]
        if not isinstance(declarations, list) or not all(isinstance(value, dict) for value in declarations):
            raise TransactionError("invalid-request", "candidate declarations must be structured intents")
        package = item["package"]
        if item["operation"] == "construct":
            if not isinstance(package, str) or not _PACKAGE_NAME.fullmatch(package) or not declarations:
                raise TransactionError("invalid-request", "constructed candidate requires package and declarations")
        elif package is not None or declarations:
            raise TransactionError("invalid-request", "deletion intent cannot contain source construction fields")
        candidate = CandidateIntent(candidate_path, item["operation"], package, selected, tuple(declarations))
        if candidate.operation == "construct":
            names = [str(value.get("name")) for value in declarations]
            if len(set(names)) != len(names):
                raise TransactionError("invalid-request", "candidate declaration names must be unique")
            _candidate_source(candidate)
        candidates.append(candidate)
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
        required = {"id", "polarity", "moduleRoot", "package", "files", "expression", "expectedState",
                    "concreteInput", "unifyIntent", "schemaIntent", "selectedKernelForms", "buildOptions"}
        if not isinstance(item, dict) or set(item) != required:
            raise TransactionError("invalid-request", "invalid probe boundary")
        if not isinstance(item["id"], str) or not _ID.fullmatch(item["id"]):
            raise TransactionError("invalid-request", "invalid probe id")
        if item["polarity"] not in {"positive", "negative", "adversarial"}:
            raise TransactionError("invalid-request", "invalid probe polarity")
        if item["expectedState"] not in {"accept", "reject", "incomplete"}:
            raise TransactionError("invalid-request", "invalid expected probe state")
        if not isinstance(item["package"], str) or not _PACKAGE_NAME.fullmatch(item["package"]):
            raise TransactionError("invalid-request", "invalid probe package")
        if not isinstance(item["files"], list) or len(item["files"]) != 1:
            raise TransactionError(
                "invalid-request",
                "equivalent value-level probes require exactly one declared source file",
            )
        files = tuple(_safe_relative(value, "probe file") for value in item["files"])
        if len(set(files)) != len(files):
            raise TransactionError("invalid-request", "probe file set contains duplicates")
        if not isinstance(item["expression"], str) or not item["expression"]:
            raise TransactionError("invalid-request", "invalid probe expression")
        if not _SELECTOR.fullmatch(item["expression"]):
            raise TransactionError("invalid-request", "probe expression must be a CUE selector path")
        for key in ("unifyIntent", "schemaIntent"):
            if item[key] is not None:
                _cue_expr(item[key])
        selected = _selected_kernel_forms(item["selectedKernelForms"], available_forms, "probe")
        if "#ClosedObligationState" not in selected:
            raise TransactionError("invalid-request", "probe construction requires the selected closed-ingress kernel form")
        if item["polarity"] in {"negative", "adversarial"} and "#NegativeFixtureConflictProbe" not in selected:
            raise TransactionError("invalid-request", "destructive probe construction requires the selected conflict-probe kernel form")
        build_options = item["buildOptions"]
        if not isinstance(build_options, dict) or set(build_options) != {"tags", "allErrors"}:
            raise TransactionError("invalid-request", "invalid probe build options")
        if build_options != {"tags": [], "allErrors": False}:
            raise TransactionError("invalid-request", "initial equivalent probes require the exact supported build options")
        probes.append(
            Probe(
                item["id"], item["polarity"], _safe_relative(item["moduleRoot"], "probe module root"),
                item["package"], files, item["expression"], item["expectedState"], item["concreteInput"],
                item["unifyIntent"], item["schemaIntent"], selected, build_options,
            )
        )
    if len({item.id for item in probes}) != len(probes):
        raise TransactionError("invalid-request", "duplicate probe id")
    if {item.polarity for item in probes}.isdisjoint({"positive"}) or {item.polarity for item in probes}.isdisjoint({"negative"}):
        raise TransactionError("missing-probes", "positive and negative probes are required")
    return Request(raw["baseRevision"], allowed, tuple(candidates), tuple(gates), tuple(probes))


def _tree_digest(root: Path) -> str:
    digest = hashlib.sha256()
    ignored = {".git", ".venv", "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"}
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root)
        if any(part in ignored for part in relative.parts) or (not path.is_file() and not path.is_symlink()):
            continue
        digest.update(relative.as_posix().encode() + b"\0")
        if path.is_symlink():
            digest.update(b"symlink\0" + os.readlink(path).encode())
        elif path.is_file():
            digest.update(b"file\0" + hashlib.sha256(path.read_bytes()).digest())
    return f"sha256:{digest.hexdigest()}"


def _copy_shadow(repo_root: Path, shadow_root: Path, base_revision: str) -> None:
    if shadow_root.exists():
        raise TransactionError("shadow-exists", "shadow root must not exist")
    archive = subprocess.run(
        ["git", "-C", str(repo_root), "archive", "--format=tar", base_revision],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if archive.returncode != 0:
        raise TransactionError("base-read-failure", archive.stderr.decode("utf-8", "replace")[:2000])
    shadow_root.mkdir()
    archive_path = shadow_root.parent / "base-revision.tar"
    archive_path.write_bytes(archive.stdout)
    try:
        with tarfile.open(archive_path, mode="r:") as stream:
            for member in stream.getmembers():
                member_path = PurePosixPath(member.name)
                if member_path.is_absolute() or ".." in member_path.parts or member.issym() or member.islnk():
                    raise TransactionError("unsafe-base-archive", "base revision contains an unsafe archive member")
            stream.extractall(shadow_root, filter="data")
    finally:
        archive_path.unlink(missing_ok=True)


def _apply_candidates(shadow: Path, request: Request) -> None:
    for candidate in request.candidates:
        path = shadow.joinpath(*candidate.path.parts)
        resolved = path.resolve(strict=False)
        if not resolved.is_relative_to(shadow):
            raise TransactionError("path-escape", f"candidate path escapes: {candidate.path}")
        if candidate.operation == "delete":
            if path.exists():
                if not path.is_file() or path.is_symlink():
                    raise TransactionError("unsafe-candidate", f"cannot remove: {candidate.path}")
                path.unlink()
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(_candidate_source(candidate), encoding="utf-8", newline="")


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


def _validate_probe_source(source: str, package: str, label: str) -> str:
    match = re.match(r"\s*package\s+([A-Za-z_][A-Za-z0-9_]*)\s*\n", source)
    if match is None or match.group(1) != package:
        raise TransactionError("invalid-probe-file", f"{label} does not declare package {package}")
    if re.search(r"(?m)^\s*import(?:\s|\()", source[match.end():]):
        raise TransactionError("unsupported-import-context", f"{label} uses imports not supported by equivalent cue-py probes")
    return source


def _concrete_value_source(value: object) -> str:
    rendered = _cue_expr(value)
    return f"close({rendered})" if isinstance(value, dict) else rendered


def _concrete_input_source(probe: Probe) -> str:
    return _concrete_value_source(probe.concrete_input)


def _probe_subject_expression_values(
    expression: str,
    concrete_input: object,
    unify_intent: object | None,
    schema_intent: object | None,
) -> str:
    rendered_input = _concrete_value_source(concrete_input)
    subject = f"({expression}) & {rendered_input}"
    if unify_intent is not None:
        subject = f"({subject}) & ({_cue_expr(unify_intent)})"
    if schema_intent is not None:
        subject = f"({subject}) & ({_cue_expr(schema_intent)})"
    return subject


def _probe_subject_expression(probe: Probe) -> str:
    return _probe_subject_expression_values(
        probe.expression,
        probe.concrete_input,
        probe.unify_intent,
        probe.schema_intent,
    )


def _probe_materialization(
    probe: Probe,
    shadow: Path,
    binding: Mapping[str, object],
) -> dict[str, object]:
    module = shadow.joinpath(*probe.module_root.parts).resolve(strict=True)
    if not module.is_relative_to(shadow) or not (module / "cue.mod/module.cue").is_file():
        raise TransactionError("invalid-module-coordinate", f"invalid probe module root: {probe.id}")
    relative = probe.files[0]
    path = module.joinpath(*relative.parts).resolve(strict=True)
    if not path.is_relative_to(module) or not path.is_file() or path.is_symlink():
        raise TransactionError("invalid-file-coordinate", f"invalid probe file: {relative}")
    semantic_source = _validate_probe_source(
        path.read_text(encoding="utf-8"), probe.package, relative.as_posix()
    )
    file_digests = {relative.as_posix(): _digest_bytes(semantic_source.encode())}
    effective_expression = _probe_subject_expression(probe)
    components: dict[str, object] = {
        "moduleRoot": probe.module_root.as_posix(),
        "package": probe.package,
        "files": [relative.as_posix()],
        "fileDigests": file_digests,
        "semanticSourceDigest": _digest_bytes(semantic_source.encode()),
        "effectiveExpression": effective_expression,
        "effectiveExpressionDigest": _digest_bytes(effective_expression.encode()),
        "selectedExpression": probe.expression,
        "buildOptions": dict(probe.build_options),
        "concreteInputDigest": _digest_bytes(_json_bytes(probe.concrete_input)),
        "unifyIntentDigest": None if probe.unify_intent is None else _digest_bytes(_json_bytes(probe.unify_intent)),
        "schemaIntentDigest": None if probe.schema_intent is None else _digest_bytes(_json_bytes(probe.schema_intent)),
        "selectedKernelForms": list(probe.selected_kernel_forms),
        "importContext": "none-in-initial-equivalent-probe",
        "cueCLIContext": {
            "version": binding["cueCLIVersion"],
            "binaryDigest": binding["cueBinaryDigest"],
            "operations": ["eval", "export"],
            "options": ["-p", probe.package, "-e", effective_expression, relative.as_posix()],
        },
        "cuePyContext": {
            "cuePyCommit": binding["cuePyCommit"],
            "libcueCommit": binding["libcueCommit"],
            "libcueSharedLibraryDigest": binding["libcueSharedLibraryDigest"],
            "operations": list(_CUE_PY_OPERATIONS),
        },
    }
    return {
        "module": module,
        "sourceRelative": relative.as_posix(),
        "semanticSource": semantic_source,
        "effectiveExpression": effective_expression,
        "subjectComponents": components,
        "subject": {"digest": _digest_bytes(_json_bytes(components)), "components": components},
    }


def _cue_py_worker_request(
    probes: Sequence[Probe],
    materializations: Mapping[str, Mapping[str, object]],
    cue_py_root: Path,
) -> dict[str, object]:
    return {
        "schema": WORKER_SCHEMA,
        "cuePyRoot": str(cue_py_root),
        "probes": [
            {
                "id": probe.id,
                "source": materializations[probe.id]["semanticSource"],
                "filename": materializations[probe.id]["sourceRelative"],
                "expression": probe.expression,
                "concreteInput": probe.concrete_input,
                "unifyIntent": probe.unify_intent,
                "schemaIntent": probe.schema_intent,
                "subjectComponents": materializations[probe.id]["subjectComponents"],
            }
            for probe in probes
        ],
    }


def _run_cue_py(
    probes: Sequence[Probe],
    materializations: Mapping[str, Mapping[str, object]],
    coordinates: Coordinates,
    workbook: Path,
) -> tuple[list[dict[str, object]], dict[str, object]]:
    request_path = coordinates.transient_root / "cue-py-worker-request.json"
    request_path.write_bytes(_pretty_json(_cue_py_worker_request(probes, materializations, coordinates.cue_py_root)))
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
                "subject": materializations[probe.id]["subject"],
                "rawDiagnostic": str(result["stderr"]),
            }
            for probe in probes
        ]
        return observations, result
    try:
        payload = json.loads(str(result["stdout"]))
    except json.JSONDecodeError:
        payload = None
    observations = payload.get("observations") if isinstance(payload, dict) else None
    valid = isinstance(observations, list) and len(observations) == len(probes)
    if valid:
        by_id = {str(item.get("probeID")): item for item in observations if isinstance(item, dict)}
        valid = set(by_id) == {probe.id for probe in probes} and len(by_id) == len(observations)
        valid = valid and all(
            by_id[probe.id].get("subject") == materializations[probe.id]["subject"]
            and isinstance(by_id[probe.id].get("semanticOutcome"), dict)
            and by_id[probe.id]["semanticOutcome"].get("state") in {item.value for item in Outcome}  # type: ignore[index]
            for probe in probes
        )
    if not valid:
        return ([
            {
                "probeID": probe.id,
                "evaluator": "cue-py/libcue",
                "stage": "compile",
                "semanticOutcome": {"state": "infrastructure-failure", "category": "worker-protocol"},
                "subject": materializations[probe.id]["subject"],
                "rawDiagnostic": "cue-py worker response did not match the closed protocol",
            }
            for probe in probes
        ], result)
    return observations, result


def _cli_probe(probe: Probe, materialization: Mapping[str, object], cue_bin: Path) -> dict[str, object]:
    module = materialization["module"]
    if not isinstance(module, Path):
        raise TransactionError("invalid-probe-materialization", "probe module was not materialized")
    filename = str(materialization["sourceRelative"])
    actual_source = (module / filename).read_text(encoding="utf-8")
    effective_expression = materialization["effectiveExpression"]
    if not isinstance(effective_expression, str):
        raise TransactionError("invalid-probe-materialization", "effective expression is invalid")
    components = materialization["subjectComponents"]
    if not isinstance(components, dict):
        raise TransactionError("invalid-probe-materialization", "semantic subject components are invalid")
    if _digest_bytes(actual_source.encode()) != components["semanticSourceDigest"]:
        raise TransactionError("probe-subject-mismatch", "CLI source changed after subject construction")
    if _digest_bytes(effective_expression.encode()) != components["effectiveExpressionDigest"]:
        raise TransactionError("probe-subject-mismatch", "CLI operation changed after subject construction")
    current_file_digests = {
        relative.as_posix(): _digest_file(module.joinpath(*relative.parts)) for relative in probe.files
    }
    if current_file_digests != components["fileDigests"]:
        raise TransactionError("probe-subject-mismatch", "CLI file set changed after subject construction")
    common = ("-p", probe.package, "-e", effective_expression, filename)
    eval_result = _run((str(cue_bin), "eval", *common), cwd=module)
    if eval_result["exitCode"] is None:
        outcome = {"state": "infrastructure-failure", "category": "cli-unavailable"}
        stage = "compile"
        concrete_result: dict[str, object] | None = None
    elif eval_result["exitCode"] != 0 or re.search(r"(?m)^\s*_\|_", str(eval_result["stdout"])):
        outcome = {"state": "reject", "category": "bottom"}
        stage = "validate"
        concrete_result = None
    else:
        concrete_result = _run((str(cue_bin), "export", "--out", "json", *common), cwd=module)
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
        "subject": {"digest": _digest_bytes(_json_bytes(components)), "components": components},
        "sourceDigest": _digest_bytes(actual_source.encode()),
        "effectiveExpressionDigest": _digest_bytes(effective_expression.encode()),
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
        left_subject, right_subject = left.get("subject"), right.get("subject")
        equivalent = (
            isinstance(left_subject, dict)
            and isinstance(right_subject, dict)
            and left_subject.get("digest") == right_subject.get("digest")
            and left_subject.get("components") == right_subject.get("components")
            and left_subject.get("digest") == _digest_bytes(_json_bytes(left_subject.get("components")))
            and right_subject.get("digest") == _digest_bytes(_json_bytes(right_subject.get("components")))
        )
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
                "semanticSubjectDigest": left_subject.get("digest") if equivalent else None,
            }
        )
    return comparisons


def _lsp_observation(cue_bin: Path, shadow: Path, files: Sequence[Path]) -> dict[str, object]:
    argv = (str(cue_bin), "lsp")
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
        before = _base_file_bytes(repo, base_revision, relative)
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
        before, after = _base_file_bytes(repo, base_revision, relative), _file_bytes(shadow, relative)
        expected_before = "absent" if before is None else _digest_bytes(before)
        expected_after = "absent" if after is None else _digest_bytes(after)
        if preimages.get(value) != expected_before or postimages.get(value) != expected_after:
            raise TransactionError("unsafe-patch", "patch preimage or postimage mismatch")
    verification = shadow.parent / "patch-verification"
    if verification.exists():
        raise TransactionError("unsafe-patch", "patch verification root already exists")
    _copy_shadow(repo, verification, base_revision)
    try:
        before_files = {
            path.relative_to(verification).as_posix(): _digest_file(path)
            for path in verification.rglob("*") if path.is_file() and not path.is_symlink()
        }
        check = _run(("git", "apply", "--check", "--whitespace=nowarn", "-"), cwd=verification, input_bytes=patch)
        if check["exitCode"] != 0:
            raise TransactionError("unsafe-patch", f"generated patch is not applicable: {check['stderr']}")
        applied = _run(("git", "apply", "--whitespace=nowarn", "-"), cwd=verification, input_bytes=patch)
        if applied["exitCode"] != 0:
            raise TransactionError("unsafe-patch", f"generated patch failed to apply: {applied['stderr']}")
        after_files = {
            path.relative_to(verification).as_posix(): _digest_file(path)
            for path in verification.rglob("*") if path.is_file() and not path.is_symlink()
        }
        applied_changes = {
            path for path in set(before_files) | set(after_files)
            if before_files.get(path) != after_files.get(path)
        }
        if applied_changes != set(changed):
            raise TransactionError("unsafe-patch", "applied patch path set differs from manifest")
        for value in changed:
            actual = _file_bytes(verification, _safe_relative(value, "verified patch path"))
            actual_digest = "absent" if actual is None else _digest_bytes(actual)
            if postimages.get(value) != actual_digest:
                raise TransactionError("unsafe-patch", "applied patch does not produce declared postimage")
    finally:
        shutil.rmtree(verification, ignore_errors=True)


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
    cue_version = _run((str(coordinates.cue_bin), "version"), cwd=coordinates.repo_root)
    uv_version = _run((str(coordinates.uv_bin), "--version"), cwd=coordinates.repo_root)
    if any(item["exitCode"] != 0 for item in (go_version, cue_version, uv_version)):
        raise TransactionError("binding-identity-mismatch", "tool version identity unavailable")
    try:
        cffi_version = importlib.metadata.version("cffi")
    except importlib.metadata.PackageNotFoundError as error:
        raise TransactionError("binding-identity-mismatch", "cffi is unavailable") from error
    observed = {
        "cuePyCommit": CUE_PY_COMMIT,
        "libcueCommit": LIBCUE_COMMIT,
        "libcueSharedLibraryDigest": _digest_file(coordinates.libcue_library),
        "cffiVersion": cffi_version,
        "goVersion": str(go_version["stdout"]).strip(),
        "goBinaryDigest": _digest_file(coordinates.go_bin),
        "pythonVersion": platform.python_version(),
        "platformIdentity": platform.platform(),
        "cueCLIVersion": str(cue_version["stdout"]).strip(),
        "cueBinaryDigest": _digest_file(coordinates.cue_bin),
        "uvVersion": str(uv_version["stdout"]).strip(),
        "uvBinaryDigest": _digest_file(coordinates.uv_bin),
    }
    return {
        **observed,
        "identitySource": {
            "cuePyCommit": "issue-105",
            "libcueCommit": "issue-105",
            "pythonEnvironment": "repository-pyproject-and-uv-lock",
            "remainingFields": "observed-from-verified-invocation-coordinates",
        },
        "callerExpectationAccepted": False,
    }


def _environment_identity(coordinates: Coordinates, base_revision: str) -> dict[str, object]:
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
    for name in ("pyproject.toml", "uv.lock"):
        relative = PurePosixPath(name)
        if _file_bytes(coordinates.repo_root, relative) != _base_file_bytes(coordinates.repo_root, base_revision, relative):
            raise TransactionError("project-identity-mismatch", f"{name} differs from the base revision")
    lock_check = _run((str(coordinates.uv_bin), "lock", "--check", "--project", str(coordinates.repo_root)), cwd=coordinates.repo_root)
    if lock_check["exitCode"] != 0:
        raise TransactionError("lock-check-failure", str(lock_check["stderr"]))
    exact_check = _run(
        (str(coordinates.uv_bin), "sync", "--check", "--locked", "--project", str(coordinates.repo_root)),
        cwd=coordinates.repo_root,
        env={**os.environ, "UV_PROJECT_ENVIRONMENT": str(environment_path.resolve())},
    )
    if exact_check["exitCode"] != 0:
        raise TransactionError("exact-sync-failure", str(exact_check["stderr"]))
    return {
        "uvProjectEnvironment": str(environment_path.resolve()),
        "pythonExecutable": str(Path(sys.executable).resolve()),
        "projectDigest": _digest_file(coordinates.repo_root / "pyproject.toml"),
        "lockDigest": _digest_file(coordinates.repo_root / "uv.lock"),
        "lockCheck": lock_check,
        "exactSyncCheck": exact_check,
        "locked": True,
        "exact": True,
    }


def _initial_result(coordinates: Coordinates) -> dict[str, object]:
    return {
        "schema": RESULT_SCHEMA,
        "transactionState": "incomplete",
        "startedAt": _now(),
        "authority": {
            "classification": "emergency-control-plane-recovery",
            "status": "active",
            "issue": 105,
            "blockedBy104": False,
            "ordinaryImplementationUnitAdmissionClaimed": False,
            "selfAdmissionClaimed": False,
        },
        "transaction": {
            "transientRoot": str(coordinates.transient_root),
            "shadowRoot": str(coordinates.shadow_root),
            "promotionRoot": str(coordinates.promotion_root),
        },
        "candidateConstructionObservations": [],
        "packageGateObservations": [],
        "cuePyObservations": [],
        "cueCLIObservations": [],
        "semanticComparisons": [],
        "patchProjectability": {"state": "not-evaluated"},
        "patchProjected": False,
        "patchApplied": False,
        "admissionComputed": False,
    }


def _transaction(
    coordinates: Coordinates,
    result: dict[str, object],
    projected: dict[str, object],
) -> dict[str, object]:
    workbook = coordinates.repo_root / WORKBOOK_PATH
    workbook_digest = _digest_file(workbook)
    kernel_identity = _verify_kernel(coordinates.kernel_path)
    request = _load_request(coordinates.request_path, coordinates.kernel_path, coordinates.cue_bin)
    base_revision = _git(coordinates.repo_root, "rev-parse", "HEAD")
    if request.base_revision != base_revision:
        raise TransactionError("base-revision-mismatch", "request base revision does not match repository")
    binding_identity = _binding_identity(coordinates)
    environment_identity = _environment_identity(coordinates, base_revision)
    before_digest = _tree_digest(coordinates.repo_root)
    result["repository"] = {
        "identity": REPOSITORY_ID,
        "baseRevision": base_revision,
        "root": str(coordinates.repo_root),
        "liveTreeDigestBefore": before_digest,
        "readOnlyByWorkbook": True,
        "shadowSource": "exact-base-revision-archive",
    }
    result["transaction"] = {
        **result["transaction"],  # type: ignore[arg-type]
        "requestDigest": _digest_file(coordinates.request_path),
        "workbookDigest": workbook_digest,
        "kernelIdentity": kernel_identity,
        "bindingIdentity": binding_identity,
        "environmentIdentity": environment_identity,
    }
    _copy_shadow(coordinates.repo_root, coordinates.shadow_root, base_revision)
    _apply_candidates(coordinates.shadow_root, request)
    construction = result["candidateConstructionObservations"]
    assert isinstance(construction, list)
    for candidate in request.candidates:
        formatter: dict[str, object] | None = None
        if candidate.operation == "construct":
            formatter = _run(
                (str(coordinates.cue_bin), "fmt", candidate.path.as_posix()),
                cwd=coordinates.shadow_root,
            )
            if formatter["exitCode"] != 0:
                raise TransactionError("candidate-format-failure", str(formatter["stderr"]))
        construction.append({
            "path": candidate.path.as_posix(),
            "operation": candidate.operation,
            "selectedKernelForms": list(candidate.selected_kernel_forms),
            "constructedDigest": "absent" if candidate.operation == "delete" else _digest_file(
                coordinates.shadow_root.joinpath(*candidate.path.parts)
            ),
            "formatter": formatter,
        })
    try:
        pair = _candidate_patch(coordinates.repo_root, coordinates.shadow_root, request, base_revision)
        if pair is None:
            result["patchProjectability"] = {"state": "not-projectable", "reason": "candidate has no base-revision delta"}
        else:
            projected["patch"], projected["manifest"] = pair
            result["patchProjectability"] = {"state": "projectable", "safetyValidated": True}
            result["patchProjected"] = True
    except Exception as error:
        result["patchProjectability"] = {
            "state": "unsafe",
            "category": error.category if isinstance(error, TransactionError) else "patch-construction-failure",
            "message": str(error)[:4000],
        }
    lsp_files = [
        coordinates.shadow_root.joinpath(*candidate.path.parts)
        for candidate in request.candidates if candidate.operation == "construct"
    ]
    result["lspObservation"] = _lsp_observation(coordinates.cue_bin, coordinates.shadow_root, lsp_files)
    materializations: dict[str, Mapping[str, object]] = {}
    for probe in request.probes:
        materialization = _probe_materialization(probe, coordinates.shadow_root, binding_identity)
        materializations[probe.id] = materialization
    gate_observations = result["packageGateObservations"]
    assert isinstance(gate_observations, list)
    for gate in request.gates:
        gate_observations.append(_gate_observation(gate, coordinates.shadow_root, coordinates.cue_bin))
    cue_py_observations, cue_py_process = _run_cue_py(request.probes, materializations, coordinates, workbook)
    result["cuePyObservations"] = cue_py_observations
    result["cuePyWorkerProcess"] = cue_py_process
    cli_observations = result["cueCLIObservations"]
    assert isinstance(cli_observations, list)
    for probe in request.probes:
        cli_observations.append(_cli_probe(probe, materializations[probe.id], coordinates.cue_bin))
    comparisons = _compare(request.probes, cue_py_observations, cli_observations)
    result["semanticComparisons"] = comparisons

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
    after_digest = _tree_digest(coordinates.repo_root)
    repository = result["repository"]
    assert isinstance(repository, dict)
    repository["liveTreeDigestAfter"] = after_digest
    if before_digest != after_digest:
        raise TransactionError("live-repository-mutated", "live repository identity changed during transaction")
    result["transactionState"] = state
    result["finishedAt"] = _now()
    return result


def _exception_result(
    error: BaseException,
    coordinates: Coordinates | None,
    prior: Mapping[str, object] | None = None,
) -> dict[str, object]:
    category = error.category if isinstance(error, TransactionError) else "unexpected-exception"
    result = dict(prior) if prior is not None else {
        "schema": RESULT_SCHEMA,
        "authority": {
            "classification": "emergency-control-plane-recovery",
            "status": "active",
            "issue": 105,
            "ordinaryImplementationUnitAdmissionClaimed": False,
            "selfAdmissionClaimed": False,
        },
        "patchProjected": False,
        "patchApplied": False,
        "admissionComputed": False,
    }
    result.update({
        "transactionState": "exceptional",
        "finishedAt": _now(),
        "failure": {
            "category": category,
            "type": type(error).__name__,
            "message": str(error)[:4000],
            "traceback": traceback.format_exc(limit=12)[:12000],
        },
        "transaction": result.get("transaction") if result.get("transaction") is not None else (None if coordinates is None else {
            "transientRoot": str(coordinates.transient_root),
            "shadowRoot": str(coordinates.shadow_root),
            "promotionRoot": str(coordinates.promotion_root),
        }),
    })
    return result


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


def _worker_subject_valid(probe: object) -> bool:
    required = {
        "id", "source", "filename", "expression", "concreteInput", "unifyIntent", "schemaIntent",
        "subjectComponents",
    }
    if not isinstance(probe, dict) or set(probe) != required or not isinstance(probe["subjectComponents"], dict):
        return False
    components = probe["subjectComponents"]
    try:
        module = Path.cwd().joinpath(*_safe_relative(components["moduleRoot"], "worker module root").parts).resolve(strict=True)
        if not module.is_relative_to(Path.cwd().resolve(strict=True)):
            return False
        files = components["files"]
        if not isinstance(files, list):
            return False
        file_digests = {
            relative.as_posix(): _digest_file(module.joinpath(*relative.parts).resolve(strict=True))
            for relative in (_safe_relative(value, "worker probe file") for value in files)
        }
        source_path = module.joinpath(*_safe_relative(probe["filename"], "worker source").parts).resolve(strict=True)
        unify_digest = None if probe["unifyIntent"] is None else _digest_bytes(_json_bytes(probe["unifyIntent"]))
        schema_digest = None if probe["schemaIntent"] is None else _digest_bytes(_json_bytes(probe["schemaIntent"]))
        effective_expression = _probe_subject_expression_values(
            probe["expression"], probe["concreteInput"], probe["unifyIntent"], probe["schemaIntent"]
        )
        return (
            file_digests == components["fileDigests"]
            and source_path == module.joinpath(*_safe_relative(files[0], "worker source file").parts).resolve(strict=True)
            and _digest_file(source_path) == components["semanticSourceDigest"]
            and _digest_bytes(str(probe["source"]).encode()) == components["semanticSourceDigest"]
            and effective_expression == components["effectiveExpression"]
            and _digest_bytes(effective_expression.encode()) == components["effectiveExpressionDigest"]
            and probe["expression"] == components["selectedExpression"]
            and _digest_bytes(_json_bytes(probe["concreteInput"])) == components["concreteInputDigest"]
            and unify_digest == components["unifyIntentDigest"]
            and schema_digest == components["schemaIntentDigest"]
        )
    except (KeyError, OSError, TransactionError, TypeError, ValueError):
        return False


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
        if not _worker_subject_valid(probe):
            components = probe.get("subjectComponents", {}) if isinstance(probe, dict) else {}
            observations.append({
                "probeID": probe.get("id", "invalid") if isinstance(probe, dict) else "invalid",
                "evaluator": "cue-py/libcue",
                "stage": "compile",
                "semanticOutcome": {"state": "infrastructure-failure", "category": "subject-observation-mismatch"},
                "subject": {"digest": _digest_bytes(_json_bytes(components)), "components": components},
                "rawDiagnostic": "cue-py worker effective inputs differ from the declared semantic subject",
            })
            continue
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
                stage = "lookup"
                path = probe["expression"]
                value = value.lookup(path)
                looked_up_error = value.error()
                if isinstance(looked_up_error, cue.Err):
                    raise TransactionError("bottom", looked_up_error.err)
                stage = "unify-concrete-input"
                value = value.unify(context.compile(_concrete_value_source(probe["concreteInput"])))
                concrete_error = value.error()
                if isinstance(concrete_error, cue.Err):
                    raise TransactionError("bottom", concrete_error.err)
                if probe["unifyIntent"] is not None:
                    stage = "unify"
                    value = value.unify(context.compile(_cue_expr(probe["unifyIntent"])))
                    unified_error = value.error()
                    if isinstance(unified_error, cue.Err):
                        raise TransactionError("bottom", unified_error.err)
                if probe["schemaIntent"] is not None:
                    stage = "schema"
                    value = value.unify(context.compile(_cue_expr(probe["schemaIntent"])))
                    schema_error = value.error()
                    if isinstance(schema_error, cue.Err):
                        raise TransactionError("bottom", schema_error.err)
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
            "subject": {
                "digest": _digest_bytes(_json_bytes(probe["subjectComponents"])),
                "components": probe["subjectComponents"],
            },
        }
        if path is not None:
            observation["path"] = path
        if diagnostic is not None:
            observation["rawDiagnostic"] = diagnostic[:20000]
        observations.append(observation)
    print(json.dumps({"observations": observations}, sort_keys=True))
    return 0


def _self_test(fixture_path: Path, cue_bin: Path, kernel_path: Path) -> int:
    fixture = json.loads(fixture_path.read_bytes())
    if not isinstance(fixture, dict) or fixture.get("schema") != "factory.cue-emergency-conformance-fixture.v1":
        raise TransactionError("invalid-conformance-fixture", "fixture identity mismatch")
    checks: list[dict[str, object]] = []

    def record(name: str, passed: bool, detail: str = "") -> None:
        checks.append({"name": name, "passed": passed, "detail": detail})
        if not passed:
            raise TransactionError("conformance-failure", f"{name}: {detail}")

    def cue_accepts(source: str, expression: str) -> tuple[bool, str]:
        observation = _run(
            (str(cue_bin), "eval", "-", "-e", expression),
            cwd=fixture_path.parent,
            input_bytes=source.encode(),
        )
        return observation["exitCode"] == 0, str(observation["stderr"])

    forms = tuple(_KERNEL_FORM_FOR_INTENT.values())
    state = fixture["state"]
    resource = fixture["resource"]
    declarations = (
        {"form": "closed-ingress", "name": "resource", "fields": resource},
        {"form": "exact-cardinality", "name": "resourceCount", "collection": state["resources"], "count": 1},
        {"form": "value", "name": "state", "value": state},
        {"form": "wiring", "name": "wired", "target": state},
        {"form": "preservation", "name": "preserved", "authority": state, "target": state},
    )
    candidate = CandidateIntent(PurePosixPath("conformance.cue"), "construct", "conformance", forms, declarations)
    source = _candidate_source(candidate)
    accepted, detail = cue_accepts(source, "preserved")
    record("kernel-projection-positive", accepted, detail)
    accepted, detail = cue_accepts(source, "wired")
    record("wiring-applies-closed-state-construction", accepted, detail)
    accepted, detail = cue_accepts(source, "resourceCount")
    record("exact-cardinality-positive", accepted, detail)

    widened = CandidateIntent(
        PurePosixPath("widened.cue"),
        "construct",
        "conformance",
        ("#NoWideningProof",),
        ({
            "form": "preservation",
            "name": "preserved",
            "authority": state,
            "target": fixture["widenedState"],
        },),
    )
    accepted, detail = cue_accepts(_candidate_source(widened), "preserved")
    record("preservation-rejects-widening", not accepted, detail)

    extra_resource = dict(resource)
    extra_resource["claimantValid"] = True
    closed = CandidateIntent(
        PurePosixPath("closed.cue"),
        "construct",
        "conformance",
        ("#Resource",),
        ({"form": "closed-ingress", "name": "resource", "fields": extra_resource},),
    )
    accepted, detail = cue_accepts(_candidate_source(closed), "resource")
    record("closed-ingress-rejects-extra-field", not accepted, detail)

    wrong_count = CandidateIntent(
        PurePosixPath("cardinality.cue"),
        "construct",
        "conformance",
        ("#StateKeySet",),
        ({"form": "exact-cardinality", "name": "count", "collection": state["resources"], "count": 2},),
    )
    accepted, detail = cue_accepts(_candidate_source(wrong_count), "count")
    record("exact-cardinality-negative", not accepted, detail)

    probe_source = "package conformance\n\nsubject: {x: int}\n"
    probe_expression = _probe_subject_expression_values(
        "subject", {"x": 1}, None, {"x": {"$ref": "int"}}
    )
    accepted, detail = cue_accepts(probe_source, probe_expression)
    record("schema-constraint-uses-unification", accepted, detail)

    request_value = fixture["request"]
    with tempfile.TemporaryDirectory(prefix="factory-cue-self-test-") as temporary:
        root = Path(temporary)
        request_file = root / "request.json"
        request_file.write_bytes(_pretty_json(request_value))
        loaded = _load_request(request_file, kernel_path, cue_bin)
        record("closed-request-v3", len(loaded.probes) == 2)

        multi_file = copy.deepcopy(request_value)
        multi_file["probes"][0]["files"].append("second.cue")
        request_file.write_bytes(_pretty_json(multi_file))
        try:
            _load_request(request_file, kernel_path, cue_bin)
        except TransactionError as error:
            record("multi-file-equivalence-rejected", error.category == "invalid-request", str(error))
        else:
            record("multi-file-equivalence-rejected", False, "multi-file probe was accepted")

        arbitrary_lsp = copy.deepcopy(request_value)
        arbitrary_lsp["lsp"] = {"argv": ["/bin/sh", "-c", "false"]}
        request_file.write_bytes(_pretty_json(arbitrary_lsp))
        try:
            _load_request(request_file, kernel_path, cue_bin)
        except TransactionError as error:
            record("arbitrary-lsp-request-rejected", error.category == "invalid-request", str(error))
        else:
            record("arbitrary-lsp-request-rejected", False, "arbitrary LSP argv was accepted")

        incomplete_kernel = root / "kernel.cue"
        incomplete_kernel.write_text("package kernel\n\n#Resource: {}\n", encoding="utf-8")
        try:
            _kernel_form_names(incomplete_kernel, cue_bin)
        except TransactionError as error:
            record("kernel-forms-derived-from-content", error.category == "kernel-form-unavailable", str(error))
        else:
            record("kernel-forms-derived-from-content", False, "missing kernel forms were treated as available")

    print(json.dumps({"schema": fixture["schema"], "passed": len(checks), "checks": checks}, sort_keys=True))
    return 0


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--authority", action="store_true")
    parser.add_argument("--cue-py-worker", nargs=1)
    parser.add_argument("--self-test", nargs=1)
    for name in (
        "repo-root", "transient-root", "shadow-root", "promotion-root", "request",
        "kernel-path", "cue-py-root", "libcue-root", "libcue-library", "cue-bin",
        "go-bin", "uv-bin",
    ):
        parser.add_argument(f"--{name}")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.authority:
        print(json.dumps({
            "schema": "factory.cue-emergency-implementation-constants.v1",
            "cuePy": {"repository": CUE_PY_REPOSITORY, "revision": CUE_PY_COMMIT},
            "libcue": {"repository": LIBCUE_REPOSITORY, "revision": LIBCUE_COMMIT},
            "kernel": {
                "repository": KERNEL_REPOSITORY,
                "revision": KERNEL_COMMIT,
                "relativePath": KERNEL_RELATIVE_PATH.as_posix(),
                "gitBlobSHA1": KERNEL_BLOB,
            },
        }, sort_keys=True))
        return 0
    if args.cue_py_worker is not None:
        return _worker(args.cue_py_worker)
    if args.self_test is not None:
        if args.cue_bin is None or args.kernel_path is None:
            raise TransactionError("invalid-coordinate", "self-test requires --cue-bin and --kernel-path")
        return _self_test(
            _absolute_existing(args.self_test[0], directory=False, label="conformance fixture"),
            _absolute_existing(args.cue_bin, directory=False, label="cue binary"),
            _absolute_existing(args.kernel_path, directory=False, label="kernel"),
        )
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
    journal: dict[str, object] | None = None
    projected: dict[str, object] = {}
    try:
        coordinates = _coordinates(args)
        journal = _initial_result(coordinates)
        result = _transaction(coordinates, journal, projected)
    except BaseException as error:
        result = _exception_result(error, coordinates, journal)
    result_bytes = _pretty_json(result)
    if coordinates is None:
        print(result_bytes.decode(), file=sys.stderr, end="")
        return 2
    artifacts = {"bounded-result.json": result_bytes}
    patch, manifest = projected.get("patch"), projected.get("manifest")
    if isinstance(patch, bytes) and isinstance(manifest, dict):
        artifacts["candidate.patch"] = patch
        artifacts["candidate-patch-manifest.json"] = _pretty_json(manifest)
    try:
        _atomic_promote(coordinates.promotion_root, artifacts)
        promoted = True
    except BaseException as error:
        fallback = _exception_result(error, coordinates, result)
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
