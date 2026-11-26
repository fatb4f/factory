"""Metadata-only discovery and explicit approval for the single-module pilot."""

from importlib.metadata import distribution
import importlib.util
from pathlib import Path
import re
import sys

from runtime.transform_execution import digest, semantic_json
from runtime.typed_transform import TransformRejected

_LOADED = {}


def discover(package):
    return tuple(ep for ep in distribution(package).entry_points
                 if ep.group == "factory.transforms")


def installed_entry_digest(package, transform_id):
    dist = distribution(package)
    matches = [ep for ep in discover(package) if ep.name == transform_id]
    if len(matches) != 1:
        raise TransformRejected("expected one matching transform entry point")
    entry = matches[0]
    # M1 qualifies only a single installed Python module, not arbitrary packages.
    if not re.fullmatch(r"[A-Za-z_]\w*:[A-Za-z_]\w*", entry.value):
        raise TransformRejected("unsupported pilot entry point")
    relative = entry.module + ".py"
    files = [file for file in dist.files or () if str(file) == relative]
    if len(files) != 1:
        raise TransformRejected("missing installed pilot module")
    path = dist.locate_file(files[0]).resolve()
    identity = digest(semantic_json({
        "distribution": dist.metadata["Name"],
        "version": dist.version,
        "entry": entry.value,
        "transform": transform_id,
        "moduleDigest": digest(path.read_bytes()),
    }))
    return dist.version, identity, entry, path


def load_approved(package, transform_id, *, version, approved_digest):
    actual_version, identity, entry, path = installed_entry_digest(package, transform_id)
    if (actual_version, identity) != (version, approved_digest):
        raise TransformRejected("installed extension does not match approval")
    cached = _LOADED.get(entry.module)
    if cached is not None and cached[:2] == (identity, sys.modules.get(entry.module)):
        return cached[2]
    if entry.module in sys.modules:
        raise TransformRejected("pilot extension module already loaded outside its approval")
    spec = importlib.util.find_spec(entry.module)
    if spec is None or spec.origin is None or path != Path(spec.origin).resolve():
        raise TransformRejected("installed extension module origin mismatch")
    transform = entry.load()
    _LOADED[entry.module] = (identity, sys.modules[entry.module], transform)
    return transform
