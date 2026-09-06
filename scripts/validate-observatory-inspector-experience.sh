#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Compose the independently qualified workbook and industrial-reference gates.
bash scripts/validate-workbook-introspection.sh
bash scripts/validate-industrial-inspector.sh

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_INSPECTOR_EXPERIENCE_TMP="$tmpdir"

fixture_pkg=./world/industrial-signals/fixtures:industrialsignalsfixtures
cue export "$fixture_pkg" -e industrialWorkbookContextSnapshot --out json >"$tmpdir/context.json"
cue export "$fixture_pkg" -e industrialWorkbookBinding --out json >"$tmpdir/binding.json"
cat >"$tmpdir/model-config.json" <<EOF
{
  "repository": "github.com/fatb4f/factory",
  "revision": "$(git rev-parse HEAD)",
  "files": [
    "contracts/world/industrial-signals/contract.cue",
    "contracts/world/industrial-signals/snapshot-realization.cue"
  ]
}
EOF
python3 scripts/cue_model_introspection.py "$tmpdir/model-config.json" --root . --output "$tmpdir/logical.json"

PYTHONPATH=. python3 - <<'PY'
from __future__ import annotations

from dataclasses import dataclass
import importlib.util
from io import StringIO
import json
import os
from pathlib import Path

import ibis
from ibis.expr import types as ir
from rich.console import Console
from rich.text import Text

from runtime.ibis_adapter import lower_relational_plan
from runtime.introspection import IntrospectionGraph
from runtime.rich_adapter import render_rich_tree, to_rich_text
from runtime.semantic_metadata import project_python_model, semantic_type
from runtime.semantic_runtime import SemanticRuntime
from runtime.structurizr_adapter import render_structurizr_dsl


def dsl_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"').replace("\r", " ").replace("\n", "\\n")
    return f'"{escaped}"'


def compact_json(value: object) -> str:
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


tmp = Path(os.environ["OBS_INSPECTOR_EXPERIENCE_TMP"])
context = json.loads((tmp / "context.json").read_text())
directory_binding = json.loads((tmp / "binding.json").read_text())
logical = json.loads((tmp / "logical.json").read_text())
subject = directory_binding["subjects"][0]
cue_root = "cue:industrialsignals:#IndustrialGraphSnapshotRealization"


@semantic_type(
    cue_package="industrialsignals",
    cue_type="#IndustrialGraphSnapshotRealization",
    space="world.industrial-signals",
    source="contracts/world/industrial-signals/snapshot-realization.cue",
)
@dataclass(frozen=True)
class IndustrialGraphSnapshotRealization:
    project_id: str
    amount: float


python_projection = project_python_model([IndustrialGraphSnapshotRealization])
python_type = next(node["id"] for node in python_projection["nodes"] if node["kind"] == "type")
plan = {
    "kind": "RelationalPlan",
    "id": "industrial-inspector-real-ibis",
    "request": {
        "id": "industrial-inspector-real-ibis-request",
        "source": {
            "id": "industrial-inspector-real-source",
            "semanticRef": subject,
            "snapshotDigest": context["identity"]["digest"],
            "provenance": ["industrial-inspector-realization"],
            "admissibility": {
                "state": "admitted",
                "authority": "contracts/world/industrial-signals/contract.cue",
                "basis": ["industrial-inspector-realization"],
            },
        },
        "grain": {"unit": "project", "keys": ["project_id"]},
    },
    "steps": [
        {"kind": "filter", "predicate": "amount > 0", "basis": ["industrial-inspector-realization"]},
        {"kind": "project", "fields": ["project_id", "amount"]},
    ],
    "outputGrain": {"unit": "project", "keys": ["project_id"]},
    "provenance": {
        "authority": "contracts/state/analytics-ir.cue",
        "basis": ["industrial-inspector-realization"],
    },
}
source_table = ibis.table({"project_id": "string", "amount": "float64"}, name="industrial_inspector_source")
lowering = lower_relational_plan(
    plan,
    {"industrial-inspector-real-source": source_table},
    upstream_node=python_type,
)
assert isinstance(lowering.expression, ir.Table)
assert lowering.ibis_version == ibis.__version__
analytics_projection = lowering.introspection
ibis_node = f"analytics:{plan['id']}:ibis-expression"

graph = IntrospectionGraph.from_projections(logical, python_projection, analytics_projection)
inspection_binding = {
    "id": "inspection:world.industrial-signals:qualified",
    "subject": subject,
    "projection": graph.projection["digest"],
    "roots": [cue_root],
}

