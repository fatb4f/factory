# /// script
# requires-python = ">=3.11"
# dependencies = ["marimo"]
# ///

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

import marimo

__generated_with = "0.19.0"
app = marimo.App(width="full")


@app.cell
def _():
    import json
    import re
    import subprocess
    from pathlib import Path
    from typing import Any

    import marimo as mo

    def qualify(boundary: str, kind: str, local_id: str) -> str:
        return f"{boundary}.{kind}.{local_id}"

    def local_id(resource: dict[str, Any], prefix: str) -> str:
        value = resource.get("local_id")
        if isinstance(value, str) and value:
            return value
        name = str(resource["name"])
        marker = f"{prefix}."
        return name[len(marker) :] if name.startswith(marker) else name

    def normalize(value: dict[str, Any]) -> dict[str, Any]:
        prompt = value.get("prompt")
        if not isinstance(prompt, str) or not prompt.strip():
            raise ValueError("prompt must be a non-empty string")
        raw_budget = value.get("budget") or {}

        def budget(name: str, default: int, low: int, high: int) -> int:
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
                "maxFragments": budget("maxFragments", 12, 1, 32),
                "maxSteps": budget("maxSteps", 8, 1, 32),
                "maxNodes": budget("maxNodes", 48, 4, 128),
                "maxTokens": budget("maxTokens", 6000, 256, 20_000),
            },
        }

    def cue_export(path: Path) -> dict[str, Any]:
        completed = subprocess.run(
            ["cue", "export", ".", "-e", "output", "--out", "json"],
            cwd=path,
            check=False,
            capture_output=True,
            text=True,
            timeout=15,
        )
        if completed.returncode != 0:
            reason = (completed.stderr or completed.stdout).strip()
            raise RuntimeError(
                reason or f"cue export failed with {completed.returncode}"
            )
        output = json.loads(completed.stdout)
        if not isinstance(output, dict):
            raise TypeError(f"{path}: output must be an object")
        return output

    def load(request: dict[str, Any]):
        root = Path(request["repo_root"]) / "marimo/profiles/context-resolver/.kb"
        allowed = set((request.get("scope") or {}).get("boundaries") or [])
        try:
            parent = cue_export(root)
        except Exception as exc:
            return {}, [{"boundary": "context-resolver", "reason": str(exc)}]

        boundaries: dict[str, dict[str, Any]] = {}
        errors: list[dict[str, str]] = []
        for spec in parent.get("boundaries", {}).values():
            identity = spec["id"]
            if allowed and identity != "context-resolver" and identity not in allowed:
                continue
            path = (root / spec["path"]).resolve()
            try:
                output = parent if identity == "context-resolver" else cue_export(path)
                context = output.get("context")
                workflow = output.get("workflow")
                if not isinstance(context, dict) or context.get("valid") is not True:
                    raise ValueError("context graph projection is missing or invalid")
                if not isinstance(workflow, dict) or workflow.get("valid") is not True:
                    raise ValueError("workflow graph projection is missing or invalid")
            except Exception as exc:
                errors.append({"boundary": identity, "reason": str(exc)})
                continue
            boundaries[identity] = {
                "path": str(path),
                "selectors": list(spec.get("selectors") or []),
                "output": output,
            }
        return boundaries, errors

    def topology_order(projection: dict[str, Any]) -> list[str]:
        def layer_key(name: str) -> tuple[int, str]:
            try:
                return int(name.rsplit("_", 1)[1]), name
            except (IndexError, ValueError):
                return 0, name

        ordered: list[str] = []
        for layer in sorted(projection.get("topology", {}), key=layer_key):
            ordered.extend(sorted(projection["topology"][layer]))
        known = set(ordered)
        ordered.extend(
            sorted(
                resource_id
                for resource_id in projection.get("resources", {})
                if resource_id not in known
            )
        )
        return ordered

    def closure(projection: dict[str, Any], resource_id: str) -> set[str]:
        resources = projection.get("resources", {})
        if resource_id not in resources:
            return set()
        resource = resources[resource_id]
        result = {resource_id}
        result.update(resource.get("ancestors", {}))
        result.update(projection.get("dependents", {}).get(resource_id, {}))
        return {item for item in result if item in resources}

    def select(boundaries: dict[str, Any], request: dict[str, Any]):
        tokens = set(request["tokens"])
        allowed = set((request.get("scope") or {}).get("boundaries") or [])
        candidates: list[dict[str, Any]] = []

        for boundary, item in boundaries.items():
            if allowed and boundary != "context-resolver" and boundary not in allowed:
                continue
            output = item["output"]
            for kind, field, prefix in (
                ("fragment", "context", "fragment"),
                ("step", "workflow", "step"),
            ):
                for graph_id, resource in output[field].get("resources", {}).items():
                    local = local_id(resource, prefix)
                    packet_id = qualify(boundary, kind, local)
                    selectors = list(item["selectors"]) + list(
                        resource.get("selectors") or []
                    )
                    text = " ".join(
                        (
                            packet_id,
                            str(resource.get("description", "")),
                            " ".join(selectors),
                        )
                    ).lower()
                    matched = sorted(token for token in tokens if token in text)
                    candidates.append(
                        {
                            "id": packet_id,
                            "boundary": boundary,
                            "kind": kind,
                            "graph_id": graph_id,
                            "score": len(matched) * 10,
                            "priority": int(resource.get("priority", 0)),
                            "matched": matched,
                        }
                    )

        candidates.sort(
            key=lambda item: (-item["score"], -item["priority"], item["id"])
        )
        seeds = [item for item in candidates if item["score"] > 0]
        control_id = qualify("context-resolver", "fragment", "workbook")
        control = next((item for item in candidates if item["id"] == control_id), None)
        if control is not None and all(item["id"] != control_id for item in seeds):
            seeds.append(control)
        if not seeds:
            seeds = [
                item for item in candidates if item["boundary"] == "context-resolver"
            ]
        seeds = seeds[
            : request["budget"]["maxFragments"] + request["budget"]["maxSteps"]
        ]

        selected: dict[str, dict[str, set[str]]] = {
            boundary: {"context": set(), "workflow": set()} for boundary in boundaries
        }

        def include(boundary: str, field: str, graph_id: str) -> bool:
            projection = boundaries[boundary]["output"][field]
            expanded = closure(projection, graph_id)
            before = len(selected[boundary][field])
            selected[boundary][field].update(expanded)
            return len(selected[boundary][field]) != before

        for seed in seeds:
            field = "context" if seed["kind"] == "fragment" else "workflow"
            include(seed["boundary"], field, seed["graph_id"])

        changed = True
        while changed:
            changed = False
            for boundary, fields in selected.items():
                output = boundaries[boundary]["output"]
                fragment_locals = {
                    local_id(output["context"]["resources"][graph_id], "fragment")
                    for graph_id in fields["context"]
                }
                for graph_id, step in output["workflow"].get("resources", {}).items():
                    if fragment_locals.intersection(step.get("fragments", {})):
                        changed = include(boundary, "workflow", graph_id) or changed
                for graph_id in tuple(fields["workflow"]):
                    step = output["workflow"]["resources"][graph_id]
                    for fragment in step.get("fragments", {}):
                        changed = (
                            include(boundary, "context", f"fragment.{fragment}")
                            or changed
                        )

        ordered_refs: list[tuple[str, str, str]] = []
        for boundary in sorted(selected):
            output = boundaries[boundary]["output"]
            for graph_id in topology_order(output["context"]):
                if graph_id in selected[boundary]["context"]:
                    ordered_refs.append((boundary, "context", graph_id))
            for graph_id in topology_order(output["workflow"]):
                if graph_id in selected[boundary]["workflow"]:
                    ordered_refs.append((boundary, "workflow", graph_id))

        truncated = len(ordered_refs) > request["budget"]["maxNodes"]
        retained = set(ordered_refs[: request["budget"]["maxNodes"]])
        for boundary in selected:
            selected[boundary]["context"] = {
                graph_id
                for candidate_boundary, field, graph_id in retained
                if candidate_boundary == boundary and field == "context"
            }
            selected[boundary]["workflow"] = {
                graph_id
                for candidate_boundary, field, graph_id in retained
                if candidate_boundary == boundary and field == "workflow"
            }

        return {
            "seeds": [
                {key: item[key] for key in ("id", "score", "matched")} for item in seeds
            ],
            "selected": selected,
            "scores": {item["id"]: item for item in candidates},
            "truncated": truncated,
        }

    def project(request, boundaries, selected, boundary_errors):
        repo_root = Path(request["repo_root"]).resolve()
        max_chars = max(
            256,
            request["budget"]["maxTokens"] * 4 // request["budget"]["maxFragments"],
        )
        nodes: list[dict[str, Any]] = []
        edges: list[dict[str, str]] = []
        source_errors: list[dict[str, str]] = []
        fragment_candidates: list[tuple[str, str, dict[str, Any]]] = []
        plan: list[dict[str, Any]] = []
        selected_checks: dict[str, set[str]] = {}
        selected_gates: dict[str, set[str]] = {}

        for boundary in sorted(boundaries):
            output = boundaries[boundary]["output"]
            chosen = selected["selected"].get(
                boundary, {"context": set(), "workflow": set()}
            )
            selected_checks[boundary] = set()
            selected_gates[boundary] = set()

            for graph_id in sorted(chosen["context"]):
                resource = output["context"]["resources"][graph_id]
                local = local_id(resource, "fragment")
                identity = qualify(boundary, "fragment", local)
                node = {
                    "id": identity,
                    "boundary": boundary,
                    "kind": "fragment",
                    "local_id": local,
                    "description": resource.get("description", ""),
                    "depth": resource.get("depth", 0),
                }
                nodes.append(node)
                fragment_candidates.append((boundary, identity, resource))
                for dependency in resource.get("depends_on", {}):
                    dependency_resource = output["context"]["resources"].get(
                        dependency, {"name": dependency}
                    )
                    edges.append(
                        {
                            "source": identity,
                            "target": qualify(
                                boundary,
                                "fragment",
                                local_id(dependency_resource, "fragment"),
                            ),
                            "kind": "depends-on",
                        }
                    )

            workflow_resources = output["workflow"]["resources"]
            for graph_id in topology_order(output["workflow"]):
                if graph_id not in chosen["workflow"]:
                    continue
                resource = workflow_resources[graph_id]
                local = local_id(resource, "step")
                identity = qualify(boundary, "step", local)
                nodes.append(
                    {
                        "id": identity,
                        "boundary": boundary,
                        "kind": "step",
                        "local_id": local,
                        "description": resource.get("description", ""),
                        "depth": resource.get("depth", 0),
                    }
                )
                dependencies = []
                for dependency in resource.get("depends_on", {}):
                    dependency_resource = workflow_resources.get(
                        dependency, {"name": dependency}
                    )
                    target = qualify(
                        boundary,
                        "step",
                        local_id(dependency_resource, "step"),
                    )
                    dependencies.append(target)
                    edges.append(
                        {"source": identity, "target": target, "kind": "depends-on"}
                    )
                fragments = [
                    qualify(boundary, "fragment", fragment)
                    for fragment in resource.get("fragments", {})
                ]
                checks = [
                    qualify(boundary, "check", check)
                    for check in resource.get("checks", {})
                ]
                gates = [
                    qualify(boundary, "gate", gate)
                    for gate in resource.get("gates", {})
                ]
                selected_checks[boundary].update(resource.get("checks", {}))
                selected_gates[boundary].update(resource.get("gates", {}))
                edges.extend(
                    {"source": identity, "target": target, "kind": "uses-fragment"}
                    for target in fragments
                )
                edges.extend(
                    {"source": identity, "target": target, "kind": "checked-by"}
                    for target in checks
                )
                edges.extend(
                    {"source": identity, "target": target, "kind": "gated-by"}
                    for target in gates
                )
                plan.append(
                    {
                        "id": identity,
                        "description": resource.get("description", ""),
                        "depends_on": dependencies,
                        "fragments": fragments,
                        "checks": checks,
                        "gates": gates,
                    }
                )

        score_map = selected["scores"]
        fragment_candidates.sort(
            key=lambda item: (
                -score_map.get(item[1], {}).get("score", 0),
                -int(item[2].get("priority", 0)),
                item[1],
            )
        )
        fragments = []
        for boundary, identity, resource in fragment_candidates[
            : request["budget"]["maxFragments"]
        ]:
            path = (
                Path(boundaries[boundary]["path"]) / resource["source"]["path"]
            ).resolve()
            try:
                path.relative_to(repo_root)
                with path.open(encoding="utf-8", errors="replace") as source:
                    content = source.read(max_chars)
            except Exception as exc:
                content = str(resource.get("description", ""))
                source_errors.append({"fragment": identity, "reason": str(exc)})
            fragments.append(
                {
                    "id": identity,
                    "boundary": boundary,
                    "source": resource["source"],
                    "content": content,
                    "reason": ", ".join(score_map.get(identity, {}).get("matched", []))
                    or "Apercue graph closure",
                }
            )

        references_admitted = not boundary_errors and all(
            item["output"]["context"].get("valid") is True
            and item["output"]["workflow"].get("valid") is True
            for item in boundaries.values()
        )

        for boundary, gate_ids in selected_gates.items():
            for gate_id in gate_ids:
                gate = boundaries[boundary]["output"].get("gates", {}).get(gate_id, {})
                selected_checks[boundary].update(gate.get("requires", {}))

        checks = []
        for boundary in sorted(selected_checks):
            declarations = boundaries[boundary]["output"].get("checks", {})
            for check_id in sorted(selected_checks[boundary]):
                declaration = declarations[check_id]
                status = "pending"
                if check_id == "references_admitted":
                    status = "pass" if references_admitted else "fail"
                elif check_id == "sources_bounded":
                    status = "pass" if not source_errors else "fail"
                identity = qualify(boundary, "check", check_id)
                nodes.append(
                    {
                        "id": identity,
                        "boundary": boundary,
                        "kind": "check",
                        "local_id": check_id,
                        "description": declaration["description"],
                    }
                )
                checks.append(
                    {
                        "id": identity,
                        "description": declaration["description"],
                        "status": status,
                        "command": declaration.get("command"),
                    }
                )

        check_status = {item["id"]: item["status"] for item in checks}
        gates = []
        for boundary in sorted(selected_gates):
            declarations = boundaries[boundary]["output"].get("gates", {})
            for gate_id in sorted(selected_gates[boundary]):
                declaration = declarations[gate_id]
                identity = qualify(boundary, "gate", gate_id)
                required = [
                    qualify(boundary, "check", check_id)
                    for check_id in declaration.get("requires", {})
                ]
                satisfied = bool(required) and all(
                    check_status.get(check_id) == "pass" for check_id in required
                )
                nodes.append(
                    {
                        "id": identity,
                        "boundary": boundary,
                        "kind": "gate",
                        "local_id": gate_id,
                        "description": declaration["description"],
                    }
                )
                edges.extend(
                    {"source": identity, "target": check_id, "kind": "requires"}
                    for check_id in required
                )
                gates.append(
                    {
                        "id": identity,
                        "description": declaration["description"],
                        "satisfied": satisfied,
                    }
                )

        graph_truncated = (
            selected["truncated"]
            or len(nodes) > request["budget"]["maxNodes"]
        )
        if len(nodes) > request["budget"]["maxNodes"]:
            nodes = nodes[: request["budget"]["maxNodes"]]
            retained_node_ids = {node["id"] for node in nodes}
            edges = [
                edge
                for edge in edges
                if edge["source"] in retained_node_ids
                and edge["target"] in retained_node_ids
            ]

        unresolved = list(boundary_errors) + source_errors
        if graph_truncated:
            unresolved.append({"kind": "budget", "reason": "maxNodes reached"})
        self_gates = [
            item for item in gates if item["id"].startswith("context-resolver.gate.")
        ]
        result = {
            "schema": "factory.context-packet.v0",
            "authority": False,
            "generated": True,
            "transient": True,
            "admitted": False,
            "request": request,
            "context_graph": {
                "seeds": selected["seeds"],
                "nodes": nodes,
                "edges": edges,
                "truncated": graph_truncated,
            },
            "selected_fragments": fragments,
            "implementation_plan": plan[: request["budget"]["maxSteps"]],
            "checks": checks,
            "gates": gates,
            "unresolved_context": unresolved,
            "metrics": {
                "estimatedTokens": 0,
                "budgetRemaining": 0,
                "truncationReasons": [],
            },
        }

        # Cap each source before serialization, then reduce all remaining source
        # bodies proportionally in one pass. Runtime is linear in packet size;
        # it never performs fixed-size trim-and-reserialize loops.
        budget_chars = request["budget"]["maxTokens"] * 4
        content_budget_chars = max(0, budget_chars - 256)
        serialized = json.dumps(
            result,
            ensure_ascii=False,
            separators=(",", ":"),
        )
        content_truncated = False
        if len(serialized) > content_budget_chars:
            content_chars = sum(len(item["content"]) for item in fragments)
            allowed_content = max(
                0,
                content_chars - (len(serialized) - content_budget_chars),
            )
            if allowed_content < content_chars and content_chars:
                remaining = allowed_content
                for index, item in enumerate(fragments):
                    if index == len(fragments) - 1:
                        limit = remaining
                    else:
                        limit = min(
                            len(item["content"]),
                            len(item["content"]) * allowed_content // content_chars,
                        )
                    item["content"] = item["content"][:limit]
                    remaining -= limit
                content_truncated = True
                serialized = json.dumps(
                    result,
                    ensure_ascii=False,
                    separators=(",", ":"),
                )

        admission_ready = (
            bool(fragments)
            and not unresolved
            and bool(self_gates)
            and all(item["satisfied"] for item in self_gates)
        )
        truncation_reasons = ["maxTokens"] if content_truncated else []
        previous_state = None
        for _ in range(16):
            serialized = json.dumps(
                result,
                ensure_ascii=False,
                separators=(",", ":"),
            )
            estimated_tokens = (len(serialized) + 3) // 4
            state = (
                estimated_tokens,
                request["budget"]["maxTokens"] - estimated_tokens,
                admission_ready and len(serialized) <= budget_chars,
            )
            result["metrics"] = {
                "estimatedTokens": state[0],
                "budgetRemaining": state[1],
                "truncationReasons": truncation_reasons,
            }
            result["admitted"] = state[2]
            if state == previous_state:
                break
            previous_state = state
        return result

    return load, mo, normalize, project, select


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
def _(normalize, workbook_request):
    normalized_request = normalize(workbook_request)
    return (normalized_request,)


