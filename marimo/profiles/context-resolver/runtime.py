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

    raw_budget = value.get("budget") or {}

    def bounded(name: str, default: int, low: int, high: int) -> int:
        result = raw_budget.get(name, default)
        if not isinstance(result, int):
            raise TypeError(f"budget.{name} must be an integer")
        return max(low, min(high, result))

    return {
        "schema": "factory.context-request.v0",
        "event": str(value.get("event", "interactive")),
        "prompt": prompt.strip(),
        "repo_root": str(Path(value.get("repo_root", ".")).resolve()),
        "tokens": sorted(set(re.findall(r"[a-z0-9_./-]+", prompt.lower()))),
        "scope": value.get("scope") or {},
        "budget": {
            "maxFragments": bounded("maxFragments", 12, 1, 32),
            "maxSteps": bounded("maxSteps", 8, 1, 32),
            "maxNodes": bounded("maxNodes", 48, 4, 128),
            "maxTokens": bounded("maxTokens", 6000, 256, 20000),
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
    output = json.loads(run.stdout)
    if not isinstance(output, dict):
        raise TypeError(f"{path}: output must be an object")
    return output


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

    def edge(source: str, target: str, kind: str) -> None:
        edges.append({"source": source, "target": target, "kind": kind})

    for boundary_id, boundary in boundaries.items():
        output = boundary["output"]
        boundary_selectors = list(boundary["selectors"])

        for local_id, fragment in output.get("fragments", {}).items():
            node_id = q(boundary_id, "fragment", local_id)
            nodes[node_id] = {
                "id": node_id,
                "boundary": boundary_id,
                "local_id": local_id,
                "kind": "fragment",
                "description": fragment["description"],
                "selectors": boundary_selectors
                + list(fragment.get("selectors") or []),
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
                    "selectors": boundary_selectors,
                    "requires": list(
                        (declaration.get("requires") or {}).keys()
                    ),
                    "command": declaration.get("command"),
                }

        for local_id, step in output.get("steps", {}).items():
            source = q(boundary_id, "step", local_id)
            for target in step.get("depends_on", {}):
                edge(source, q(boundary_id, "step", target), "depends-on")
            for target in step.get("fragments", {}):
                edge(
                    source,
                    q(boundary_id, "fragment", target),
                    "uses-fragment",
                )
            for target in step.get("checks", {}):
                edge(source, q(boundary_id, "check", target), "checked-by")
            for target in step.get("gates", {}):
                edge(source, q(boundary_id, "gate", target), "gated-by")

        for local_id, gate in output.get("gates", {}).items():
            for target in gate.get("requires", {}):
                edge(
                    q(boundary_id, "gate", local_id),
                    q(boundary_id, "check", target),
                    "requires",
                )

    return {"nodes": nodes, "edges": edges}


def filter_graph(
    graph: dict[str, Any], request: dict[str, Any]
) -> dict[str, Any]:
    tokens = set(request["tokens"])
    scope = request.get("scope") or {}
    allowed_boundaries = set(scope.get("boundaries") or [])
    candidates: list[dict[str, Any]] = []

    for node in graph["nodes"].values():
        if node["kind"] not in {"fragment", "step"}:
            continue
        if allowed_boundaries and node["boundary"] not in allowed_boundaries:
            continue
        text = " ".join(
            (
                node["id"],
                node["description"],
                " ".join(node.get("selectors", [])),
            )
        ).lower()
        matched = sorted(token for token in tokens if token in text)
        candidates.append(
            {
                "id": node["id"],
                "score": len(matched) * 10,
                "priority": int(node.get("priority", 0)),
                "matched": matched,
            }
        )

    candidates.sort(
        key=lambda item: (-item["score"], -item["priority"], item["id"])
    )
    seeds = [item for item in candidates if item["score"] > 0]
    control_id = "context-resolver:fragment:workbook"
    if control_id in graph["nodes"] and all(
        item["id"] != control_id for item in seeds
    ):
        seeds.append(
            {
                "id": control_id,
                "score": 0,
                "priority": 100,
                "matched": [],
            }
        )
    if not seeds:
        seeds = [
            item
            for item in candidates
            if item["id"].startswith("context-resolver:")
        ]

    seed_limit = (
        request["budget"]["maxFragments"] + request["budget"]["maxSteps"]
    )
    seeds = seeds[:seed_limit]

    outgoing: dict[str, list[dict[str, str]]] = defaultdict(list)
    incoming: dict[str, list[dict[str, str]]] = defaultdict(list)
    for item in graph["edges"]:
        outgoing[item["source"]].append(item)
        incoming[item["target"]].append(item)

    queue = deque(item["id"] for item in seeds)
    included: set[str] = set()
    while queue and len(included) < request["budget"]["maxNodes"]:
        node_id = queue.popleft()
        if node_id in included or node_id not in graph["nodes"]:
            continue
        included.add(node_id)
        queue.extend(item["target"] for item in outgoing[node_id])
        queue.extend(
            item["source"]
            for item in incoming[node_id]
            if item["kind"] in {"uses-fragment", "depends-on"}
        )

    return {
        "seeds": seeds,
        "nodes": {
            node_id: graph["nodes"][node_id]
            for node_id in sorted(included)
        },
        "edges": [
            item
            for item in graph["edges"]
            if item["source"] in included and item["target"] in included
        ],
        "scores": {item["id"]: item for item in candidates},
        "truncated": bool(queue),
    }


def _ordered_steps(selected: dict[str, Any]) -> list[str]:
    steps = {
        node_id
        for node_id, node in selected["nodes"].items()
        if node["kind"] == "step"
    }
    dependencies = {node_id: set() for node_id in steps}
    for item in selected["edges"]:
        if (
            item["kind"] == "depends-on"
            and item["source"] in steps
            and item["target"] in steps
        ):
            dependencies[item["source"]].add(item["target"])

    ordered: list[str] = []
    while dependencies:
        ready = sorted(
            node_id
            for node_id, values in dependencies.items()
            if not values
        )
        if not ready:
            ready = [sorted(dependencies)[0]]
        for node_id in ready:
            ordered.append(node_id)
            dependencies.pop(node_id)
            for values in dependencies.values():
                values.discard(node_id)
    return ordered


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
        key=lambda node: (
            -selected["scores"].get(node["id"], {}).get("score", 0),
            -int(node.get("priority", 0)),
            node["id"],
        )
    )
    for node in fragment_nodes[: request["budget"]["maxFragments"]]:
        path = (
            Path(node["boundary_path"]) / node["source"]["path"]
        ).resolve()
        try:
            path.relative_to(repo_root)
            content = path.read_text(encoding="utf-8", errors="replace")
        except Exception as exc:
            content = node["description"]
            source_errors.append(
                {"fragment": node["id"], "reason": str(exc)}
            )
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
    for node_id in _ordered_steps(selected)[: request["budget"]["maxSteps"]]:
        node = selected["nodes"][node_id]
        outgoing = [
            item for item in selected["edges"] if item["source"] == node_id
        ]
        plan.append(
            {
                "id": node_id,
                "description": node["description"],
                "depends_on": [
                    item["target"]
                    for item in outgoing
                    if item["kind"] == "depends-on"
                ],
                "fragments": [
                    item["target"]
                    for item in outgoing
                    if item["kind"] == "uses-fragment"
                ],
                "checks": [
                    item["target"]
                    for item in outgoing
                    if item["kind"] == "checked-by"
                ],
                "gates": [
                    item["target"]
                    for item in outgoing
                    if item["kind"] == "gated-by"
                ],
            }
        )

    references_admitted = all(
        item["source"] in graph["nodes"]
        and item["target"] in graph["nodes"]
        for item in selected["edges"]
    )
    checks = []
    for node in selected["nodes"].values():
        if node["kind"] != "check":
            continue
        status = "pending"
        if node["local_id"] == "references_admitted":
            status = "pass" if references_admitted else "fail"
        elif node["local_id"] == "sources_bounded":
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
        item
        for item in gates
        if item["id"].startswith("context-resolver:")
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
