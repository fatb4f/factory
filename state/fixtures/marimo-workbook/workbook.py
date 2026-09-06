"""Pure-Python workbook renderer fixture: no repository acquisition or admission."""

from __future__ import annotations

from runtime.marimo_adapter import render

SUBJECT = {
    "authority": {
        "id": "world.industrial-signals",
        "contract": "contracts/world/industrial-signals/contract.cue",
    },
    "subject": "world.industrial-signals",
    "kind": "graph",
}
SNAPSHOT = "sha256:" + "a" * 64

TOPOLOGY = {
    "apiVersion": "factory.workbook/v1",
    "kind": "ProjectionResult",
    "viewID": "fixture-topology",
    "presentation": "topology",
    "snapshot": SNAPSHOT,
    "subject": SUBJECT,
    "nodes": [
        {"space": "semantic", "id": "subject", "semantic": SUBJECT, "provenance": [SNAPSHOT]},
        {"space": "context", "id": "evidence", "artifact": {"id": "evidence"}, "plane": "evidential", "provenance": ["occ:evidence"]},
    ],
    "edges": [
        {"id": "edge:evidence", "plane": "evidential", "relation": "evidenced-by", "source": "subject", "target": "evidence", "basis": ["occ:evidence"], "provenance": ["occ:evidence"]}
    ],
    "rows": [],
    "points": [],
    "provenance": [SNAPSHOT],
}

TABLE = {
    **TOPOLOGY,
    "viewID": "fixture-table",
    "presentation": "table",
    "nodes": [],
    "edges": [],
    "rows": [
        {"id": "row:award", "cells": [{"field": "stage", "value": "award"}, {"field": "amount", "value": 1000000}]},
        {"id": "row:disbursement", "cells": [{"field": "stage", "value": "disbursement"}, {"field": "amount", "value": 500000}]},
    ],
}

CHART = {
    **TABLE,
    "viewID": "fixture-chart",
    "presentation": "chart",
    "rows": [],
    "points": [
        {"series": "funding", "x": "award", "y": 1000000, "provenance": ["record:award"]},
        {"series": "funding", "x": "disbursement", "y": 500000, "provenance": ["record:disbursement"]},
    ],
}

TIMELINE = {
    **CHART,
    "viewID": "fixture-timeline",
    "presentation": "timeline",
    "points": [
        {"series": "milestones", "x": "2026-03-01T00:00:00Z", "y": "construction-started", "provenance": ["record:milestone-1"]},
        {"series": "milestones", "x": "2026-07-15T00:00:00Z", "y": "equipment-installed", "provenance": ["record:milestone-2"]},
    ],
}


def render_fixture() -> dict[str, dict[str, object]]:
    return {name: render(value) for name, value in {"topology": TOPOLOGY, "table": TABLE, "chart": CHART, "timeline": TIMELINE}.items()}