@app.cell
def _(load, normalized_request):
    loaded_boundaries, boundary_errors = load(normalized_request)
    available_context_graph = {
        boundary: {
            "context": item["output"]["context"],
            "workflow": item["output"]["workflow"],
        }
        for boundary, item in loaded_boundaries.items()
    }
    return available_context_graph, boundary_errors, loaded_boundaries


@app.cell
def _(loaded_boundaries, normalized_request, select):
    filtered_context_graph = select(loaded_boundaries, normalized_request)
    return (filtered_context_graph,)


@app.cell
def _(
    boundary_errors,
    filtered_context_graph,
    loaded_boundaries,
    normalized_request,
    project,
):
    workbook_result = project(
        normalized_request,
        loaded_boundaries,
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
                "The reactive workbook filters CUE/Apercue-authoritative graph "
                "projections into a bounded Codex context packet."
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
    if not isinstance(value.get("prompt"), str) or not value["prompt"].strip():
        raise ValueError("prompt must be a non-empty string")
    return value


def _summarize_rejection(result: dict[str, Any]) -> str:
    details: list[str] = []
    for item in result.get("unresolved_context") or []:
        if not isinstance(item, dict):
            continue
        label = item.get("boundary") or item.get("fragment") or item.get("kind")
        reason = item.get("reason")
        if label and reason:
            details.append(f"{label}: {reason}")
        elif reason:
            details.append(str(reason))
    for item in result.get("checks") or []:
        if isinstance(item, dict) and item.get("status") in {"fail", "blocked"}:
            details.append(f"{item.get('id', 'check')}: {item['status']}")
    for item in result.get("gates") or []:
        if isinstance(item, dict) and item.get("satisfied") is False:
            details.append(f"{item.get('id', 'gate')}: unsatisfied")
    if not details:
        metrics = result.get("metrics")
        if isinstance(metrics, dict):
            reasons = metrics.get("truncationReasons") or []
            details.extend(str(reason) for reason in reasons)
    return "; ".join(details[:3]) or "no diagnostic details available"


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
    if not isinstance(result, dict) or not result.get("admitted"):
        if isinstance(result, dict):
            raise RuntimeError(
                "workbook context packet was not admitted: "
                f"{_summarize_rejection(result)}"
            )
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
