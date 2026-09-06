from __future__ import annotations

import hashlib
import json
import re
from collections import Counter
from typing import Any, Mapping

from .render_projection import RenderCapabilityGap, build_render_projection


def _quote(value: Any) -> str:
    text = str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\r", " ").replace("\n", "\\n")
    return f'"{text}"'


def _view_key(request_id: str) -> str:
    clean = re.sub(r"[^A-Za-z0-9]", "", request_id)
    if clean:
        return "Factory" + clean[:40]
    return "Factory" + hashlib.sha256(request_id.encode()).hexdigest()[:12]


def _json_property(value: Any) -> str:
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


def render_structurizr_dsl(inspection: Mapping[str, Any], request: Mapping[str, Any]) -> dict[str, Any]:
    if request.get("representation") != "structurizr-dsl":
        raise RenderCapabilityGap("Structurizr adapter requires request representation 'structurizr-dsl'")

    layout = str(request.get("layout", "lr"))
    if layout not in {"tb", "bt", "lr", "rl"}:
        raise RenderCapabilityGap(f"unsupported Structurizr layout: {layout!r}")

    nodes = sorted(inspection.get("nodes", []), key=lambda item: str(item["id"]))
    edges = sorted(inspection.get("edges", []), key=lambda item: str(item["id"]))
    aliases = {str(node["id"]): f"e{index:04d}" for index, node in enumerate(nodes)}
    relationship_counts = Counter(
        (
            str(edge["source"]),
            str(edge["target"]),
            str(edge["role"]),
            str(edge["relation"]),
        )
        for edge in edges
        if str(edge["source"]) in aliases and str(edge["target"]) in aliases
    )

    lines = [
        f"workspace {_quote(request['title'])} {_quote('Factory Observatory projection; downstream and non-authoritative.')} {{",
        "    !impliedRelationships false",
        "",
        "    model {",
    ]
    for node in nodes:
        node_id = str(node["id"])
        alias = aliases[node_id]
        metadata = f"{node['space']}:{node['kind']}"
        description = str(node.get("qualifiedName") or node_id)
        lines.append(f"        {alias} = element {_quote(node['label'])} {_quote(metadata)} {_quote(description)} {{")
        lines.append("            properties {")
        lines.append(f"                {_quote('factory.id')} {_quote(node_id)}")
        lines.append(f"                {_quote('factory.space')} {_quote(node['space'])}")
        lines.append(f"                {_quote('factory.kind')} {_quote(node['kind'])}")
        lines.append(f"                {_quote('factory.provenance')} {_quote(_json_property(node.get('provenance', [])))}")
        lines.append(f"                {_quote('factory.attributes')} {_quote(_json_property(node.get('attributes', [])))}")
        if node.get("qualifiedName"):
            lines.append(f"                {_quote('factory.qualifiedName')} {_quote(node['qualifiedName'])}")
        lines.append("            }")
        lines.append("        }")
    for index, edge in enumerate(edges):
        source_id = str(edge["source"])
        target_id = str(edge["target"])
        source = aliases.get(source_id)
        target = aliases.get(target_id)
        if source is None or target is None:
            continue
        edge_id = str(edge["id"])
        key = (source_id, target_id, str(edge["role"]), str(edge["relation"]))
        description = f"{edge['role']}:{edge['relation']}"
        if relationship_counts[key] > 1:
            description = f"{description} [{edge_id}]"
        relationship_alias = f"r{index:04d}"
        lines.append(f"        {relationship_alias} = {source} -> {target} {_quote(description)} {{")
        lines.append("            properties {")
        lines.append(f"                {_quote('factory.id')} {_quote(edge_id)}")
        lines.append(f"                {_quote('factory.role')} {_quote(edge['role'])}")
        lines.append(f"                {_quote('factory.relation')} {_quote(edge['relation'])}")
        lines.append(f"                {_quote('factory.source')} {_quote(source_id)}")
        lines.append(f"                {_quote('factory.target')} {_quote(target_id)}")
        lines.append(f"                {_quote('factory.basis')} {_quote(_json_property(edge.get('basis', [])))}")
        lines.append(f"                {_quote('factory.provenance')} {_quote(_json_property(edge.get('provenance', [])))}")
        if edge.get("label"):
            lines.append(f"                {_quote('factory.label')} {_quote(edge['label'])}")
        lines.append("            }")
        lines.append("        }")
    lines.extend(
        [
            "    }",
            "",
            "    views {",
            f"        custom {_quote(_view_key(str(request['id'])))} {_quote(request['title'])} {{",
            "            include *",
            f"            autoLayout {layout}",
            "        }",
            "    }",
            "}",
            "",
        ]
    )
    content = "\n".join(lines)
    return build_render_projection(
        inspection,
        request,
        media_type="text/vnd.structurizr.dsl; charset=utf-8",
        content=content,
    )
