from __future__ import annotations

import json
import re
import subprocess
from collections import defaultdict, deque
from pathlib import Path
from typing import Any


def normalize_request(value: dict[str, Any]) -> dict[str, Any]:
    prompt = value.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip():
        raise ValueError("prompt must be a non-empty string")
    budget = value.get("budget") or {}
    return {
        "schema": "factory.context-request.v0",
        "event": str(value.get("event", "interactive")),
        "prompt": prompt.strip(),
        "repo_root": str(Path(value.get("repo_root", ".")).resolve()),
        "tokens": sorted(set(re.findall(r"[a-z0-9_./-]+", prompt.lower()))),
        "scope": value.get("scope") or {},
        "budget": {
            "maxFragments": int(budget.get("maxFragments", 12)),
            "maxSteps": int(budget.get("maxSteps", 8)),
            "maxNodes": int(budget.get("maxNodes", 48)),
            "maxTokens": int(budget.get("maxTokens", 6000)),
        },
    }


def cue_export(path: Path) -> dict[str, Any]:
    run = subprocess.run(
        ["cue", "export", ".", "-e", "output", "--out", "json"],
        cwd=path,
        check=True,
        capture_output=True,
        text=True,
        timeout=10,
    )
    value = json.loads(run.stdout)
    if not isinstance(value, dict):
        raise TypeError(f"{path}: output must be an object")
    return value


def load_boundaries(
    request: dict[str, Any],
) -> tuple[dict[str, Any], list[dict[str, str]]]:
    root = Path(request["repo_root"]) / "marimo/profiles/context-resolver/.kb"
    try:
        parent = cue_export(root)
    except Exception as exc:
        return {}, [{"boundary": "context-resolver", "reason": str(exc)}]

    loaded: dict[str, Any] = {}
    errors: list[dict[str, str]] = []
    for spec in parent.get("boundaries", {}).values():
        boundary_id = spec["id"]
        path = (root / spec["path"]).resolve()
        try:
            output = parent if boundary_id == "context-resolver" else cue_export(path)
        except Exception as exc:
            errors.append({"boundary": boundary_id, "reason": str(exc)})
            continue
        loaded[boundary_id] = {
            "path": str(path),
            "selectors": list(spec.get("selectors") or []),
            "output": output,
        }
    return loaded, errors


def build_graph(boundaries: dict[str, Any]) -> dict[str, Any]:
    nodes: dict[str, dict[str, Any]] = {}
    edges: list[dict[str, str]] = []

    def q(boundary: str, kind: str, local_id: str) -> str:
        return f"{boundary}:{kind}:{local_id}"

    for boundary_id, boundary in boundaries.items():
        output = boundary["output"]
        selectors = boundary["selectors"]

        for local_id, fragment in output.get("fragments", {}).items():
            node_id = q(boundary_id, "fragment", local_id)
            nodes[node_id] = {
                "id": node_id,
                "boundary": boundary_id,
                "local_id": local_id,
                "kind": "fragment",
                "description": fragment["description"],
                "selectors": selectors + list(fragment.get("selectors") or []),
                "priority": int(fragment.get("priority", 0)),
                "source": fragment["source"],
                "boundary_path": boundary["path"],
            }

        for kind, field in (
            ("step", "steps"),
            ("check", "checks"),
            ("gate", "gates"),
        ):
            for local_id, declaration in output.get(field, {}).items():
                node_id = q(boundary_id, kind, local_id)
                nodes[node_id] = {
                    "id": node_id,
                    "boundary": boundary_id,
                    "local_id": local_id,
                    "kind": kind,
                    "description": declaration["description"],
                    "requires": list(
                        (declaration.get("requires") or {}).keys()
                    ),
                    "command": declaration.get("command"),
                }

        for local_id, step in output.get("steps", {}).items():
            source = q(boundary_id, "step", local_id)
            for target in step.get("depends_on", {}):
                edges.append(
                    {
                        "source": source,
                        "target": q(boundary_id, "step", target),
                        "kind": "depends-on",
                    }
                )
            for target in step.get("fragments", {}):
                edges.append(
                    {
                        "source": source,
                        "target": q(boundary_id, "fragment", target),
                        "kind": "uses-fragment",
                    }
                )
            for target in step.get("checks", {}):
                edges.append(
                    {
                        "source": source,
                        "target": q(boundary_id, "check", target),
                        "kind": "checked-by",
                    }
                )
            for target in step.get("gates", {}):
                edges.append(
                    {
                        "source": source,
                        "target": q(boundary_id, "gate", target),
                        "kind": "gated-by",
                    }
                )

        for local_id, gate in output.get("gates", {}).items():
            for target in gate.get("requires", {}):
                edges.append(
                    {
                        "source": q(boundary_id, "gate", local_id),
                        "target": q(boundary_id, "check", target),
                        "kind": "requires",
                    }
                )

    return {"nodes": nodes, "edges": edges}


