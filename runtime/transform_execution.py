"""Shared executor for explicitly trusted, read-only v0.1 pilot transforms."""

from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
from time import monotonic_ns
from typing import Callable, Generic, TypeVar
from uuid import uuid4

from runtime.typed_transform import TransformContext, TransformRejected, TypedTransform

I = TypeVar("I")
ROOT = Path(__file__).resolve().parents[1]


def digest(value: bytes) -> str:
    return "sha256:" + hashlib.sha256(value).hexdigest()


def semantic_json(value) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"),
                      ensure_ascii=False, allow_nan=False).encode()


def validate_receipt(receipt):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "receipt.json"
        path.write_bytes(semantic_json(receipt))
        subprocess.run(
            ["cue", "vet", "-c", "./contracts/state:state", str(path),
             "-d", "#TransformInvocation"], cwd=ROOT, check=True, capture_output=True,
        )


@dataclass(frozen=True)
class TransformSpec(Generic[I]):
    transform_id: str
    version: str
    extension_digest: str
    contract_version: str
    transform: TypedTransform[I, list]
    validate_output: Callable[[I, list], tuple[str, ...]]


@dataclass(frozen=True)
class Prepared(Generic[I]):
    value: I
    snapshot_id: str
    snapshot_digest: str
    source_revisions: tuple[str, ...]
    schema_version: str
    cutoff: str
    scope_digest: str
    policy_version: str
    input_refs: tuple[str, ...]
    context: TransformContext


@dataclass(frozen=True)
class Execution:
    semantic_output: bytes
    receipt_json: bytes

    @property
    def receipt(self):
        return json.loads(self.receipt_json)


class Executor(Generic[I]):
    def __init__(self, *, contract_version, contract_digest):
        self.contract_version = contract_version
        self.contract_digest = contract_digest
        self._registered: dict[tuple[str, str], TransformSpec[I]] = {}
        self._enabled: set[tuple[str, str]] = set()

    def enable(self, spec: TransformSpec[I]):
        if spec.contract_version != self.contract_version:
            raise TransformRejected("incompatible transform contract")
        key = (spec.transform_id, spec.version)
        if key in self._registered and self._registered[key] != spec:
            raise TransformRejected("transform version already bound")
        self._registered[key] = spec
        self._enabled.add(key)

    def disable(self, transform_id, version):
        self._enabled.discard((transform_id, version))

    def run(self, transform_id, version, prepare: Callable[[], Prepared[I]],
            *, expected_extension_digest=None):
        key = (transform_id, version)
        if key not in self._enabled:
            raise TransformRejected("transform version is not enabled")
        spec = self._registered[key]
        if expected_extension_digest is not None and spec.extension_digest != expected_extension_digest:
            raise TransformRejected("historical extension digest mismatch")
        started = monotonic_ns()
        prepared = prepare()  # Caller authorization and snapshot binding precede dispatch.
        result = spec.transform(prepared.value, context=prepared.context)
        if result.input_digests != prepared.context.input_digests:
            raise TransformRejected("transform input provenance differs from bound inputs")
        provenance = spec.validate_output(prepared.value, result.value)
        output = semantic_json(result.value)
        receipt = {
            "apiVersion": "factory.transforms/invocation-v1",
            "invocationID": str(uuid4()),
            "transformID": transform_id,
            "transformVersion": version,
            "extensionDigest": spec.extension_digest,
            "contractVersion": spec.contract_version,
            "contractDigest": self.contract_digest,
            "snapshotRef": {
                "id": prepared.snapshot_id,
                "digest": prepared.snapshot_digest,
                "sourceRevisionRefs": list(prepared.source_revisions),
                "schemaVersion": prepared.schema_version,
            },
            "knowledgeCutoff": prepared.cutoff,
            "authorizationReceipt": {
                "policyVersion": prepared.policy_version,
                "scopeDigest": prepared.scope_digest,
                "decision": "allowed",
            },
            "inputRefs": list(prepared.input_refs),
            "outputDigest": digest(output),
            "provenanceRefs": list(provenance),
            "executionBackend": "in-process",
            "durationNS": monotonic_ns() - started,
            "outcome": "success" if result.value else "empty",
        }
        validate_receipt(receipt)
        return Execution(output, semantic_json(receipt))
