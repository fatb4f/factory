from __future__ import annotations

from typing import Any, Mapping, Sequence

from runtime.introspection import IntrospectionGraph
from runtime.marimo_adapter import render
from runtime.rich_adapter import render_rich_tree
from runtime.semantic_runtime import SemanticRuntime
from runtime.structurizr_adapter import render_structurizr_dsl
from runtime.workbook import AnalyticalExecutor, Workbook


WORKBOOK_PATH = "world/industrial-signals/workbook.py"


def bind(
    *,
    snapshot: Mapping[str, Any],
    bindings: Sequence[Mapping[str, Any]],
    runtime: SemanticRuntime,
    includes: Sequence[Mapping[str, Any]] = (),
    analytical_executor: AnalyticalExecutor | None = None,
    introspection_graph: IntrospectionGraph | None = None,
    introspection_bindings: Sequence[Mapping[str, Any]] = (),
) -> Workbook:
    """Bind this directory to admitted semantic/context state only."""
    return Workbook.here(
        WORKBOOK_PATH,
        snapshot=snapshot,
        bindings=bindings,
        runtime=runtime,
        includes=includes,
        analytical_executor=analytical_executor,
        introspection_graph=introspection_graph,
        introspection_bindings=introspection_bindings,
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


def inspector_views(
    workbook: Workbook,
    *,
    introspection_binding: Mapping[str, Any],
) -> tuple[dict[str, Any], ...]:
    """Select logical, integration, and lineage inspections from an explicit binding.

    The supplied binding is the only bridge from the directory-bound semantic
    subject to introspection node identity. This module never derives model roots
    from the workbook path, CUE package names, Python class names, or labels.
    """
    binding_id = str(introspection_binding["id"])
    roots = [str(root) for root in introspection_binding.get("roots", [])]
    if not roots:
        raise ValueError("industrial inspector requires an explicit introspection root binding")
    common = {"kind": "introspection", "binding": binding_id}
    return (
        {
            "id": "industrial-logical-model",
            "presentation": "inspection",
            "source": {
                **common,
                "request": {
                    "id": "inspect:industrial-signals:logical",
                    "roots": roots,
                    "direction": "both",
                    "maxDepth": 4,
                    "spaces": ["cue"],
                    "roles": ["structural", "model"],
                },
            },
        },
        {
            "id": "industrial-integration-model",
            "presentation": "inspection",
            "source": {
                **common,
                "request": {
                    "id": "inspect:industrial-signals:integration",
                    "roots": roots,
                    "direction": "both",
                    "maxDepth": 8,
                    "spaces": ["cue", "python", "analytics"],
                    "roles": ["structural", "model", "lineage", "analytical"],
                },
            },
        },
        {
            "id": "industrial-lineage",
            "presentation": "inspection",
            "source": {
                **common,
                "request": {
                    "id": "inspect:industrial-signals:lineage",
                    "roots": roots,
                    "direction": "outgoing",
                    "maxDepth": 12,
                    "spaces": ["cue", "python", "analytics"],
                    "roles": ["lineage", "analytical"],
                },
            },
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


def evaluate_inspector(
    workbook: Workbook,
    *,
    introspection_binding: Mapping[str, Any],
) -> dict[str, dict[str, Any]]:
    return {
        view["id"]: workbook.evaluate(view)
        for view in inspector_views(workbook, introspection_binding=introspection_binding)
    }


def render_inspector(
    result: Mapping[str, Any],
    *,
    representation: str,
    view: str,
    title: str | None = None,
    layout: str = "lr",
) -> dict[str, Any]:
    """Lower one workbook inspection result through a qualified render adapter."""
    if result.get("kind") != "InspectionViewResult":
        raise ValueError("industrial inspector rendering requires an InspectionViewResult")
    inspection = result["inspection"]
    roots = [str(root) for root in inspection.get("roots", [])]
    if not roots:
        raise ValueError("inspection result has no renderable root")
    request: dict[str, Any] = {
        "id": f"render:{result['viewID']}:{representation}",
        "representation": representation,
        "view": view,
        "title": title or str(result["viewID"]),
        "upstreamNode": roots[0],
    }
    if representation == "rich-tree":
        return render_rich_tree(inspection, request)
    if representation == "structurizr-dsl":
        request["layout"] = layout
        return render_structurizr_dsl(inspection, request)
    raise ValueError(f"unsupported industrial inspector representation: {representation!r}")


def render_inspector_pair(
    result: Mapping[str, Any],
    *,
    view: str,
    title: str | None = None,
    layout: str = "lr",
) -> dict[str, dict[str, Any]]:
    return {
        "rich-tree": render_inspector(
            result,
            representation="rich-tree",
            view=view,
            title=title,
            layout=layout,
        ),
        "structurizr-dsl": render_inspector(
            result,
            representation="structurizr-dsl",
            view=view,
            title=title,
            layout=layout,
        ),
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
