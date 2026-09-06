from __future__ import annotations

from collections import defaultdict
from typing import Any, Mapping

from .render_projection import RenderCapabilityGap, build_render_projection


def _node_label(node: Mapping[str, Any]) -> str:
    return f"{node['label']} [{node['space']}/{node['kind']}]"


def _render_root(
    root: str,
    nodes: Mapping[str, Mapping[str, Any]],
    outgoing: Mapping[str, list[Mapping[str, Any]]],
    incoming: Mapping[str, list[Mapping[str, Any]]],
) -> list[str]:
    lines: list[str] = []
    seen: set[str] = set()

    def walk(
        node_id: str,
        prefix: str,
        connector: str,
        edge_label: str | None = None,
        direction: str | None = None,
        parent_edge_id: str | None = None,
    ) -> None:
        node = nodes[node_id]
        if edge_label:
            arrow = "→" if direction == "outgoing" else "←"
            lead = f"{connector}{edge_label} {arrow} "
        else:
            lead = connector
        cycle = node_id in seen
        lines.append(prefix + lead + _node_label(node) + (" ↩" if cycle else ""))
        if cycle:
            return
        seen.add(node_id)

        neighbors: list[tuple[str, Mapping[str, Any], str]] = []
        for edge in outgoing.get(node_id, []):
            if str(edge["id"]) == parent_edge_id:
                continue
            target = str(edge["target"])
            if target in nodes:
                neighbors.append((target, edge, "outgoing"))
        for edge in incoming.get(node_id, []):
            if str(edge["id"]) == parent_edge_id:
                continue
            source = str(edge["source"])
            if source in nodes:
                neighbors.append((source, edge, "incoming"))
        neighbors.sort(
            key=lambda item: (
                str(item[1]["role"]),
                str(item[1]["relation"]),
                item[2],
                item[0],
                str(item[1]["id"]),
            )
        )
        for index, (neighbor_id, edge, edge_direction) in enumerate(neighbors):
            last = index == len(neighbors) - 1
            child_connector = "└─ " if last else "├─ "
            child_prefix = prefix + ("   " if last else "│  ")
            label = f"{edge['role']}:{edge['relation']}"
            walk(
                neighbor_id,
                child_prefix,
                child_connector,
                label,
                edge_direction,
                str(edge["id"]),
            )

    walk(root, "", "")
    return lines


def render_rich_tree(inspection: Mapping[str, Any], request: Mapping[str, Any]) -> dict[str, Any]:
    if request.get("representation") != "rich-tree":
        raise RenderCapabilityGap("Rich adapter requires request representation 'rich-tree'")

    nodes = {str(node["id"]): node for node in inspection.get("nodes", [])}
    outgoing: dict[str, list[Mapping[str, Any]]] = defaultdict(list)
    incoming: dict[str, list[Mapping[str, Any]]] = defaultdict(list)
    for edge in inspection.get("edges", []):
        outgoing[str(edge["source"])].append(edge)
        incoming[str(edge["target"])].append(edge)

    lines = [str(request["title"])]
    for root in inspection.get("roots", []):
        root_id = str(root)
        if root_id not in nodes:
            continue
        lines.extend(_render_root(root_id, nodes, outgoing, incoming))
    if len(lines) == 1:
        for node_id in sorted(nodes):
            lines.append(_node_label(nodes[node_id]))
    content = "\n".join(lines) + "\n"
    return build_render_projection(
        inspection,
        request,
        media_type="text/plain; charset=utf-8",
        content=content,
    )


def to_rich_text(projection: Mapping[str, Any]) -> Any:
    if projection.get("kind") != "RenderProjection" or projection.get("request", {}).get("representation") != "rich-tree":
        raise RenderCapabilityGap("native Rich realization requires a rich-tree RenderProjection")
    try:
        from rich.text import Text
    except ModuleNotFoundError as exc:
        raise RenderCapabilityGap("native Rich realization requires the optional 'rich' dependency") from exc
    return Text(str(projection["payload"]["content"]))
