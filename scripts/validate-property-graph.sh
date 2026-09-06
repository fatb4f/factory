#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_PROPERTY_GRAPH_TMP="$tmpdir"

cue vet -c=false ./contracts/state:state
cue vet -c=false ./world/industrial-signals/fixtures:industrialsignalsfixtures
cue export ./world/industrial-signals/fixtures:industrialsignalsfixtures -e industrialWorkbookContextSnapshot --out json >"$tmpdir/context.json"
cue export ./world/industrial-signals/fixtures:industrialsignalsfixtures -e industrialWorkbookBinding --out json >"$tmpdir/binding.json"

PYTHONPATH=. python3 - <<'PY'
from __future__ import annotations

import copy
import json
import os
from pathlib import Path

from runtime.property_graph_adapter import Neo4jBatchAdapter, PropertyGraphBoundaryError, project
from runtime.semantic_runtime import SemanticRuntime
from runtime.workbook import Workbook


tmp = Path(os.environ["OBS_PROPERTY_GRAPH_TMP"])
context = json.loads((tmp / "context.json").read_text())
binding = json.loads((tmp / "binding.json").read_text())
runtime = SemanticRuntime(context)
workbook = Workbook.here(
    "world/industrial-signals/workbook.py",
    snapshot=context,
    bindings=[binding],
    runtime=runtime,
)

projections = {}
property_graphs = {}
for plane in ("semantic", "documentary", "operational", "evidential"):
    view = {
        "id": f"property-graph-{plane}",
        "presentation": "topology",
        "source": {
            "kind": "bounded-navigation",
            "root": workbook.scope.primary,
            "plane": plane,
            "maxDepth": 2,
        },
    }
    projection = workbook.evaluate(view)
    graph = project(projection)
    projections[plane] = projection
    property_graphs[plane] = graph
    assert graph == project(projection)
    assert graph["snapshot"] == projection["snapshot"]
    assert graph["subject"] == projection["subject"]
    assert graph["direction"] == "factory-to-backend"
    assert graph["reverseAdmission"] is False
    (tmp / f"property-graph-{plane}.json").write_text(json.dumps(graph, indent=2, sort_keys=True) + "\n")

semantic_projection = projections["semantic"]
semantic_graph = property_graphs["semantic"]
assert semantic_projection["edges"]
assert semantic_graph["edges"]
for source_edge, graph_edge in zip(semantic_projection["edges"], semantic_graph["edges"], strict=True):
    assert source_edge["plane"] == "semantic"
    assert graph_edge["relationAuthority"] == source_edge["relationAuthority"]
    assert graph_edge["admittedSnapshot"] == source_edge["admittedSnapshot"]
    assert graph_edge["basis"] == source_edge["basis"]
    assert graph_edge["provenance"] == source_edge["provenance"]
for node in semantic_graph["nodes"]:
    if node["class"] == "semantic":
        assert node["authority"] == node["semantic"]["authority"]

for plane in ("documentary", "operational", "evidential"):
    graph = property_graphs[plane]
    assert graph["edges"]
    assert {edge["plane"] for edge in graph["edges"]} == {plane}
    assert all("relationAuthority" not in edge for edge in graph["edges"])
    assert all("admittedSnapshot" not in edge for edge in graph["edges"])
    assert any(node["class"] == "context" and node["plane"] == plane for node in graph["nodes"])

# Semantic relation authority must be preserved by the workbook projection;
# the property-graph adapter refuses to reconstruct it from endpoints.
missing_authority = copy.deepcopy(semantic_projection)
del missing_authority["edges"][0]["relationAuthority"]
try:
    project(missing_authority)
except PropertyGraphBoundaryError:
    pass
else:
    raise AssertionError("semantic edge without relation authority did not fail closed")

neo4j = Neo4jBatchAdapter()
bundle = neo4j.load(semantic_graph)
assert bundle["target"]["id"] == "neo4j"
assert bundle["direction"] == "factory-to-backend"
assert bundle["reverseAdmission"] is False
assert bundle["source"]["snapshot"] == semantic_graph["snapshot"]
assert bundle["nodes"] == semantic_graph["nodes"]
assert bundle["edges"] == semantic_graph["edges"]

# The transport target is replaceable without changing Factory contracts.
future_bundle = Neo4jBatchAdapter(target_id="future-property-graph", version="fixture/v1").load(semantic_graph)
assert future_bundle["target"]["id"] == "future-property-graph"
assert future_bundle["nodes"] == bundle["nodes"]
assert future_bundle["edges"] == bundle["edges"]

# Backend-side mutation is isolated from the Factory projection and there is no
# backend-to-Factory admission API on the adapter.
mutated = copy.deepcopy(bundle)
mutated["nodes"][0]["id"] = "backend-only-layout-or-label-state"
assert semantic_graph["nodes"][0]["id"] != mutated["nodes"][0]["id"]
assert not hasattr(neo4j, "admit")
assert not hasattr(neo4j, "import_from_backend")
assert not hasattr(neo4j, "read_back")

(tmp / "neo4j-load-bundle.json").write_text(json.dumps(bundle, indent=2, sort_keys=True) + "\n")
(tmp / "future-load-bundle.json").write_text(json.dumps(future_bundle, indent=2, sort_keys=True) + "\n")
PY

for graph in "$tmpdir"/property-graph-*.json; do
  cue vet -c=false "$graph" ./contracts/state/*.cue -d '#PropertyGraphProjection'
done
for bundle in "$tmpdir"/*-load-bundle.json; do
  cue vet -c=false "$bundle" ./contracts/state/*.cue -d '#PropertyGraphLoadBundle'
done

echo "property graph validation passed"
