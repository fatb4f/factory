#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_RENDER_TMP="$tmpdir"

PYTHONPATH=.:scripts python3 - <<'PY'
import json
import os
from io import StringIO
from pathlib import Path

import ibis
from ibis.expr import types as ir
from rich.console import Console
from rich.text import Text

from cue_model_introspection import compile_cue_model
from runtime.generated.semantic_context import (
    ContextArtifact,
    ContextArtifactRef,
    SemanticAuthorityRef,
    SemanticRef,
    SourceOccurrence,
)
from runtime.ibis_adapter import lower_relational_plan
from runtime.introspection import IntrospectionGraph
from runtime.render_projection import RenderCapabilityGap
from runtime.rich_adapter import render_rich_tree, to_rich_text
from runtime.semantic_metadata import project_python_model
from runtime.structurizr_adapter import render_structurizr_dsl

tmp = Path(os.environ["OBS_RENDER_TMP"])
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

real_plan = {
    "kind": "RelationalPlan",
    "id": "plan:render-real-ibis",
    "request": {
        "id": "render-real-ibis",
        "source": {
            "id": "render-source",
            "snapshotDigest": "sha256:" + "9" * 64,
            "semanticRef": {
                "authority": {
                    "id": "world.industrial-signals",
                    "contract": "contracts/world/industrial-signals/contract.cue",
                },
                "subject": "world.industrial-signals",
                "kind": "graph",
            },
            "provenance": ["render-real-ibis-fixture"],
            "admissibility": {
                "state": "admitted",
                "authority": "contracts/world/industrial-signals/contract.cue",
                "basis": ["render-real-ibis-fixture"],
            },
        },
        "grain": {"keys": ["id"], "unit": "row"},
    },
    "steps": [
        {"kind": "filter", "predicate": "amount > 0", "basis": ["render-real-ibis-fixture"]},
        {"kind": "project", "fields": ["id", "amount"]},
    ],
    "outputGrain": {"keys": ["id"], "unit": "row"},
    "provenance": {
        "authority": "contracts/state/analytics-ir.cue",
        "basis": ["render-real-ibis-fixture"],
    },
}
source_table = ibis.table({"id": "int64", "amount": "float64"}, name="render_source")
lowering = lower_relational_plan(
    real_plan,
    {"render-source": source_table},
    upstream_node=python_ref,
)
assert isinstance(lowering.expression, ir.Table)
assert lowering.ibis_version == ibis.__version__
analytics_projection = lowering.introspection
ibis_node = f"analytics:{real_plan['id']}:ibis-expression"
assert any(node["id"] == ibis_node for node in analytics_projection["nodes"])

graph = IntrospectionGraph.from_projections(cue_projection, python_projection, analytics_projection)
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
assert rich_projection["request"]["representation"] == "rich-tree"
assert rich_projection["payload"]["mediaType"] == "text/plain; charset=utf-8"
assert "Factory semantic lineage" in rich_projection["payload"]["content"]
assert "lineage:projects-to" in rich_projection["payload"]["content"]
assert "analytical:then" in rich_projection["payload"]["content"]

native_rich = to_rich_text(rich_projection)
assert isinstance(native_rich, Text)
rich_buffer = StringIO()
Console(file=rich_buffer, force_terminal=False, color_system=None, width=200).print(native_rich, end="")
assert "Factory semantic lineage" in rich_buffer.getvalue()

incoming_inspection = graph.inspect(
    {
        "id": "incoming-ibis-lineage",
        "roots": [ibis_node],
        "direction": "incoming",
        "maxDepth": 32,
        "roles": ["lineage", "analytical"],
    }
)
incoming_ids = {str(node["id"]) for node in incoming_inspection["nodes"]}
assert cue_ref in incoming_ids
assert python_ref in incoming_ids
incoming_projection = render_rich_tree(
    incoming_inspection,
    {
        "id": "incoming-ibis-rich",
        "representation": "rich-tree",
        "view": "lineage",
        "title": "Incoming Ibis lineage",
        "upstreamNode": ibis_node,
    },
)
incoming_content = incoming_projection["payload"]["content"]
assert "←" in incoming_content
for node in incoming_inspection["nodes"]:
    assert str(node["label"]) in incoming_content

wrong_rich_request = dict(rich_request)
wrong_rich_request["representation"] = "structurizr-dsl"
try:
    render_rich_tree(inspection, wrong_rich_request)
except RenderCapabilityGap:
    pass
else:
    raise AssertionError("Rich adapter accepted a structurizr-dsl request")

struct_request = {
    "id": "semantic-integration-structurizr",
    "representation": "structurizr-dsl",
    "view": "integration",
    "title": "Factory semantic integration",
    "upstreamNode": ibis_node,
    "layout": "lr",
}
struct_projection = render_structurizr_dsl(inspection, struct_request)
assert struct_projection["request"]["representation"] == "structurizr-dsl"
assert struct_projection["payload"]["mediaType"] == "text/vnd.structurizr.dsl; charset=utf-8"
dsl = struct_projection["payload"]["content"]
assert 'workspace "Factory semantic integration"' in dsl
assert "!impliedRelationships false" in dsl
assert " = element " in dsl
assert "custom " in dsl
assert '"factory.id"' in dsl
assert '"factory.basis"' in dsl
assert '"factory.provenance"' in dsl
assert cue_ref in dsl
assert ibis_node in dsl
for edge in inspection["edges"]:
    assert str(edge["id"]) in dsl

wrong_struct_request = dict(struct_request)
wrong_struct_request["representation"] = "rich-tree"
try:
    render_structurizr_dsl(inspection, wrong_struct_request)
except RenderCapabilityGap:
    pass
else:
    raise AssertionError("Structurizr adapter accepted a rich-tree request")

for name, projection in (
    ("rich-render.json", rich_projection),
    ("structurizr-render.json", struct_projection),
):
    (tmp / name).write_text(json.dumps(projection, indent=2, sort_keys=True) + "\n", encoding="utf-8")
(tmp / "structurizr.dsl").write_text(dsl, encoding="utf-8")

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

if [[ -n "${STRUCTURIZR_WAR:-}" ]]; then
    if [[ ! -f "$STRUCTURIZR_WAR" ]]; then
        echo "STRUCTURIZR_WAR does not exist: $STRUCTURIZR_WAR" >&2
        exit 1
    fi
    java -jar "$STRUCTURIZR_WAR" validate -workspace "$tmpdir/structurizr.dsl"
elif command -v structurizr >/dev/null 2>&1; then
    structurizr validate -workspace "$tmpdir/structurizr.dsl"
else
    echo "Structurizr validation requires STRUCTURIZR_WAR or the structurizr command" >&2
    exit 1
fi

echo "Observatory render projection validation passed"
