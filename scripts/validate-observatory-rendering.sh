#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_RENDER_TMP="$tmpdir"

cue export ./state/fixtures:statefixtures -e relationalPlan --out json >"$tmpdir/plan.json"

PYTHONPATH=.:scripts python3 - <<'PY'
import json
import os
from pathlib import Path

from cue_model_introspection import compile_cue_model
from runtime.generated.semantic_context import (
    ContextArtifact,
    ContextArtifactRef,
    SemanticAuthorityRef,
    SemanticRef,
    SourceOccurrence,
)
from runtime.ibis_adapter import project_analytics_model
from runtime.introspection import IntrospectionGraph
from runtime.rich_adapter import render_rich_tree
from runtime.semantic_metadata import project_python_model
from runtime.structurizr_adapter import render_structurizr_dsl

tmp = Path(os.environ["OBS_RENDER_TMP"])
plan = json.loads((tmp / "plan.json").read_text(encoding="utf-8"))
python_ref = "python:runtime.generated.semantic_context.SemanticRef"
cue_ref = "cue:state:#SemanticRef"

cue_projection = compile_cue_model(
    {
        "repository": "github.com/fatb4f/factory",
        "revision": "fixture",
        "files": ["contracts/state/semantic-context.cue"],
    },
    Path("."),
)
python_projection = project_python_model(
    [SemanticAuthorityRef, SemanticRef, SourceOccurrence, ContextArtifactRef, ContextArtifact]
)
analytics_projection = project_analytics_model(
    plan,
    upstream_node=python_ref,
    target_version="adapter-v1",
)
graph = IntrospectionGraph.from_projections(cue_projection, python_projection, analytics_projection)
ibis_node = f"analytics:{plan['id']}:ibis-expression"
inspection = graph.inspect(
    {
        "id": "end-to-end-lineage",
        "roots": [cue_ref],
        "direction": "outgoing",
        "maxDepth": 32,
        "roles": ["lineage", "analytical"],
    }
)
assert any(node["id"] == ibis_node for node in inspection["nodes"])

rich_request = {
    "id": "semantic-lineage-rich",
    "representation": "rich-tree",
    "view": "lineage",
    "title": "Factory semantic lineage",
    "upstreamNode": ibis_node,
}
rich_projection = render_rich_tree(inspection, rich_request)
assert "Factory semantic lineage" in rich_projection["payload"]["content"]
assert "lineage:projects-to" in rich_projection["payload"]["content"]
assert "analytical:then" in rich_projection["payload"]["content"]

struct_request = {
    "id": "semantic-integration-structurizr",
    "representation": "structurizr-dsl",
    "view": "integration",
    "title": "Factory semantic integration",
    "upstreamNode": ibis_node,
    "layout": "lr",
}
struct_projection = render_structurizr_dsl(inspection, struct_request)
dsl = struct_projection["payload"]["content"]
assert 'workspace "Factory semantic integration"' in dsl
assert "!impliedRelationships false" in dsl
assert " = element " in dsl
assert "custom " in dsl
assert '"factory.id"' in dsl
assert cue_ref in dsl
assert ibis_node in dsl

for name, projection in (
    ("rich-render.json", rich_projection),
    ("structurizr-render.json", struct_projection),
):
    (tmp / name).write_text(json.dumps(projection, indent=2, sort_keys=True) + "\n", encoding="utf-8")

end_to_end = IntrospectionGraph.from_projections(
    cue_projection,
    python_projection,
    analytics_projection,
    rich_projection,
)
rich_artifact = "render:semantic-lineage-rich:artifact"
path = end_to_end.lineage_path(cue_ref, rich_artifact)
assert path.nodes[0] == cue_ref
assert python_ref in path.nodes
assert ibis_node in path.nodes
assert path.nodes[-1] == rich_artifact

merged = end_to_end.projection
(tmp / "render-inspection.json").write_text(json.dumps(merged, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

cue vet -c=false "$tmpdir/rich-render.json" ./contracts/state/*.cue -d '#RenderProjection'
cue vet -c=false "$tmpdir/structurizr-render.json" ./contracts/state/*.cue -d '#RenderProjection'
cue vet -c=false "$tmpdir/render-inspection.json" ./contracts/state/*.cue -d '#InspectionProjection'

echo "Observatory render projection validation passed"
