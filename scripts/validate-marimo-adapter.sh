#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

PYTHONPATH=. python3 - <<'PY'
from copy import deepcopy
import importlib.util
from pathlib import Path

from runtime.marimo_adapter import MarimoCapabilityGap, drilldown, filter_projection, render

fixture_path = Path("state/fixtures/marimo-workbook/workbook.py")
spec = importlib.util.spec_from_file_location("marimo_workbook_fixture", fixture_path)
module = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(module)

first = module.render_fixture()
second = module.render_fixture()
assert first == second
assert first["topology"]["payload"]["kind"] == "mermaid"
mermaid = first["topology"]["payload"]["text"]
assert "evidential:evidenced-by" in mermaid
assert "basis=occ:evidence" in mermaid
assert first["table"]["payload"]["records"][0]["_id"] == "row:award"
assert first["chart"]["payload"]["series"] == ["funding"]
assert first["timeline"]["payload"]["series"] == ["milestones"]

original = deepcopy(module.TOPOLOGY)
filtered = filter_projection(module.TOPOLOGY, node_ids=["subject"])
assert filtered["snapshot"] == module.TOPOLOGY["snapshot"]
assert filtered["subject"] == module.TOPOLOGY["subject"]
assert module.TOPOLOGY == original
assert len(filtered["nodes"]) == 1 and filtered["edges"] == []

node_detail = drilldown(module.TOPOLOGY, "evidence")
assert node_detail["collection"] == "nodes"
assert node_detail["item"]["plane"] == "evidential"
assert "occ:evidence" in node_detail["provenance"]
edge_detail = drilldown(module.TOPOLOGY, "edge:evidence")
assert edge_detail["item"]["basis"] == ["occ:evidence"]

unsupported = {**module.TOPOLOGY, "viewID": "property-graph", "presentation": "property-graph"}
try:
    render(unsupported)
except MarimoCapabilityGap:
    pass
else:
    raise AssertionError("property-graph presentation should remain a typed Marimo gap until #150")
PY

grep -Fq 'from runtime.marimo_adapter import render' state/fixtures/marimo-workbook/workbook.py
! grep -Eq 'requests|urllib|subprocess|repository_context|acquir|admit|refresh' state/fixtures/marimo-workbook/workbook.py

echo "marimo adapter validation passed"
