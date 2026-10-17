"""Wire/native conversion and an explicit CUE validation gate.

Native objects are runtime representations. Neither construction, decoding nor
CUE shape validation admits domain facts or establishes runtime API behavior.
"""
from __future__ import annotations

from dataclasses import dataclass, fields, is_dataclass
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from typing import Any


class NativeBindingError(ValueError):
    pass


class UnsetType:
    __slots__ = ()

    def __repr__(self):
        return "UNSET"


UNSET = UnsetType()


def _digest(data):
    return "sha256:" + hashlib.sha256(data).hexdigest()


def _canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()


def to_wire(value):
    if isinstance(value, UnsetType):
        raise NativeBindingError("UNSET has no standalone wire value")
    if is_dataclass(value) and not isinstance(value, type):
        return {f.name: to_wire(v) for f in fields(value) if not isinstance(v := getattr(value, f.name), UnsetType)}
    if isinstance(value, (tuple, list)):
        return [to_wire(v) for v in value]
    if isinstance(value, dict):
        return {k: to_wire(v) for k, v in value.items()}
    if value is None or type(value) in {str, int, float, bool}:
        return value
    raise NativeBindingError(f"unsupported wire value: {type(value).__name__}")


@dataclass(frozen=True, slots=True)
class CueValidatedValue:
    value: Any
    cue_type: str
    payload_digest: str
    cue_inputs_digest: str
    cue_version: str
    plan_digest: str
    api_facts_digest: str
    admission: str = "not-determined"


class NativeModelAdapter:
    def __init__(self, module, root: Path | None = None):
        self.module = module
        self.plan = json.loads(_canonical(module.PROJECTION_PLAN))
        self.root = root or Path(__file__).resolve().parents[1]
        if _digest(_canonical(self.plan)) != module.PLAN_DIGEST:
            raise NativeBindingError("generated projection plan digest mismatch")
        source = (self.root / self.plan["source"]).resolve()
        if not source.is_relative_to(self.root.resolve()) or _digest(source.read_bytes()) != self.plan["sourceDigest"]:
            raise NativeBindingError("CUE authority source drift")
        self.authority_directory = source.parent
        target = self.plan["apiSource"]["targetPython"]
        if sys.version_info[:2] != (target["major"], target["minor"]):
            raise NativeBindingError("native binding requires its qualified Python major/minor")
        self.types = {item["name"]: item for item in self.plan["types"]}

    def _element(self, annotation, value, depth):
        kind = annotation["kind"]
        if kind == "local":
            return self.decode(annotation["name"], value, _depth=depth + 1)
        if kind == "api":
            symbol = self.plan["apiSource"]["requests"][annotation["api"]]
            target = {("builtins", "str"): str, ("builtins", "int"): int}.get((symbol["module"], symbol["symbol"]))
            if target is None or type(value) is not target:
                raise NativeBindingError("wire scalar does not match native API target")
            return value
        if kind == "literal":
            if type(value) is not str or value not in annotation["values"]:
                raise NativeBindingError("wire literal outside projected alternatives")
            return value
        if kind == "tuple":
            if type(value) is not list:
                raise NativeBindingError("wire sequence must be a JSON array")
            return tuple(self._element(annotation["item"], v, depth + 1) for v in value)
        raise NativeBindingError("unsupported native annotation")

    def decode(self, type_name, value, *, _depth=0):
        """Structural conversion only. This method does not validate CUE constraints."""
        if _depth > 32 or type(value) is not dict or type_name not in self.types:
            raise NativeBindingError("invalid or excessively nested native input")
        item = self.types[type_name]
        allowed = {field["name"] for field in item["fields"]}
        if set(value) - allowed:
            raise NativeBindingError("unknown wire fields")
        kwargs = {}
        for field in item["fields"]:
            name = field["name"]
            if name not in value:
                if not field["optional"]:
                    raise NativeBindingError(f"missing required field: {name}")
            else:
                kwargs[name] = self._element(field["annotation"], value[name], _depth)
        return getattr(self.module, type_name)(**kwargs)

    def decode_validated(self, type_name, value):
        """Validate current CUE constraints before returning a native value.

        The receipt is validation evidence, not an admission grant. CUE files are
        passed explicitly; neither a model name nor subprocess output is executed.
        """
        native = self.decode(type_name, value)
        payload = _canonical(to_wire(native))
        cue_type = self.types[type_name]["cueType"]
        package = sorted(self.authority_directory.glob("*.cue"))
        # Conservative local authority-input superset includes imported local
        # contracts, not merely the root package whose definitions are selected.
        inputs = sorted((self.root / "contracts").rglob("*.cue")) + sorted((self.root / "cue.mod").glob("*.cue"))
        inputs_digest = _digest(_canonical({str(p.relative_to(self.root)): _digest(p.read_bytes()) for p in inputs}))
        cue_version = subprocess.check_output(["cue", "version"], cwd=self.root, text=True).splitlines()[0]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "value.json"
            path.write_bytes(payload)
            result = subprocess.run(["cue", "vet", "-c", str(path), *map(str, package), "-d", cue_type],
                                    cwd=self.root, capture_output=True, text=True)
            if result.returncode:
                raise NativeBindingError(result.stderr)
        return CueValidatedValue(native, cue_type, _digest(payload), inputs_digest, cue_version,
                                 self.module.PLAN_DIGEST, self.module.API_FACTS_DIGEST)
