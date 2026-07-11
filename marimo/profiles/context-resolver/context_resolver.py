# /// script
# requires-python = ">=3.11"
# dependencies = ["marimo"]
# ///

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import defaultdict, deque
from pathlib import Path
from typing import Any

import marimo

__generated_with = "0.19.0"
app = marimo.App(width="full")


def _normalize_request(value: dict[str, Any]) -> dict[str, Any]:
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
            "maxTokens": bounded("maxTokens", 6000, 256, 20_000),
        },
    }


def _cue_export(path: Path) -> dict[str, Any]:
    completed = subprocess.run(
        ["cue", "export", ".", "-e", "output", "--out", "json"],
        cwd=path,
        check=True,
        capture_output=True,
        text=True,
        timeout=10,
    )
    output = json.loads(completed.stdout)
    if not isinstance(output, dict):
        raise TypeError(f"{path}: output must be an object")
    return output


def _load_boundaries(
    request: dict[str, Any],
) -> tuple[dict[str, Any], list[dict[str, str]]]:
    root = Path(request["repo_root"]) / "marimo/profiles/context-resolver/.kb"
    try:
        parent = _cue_export(root)
    except Exception as exc:
        return {}, [{"boundary": "context-resolver", "reason": str(exc)}]

    loaded: dict[str, Any] = {}
    errors: list[dict[str, str]] = []
    for spec in parent.get("boundaries", {}).values():
        boundary_id = spec["id"]
        path = (root / spec["path"]).resolve()
        try:
            output = parent if boundary_id == "context-resolver" else _cue_export(path)
        except Exception as exc:
            errors.append({"boundary": boundary_id, "reason": str(exc)})
            continue
        loaded[boundary_id] = {
            "path": str(path),
            "selectors": list(spec.get("selectors") or []),
            "output": output,
        }
    return loaded, errors


def _build_graph(boundaries: dict[str, Any]) -> dict[str, Any]:
    nodes: dict[str, dict[str, Any]] = {}
    edges: list[dict[str, str]] = []

    def node_id(boundary: str, kind: str, local_id: str) -> str:
        return f"{boundary}:{kind}:{local_id}"

    def add_edge(source: str, target: str, kind: str) -> None:
        edges.append({"source": source, "target": target, "kind": kind})

    for boundary_id, boundary in boundaries.items():
        output = boundary["output"]
        selectors = list(boundary["selectors"])
        for local_id, fragment in output.get("fragments", {}).items():
            identity = node_id(boundary_id, "fragment", local_id)
            nodes[identity] = {
                "id": identity,
                "boundary": boundary_id,
                "local_id": local_id,
                "kind": "fragment",
                "description": fragment["description"],
                "selectors": selectors + list(fragment.get("selectors") or []),
                "priority": int(fragment.get("priority", 0)),
                "source": fragment["source"],
                "boundary_path": boundary["path"],
            }
        for kind, field in (("step", "steps"), ("check", "checks"), ("gate", "gates")):
            for local_id, declaration in output.get(field, {}).items():
                identity = node_id(boundary_id, kind, local_id)
                nodes[identity] = {
                    "id": identity,
                    "boundary": boundary_id,
                    "local_id": local_id,
                    "kind": kind,
                    "description": declaration["description"],
                    "selectors": selectors,
                    "requires": list((declaration.get("requires") or {}).keys()),
                    "command": declaration.get("command"),
                }
        for local_id, step in output.get("steps", {}).items():
            source = node_id(boundary_id, "step", local_id)
            for target in step.get("depends_on", {}):
                add_edge(source, node_id(boundary_id, "step", target), "depends-on")
            for target in step.get("fragments", {}):
                add_edge(source, node_id(boundary_id, "fragment", target), "uses-fragment")
            for target in step.get("checks", {}):
                add_edge(source, node_id(boundary_id, "check", target), "checked-by")
            for target in step.get("gates", {}):
                add_edge(source, node_id(boundary_id, "gate", target), "gated-by")
        for local_id, gate in output.get("gates", {}).items():
            for target in gate.get("requires", {}):
                add_edge(
                    node_id(boundary_id, "gate", local_id),
                    node_id(boundary_id, "check", target),
                    "requires",
                )
    return {"nodes": nodes, "edges": edges}