workbook_path = Path("world/industrial-signals/workbook.py")
spec = importlib.util.spec_from_file_location("industrial_signals_workbook", workbook_path)
assert spec is not None and spec.loader is not None
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
workbook = module.bind(
    snapshot=context,
    bindings=[directory_binding],
    runtime=SemanticRuntime(context),
    introspection_graph=graph,
    introspection_bindings=[inspection_binding],
)
results = module.evaluate_inspector(workbook, introspection_binding=inspection_binding)
lineage_result = results["industrial-lineage"]
inspection = lineage_result["inspection"]
node_ids = {node["id"] for node in inspection["nodes"]}
assert cue_root in node_ids
assert python_type in node_ids
assert ibis_node in node_ids
roles = {edge["role"] for edge in inspection["edges"]}
assert {"lineage", "analytical"} <= roles

rich_projection = render_rich_tree(
    inspection,
    {
        "id": "industrial-workbook-lineage-rich",
        "representation": "rich-tree",
        "view": "lineage",
        "title": "Industrial workbook semantic lineage",
        "upstreamNode": ibis_node,
    },
)
native_rich = to_rich_text(rich_projection)
assert isinstance(native_rich, Text)
buffer = StringIO()
Console(file=buffer, force_terminal=False, color_system=None, width=240).print(native_rich, end="")
rich_text = buffer.getvalue()
assert "Industrial workbook semantic lineage" in rich_text
assert "projects-to" in rich_text
assert "realizes-as" in rich_text
assert "lowers-to" in rich_text

struct_projection = render_structurizr_dsl(
    inspection,
    {
        "id": "industrial-workbook-lineage-structurizr",
        "representation": "structurizr-dsl",
        "view": "lineage",
        "title": "Industrial workbook semantic lineage",
        "upstreamNode": ibis_node,
        "layout": "lr",
    },
)
dsl = struct_projection["payload"]["content"]
assert "!impliedRelationships false" in dsl
assert cue_root in dsl
assert python_type in dsl
assert ibis_node in dsl
for edge in inspection["edges"]:
    assert str(edge["id"]) in dsl
    basis = compact_json(edge.get("basis", []))
    provenance = compact_json(edge.get("provenance", []))
    assert f'{dsl_quote("factory.basis")} {dsl_quote(basis)}' in dsl
    assert f'{dsl_quote("factory.provenance")} {dsl_quote(provenance)}' in dsl

end_to_end = IntrospectionGraph.from_projections(
    logical,
    python_projection,
    analytics_projection,
    rich_projection,
)
artifact = "render:industrial-workbook-lineage-rich:artifact"
path = end_to_end.lineage_path(cue_root, artifact)
assert python_type in path.nodes
assert ibis_node in path.nodes
assert path.nodes[-1] == artifact

(tmp / "lineage-result.json").write_text(json.dumps(lineage_result, indent=2, sort_keys=True) + "\n")
(tmp / "rich-render.json").write_text(json.dumps(rich_projection, indent=2, sort_keys=True) + "\n")
(tmp / "structurizr-render.json").write_text(json.dumps(struct_projection, indent=2, sort_keys=True) + "\n")
(tmp / "end-to-end.json").write_text(json.dumps(end_to_end.projection, indent=2, sort_keys=True) + "\n")
(tmp / "structurizr.dsl").write_text(dsl)
PY

cue vet -c=false "$tmpdir/lineage-result.json" ./contracts/state/*.cue -d '#InspectionViewResult'
cue vet -c=false "$tmpdir/rich-render.json" ./contracts/state/*.cue -d '#RenderProjection'
cue vet -c=false "$tmpdir/structurizr-render.json" ./contracts/state/*.cue -d '#RenderProjection'
cue vet -c=false "$tmpdir/end-to-end.json" ./contracts/state/*.cue -d '#InspectionProjection'

if [[ -n "${STRUCTURIZR_WAR:-}" ]]; then
  test -f "$STRUCTURIZR_WAR"
  java -jar "$STRUCTURIZR_WAR" validate -workspace "$tmpdir/structurizr.dsl"
elif command -v structurizr >/dev/null 2>&1; then
  structurizr validate -workspace "$tmpdir/structurizr.dsl"
else
  echo "Structurizr validation requires STRUCTURIZR_WAR or structurizr" >&2
  exit 1
fi

echo "Observatory semantic inspector experience validation passed"
