from __future__ import annotations

from typing import Any, Mapping, Sequence

from runtime.marimo_adapter import render
from runtime.semantic_runtime import SemanticRuntime
from runtime.workbook import AnalyticalExecutor, Workbook


WORKBOOK_PATH = "world/industrial-signals/workbook.py"


def bind(
    *,
    snapshot: Mapping[str, Any],
    bindings: Sequence[Mapping[str, Any]],
    runtime: SemanticRuntime,
    includes: Sequence[Mapping[str, Any]] = (),
    analytical_executor: AnalyticalExecutor | None = None,
) -> Workbook:
    """Bind this directory to admitted semantic/context state only."""
    return Workbook.here(
        WORKBOOK_PATH,
        snapshot=snapshot,
        bindings=bindings,
        runtime=runtime,
        includes=includes,
        analytical_executor=analytical_executor,
    )


def reference_views(
    workbook: Workbook,
    *,
    dense_request: Mapping[str, Any],
    trajectory_request: Mapping[str, Any],
    context_request: Mapping[str, Any],
) -> tuple[dict[str, Any], ...]:
    """Select bounded/context and admitted analytical projections.

    The workbook owns view selection only. Identity, domain semantics, analytical
    transformations, freshness, and admission remain upstream of this module.
    """
    primary = dict(workbook.scope.primary)
    return (
        {
            "id": "industrial-topology",
            "presentation": "topology",
            "source": {"kind": "bounded-navigation", "root": primary, "plane": "semantic", "maxDepth": 3},
        },
        {
            "id": "industrial-documentary-context",
            "presentation": "topology",
            "source": {"kind": "bounded-navigation", "root": primary, "plane": "documentary", "maxDepth": 2},
        },
        {
            "id": "industrial-tracker-context",
            "presentation": "topology",
            "source": {"kind": "bounded-navigation", "root": primary, "plane": "operational", "maxDepth": 2},
        },
        {
            "id": "industrial-event-watch-context",
            "presentation": "topology",
            "source": {"kind": "bounded-navigation", "root": primary, "plane": "evidential", "maxDepth": 2},
        },
        {
            "id": "industrial-records",
            "presentation": "table",
            "source": {"kind": "analytical", "request": dict(dense_request)},
        },
        {
            "id": "funding-trajectory",
            "presentation": "chart",
            "source": {"kind": "analytical", "request": dict(trajectory_request)},
        },
        {
            "id": "repository-context-index",
            "presentation": "table",
            "source": {"kind": "analytical", "request": dict(context_request)},
        },
    )


def evaluate_reference(
    workbook: Workbook,
    *,
    dense_request: Mapping[str, Any],
    trajectory_request: Mapping[str, Any],
    context_request: Mapping[str, Any],
) -> dict[str, dict[str, Any]]:
    return {
        view["id"]: workbook.evaluate(view)
        for view in reference_views(
            workbook,
            dense_request=dense_request,
            trajectory_request=trajectory_request,
            context_request=context_request,
        )
    }


def render_reference(
    workbook: Workbook,
    *,
    dense_request: Mapping[str, Any],
    trajectory_request: Mapping[str, Any],
    context_request: Mapping[str, Any],
) -> dict[str, dict[str, Any]]:
    projections = evaluate_reference(
        workbook,
        dense_request=dense_request,
        trajectory_request=trajectory_request,
        context_request=context_request,
    )
    return {view_id: render(projection) for view_id, projection in projections.items()}
