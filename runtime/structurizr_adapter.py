from __future__ import annotations

import hashlib
import re
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


def render_structurizr_dsl(inspection: Mapping[str, Any], request: Mapping[str, Any]) -> dict[str, Any]:
    layout = str(request.get("layout", "lr"))
    if layout not in {"tb", "bt", "lr", "rl"}:
        raise RenderCapabilityGap(f"unsupported Structurizr layout: {layout!r}")

    nodes = sorted(inspection.get("nodes", []), key=lambda item: str(item["id"]))
    edges = sorted(inspection.get("edges", []), key=lambda item: str(item["id"]))
    aliases = {str(node["id"]): f"e{index:04d}" for index, node in enumerate(nodes)}

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
        provenance = ",".join(str(item) for item in node.get("provenance", []))
        if provenance:
            lines.append(f"                {_quote('factory.provenance')} {_quote(provenance)}")
        lines.append("            }")
        lines.append("        }")
    for edge in edges:
        source = aliases.get(str(edge["source"]))
        target = aliases.get(str(edge["target"]))
        if source is None or target is None:
            continue
        description = f"{edge['role']}:{edge['relation']}"
        lines.append(f"        {source} -> {target} {_quote(description)}")
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