def _filter_graph(graph: dict[str, Any], request: dict[str, Any]) -> dict[str, Any]:
    tokens = set(request["tokens"])
    allowed = set((request.get("scope") or {}).get("boundaries") or [])
    candidates = []
    for node in graph["nodes"].values():
        if node["kind"] not in {"fragment", "step"}:
            continue
        if allowed and node["boundary"] not in allowed:
            continue
        text = " ".join(
            (node["id"], node["description"], " ".join(node.get("selectors", [])))
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
    candidates.sort(key=lambda item: (-item["score"], -item["priority"], item["id"]))
    seeds = [item for item in candidates if item["score"] > 0]
    control = "context-resolver:fragment:workbook"
    if control in graph["nodes"] and all(item["id"] != control for item in seeds):
        seeds.append({"id": control, "score": 0, "priority": 100, "matched": []})
    if not seeds:
        seeds = [item for item in candidates if item["id"].startswith("context-resolver:")]
    limit = request["budget"]["maxFragments"] + request["budget"]["maxSteps"]
    seeds = seeds[:limit]

    outgoing: dict[str, list[dict[str, str]]] = defaultdict(list)
    incoming: dict[str, list[dict[str, str]]] = defaultdict(list)
    for edge in graph["edges"]:
        outgoing[edge["source"]].append(edge)
        incoming[edge["target"]].append(edge)

    queue = deque(item["id"] for item in seeds)
    included: set[str] = set()
    while queue and len(included) < request["budget"]["maxNodes"]:
        identity = queue.popleft()
        if identity in included or identity not in graph["nodes"]:
            continue
        included.add(identity)
        queue.extend(edge["target"] for edge in outgoing[identity])
        queue.extend(
            edge["source"]
            for edge in incoming[identity]
            if edge["kind"] in {"uses-fragment", "depends-on"}
        )
    return {
        "seeds": seeds,
        "nodes": {identity: graph["nodes"][identity] for identity in sorted(included)},
        "edges": [
            edge
            for edge in graph["edges"]
            if edge["source"] in included and edge["target"] in included
        ],
        "scores": {item["id"]: item for item in candidates},
        "truncated": bool(queue),
    }


def _ordered_steps(selected: dict[str, Any]) -> list[str]:
    steps = {
        identity
        for identity, node in selected["nodes"].items()
        if node["kind"] == "step"
    }
    dependencies = {identity: set() for identity in steps}
    for edge in selected["edges"]:
        if edge["kind"] == "depends-on" and edge["source"] in steps and edge["target"] in steps:
            dependencies[edge["source"]].add(edge["target"])
    ordered: list[str] = []
    while dependencies:
        ready = sorted(identity for identity, values in dependencies.items() if not values)
        if not ready:
            ready = [sorted(dependencies)[0]]
        for identity in ready:
            ordered.append(identity)
            dependencies.pop(identity)
            for values in dependencies.values():
                values.discard(identity)
    return ordered


def _project_result(
    request: dict[str, Any],
    graph: dict[str, Any],
    selected: dict[str, Any],
    boundary_errors: list[dict[str, str]],
) -> dict[str, Any]:
    repo_root = Path(request["repo_root"]).resolve()
    max_chars = max(
        256,
        request["budget"]["maxTokens"] * 4 // request["budget"]["maxFragments"],
    )
    source_errors = []
    fragments = []
    fragment_nodes = [node for node in selected["nodes"].values() if node["kind"] == "fragment"]
    fragment_nodes.sort(
        key=lambda node: (
            -selected["scores"].get(node["id"], {}).get("score", 0),
            -int(node.get("priority", 0)),
            node["id"],
        )
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
                    selected["scores"].get(node["id"], {}).get("matched", [])
                )
                or "dependency closure",
            }
        )

    plan = []
    for identity in _ordered_steps(selected)[: request["budget"]["maxSteps"]]:
        node = selected["nodes"][identity]
        outgoing = [edge for edge in selected["edges"] if edge["source"] == identity]
        plan.append(
            {
                "id": identity,
                "description": node["description"],
                "depends_on": [edge["target"] for edge in outgoing if edge["kind"] == "depends-on"],
                "fragments": [edge["target"] for edge in outgoing if edge["kind"] == "uses-fragment"],
                "checks": [edge["target"] for edge in outgoing if edge["kind"] == "checked-by"],
                "gates": [edge["target"] for edge in outgoing if edge["kind"] == "gated-by"],
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
        required = [f"{node['boundary']}:check:{item}" for item in node.get("requires", [])]
        gates.append(
            {
                "id": node["id"],
                "description": node["description"],
                "satisfied": bool(required)
                and all(check_status.get(identity) == "pass" for identity in required),
            }
        )

    unresolved = boundary_errors + source_errors
    if selected["truncated"]:
        unresolved.append({"kind": "budget", "reason": "maxNodes reached"})
    self_gates = [item for item in gates if item["id"].startswith("context-resolver:")]
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


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _():
    # app.run(defs=...) replaces this isolated input definition.
    workbook_request = {
        "schema": "factory.context-request.v0",
        "event": "interactive",
        "prompt": "context resolver",
        "repo_root": ".",
        "budget": {
            "maxFragments": 12,
            "maxSteps": 8,
            "maxNodes": 48,
            "maxTokens": 6000,
        },
    }
    return (workbook_request,)


@app.cell
def _(workbook_request):
    normalized_request = _normalize_request(workbook_request)
    return (normalized_request,)


@app.cell
def _(normalized_request):
    loaded_boundaries, boundary_errors = _load_boundaries(normalized_request)
    return boundary_errors, loaded_boundaries


@app.cell
def _(loaded_boundaries):
    available_context_graph = _build_graph(loaded_boundaries)
    return (available_context_graph,)


@app.cell
def _(available_context_graph, normalized_request):
    filtered_context_graph = _filter_graph(available_context_graph, normalized_request)
    return (filtered_context_graph,)


@app.cell
def _(
    available_context_graph,
    boundary_errors,
    filtered_context_graph,
    normalized_request,
):
    workbook_result = _project_result(
        normalized_request,
        available_context_graph,
        filtered_context_graph,
        boundary_errors,
    )
    return (workbook_result,)


@app.cell
def _(mo, workbook_result):
    mo.vstack(
        [
            mo.md("# Context resolver"),
            mo.md(
                "The reactive workbook DAG filters CUE-authoritative nested "
                "context graphs into a bounded Codex packet."
            ),
            mo.json(workbook_result),
        ]
    )
    return


_ALLOWED_HOOK_FIELDS = {
    "agent_id",
    "agent_type",
    "cwd",
    "hook_event_name",
    "model",
    "permission_mode",
    "prompt",
    "session_id",
    "transcript_path",
    "turn_id",
}


def _read_hook_event() -> dict[str, Any]:
    value = json.load(sys.stdin)
    if not isinstance(value, dict):
        raise ValueError("hook input must be an object")
    if set(value) - _ALLOWED_HOOK_FIELDS:
        raise ValueError("hook input contains unknown fields")
    if value.get("hook_event_name") != "UserPromptSubmit":
        raise ValueError("unsupported hook event")
    prompt = value.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip():
        raise ValueError("prompt must be a non-empty string")
    return value


def _run_codex_hook(repo_root: Path) -> int:
    event = _read_hook_event()
    request = {
        "schema": "factory.context-request.v0",
        "event": "UserPromptSubmit",
        "prompt": event["prompt"],
        "repo_root": str(repo_root.resolve()),
        "budget": {
            "maxFragments": 12,
            "maxSteps": 8,
            "maxNodes": 48,
            "maxTokens": 6000,
        },
    }
    _outputs, definitions = app.run(defs={"workbook_request": request})
    result = definitions.get("workbook_result")
    if not isinstance(result, dict):
        raise RuntimeError("workbook did not define workbook_result")
    if not result.get("admitted"):
        raise RuntimeError("workbook context packet was not admitted")
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": json.dumps(
                    result,
                    ensure_ascii=False,
                    separators=(",", ":"),
                ),
            }
        },
        sys.stdout,
        ensure_ascii=False,
        separators=(",", ":"),
    )
    sys.stdout.write("\n")
    return 0


def _main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--codex-hook", action="store_true")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    args, marimo_args = parser.parse_known_args()
    if args.codex_hook:
        return _run_codex_hook(args.repo_root)
    sys.argv = [sys.argv[0], *marimo_args]
    app.run()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(_main())
    except Exception as exc:
        print(f"factory context resolver: {exc}", file=sys.stderr)
        raise SystemExit(2) from exc
