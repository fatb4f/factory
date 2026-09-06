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
) -> list[str]:
    lines: list[str] = []
    seen: set[str] = set()

    def walk(node_id: str, prefix: str, connector: str, edge_label: str | None = None) -> None:
        node = nodes[node_id]
        lead = f"{connector}{edge_label} → " if edge_label else connector
        cycle = node_id in seen
        lines.append(prefix + lead + _node_label(node) + (" ↩" if cycle else ""))
        if cycle:
            return
        seen.add(node_id)
        children = [
            edge for edge in outgoing.get(node_id, [])
            if str(edge["target"]) in nodes
        ]
        children.sort(key=lambda edge: (str(edge["role"]), str(edge["relation"]), str(edge["target"])))
        for index, edge in enumerate(children):
            last = index == len(children) - 1
            child_connector = "└─ " if last else "├─ "
            child_prefix = prefix + ("   " if last else "│  ")
            label = f"{edge['role']}:{edge['relation']}"
            walk(str(edge["target"]), child_prefix, child_connector, label)

    walk(root, "", "")
    return lines


def render_rich_tree(inspection: Mapping[str, Any], request: Mapping[str, Any]) -> dict[str, Any]:
    nodes = {str(node["id"]): node for node in inspection.get("nodes", [])}
    outgoing: dict[str, list[Mapping[str, Any]]] = defaultdict(list)
    for edge in inspection.get("edges", []):
        outgoing[str(edge["source"])].append(edge)

    lines = [str(request["title"])]
    for root in inspection.get("roots", []):
        root_id = str(root)
        if root_id not in nodes:
            continue
        lines.extend(_render_root(root_id, nodes, outgoing))
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
