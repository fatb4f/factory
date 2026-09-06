from __future__ import annotations

import hashlib
import json
from typing import Any, Mapping


class RenderProjectionError(RuntimeError):
    pass


class RenderCapabilityGap(RenderProjectionError):
    pass


def _canonical(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def _digest(value: Any) -> str:
    return "sha256:" + hashlib.sha256(_canonical(value)).hexdigest()


def _edge_id(relation: str, source: str, target: str) -> str:
    return "edge:" + hashlib.sha256(f"render\0{relation}\0{source}\0{target}".encode()).hexdigest()


def _attrs(**values: Any) -> list[dict[str, str]]:
    result: list[dict[str, str]] = []
    for key in sorted(values):
        value = values[key]
        if value is None:
            continue
        encoded = value if isinstance(value, str) else json.dumps(
            value, sort_keys=True, separators=(",", ":"), ensure_ascii=False
        )
        result.append({"key": key, "value": encoded})
    return result


def build_render_projection(
    inspection: Mapping[str, Any],
    request: Mapping[str, Any],
    *,
    media_type: str,
    content: str,
) -> dict[str, Any]:
    if inspection.get("kind") != "InspectionResult":
        raise RenderProjectionError("rendering requires a bounded InspectionResult")
    inspection_digest = str(inspection.get("digest") or "")
    if not inspection_digest.startswith("sha256:"):
        raise RenderProjectionError("inspection result lacks immutable digest")
    if not content:
        raise RenderProjectionError("render payload cannot be empty")

    request_id = str(request["id"])
    representation = str(request["representation"])
    if representation not in {"rich-tree", "structurizr-dsl"}:
        raise RenderCapabilityGap(f"unsupported render representation: {representation!r}")
    view = str(request["view"])
    if view not in {"inspection", "integration", "lineage"}:
        raise RenderCapabilityGap(f"unsupported render view: {view!r}")
    upstream = str(request["upstreamNode"])
    node_ids = {str(node["id"]) for node in inspection.get("nodes", [])}
    if upstream not in node_ids:
        raise RenderProjectionError("render upstreamNode is not present in the bounded inspection result")

    layout = request.get("layout")
    if layout is not None and layout not in {"tb", "bt", "lr", "rl"}:
        raise RenderCapabilityGap(f"unsupported render layout: {layout!r}")

    prefix = f"render:{request_id}"
    view_id = f"{prefix}:view"
    artifact_id = f"{prefix}:artifact"
    provenance = sorted(
        {
            inspection_digest,
            str(inspection["projectionDigest"]),
            upstream,
        }
    )
    normalized_request = {
        "id": request_id,
        "representation": representation,
        "view": view,
        "title": str(request["title"]),
        "upstreamNode": upstream,
        **({"layout": str(layout)} if layout is not None else {}),
    }
    nodes = [
        {
            "id": view_id,
            "space": "render",
            "kind": "view",
            "name": str(request["title"]),
            "qualifiedName": f"{representation}:{view}:{request_id}",
            "attributes": _attrs(representation=representation, view=view, layout=layout),
            "provenance": provenance,
        },
        {
            "id": artifact_id,
            "space": "render",
            "kind": "artifact",
            "name": representation,
            "qualifiedName": f"{representation}:{request_id}:artifact",
            "attributes": _attrs(mediaType=media_type),
            "provenance": provenance,
        },
    ]
    edges = [
        {
            "id": _edge_id("renders-as", upstream, view_id),
            "role": "render",
            "relation": "renders-as",
            "source": upstream,
            "target": view_id,
            "basis": [inspection_digest],
            "provenance": provenance,
        },
        {
            "id": _edge_id("materializes-as", view_id, artifact_id),
            "role": "render",
            "relation": "materializes-as",
            "source": view_id,
            "target": artifact_id,
            "basis": [representation, media_type],
            "provenance": provenance,
        },
    ]
    payload = {
        "apiVersion": "factory.introspection/v1",
        "kind": "RenderProjection",
        "sourceInspection": inspection_digest,
        "request": normalized_request,
        "nodes": sorted(nodes, key=lambda item: item["id"]),
        "edges": sorted(edges, key=lambda item: item["id"]),
        "payload": {"mediaType": media_type, "content": content},
    }
    result = dict(payload)
    result["digest"] = _digest(payload)
    return result
