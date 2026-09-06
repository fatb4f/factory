#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_INDUSTRIAL_INSPECTOR_TMP="$tmpdir"

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
import json
import os
from pathlib import Path

from runtime.ibis_adapter import project_analytics_model
from runtime.introspection import IntrospectionGraph
from runtime.semantic_metadata import project_python_model, semantic_type
from runtime.semantic_runtime import SemanticRuntime


tmp = Path(os.environ["OBS_INDUSTRIAL_INSPECTOR_TMP"])
context = json.loads((tmp / "context.json").read_text())
directory_binding = json.loads((tmp / "binding.json").read_text())
logical = json.loads((tmp / "logical.json").read_text())
subject = directory_binding["subjects"][0]
cue_root = "cue:industrialsignals:#IndustrialGraphSnapshotRealization"
assert cue_root in {node["id"] for node in logical["nodes"]}


@semantic_type(
    cue_package="industrialsignals",
    cue_type="#IndustrialGraphSnapshotRealization",
    space="world.industrial-signals",
    source="contracts/world/industrial-signals/snapshot-realization.cue",
)
@dataclass(frozen=True)
class IndustrialGraphSnapshotRealization:
    snapshot: str


python_projection = project_python_model([IndustrialGraphSnapshotRealization])
python_type = next(node["id"] for node in python_projection["nodes"] if node["kind"] == "type")
plan = {
    "kind": "RelationalPlan",
    "id": "industrial-inspector-plan",
    "request": {
        "id": "industrial-inspector-request",
        "source": {
            "id": "industrial-inspector-source",
            "semanticRef": subject,
            "snapshotDigest": context["identity"]["digest"],
            "provenance": ["industrial-inspector-fixture"],
            "admissibility": {"state": "admitted", "basis": ["industrial-inspector-fixture"]},
        },
        "grain": {"unit": "project", "keys": ["project_id"]},
    },
    "steps": [{"kind": "project", "fields": ["project_id", "amount"]}],
    "outputGrain": {"unit": "project", "keys": ["project_id"]},
    "provenance": {"basis": ["industrial-inspector-fixture"]},
}
analytics_projection = project_analytics_model(plan, upstream_node=python_type)
graph = IntrospectionGraph.from_projections(logical, python_projection, analytics_projection)
inspection_binding = {
    "id": "inspection:world.industrial-signals",
    "subject": subject,
    "projection": graph.projection["digest"],
    "roots": [cue_root],
}

workbook_path = Path("world/industrial-signals/workbook.py")
spec = importlib.util.spec_from_file_location("industrial_signals_workbook", workbook_path)
assert spec is not None and spec.loader is not None
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

runtime = SemanticRuntime(context)
workbook = module.bind(
    snapshot=context,
    bindings=[directory_binding],
    runtime=runtime,
    introspection_graph=graph,
    introspection_bindings=[inspection_binding],
)

legacy_ids = [
    view["id"]
    for view in module.reference_views(
        workbook,
        dense_request={"id": "dense"},
        trajectory_request={"id": "trajectory"},
        context_request={"id": "context"},
    )
]
assert legacy_ids == [
    "industrial-topology",
    "industrial-documentary-context",
    "industrial-tracker-context",
    "industrial-event-watch-context",
    "industrial-records",
    "funding-trajectory",
    "repository-context-index",
]

views = module.inspector_views(workbook, introspection_binding=inspection_binding)
assert [view["id"] for view in views] == [
    "industrial-logical-model",
    "industrial-integration-model",
    "industrial-lineage",
]
assert all(view["source"]["binding"] == inspection_binding["id"] for view in views)
assert all(view["source"]["request"]["roots"] == [cue_root] for view in views)

results = module.evaluate_inspector(workbook, introspection_binding=inspection_binding)
logical_result = results["industrial-logical-model"]
integration_result = results["industrial-integration-model"]
lineage_result = results["industrial-lineage"]
assert {node["space"] for node in logical_result["inspection"]["nodes"]} == {"cue"}
assert {"cue", "python", "analytics"} <= {node["space"] for node in integration_result["inspection"]["nodes"]}
lineage_relations = {edge["relation"] for edge in lineage_result["inspection"]["edges"]}
assert {"projects-to", "realizes-as", "lowers-to"} <= lineage_relations

rendered = module.render_inspector_pair(
    integration_result,
    view="integration",
    title="Industrial Signals Integration",
)
assert rendered["rich-tree"]["request"]["representation"] == "rich-tree"
assert rendered["structurizr-dsl"]["request"]["representation"] == "structurizr-dsl"
assert "IndustrialGraphSnapshotRealization" in rendered["rich-tree"]["payload"]["content"]
assert "!impliedRelationships false" in rendered["structurizr-dsl"]["payload"]["content"]

# The inspector is downstream only: current event-watch and graph-target execution
# remain distinct definitions in the authoritative CUE model, and legacy workbook
# views are unchanged rather than reconstructed from inspection adjacency.
logical_ids = {node["id"] for node in logical["nodes"]}
assert "cue:industrialsignals:#EventWatchExecution" in logical_ids
assert "cue:industrialsignals:#IndustrialGraphExecution" in logical_ids

for name, result in results.items():
    (tmp / f"{name}.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
for representation, projection in rendered.items():
    safe = representation.replace("-", "_")
    (tmp / f"render_{safe}.json").write_text(json.dumps(projection, indent=2, sort_keys=True) + "\n")
PY

for result in "$tmpdir"/industrial-*.json; do
  cue vet -c=false "$result" ./contracts/state/*.cue -d '#InspectionViewResult'
done
for projection in "$tmpdir"/render_*.json; do
  cue vet -c=false "$projection" ./contracts/state/*.cue -d '#RenderProjection'
done

echo "Industrial semantic inspector validation passed"