def filter_graph(
    graph: dict[str, Any], request: dict[str, Any]
) -> dict[str, Any]:
    tokens = set(request["tokens"])
    candidates = []
    for node in graph["nodes"].values():
        if node["kind"] not in {"fragment", "step"}:
            continue
        text = " ".join(
            [
                node["id"],
                node["description"],
                " ".join(node.get("selectors", [])),
            ]
        ).lower()
        matched = sorted(token for token in tokens if token in text)
        score = len(matched) * 10 + int(node.get("priority", 0))
        candidates.append(
            {"id": node["id"], "score": score, "matched": matched}
        )

    candidates.sort(key=lambda item: (-item["score"], item["id"]))
    seeds = [item for item in candidates if item["score"] > 0]
    if not seeds:
        seeds = [
            item
            for item in candidates
            if item["id"].startswith("context-resolver:")
        ]
    seeds = seeds[
        : request["budget"]["maxFragments"]
        + request["budget"]["maxSteps"]
    ]

    outgoing: dict[str, list[dict[str, str]]] = defaultdict(list)
    incoming: dict[str, list[dict[str, str]]] = defaultdict(list)
    for edge in graph["edges"]:
        outgoing[edge["source"]].append(edge)
        incoming[edge["target"]].append(edge)

    queue = deque(item["id"] for item in seeds)
    included: set[str] = set()
    while queue and len(included) < request["budget"]["maxNodes"]:
        node_id = queue.popleft()
        if node_id in included or node_id not in graph["nodes"]:
            continue
        included.add(node_id)
        queue.extend(edge["target"] for edge in outgoing[node_id])
        queue.extend(
            edge["source"]
            for edge in incoming[node_id]
            if edge["kind"] == "uses-fragment"
        )

    return {
        "seeds": seeds,
        "nodes": {
            node_id: graph["nodes"][node_id]
            for node_id in sorted(included)
        },
        "edges": [
            edge
            for edge in graph["edges"]
            if edge["source"] in included and edge["target"] in included
        ],
        "scores": {item["id"]: item for item in candidates},
        "truncated": bool(queue),
    }


def project_result(
    request: dict[str, Any],
    graph: dict[str, Any],
    selected: dict[str, Any],
    boundary_errors: list[dict[str, str]],
) -> dict[str, Any]:
    repo_root = Path(request["repo_root"]).resolve()
    max_chars = max(
        256,
        request["budget"]["maxTokens"]
        * 4
        // request["budget"]["maxFragments"],
    )

    fragments = []
    source_errors = []
    fragment_nodes = [
        node
        for node in selected["nodes"].values()
        if node["kind"] == "fragment"
    ]
    fragment_nodes.sort(
        key=lambda node: -selected["scores"]
        .get(node["id"], {})
        .get("score", 0)
    )
    for node in fragment_nodes[: request["budget"]["maxFragments"]]:
        path = (Path(node["boundary_path"]) / node["source"]["path"]).resolve()
        try:
            path.relative_to(repo_root)
            content = path.read_text(encoding="utf-8", errors="replace")
        except Exception as exc:
            content = node["description"]
            source_errors.append({"fragment": node["id"], "reason": str(exc)})
        fragments.append(
            {
                "id": node["id"],
                "source": node["source"],
                "content": content[:max_chars],
                "reason": ", ".join(
                    selected["scores"]
                    .get(node["id"], {})
                    .get("matched", [])
                )
                or "dependency closure",
            }
        )

    plan = []
    for node in selected["nodes"].values():
        if node["kind"] != "step" or len(plan) >= request["budget"]["maxSteps"]:
            continue
        outgoing = [
            edge for edge in selected["edges"] if edge["source"] == node["id"]
        ]
        plan.append(
            {
                "id": node["id"],
                "description": node["description"],
                "depends_on": [
                    edge["target"]
                    for edge in outgoing
                    if edge["kind"] == "depends-on"
                ],
                "fragments": [
                    edge["target"]
                    for edge in outgoing
                    if edge["kind"] == "uses-fragment"
                ],
                "checks": [
                    edge["target"]
                    for edge in outgoing
                    if edge["kind"] == "checked-by"
                ],
                "gates": [
                    edge["target"]
                    for edge in outgoing
                    if edge["kind"] == "gated-by"
                ],
            }
        )

    references_admitted = all(
        edge["source"] in graph["nodes"] and edge["target"] in graph["nodes"]
        for edge in selected["edges"]
    )
    checks = []
    for node in selected["nodes"].values():
        if node["kind"] != "check":
            continue
        status = (
            "pass"
            if node["local_id"] == "references_admitted" and references_admitted
            else "pending"
        )
        if node["local_id"] == "sources_bounded":
            status = "pass" if not source_errors else "fail"
        checks.append(
            {
                "id": node["id"],
                "description": node["description"],
                "status": status,
                "command": node.get("command"),
            }
        )

    check_status = {item["id"]: item["status"] for item in checks}
    gates = []
    for node in selected["nodes"].values():
        if node["kind"] != "gate":
            continue
        required = [
            f"{node['boundary']}:check:{item}"
            for item in node.get("requires", [])
        ]
        satisfied = bool(required) and all(
            check_status.get(item) == "pass" for item in required
        )
        gates.append(
            {
                "id": node["id"],
                "description": node["description"],
                "satisfied": satisfied,
            }
        )

    unresolved = boundary_errors + source_errors
    if selected["truncated"]:
        unresolved.append({"kind": "budget", "reason": "maxNodes reached"})

    self_gates = [
        item for item in gates if item["id"].startswith("context-resolver:")
    ]
    return {
        "schema": "factory.context-packet.v0",
        "authority": False,
        "generated": True,
        "transient": True,
        "admitted": bool(fragments)
        and bool(self_gates)
        and all(item["satisfied"] for item in self_gates),
        "request": request,
        "context_graph": {
            "seeds": selected["seeds"],
            "nodes": list(selected["nodes"].values()),
            "edges": selected["edges"],
            "truncated": selected["truncated"],
        },
        "selected_fragments": fragments,
        "implementation_plan": plan,
        "checks": checks,
        "gates": gates,
        "unresolved_context": unresolved,
    }
