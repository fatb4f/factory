#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

section() {
  printf '\n== %s ==\n' "$1"
}

section "Observatory shared contracts"
cue vet -c=false ./contracts/state:state
cue vet -c=false ./state/fixtures:statefixtures

section "Repository context compiler"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

python3 scripts/repository_context.py \
  state/fixtures/repository-context/config.json \
  --root state/fixtures/repository-context \
  --output "$tmpdir/build-a.json"
python3 scripts/repository_context.py \
  state/fixtures/repository-context/config.json \
  --root state/fixtures/repository-context \
  --output "$tmpdir/build-b.json"

cmp -s "$tmpdir/build-a.json" "$tmpdir/build-b.json"
cue vet -c=false "$tmpdir/build-a.json" ./contracts/state/*.cue -d '#RepositoryContextBuild'

PYTHONPATH=scripts python3 - <<'PY'
import json
from pathlib import Path
from repository_context import UnsupportedNormativeFence, compile_repository_context, parse_typed_markdown

root = Path("state/fixtures/repository-context")
config = json.loads((root / "config.json").read_text(encoding="utf-8"))
first = compile_repository_context(json.loads(json.dumps(config)), root)
second = compile_repository_context(json.loads(json.dumps(config)), root)
assert first["outputDigest"] == second["outputDigest"]
try:
    parse_typed_markdown("unsupported.md", b"```cue unsupported-type\nvalue: 1\n```\n", {"semantic-ref"})
except UnsupportedNormativeFence:
    pass
else:
    raise AssertionError("unsupported normative CUE fence did not fail closed")
assert first["snapshot"]["semanticRelations"] == []
assert {item["analyzer"] for item in first["structuralObservations"]} >= {"python-ast", "jedi", "tree-sitter"}
assert first["trackerMetadata"][0]["factoryIssueKey"].startswith("engineering:")
assert first["trackerMetadata"][0]["issueNumber"] == 145
PY

echo "observatory validation passed"
