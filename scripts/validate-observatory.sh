#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

section() {
  printf '\n== %s ==\n' "$1"
}

section "Observatory shared contracts"
cue vet -c=false ./contracts/state:state
cue vet -c=false ./state/fixtures:statefixtures

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_TMP="$tmpdir"

section "Repository context compiler"
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

section "Industrial graph snapshot realization"
cue vet -c=false ./contracts/world/industrial-signals:industrialsignals
cue vet -c=false ./world/industrial-signals/fixtures:industrialsignalsfixtures
cue export ./world/industrial-signals/fixtures:industrialsignalsfixtures -e graphSnapshotInput --out json >"$tmpdir/industrial-input.json"
python3 scripts/industrial_graph_snapshot.py "$tmpdir/industrial-input.json" --output "$tmpdir/industrial-snapshot-a.json"
python3 scripts/industrial_graph_snapshot.py "$tmpdir/industrial-input.json" --output "$tmpdir/industrial-snapshot-b.json"
cmp -s "$tmpdir/industrial-snapshot-a.json" "$tmpdir/industrial-snapshot-b.json"
cue vet -c=false "$tmpdir/industrial-snapshot-a.json" ./contracts/world/industrial-signals/*.cue -d '#IndustrialGraphSnapshot'
jq '{industrialSignals:{domain:"world.industrial-signals",snapshotID:.snapshotID,digest:.digest,observedThrough:.observedThrough}}' "$tmpdir/industrial-snapshot-a.json" >"$tmpdir/constraint-input.json"
cue vet -c=false "$tmpdir/constraint-input.json" ./contracts/world/industrial-constraints/*.cue -d '#RelationalConstraintInput'
if cue vet -c=false ./world/industrial-signals/fixtures/negative:industrialsignalsnegative; then
  echo "expected event-watch/industrial-graph execution conflict" >&2
  exit 1
fi

section "Directory-bound workbook"
cue export ./state/fixtures:statefixtures -e semanticContextSnapshot --out json >"$tmpdir/workbook-snapshot.json"
cue export ./state/fixtures:statefixtures -e analyticsRequest --out json >"$tmpdir/workbook-analytics-request.json"
PYTHONPATH=. python3 - <<'PY'
import json
import os
from pathlib import Path
from runtime.semantic_runtime import SemanticRuntime
from runtime.workbook import DirectoryBindingError, Workbook, WorkbookCapabilityGap

tmp = Path(os.environ["OBS_TMP"])
snapshot = json.loads((tmp / "workbook-snapshot.json").read_text())
request = json.loads((tmp / "workbook-analytics-request.json").read_text())
runtime = SemanticRuntime(snapshot)
primary, secondary = snapshot["subjects"][:2]
binding = {
    "id": "binding:world.industrial-signals",
    "directory": {"repository": "github.com/fatb4f/factory", "revision": "fixture", "path": "world/industrial-signals"},
    "subjects": [primary],
}
workbook = Workbook.here(
    "world/industrial-signals/workbook.py",
    snapshot=snapshot,
    bindings=[binding],
    runtime=runtime,
    includes=[secondary],
)
try:
    Workbook.here("world/missing/workbook.py", snapshot=snapshot, bindings=[binding], runtime=runtime)
except DirectoryBindingError:
    pass
else:
    raise AssertionError("missing binding did not fail closed")
ambiguous = {**binding, "id": "binding:ambiguous", "subjects": [primary, secondary]}
try:
    Workbook.here("world/industrial-signals/workbook.py", snapshot=snapshot, bindings=[ambiguous], runtime=runtime)
except DirectoryBindingError:
    pass
else:
    raise AssertionError("ambiguous binding did not require an explicit subject")
explicit = Workbook.here(
    "world/industrial-signals/workbook.py",
    snapshot=snapshot,
    bindings=[ambiguous],
    runtime=runtime,
    subject=secondary,
)
assert explicit.scope.primary == secondary
child = workbook.child(subject=secondary)
assert child.scope.primary == secondary
navigation = {
    "id": "evidence-topology",
    "presentation": "topology",
    "source": {"kind": "bounded-navigation", "root": primary, "plane": "evidential", "maxDepth": 2},
}
first = workbook.evaluate(navigation)
second = workbook.evaluate(navigation)
assert first == second
assert first["snapshot"] == snapshot["identity"]["digest"]
assert first["edges"]
(tmp / "workbook-navigation.json").write_text(json.dumps(first, indent=2, sort_keys=True) + "\n")
class RecordingExecutor:
    def __init__(self): self.request = None
    def execute(self, request_value, *, snapshot, subject):
        self.request = request_value
        return {
            "rows": [{"id": "row-1", "cells": [{"field": "project_id", "value": "project.capacity-expansion"}, {"field": "amount_total", "value": 1000000}]}],
            "points": [{"series": "amount_total", "x": "funding-award", "y": 1000000, "provenance": [snapshot]}],
        }
executor = RecordingExecutor()
analytical_workbook = Workbook.here(
    "world/industrial-signals/workbook.py",
    snapshot=snapshot,
    bindings=[binding],
    runtime=runtime,
    includes=[secondary],
    analytical_executor=executor,
)
analytical_view = {"id": "funding-chart", "presentation": "chart", "source": {"kind": "analytical", "request": request}}
analytical = analytical_workbook.evaluate(analytical_view)
assert executor.request == request
assert analytical["rows"] and analytical["points"]
(tmp / "workbook-analytical.json").write_text(json.dumps(analytical, indent=2, sort_keys=True) + "\n")
try:
    workbook.evaluate({"id": "bad", "presentation": "table", "source": {"kind": "unknown"}})
except WorkbookCapabilityGap:
    pass
else:
    raise AssertionError("unsupported workbook source did not fail typed")
PY
cue vet -c=false "$tmpdir/workbook-navigation.json" ./contracts/state/*.cue -d '#ProjectionResult'
cue vet -c=false "$tmpdir/workbook-analytical.json" ./contracts/state/*.cue -d '#ProjectionResult'

echo "observatory validation passed"
