from __future__ import annotations

import copy
import json
from typing import Any, Mapping, Sequence


class MarimoCapabilityGap(RuntimeError):
    pass


def _canonical(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def _label(node: Mapping[str, Any]) -> str:
    if node["space"] == "semantic":
        semantic = node["semantic"]
        return str(semantic.get("subject") or node["id"])
    return str(node.get("artifact", {}).get("id") or node["id"])


def filter_projection(
    projection: Mapping[str, Any],
    *,
    node_ids: Sequence[str] | None = None,
    row_ids: Sequence[str] | None = None,
    series: Sequence[str] | None = None,
) -> dict[str, Any]:
    result = copy.deepcopy(dict(projection))
    if node_ids is not None:
        allowed_nodes = set(node_ids)
        result["nodes"] = [node for node in result.get("nodes", []) if node["id"] in allowed_nodes]
        result["edges"] = [
            edge
            for edge in result.get("edges", [])
            if edge["source"] in allowed_nodes and edge["target"] in allowed_nodes
        ]
    if row_ids is not None:
        allowed_rows = set(row_ids)
        result["rows"] = [row for row in result.get("rows", []) if row["id"] in allowed_rows]
    if series is not None:
        allowed_series = set(series)
        result["points"] = [point for point in result.get("points", []) if point["series"] in allowed_series]
    return result


def drilldown(projection: Mapping[str, Any], item_id: str) -> dict[str, Any]:
    for collection in ("nodes", "edges", "rows"):
        for item in projection.get(collection, []):
            if item.get("id") == item_id:
                return {
                    "snapshot": projection["snapshot"],
                    "subject": projection["subject"],
                    "collection": collection,
                    "item": copy.deepcopy(item),
                    "provenance": copy.deepcopy(item.get("provenance", projection.get("provenance", []))),
                }
    matches = [point for point in projection.get("points", []) if point.get("series") == item_id]
    if matches:
        return {
            "snapshot": projection["snapshot"],
            "subject": projection["subject"],
            "collection": "points",
            "item": copy.deepcopy(matches),
            "provenance": sorted({source for point in matches for source in point.get("provenance", [])}),
        }
    raise KeyError(item_id)


def render_topology(projection: Mapping[str, Any]) -> dict[str, Any]:
    nodes = sorted(projection.get("nodes", []), key=lambda item: item["id"])
    edges = sorted(projection.get("edges", []), key=lambda item: item["id"])
    aliases = {node["id"]: f"n{index}" for index, node in enumerate(nodes)}
    lines = ["flowchart TD"]
    for node in nodes:
        label = _label(node).replace('"', "'")
        lines.append(f'    {aliases[node["id"]]}["{label}"]')
        lines.append(f'    %% node {aliases[node["id"]]} id={node["id"]} space={node["space"]}')
    for edge in edges:
        if edge["source"] not in aliases or edge["target"] not in aliases:
            continue
        relation = str(edge["relation"]).replace('"', "'")
        plane = str(edge["plane"])
        basis = ",".join(str(item) for item in edge.get("basis", []))
        lines.append(f'    {aliases[edge["source"]]} -->|"{plane}:{relation}"| {aliases[edge["target"]]}')
        lines.append(f'    %% edge id={edge["id"]} plane={plane} basis={basis}')
    return {
        "kind": "mermaid",
        "text": "\n".join(lines) + "\n",
        "metadata": {
            "snapshot": projection["snapshot"],
            "subject": projection["subject"],
            "nodes": copy.deepcopy(nodes),
            "edges": copy.deepcopy(edges),
        },
    }


def render_table(projection: Mapping[str, Any]) -> dict[str, Any]:
    records: list[dict[str, Any]] = []
    for row in sorted(projection.get("rows", []), key=lambda item: item["id"]):
        record: dict[str, Any] = {"_id": row["id"]}
        for cell in row.get("cells", []):
            record[str(cell["field"])] = cell.get("value")
        records.append(record)
    return {
        "kind": "table",
        "records": records,
        "metadata": {
            "snapshot": projection["snapshot"],
            "subject": projection["subject"],
            "provenance": copy.deepcopy(projection.get("provenance", [])),
        },
    }


def _render_points(projection: Mapping[str, Any], kind: str) -> dict[str, Any]:
    points = sorted(
        projection.get("points", []),
        key=lambda item: (str(item["series"]), _canonical(item.get("x")), _canonical(item.get("y"))),
    )
    return {
        "kind": kind,
        "points": copy.deepcopy(points),
        "series": sorted({str(point["series"]) for point in points}),
        "metadata": {
            "snapshot": projection["snapshot"],
            "subject": projection["subject"],
            "provenance": copy.deepcopy(projection.get("provenance", [])),
        },
    }


def render(projection: Mapping[str, Any]) -> dict[str, Any]:
    presentation = str(projection["presentation"])
    if presentation == "topology":
        payload = render_topology(projection)
    elif presentation == "table":
        payload = render_table(projection)
    elif presentation == "chart":
        payload = _render_points(projection, "chart")
    elif presentation == "timeline":
        payload = _render_points(projection, "timeline")
    else:
        raise MarimoCapabilityGap(f"unsupported Marimo workbook presentation: {presentation!r}")
    return {
        "adapter": "factory.workbook.marimo/v1",
        "viewID": projection["viewID"],
        "presentation": presentation,
        "snapshot": projection["snapshot"],
        "subject": copy.deepcopy(projection["subject"]),
        "payload": payload,
    }
