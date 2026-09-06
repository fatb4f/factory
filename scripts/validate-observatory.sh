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
python3 scripts/repository_context.py state/fixtures/repository-context/config.json --root state/fixtures/repository-context --output "$tmpdir/build-a.json"
python3 scripts/repository_context.py state/fixtures/repository-context/config.json --root state/fixtures/repository-context --output "$tmpdir/build-b.json"
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

section "Semantic runtime code generation"
cue export ./contracts/state:state -e semanticRuntimeProjection --out json >"$tmpdir/runtime-projection.json"
python3 scripts/generate_semantic_runtime_types.py "$tmpdir/runtime-projection.json" --output "$tmpdir/semantic_context.py"
cmp -s "$tmpdir/semantic_context.py" runtime/generated/semantic_context.py

section "Semantic runtime navigation"
PYTHONPATH=.:scripts python3 - <<'PY'
import json
from pathlib import Path
from repository_context import compile_repository_context
from runtime.semantic_runtime import AdmissionBoundaryError, SemanticRuntime, SnapshotLookupAdapter
root = Path("state/fixtures/repository-context")
config = json.loads((root / "config.json").read_text(encoding="utf-8"))
snapshot = compile_repository_context(config, root)["snapshot"]
runtime = SemanticRuntime(snapshot)
subject = runtime.semantic(snapshot["subjects"][0])
assert subject.snapshot == snapshot["identity"]["digest"]
documentary = subject.adjacent("documentary")
assert len(documentary) == 1
assert documentary[0].occurrence["locator"] == "context.md"
assert subject.provenance("adjacent", "documentary").plane == "documentary"
assert subject.traverse("evidential", 2)
class CountingAdapter(SnapshotLookupAdapter):
    def __init__(self, snapshot):
        super().__init__(snapshot)
        self.subject_reads = 0
    def subject(self, ref):
        self.subject_reads += 1
        return super().subject(ref)
adapter = CountingAdapter(snapshot)
lazy_runtime = SemanticRuntime(snapshot, adapter=adapter)
lazy_runtime.semantic(snapshot["subjects"][0])
assert adapter.subject_reads > 0
fake_relation = {
    "plane": "semantic",
    "authority": snapshot["subjects"][0]["authority"],
    "predicate": {"authority": snapshot["subjects"][0]["authority"], "id": "python-only-inference"},
    "snapshot": {"authority": snapshot["subjects"][0]["authority"], "id": "not-admitted"},
    "source": snapshot["subjects"][0],
    "target": snapshot["subjects"][0],
    "basis": {"occurrences": [snapshot["occurrences"][0]["id"]]},
}
try:
    runtime.serialize_admitted_semantic_relation(fake_relation)
except AdmissionBoundaryError:
    pass
else:
    raise AssertionError("Python-only semantic relation crossed admission boundary")
PY

echo "observatory validation passed"
