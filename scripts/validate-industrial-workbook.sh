#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_INDUSTRIAL_TMP="$tmpdir"

cue vet -c=false ./contracts/state:state
cue vet -c=false ./contracts/world/industrial-signals:industrialsignals
cue vet -c=false ./world/industrial-signals/fixtures:industrialsignalsfixtures

fixture_pkg=./world/industrial-signals/fixtures:industrialsignalsfixtures
cue export "$fixture_pkg" -e industrialWorkbookContextSnapshot --out json >"$tmpdir/context.json"
cue export "$fixture_pkg" -e industrialWorkbookBinding --out json >"$tmpdir/binding.json"
cue export "$fixture_pkg" -e industrialDenseTableRequest --out json >"$tmpdir/dense-request.json"
cue export "$fixture_pkg" -e fundingTrajectoryRequest --out json >"$tmpdir/trajectory-request.json"
cue export "$fixture_pkg" -e industrialContextIndexRequest --out json >"$tmpdir/context-request.json"
cue export "$fixture_pkg" -e graphSnapshotInput --out json >"$tmpdir/graph-input.json"
cue export "$fixture_pkg" -e watchRun --out json >"$tmpdir/watch-run.json"

PYTHONPATH=. python3 - <<'PY'
from __future__ import annotations

import ast
import importlib.util
import json
import os
from pathlib import Path
from typing import Any

from runtime.semantic_runtime import SemanticRuntime


tmp = Path(os.environ["OBS_INDUSTRIAL_TMP"])
context = json.loads((tmp / "context.json").read_text())
binding = json.loads((tmp / "binding.json").read_text())
dense_request = json.loads((tmp / "dense-request.json").read_text())
trajectory_request = json.loads((tmp / "trajectory-request.json").read_text())
context_request = json.loads((tmp / "context-request.json").read_text())
graph_input = json.loads((tmp / "graph-input.json").read_text())
watch_run = json.loads((tmp / "watch-run.json").read_text())

workbook_path = Path("world/industrial-signals/workbook.py")
spec = importlib.util.spec_from_file_location("industrial_signals_workbook", workbook_path)
assert spec is not None and spec.loader is not None
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

# The domain workbook may select projections but may not acquire, parse, refresh,
# reconcile identity, or admit domain state itself.
tree = ast.parse(workbook_path.read_text(encoding="utf-8"))
imports: set[str] = set()
for node in ast.walk(tree):
    if isinstance(node, ast.Import):
        imports.update(alias.name.split(".")[0] for alias in node.names)
    elif isinstance(node, ast.ImportFrom) and node.module:
        imports.add(node.module.split(".")[0])
assert imports <= {"__future__", "typing", "runtime"}, imports


def cells(**values: Any) -> list[dict[str, Any]]:
    result = []
    for field, value in values.items():
        if value is None:
            continue
        if isinstance(value, (dict, list)):
            value = json.dumps(value, sort_keys=True, separators=(",", ":"))
        result.append({"field": field, "value": value})
    return result or [{"field": "empty", "value": True}]


def dense_rows() -> list[dict[str, Any]]:
    rows = []
    for record in graph_input["records"]:
        provenance = record.get("provenance", {})
        rows.append({
            "id": record["id"],
            "cells": cells(
                kind=record.get("kind"),
                id=record.get("id"),
                state=record.get("state"),
                surface=record.get("surface"),
                flowKind=record.get("flowKind"),
                authorizedAt=record.get("authorizedAt"),
                occurredAt=record.get("occurredAt"),
                observedAt=record.get("observedAt"),
                startedAt=record.get("startedAt"),
                source=provenance.get("source"),
                recordID=provenance.get("recordID"),
                evidenceCount=len(record.get("evidence", [])),
            ),
        })
    return rows


def funding_points() -> list[dict[str, Any]]:
    points = []
    for record in graph_input["records"]:
        kind = record.get("kind")
        flow_kind = record.get("flowKind")
        stage = None
        when = None
        if kind == "funding-award":
            stage, when = "award", record.get("authorizedAt")
        elif kind == "funding-flow" and flow_kind == "disbursement":
            stage, when = "disbursement", record.get("occurredAt")
        elif kind == "funding-flow" and flow_kind == "audited-expenditure":
            stage, when = "expenditure", record.get("occurredAt")
        elif kind == "project-milestone":
            stage, when = "milestone", record.get("observedAt")
        elif kind == "outcome-observation":
            stage, when = "outcome", record.get("observedAt")
        if stage is not None:
            points.append({"series": stage, "x": when, "y": 1, "provenance": [record["id"]]})
    return points


