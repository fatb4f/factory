#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

section() {
  printf '\n== %s ==\n' "$1"
}

section "CUE logical-model introspection"
python3 scripts/cue_model_introspection.py state/fixtures/introspection-model/config.json \
  --root state/fixtures/introspection-model --output "$tmpdir/model-a.json"
python3 scripts/cue_model_introspection.py state/fixtures/introspection-model/config.json \
  --root state/fixtures/introspection-model --output "$tmpdir/model-b.json"
cmp -s "$tmpdir/model-a.json" "$tmpdir/model-b.json"
cue vet -c=false "$tmpdir/model-a.json" ./contracts/state/*.cue -d '#LogicalModelProjection'

PYTHONPATH=scripts python3 - <<'PY'
import json
import tempfile
from pathlib import Path

from cue_model_introspection import CueModelError, compile_cue_model

root = Path("state/fixtures/introspection-model")
config = json.loads((root / "config.json").read_text(encoding="utf-8"))
projection = compile_cue_model(config, root)
nodes = {item["id"]: item for item in projection["nodes"]}
edges = {(item["relation"], item["source"], item["target"]) for item in projection["edges"]}

project = nodes["cue:observatorymodel:#Project"]
assert len(project["sources"]) == 2
assert nodes["cue:observatorymodel:#Project.external"]["required"] is False
assert ("conjoins", "cue:observatorymodel:#Project", "cue:observatorymodel:#Entity") in edges
assert ("references", "cue:observatorymodel:#Project.owner", "cue:observatorymodel:#Organization") in edges
assert any(
    relation == "references" and target == "cue-import:example.com/external:model:#External"
    for relation, _, target in edges
)

with tempfile.TemporaryDirectory() as tmp:
    bad_root = Path(tmp)
    (bad_root / "bad.cue").write_text("#MissingPackage: {value: string}\n", encoding="utf-8")
    try:
        compile_cue_model(
            {"repository": "fixture", "revision": "fixture", "files": ["bad.cue"]},
            bad_root,
        )
    except CueModelError:
        pass
    else:
        raise AssertionError("CUE model introspection accepted a source without a package declaration")
PY

echo "observatory introspection validation passed"