def context_rows() -> list[dict[str, Any]]:
    rows = []
    for artifact in context["artifacts"]:
        occurrence = artifact["occurrence"]
        source = occurrence["source"]
        factory_issue_key = source["id"] if source["kind"] == "github-issue" else None
        rows.append({
            "id": artifact["id"],
            "cells": cells(
                id=artifact["id"],
                plane=artifact["plane"],
                role=artifact["role"],
                sourceKind=source["kind"],
                sourceID=source["id"],
                locator=occurrence["locator"],
                occurrence=occurrence["id"],
                factoryIssueKey=factory_issue_key,
            ),
        })
    for gap in context.get("coverageGaps", []):
        rows.append({
            "id": gap["id"],
            "cells": cells(id=gap["id"], plane=gap["plane"], role="coverage-gap", coverageGap=gap["description"]),
        })
    return rows


class FixtureExecutor:
    def execute(self, request, *, snapshot, subject):
        assert request["source"]["admissibility"]["state"] == "admitted"
        assert subject == binding["subjects"][0]
        request_id = request["id"]
        if request_id == dense_request["id"]:
            return {"rows": dense_rows()}
        if request_id == trajectory_request["id"]:
            return {"points": funding_points()}
        if request_id == context_request["id"]:
            return {"rows": context_rows()}
        raise AssertionError(f"unexpected analytical request: {request_id}")


runtime = SemanticRuntime(context)
workbook = module.bind(
    snapshot=context,
    bindings=[binding],
    runtime=runtime,
    analytical_executor=FixtureExecutor(),
)
assert workbook.scope.primary == binding["subjects"][0]

views = module.reference_views(
    workbook,
    dense_request=dense_request,
    trajectory_request=trajectory_request,
    context_request=context_request,
)
assert views[0]["source"]["root"] == workbook.scope.primary
assert views[0]["source"]["kind"] == "bounded-navigation"

projections = module.evaluate_reference(
    workbook,
    dense_request=dense_request,
    trajectory_request=trajectory_request,
    context_request=context_request,
)
rendered = module.render_reference(
    workbook,
    dense_request=dense_request,
    trajectory_request=trajectory_request,
    context_request=context_request,
)
assert rendered == module.render_reference(
    workbook,
    dense_request=dense_request,
    trajectory_request=trajectory_request,
    context_request=context_request,
)

# Canonical topology is semantic and snapshot-qualified; event-watch remains
# evidential and cannot appear as a semantic edge through workbook proximity.
topology = projections["industrial-topology"]
assert topology["edges"] and {edge["plane"] for edge in topology["edges"]} == {"semantic"}
event_context = projections["industrial-event-watch-context"]
assert event_context["edges"] and {edge["plane"] for edge in event_context["edges"]} == {"evidential"}
assert "artifact-industrial-event-watch" not in {node["id"] for node in topology["nodes"]}
watch_ids = {event["id"] for event in watch_run["events"]}
graph_ids = {record["id"] for record in graph_input["records"]}
assert watch_ids.isdisjoint(graph_ids)

# Response hypotheses and admitted responses remain different typed records.
dense = projections["industrial-records"]
records = {
    row["id"]: {cell["field"]: cell["value"] for cell in row["cells"]}
    for row in dense["rows"]
}
assert records["fixture.response.hypothesis"]["kind"] == "response-hypothesis"
assert records["fixture.response.hypothesis"]["state"] == "hypothesis"
assert records["fixture.response.admitted"]["kind"] == "admitted-response"
assert records["fixture.response.admitted"]["state"] == "admitted"

# Funding accountability stages remain mechanically distinct.
trajectory = projections["funding-trajectory"]
assert {point["series"] for point in trajectory["points"]} == {
    "award", "disbursement", "expenditure", "milestone", "outcome"
}

# Documentary proposal/decision state and operational tracker identity coexist
# with evidence and coverage gaps while retaining their planes and locators.
context_projection = projections["repository-context-index"]
context_records = {
    row["id"]: {cell["field"]: cell["value"] for cell in row["cells"]}
    for row in context_projection["rows"]
}
roles = {record.get("role") for record in context_records.values()}
assert {"documentation", "proposal", "decision", "tracker-projection", "event-watch-observation", "coverage-gap"} <= roles
tracker = context_records["artifact-industrial-workbook-tracker"]
assert tracker["plane"] == "operational"
assert tracker["factoryIssueKey"] == "engineering:graph:world.industrial-signals:projection:reference-workbook"
assert tracker["locator"] == "issues/149"
assert context_records["artifact-industrial-event-watch"]["plane"] == "evidential"
assert context_records["gap-industrial-audited-expenditure-coverage"]["plane"] == "evidential"

for view_id, projection in projections.items():
    (tmp / f"projection-{view_id}.json").write_text(json.dumps(projection, indent=2, sort_keys=True) + "\n")
PY

for projection in "$tmpdir"/projection-*.json; do
  cue vet -c=false "$projection" ./contracts/state/*.cue -d '#ProjectionResult'
done

echo "industrial workbook validation passed"
