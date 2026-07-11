# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "hypothesis>=6.140,<7",
#   "marimo>=0.19,<1",
#   "pydantic>=2.12,<3",
# ]
# ///

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Annotated, Any, Literal

import marimo
from hypothesis import HealthCheck, given, settings
from hypothesis import strategies as st
from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    StringConstraints,
    ValidationError,
    field_validator,
    model_validator,
)

__generated_with = "0.19.0"
app = marimo.App(width="full")

NonEmpty = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1)]


class StrictModel(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        strict=True,
        validate_by_alias=True,
        validate_by_name=True,
        serialize_by_alias=True,
    )


class RequestedBudget(StrictModel):
    maxFragments: int = 12
    maxSteps: int = 8
    maxNodes: int = 48
    maxTokens: int = 6000


class PacketBudget(StrictModel):
    maxFragments: int = Field(ge=1, le=32)
    maxSteps: int = Field(ge=1, le=32)
    maxNodes: int = Field(ge=4, le=128)
    maxTokens: int = Field(ge=256, le=20_000)


class BoundaryScope(StrictModel):
    boundaries: list[NonEmpty] = Field(default_factory=list)

    @field_validator("boundaries")
    @classmethod
    def canonical(cls, value: list[str]) -> list[str]:
        return sorted(set(value))


class RequestInput(StrictModel):
    schema_: Literal["factory.context-request.v0"] = Field(
        default="factory.context-request.v0", alias="schema"
    )
    event: NonEmpty = "interactive"
    prompt: NonEmpty
    repo_root: NonEmpty = "."
    scope: BoundaryScope = Field(default_factory=BoundaryScope)
    budget: RequestedBudget = Field(default_factory=RequestedBudget)


class ContextRequest(StrictModel):
    schema_: Literal["factory.context-request.v0"] = Field(alias="schema")
    event: NonEmpty
    prompt: NonEmpty
    repo_root: NonEmpty
    tokens: list[NonEmpty]
    scope: BoundaryScope
    budget: PacketBudget

    @field_validator("tokens")
    @classmethod
    def canonical_tokens(cls, value: list[str]) -> list[str]:
        if value != sorted(set(value)):
            raise ValueError("tokens must be sorted and unique")
        return value


class HookEvent(StrictModel):
    hook_event_name: Literal["UserPromptSubmit"]
    prompt: NonEmpty
    agent_id: str | None = None
    agent_type: str | None = None
    cwd: str | None = None
    model: str | None = None
    permission_mode: str | None = None
    session_id: str | None = None
    transcript_path: str | None = None
    turn_id: str | None = None


class BoundarySpec(StrictModel):
    id: NonEmpty
    path: NonEmpty
    selectors: list[str] = Field(default_factory=list)


class GraphProjection(StrictModel):
    valid: Literal[True]
    resources: dict[str, dict[str, Any]]
    topology: dict[str, dict[str, Literal[True]]]
    roots: dict[str, Literal[True]]
    leaves: dict[str, Literal[True]]
    dependents: dict[str, dict[str, Literal[True]]]

    @model_validator(mode="after")
    def closed(self) -> GraphProjection:
        ids = set(self.resources)
        ordered = [node for layer in self.topology.values() for node in layer]
        if len(ordered) != len(set(ordered)) or set(ordered) != ids:
            raise ValueError("topology must contain every resource exactly once")
        if not set(self.roots).issubset(ids) or not set(self.leaves).issubset(ids):
            raise ValueError("root and leaf references must resolve")
        for resource_id, resource in self.resources.items():
            required = {"name", "kind", "local_id", "description", "depth", "ancestors"}
            if not required.issubset(resource):
                raise ValueError(f"resource projection is incomplete: {resource_id}")
            if resource["name"] != resource_id:
                raise ValueError(f"resource name mismatch: {resource_id}")
            refs = set(resource.get("ancestors") or {}) | set(
                resource.get("depends_on") or {}
            )
            if not refs.issubset(ids):
                raise ValueError(f"resource references do not resolve: {resource_id}")
        for source, targets in self.dependents.items():
            if source not in ids or not set(targets).issubset(ids):
                raise ValueError("dependent references must resolve")
        return self


class BoundaryOutput(BaseModel):
    model_config = ConfigDict(extra="allow", strict=True)

    boundary: dict[str, Any] | None = None
    boundaries: dict[str, BoundarySpec] = Field(default_factory=dict)
    fragments: dict[str, dict[str, Any]]
    steps: dict[str, dict[str, Any]]
    checks: dict[str, dict[str, Any]]
    gates: dict[str, dict[str, Any]]
    context: GraphProjection
    workflow: GraphProjection

    @model_validator(mode="after")
    def closed(self) -> BoundaryOutput:
        fragments, steps = set(self.fragments), set(self.steps)
        checks, gates = set(self.checks), set(self.gates)
        for identity, item in self.fragments.items():
            if item.get("id") != identity:
                raise ValueError(f"fragment id mismatch: {identity}")
            if not set(item.get("depends_on") or {}).issubset(fragments):
                raise ValueError(f"fragment references do not resolve: {identity}")
        for identity, item in self.steps.items():
            if item.get("id") != identity:
                raise ValueError(f"step id mismatch: {identity}")
            refs = (
                ("depends_on", steps),
                ("fragments", fragments),
                ("checks", checks),
                ("gates", gates),
            )
            if any(not set(item.get(field) or {}).issubset(target) for field, target in refs):
                raise ValueError(f"step references do not resolve: {identity}")
        for identity, item in self.gates.items():
            if item.get("id") != identity or not set(item.get("requires") or {}).issubset(checks):
                raise ValueError(f"gate references do not resolve: {identity}")
        return self


class PacketMetrics(StrictModel):
    estimatedTokens: int = Field(ge=0)
    budgetRemaining: int
    truncationReasons: list[NonEmpty]


class ContextPacket(StrictModel):
    schema_: Literal["factory.context-packet.v0"] = Field(alias="schema")
    authority: Literal[False]
    generated: Literal[True]
    transient: Literal[True]
    admitted: bool
    request: ContextRequest
    context_graph: dict[str, Any]
    selected_fragments: list[dict[str, Any]]
    implementation_plan: list[dict[str, Any]]
    checks: list[dict[str, Any]]
    gates: list[dict[str, Any]]
    unresolved_context: list[dict[str, Any]]
    metrics: PacketMetrics

    @model_validator(mode="after")
    def admitted_packet_is_closed(self) -> ContextPacket:
        nodes = self.context_graph.get("nodes") or []
        node_ids = [item.get("id") for item in nodes]
        if None in node_ids or len(node_ids) != len(set(node_ids)):
            raise ValueError("packet node ids must be present and unique")
        known = set(node_ids)
        if len(nodes) > self.request.budget.maxNodes:
            raise ValueError("context graph exceeds maxNodes")
        if len(self.selected_fragments) > self.request.budget.maxFragments:
            raise ValueError("selected fragments exceed maxFragments")
        if len(self.implementation_plan) > self.request.budget.maxSteps:
            raise ValueError("implementation plan exceeds maxSteps")
        for edge in self.context_graph.get("edges") or []:
            if edge.get("source") not in known or edge.get("target") not in known:
                raise ValueError("packet edge references must resolve")
        for field in ("selected_fragments", "implementation_plan", "checks", "gates"):
            if not {item.get("id") for item in getattr(self, field)}.issubset(known):
                raise ValueError(f"{field} references must resolve")
        if self.metrics.budgetRemaining != self.request.budget.maxTokens - self.metrics.estimatedTokens:
            raise ValueError("budgetRemaining must match estimatedTokens")
        if self.admitted:
            self_gates = [
                gate for gate in self.gates if str(gate.get("id", "")).startswith("context-resolver.gate.")
            ]
            if (
                not self.selected_fragments
                or self.unresolved_context
                or not self_gates
                or not all(gate.get("satisfied") is True for gate in self_gates)
                or self.metrics.estimatedTokens > self.request.budget.maxTokens
            ):
                raise ValueError("admitted packet invariants are not satisfied")
        return self


class ValidationReport(StrictModel):
    schema_: Literal["factory.context-resolver.validation.v0"] = Field(alias="schema")
    passed: bool
    cases: list[dict[str, str]]


@app.cell
def _():
    import json
    import re
    import subprocess
    import tempfile
    from pathlib import Path
    from typing import Callable

    import marimo as mo

    tokens_re = re.compile(r"[a-z0-9_./-]+")

    def dump(value: Any) -> str:
        return json.dumps(value, ensure_ascii=False, separators=(",", ":"))

    def qualify(boundary: str, kind: str, local: str) -> str:
        return f"{boundary}.{kind}.{local}"

    def local(resource: dict[str, Any], prefix: str) -> str:
        if isinstance(resource.get("local_id"), str) and resource["local_id"]:
            return resource["local_id"]
        name = str(resource["name"])
        marker = f"{prefix}."
        return name[len(marker) :] if name.startswith(marker) else name

    def normalize(value: dict[str, Any]) -> dict[str, Any]:
        raw = RequestInput.model_validate(value)
        def clamp(value: int, low: int, high: int) -> int:
            return max(low, min(high, value))

        prompt = raw.prompt.strip()
        return ContextRequest(
            schema="factory.context-request.v0",
            event=raw.event,
            prompt=prompt,
            repo_root=str(Path(raw.repo_root).resolve()),
            tokens=sorted(set(tokens_re.findall(prompt.lower()))),
            scope=raw.scope,
            budget=PacketBudget(
                maxFragments=clamp(raw.budget.maxFragments, 1, 32),
                maxSteps=clamp(raw.budget.maxSteps, 1, 32),
                maxNodes=clamp(raw.budget.maxNodes, 4, 128),
                maxTokens=clamp(raw.budget.maxTokens, 256, 20_000),
            ),
        ).model_dump(mode="json")

    def cue_export(path: Path) -> dict[str, Any]:
        completed = subprocess.run(
            ["cue", "export", ".", "-e", "output", "--out", "json"],
            cwd=path,
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        if completed.returncode:
            raise RuntimeError((completed.stderr or completed.stdout).strip() or "cue export failed")
        return BoundaryOutput.model_validate_json(completed.stdout).model_dump(mode="json")

    def load(
        request: dict[str, Any],
        exporter: Callable[[Path], dict[str, Any]] = cue_export,
    ) -> tuple[dict[str, dict[str, Any]], list[dict[str, str]]]:
        repo = Path(request["repo_root"]).resolve()
        root = repo / "marimo/profiles/context-resolver/.kb"
        allowed = set(request["scope"]["boundaries"])
        try:
            parent = BoundaryOutput.model_validate(exporter(root)).model_dump(mode="json")
        except Exception as exc:
            return {}, [{"boundary": "context-resolver", "reason": str(exc)}]
        loaded, errors = {}, []
        for spec in parent.get("boundaries", {}).values():
            identity = spec["id"]
            if allowed and identity != "context-resolver" and identity not in allowed:
                continue
            path = (root / spec["path"]).resolve()
            try:
                path.relative_to(repo)
                output = parent if identity == "context-resolver" else exporter(path)
                output = BoundaryOutput.model_validate(output).model_dump(mode="json")
            except Exception as exc:
                errors.append({"boundary": identity, "reason": str(exc)})
                continue
            loaded[identity] = {
                "path": str(path),
                "selectors": list(spec.get("selectors") or []),
                "output": output,
            }
        if "context-resolver" not in loaded and not any(
            item["boundary"] == "context-resolver" for item in errors
        ):
            errors.append({"boundary": "context-resolver", "reason": "required self boundary missing"})
        return loaded, errors

    def topology(projection: dict[str, Any]) -> list[str]:
        def key(name: str) -> tuple[int, str]:
            try:
                return int(name.rsplit("_", 1)[1]), name
            except (IndexError, ValueError):
                return 0, name

        return [
            node
            for layer in sorted(projection["topology"], key=key)
            for node in sorted(projection["topology"][layer])
        ]

    def closure(projection: dict[str, Any], node: str) -> set[str]:
        if node not in projection["resources"]:
            return set()
        resource = projection["resources"][node]
        result = {node} | set(resource.get("ancestors") or {})
        result |= set(projection.get("dependents", {}).get(node) or {})
        return result & set(projection["resources"])

    def select(boundaries: dict[str, Any], request: dict[str, Any]) -> dict[str, Any]:
        wanted, candidates = set(request["tokens"]), []
        for boundary, item in boundaries.items():
            for kind, field in (("fragment", "context"), ("step", "workflow")):
                for graph_id, resource in item["output"][field]["resources"].items():
                    identity = qualify(boundary, kind, local(resource, kind))
                    haystack = " ".join(
                        [identity, resource.get("description", ""), *item["selectors"], *(resource.get("selectors") or [])]
                    ).lower()
                    matched = sorted(wanted & set(tokens_re.findall(haystack)))
                    candidates.append(
                        {
                            "id": identity,
                            "boundary": boundary,
                            "kind": kind,
                            "graph_id": graph_id,
                            "score": 10 * len(matched),
                            "priority": int(resource.get("priority", 0)),
                            "matched": matched,
                        }
                    )
        candidates.sort(key=lambda item: (-item["score"], -item["priority"], item["id"]))
        seeds = [item for item in candidates if item["score"]]
        control = next(
            (item for item in candidates if item["id"] == "context-resolver.fragment.workbook"),
            None,
        )
        if control and all(item["id"] != control["id"] for item in seeds):
            seeds.append(control)
        if not seeds:
            seeds = [item for item in candidates if item["boundary"] == "context-resolver"]
        seeds = seeds[: request["budget"]["maxFragments"] + request["budget"]["maxSteps"]]
        chosen = {boundary: {"context": set(), "workflow": set()} for boundary in boundaries}

        def include(boundary: str, field: str, graph_id: str) -> bool:
            before = len(chosen[boundary][field])
            chosen[boundary][field] |= closure(boundaries[boundary]["output"][field], graph_id)
            return before != len(chosen[boundary][field])

        for seed in seeds:
            include(seed["boundary"], "context" if seed["kind"] == "fragment" else "workflow", seed["graph_id"])
        changed = True
        while changed:
            changed = False
            for boundary, fields in chosen.items():
                output = boundaries[boundary]["output"]
                fragment_ids = {local(output["context"]["resources"][node], "fragment") for node in fields["context"]}
                for node, step in output["workflow"]["resources"].items():
                    if fragment_ids & set(step.get("fragments") or {}):
                        changed = include(boundary, "workflow", node) or changed
                for node in tuple(fields["workflow"]):
                    for fragment in output["workflow"]["resources"][node].get("fragments") or {}:
                        changed = include(boundary, "context", f"fragment.{fragment}") or changed
        ordered = []
        for boundary in sorted(chosen):
            output = boundaries[boundary]["output"]
            ordered += [(boundary, "context", node) for node in topology(output["context"]) if node in chosen[boundary]["context"]]
            ordered += [(boundary, "workflow", node) for node in topology(output["workflow"]) if node in chosen[boundary]["workflow"]]
        truncated = len(ordered) > request["budget"]["maxNodes"]
        retained = set(ordered[: request["budget"]["maxNodes"]])
        for boundary in chosen:
            for field in ("context", "workflow"):
                chosen[boundary][field] = {
                    node
                    for candidate, selected_field, node in retained
                    if candidate == boundary and selected_field == field
                }
        return {
            "seeds": [{key: item[key] for key in ("id", "score", "matched")} for item in seeds],
            "selected": chosen,
            "scores": {item["id"]: item for item in candidates},
            "truncated": truncated,
        }

    def measure(packet: dict[str, Any]) -> dict[str, Any]:
        current = ContextPacket.model_validate(packet).model_dump(mode="json")
        for _ in range(8):
            tokens = (len(dump(current).encode()) + 3) // 4
            metrics = {
                "estimatedTokens": tokens,
                "budgetRemaining": current["request"]["budget"]["maxTokens"] - tokens,
                "truncationReasons": sorted(set(current["metrics"]["truncationReasons"])),
            }
            if metrics == current["metrics"]:
                return current
            current["metrics"] = metrics
            current = ContextPacket.model_validate(current).model_dump(mode="json")
        return current

    def project(request, boundaries, selection, boundary_errors):
        repo = Path(request["repo_root"]).resolve()
        nodes, edges, fragments, plan = [], [], [], []
        source_errors, selected_checks, selected_gates = [], {}, {}
        chosen_ids = set()
        for boundary, fields in selection["selected"].items():
            output = boundaries[boundary]["output"]
            chosen_ids |= {
                qualify(boundary, "fragment", local(output["context"]["resources"][node], "fragment"))
                for node in fields["context"]
            }
            chosen_ids |= {
                qualify(boundary, "step", local(output["workflow"]["resources"][node], "step"))
                for node in fields["workflow"]
            }
        candidates = []
        for boundary in sorted(boundaries):
            output = boundaries[boundary]["output"]
            chosen = selection["selected"].get(boundary, {"context": set(), "workflow": set()})
            selected_checks[boundary], selected_gates[boundary] = set(), set()
            for node in sorted(chosen["context"]):
                resource = output["context"]["resources"][node]
                identity = qualify(boundary, "fragment", local(resource, "fragment"))
                nodes.append({"id": identity, "boundary": boundary, "kind": "fragment", "local_id": local(resource, "fragment"), "description": resource.get("description", ""), "depth": resource.get("depth", 0)})
                candidates.append((boundary, identity, resource))
                for dependency in resource.get("depends_on") or {}:
                    target = qualify(boundary, "fragment", local(output["context"]["resources"][dependency], "fragment"))
                    if target in chosen_ids:
                        edges.append({"source": identity, "target": target, "kind": "depends-on"})
            for node in topology(output["workflow"]):
                if node not in chosen["workflow"]:
                    continue
                resource = output["workflow"]["resources"][node]
                identity = qualify(boundary, "step", local(resource, "step"))
                nodes.append({"id": identity, "boundary": boundary, "kind": "step", "local_id": local(resource, "step"), "description": resource.get("description", ""), "depth": resource.get("depth", 0)})
                dependencies = []
                for dependency in resource.get("depends_on") or {}:
                    target = qualify(boundary, "step", local(output["workflow"]["resources"][dependency], "step"))
                    if target in chosen_ids:
                        dependencies.append(target)
                        edges.append({"source": identity, "target": target, "kind": "depends-on"})
                refs = {
                    "fragments": [qualify(boundary, "fragment", item) for item in resource.get("fragments") or {} if qualify(boundary, "fragment", item) in chosen_ids],
                    "checks": [qualify(boundary, "check", item) for item in resource.get("checks") or {}],
                    "gates": [qualify(boundary, "gate", item) for item in resource.get("gates") or {}],
                }
                selected_checks[boundary] |= set(resource.get("checks") or {})
                selected_gates[boundary] |= set(resource.get("gates") or {})
                edges += [{"source": identity, "target": target, "kind": "uses-fragment"} for target in refs["fragments"]]
                plan.append({"id": identity, "description": resource.get("description", ""), "depends_on": dependencies, **refs})
        scores = selection["scores"]
        candidates.sort(key=lambda item: (-scores.get(item[1], {}).get("score", 0), -int(item[2].get("priority", 0)), item[1]))
        max_chars = max(256, request["budget"]["maxTokens"] * 4 // request["budget"]["maxFragments"])
        for boundary, identity, resource in candidates[: request["budget"]["maxFragments"]]:
            path = (Path(boundaries[boundary]["path"]) / resource["source"]["path"]).resolve()
            try:
                path.relative_to(repo)
                content = path.read_text(encoding="utf-8", errors="replace")[:max_chars]
            except Exception as exc:
                content = resource.get("description", "")
                source_errors.append({"fragment": identity, "reason": str(exc)})
            fragments.append({"id": identity, "boundary": boundary, "source": resource["source"], "content": content, "reason": ", ".join(scores.get(identity, {}).get("matched", [])) or "Apercue graph closure"})
        references_ok = not boundary_errors and all(
            item["output"]["context"]["valid"] and item["output"]["workflow"]["valid"]
            for item in boundaries.values()
        )
        for boundary, gates in selected_gates.items():
            for gate in gates:
                selected_checks[boundary] |= set(boundaries[boundary]["output"]["gates"][gate].get("requires") or {})
        checks = []
        for boundary, selected_ids in selected_checks.items():
            for identity in sorted(selected_ids):
                declaration = boundaries[boundary]["output"]["checks"][identity]
                status = "pending"
                if identity == "references_admitted":
                    status = "pass" if references_ok else "fail"
                elif identity == "sources_bounded":
                    status = "pass" if not source_errors else "fail"
                packet_id = qualify(boundary, "check", identity)
                nodes.append({"id": packet_id, "boundary": boundary, "kind": "check", "local_id": identity, "description": declaration["description"]})
                checks.append({"id": packet_id, "description": declaration["description"], "status": status, "command": declaration.get("command")})
        status = {item["id"]: item["status"] for item in checks}
        gates = []
        for boundary, selected_ids in selected_gates.items():
            for identity in sorted(selected_ids):
                declaration = boundaries[boundary]["output"]["gates"][identity]
                packet_id = qualify(boundary, "gate", identity)
                required = [qualify(boundary, "check", item) for item in declaration.get("requires") or {}]
                satisfied = bool(required) and all(status.get(item) == "pass" for item in required)
                nodes.append({"id": packet_id, "boundary": boundary, "kind": "gate", "local_id": identity, "description": declaration["description"]})
                edges += [{"source": packet_id, "target": item, "kind": "requires"} for item in required]
                gates.append({"id": packet_id, "description": declaration["description"], "satisfied": satisfied})
        known = {item["id"] for item in nodes}
        edges += [{"source": step["id"], "target": target, "kind": "checked-by"} for step in plan for target in step["checks"] if target in known]
        edges += [{"source": step["id"], "target": target, "kind": "gated-by"} for step in plan for target in step["gates"] if target in known]
        truncated = selection["truncated"] or len(nodes) > request["budget"]["maxNodes"]
        if len(nodes) > request["budget"]["maxNodes"]:
            known = {item["id"] for item in nodes[: request["budget"]["maxNodes"]]}
            nodes = [item for item in nodes if item["id"] in known]
            edges = [item for item in edges if item["source"] in known and item["target"] in known]
            fragments = [item for item in fragments if item["id"] in known]
            plan = [item for item in plan if item["id"] in known]
            for item in plan:
                for field in ("depends_on", "fragments", "checks", "gates"):
                    item[field] = [target for target in item[field] if target in known]
            checks = [item for item in checks if item["id"] in known]
            gates = [item for item in gates if item["id"] in known]
        unresolved = list(boundary_errors) + source_errors
        reasons = []
        if truncated:
            unresolved.append({"kind": "budget", "reason": "maxNodes reached"})
            reasons.append("maxNodes")
        packet = {
            "schema": "factory.context-packet.v0",
            "authority": False,
            "generated": True,
            "transient": True,
            "admitted": False,
            "request": request,
            "context_graph": {"seeds": selection["seeds"], "nodes": nodes, "edges": edges, "truncated": truncated},
            "selected_fragments": fragments,
            "implementation_plan": plan[: request["budget"]["maxSteps"]],
            "checks": checks,
            "gates": gates,
            "unresolved_context": unresolved,
            "metrics": {"estimatedTokens": 0, "budgetRemaining": request["budget"]["maxTokens"], "truncationReasons": reasons},
        }
        original = [item["content"] for item in fragments]
        total = sum(map(len, original))

        def allocate(limit: int) -> None:
            remaining = limit
            for index, (item, content) in enumerate(zip(fragments, original, strict=True)):
                size = min(len(content), remaining if index == len(fragments) - 1 else len(content) * limit // max(1, total))
                item["content"], remaining = content[:size], remaining - size

        candidate = measure(packet)
        limit = request["budget"]["maxTokens"]
        if candidate["metrics"]["estimatedTokens"] > limit and original:
            low, high = 0, total
            while low < high:
                middle = (low + high + 1) // 2
                allocate(middle)
                if measure(packet)["metrics"]["estimatedTokens"] <= limit:
                    low = middle
                else:
                    high = middle - 1
            allocate(low)
            if low < total:
                packet["metrics"]["truncationReasons"] += ["maxTokens"]
            candidate = measure(packet)
        if candidate["metrics"]["estimatedTokens"] > limit:
            packet["unresolved_context"].append({"kind": "budget", "reason": "packet structure exceeds maxTokens"})
            packet["metrics"]["truncationReasons"] += ["maxTokens"]
            candidate = measure(packet)
        self_gates = [item for item in gates if item["id"].startswith("context-resolver.gate.")]
        packet["admitted"] = bool(fragments) and not packet["unresolved_context"] and bool(self_gates) and all(item["satisfied"] for item in self_gates) and candidate["metrics"]["estimatedTokens"] <= limit
        return measure(packet)

    def synthetic(source="source.txt", count=1, boundaries=None):
        context_resources = {}
        context_topology = {}
        context_dependents = {}
        fragments = {}
        for index in range(count):
            node, previous = f"fragment.n{index}", f"fragment.n{index - 1}"
            context_resources[node] = {"name": node, "kind": "fragment", "local_id": f"n{index}", "description": "synthetic fragment", "source": {"path": source}, "selectors": ["synthetic"], "priority": count - index, "depends_on": {previous: True} if index else {}, "depth": index, "ancestors": {f"fragment.n{ancestor}": True for ancestor in range(index)}}
            context_topology[f"layer_{index}"] = {node: True}
            context_dependents[node] = {f"fragment.n{child}": True for child in range(index + 1, count)}
            fragments[f"n{index}"] = {"id": f"n{index}", "description": "synthetic fragment", "source": {"path": source}, "selectors": ["synthetic"], "depends_on": {f"n{index - 1}": True} if index else {}, "priority": count - index}
        output = {
            "fragments": fragments,
            "steps": {"n0": {"id": "n0", "description": "synthetic step", "fragments": {"n0": True}, "checks": {"references_admitted": True, "sources_bounded": True}, "gates": {"packet_admitted": True}}},
            "checks": {"references_admitted": {"id": "references_admitted", "description": "references admitted"}, "sources_bounded": {"id": "sources_bounded", "description": "sources bounded"}},
            "gates": {"packet_admitted": {"id": "packet_admitted", "description": "packet admitted", "requires": {"references_admitted": True, "sources_bounded": True}}},
            "context": {"valid": True, "resources": context_resources, "topology": context_topology, "roots": {"fragment.n0": True}, "leaves": {f"fragment.n{count - 1}": True}, "dependents": context_dependents},
            "workflow": {"valid": True, "resources": {"step.n0": {"name": "step.n0", "kind": "step", "local_id": "n0", "description": "synthetic step", "depends_on": {}, "fragments": {"n0": True}, "checks": {"references_admitted": True, "sources_bounded": True}, "gates": {"packet_admitted": True}, "depth": 0, "ancestors": {}}}, "topology": {"layer_0": {"step.n0": True}}, "roots": {"step.n0": True}, "leaves": {"step.n0": True}, "dependents": {"step.n0": {}}},
        }
        if boundaries is not None:
            output |= {"boundary": {"id": "context-resolver", "kind": "self"}, "boundaries": boundaries}
        return BoundaryOutput.model_validate(output).model_dump(mode="json")

    def validate_suite():
        cases = []

        def case(identity, action):
            try:
                action()
            except Exception as exc:
                cases.append({"id": identity, "status": "fail", "detail": f"{type(exc).__name__}: {str(exc)[:400]}"})
            else:
                cases.append({"id": identity, "status": "pass", "detail": ""})

        @settings(max_examples=64, deadline=None, suppress_health_check=[HealthCheck.filter_too_much])
        @given(
            prompt=st.text(min_size=1).filter(lambda value: bool(value.strip())),
            fragments=st.integers(-1000, 1000),
            steps=st.integers(-1000, 1000),
            nodes=st.integers(-1000, 1000),
            tokens=st.integers(-10_000, 30_000),
        )
        def budget_property(prompt, fragments, steps, nodes, tokens):
            value = normalize({"prompt": prompt, "budget": {"maxFragments": fragments, "maxSteps": steps, "maxNodes": nodes, "maxTokens": tokens}})
            assert value["prompt"] == prompt.strip()
            assert value["tokens"] == sorted(set(value["tokens"]))
            assert 1 <= value["budget"]["maxFragments"] <= 32
            assert 1 <= value["budget"]["maxSteps"] <= 32
            assert 4 <= value["budget"]["maxNodes"] <= 128
            assert 256 <= value["budget"]["maxTokens"] <= 20_000

        def scoped():
            with tempfile.TemporaryDirectory() as temporary:
                repo = Path(temporary)
                root = repo / "marimo/profiles/context-resolver/.kb"
                good = repo / "marimo/profiles/code-intel/python/.kb"
                bad = repo / "marimo/profiles/code-intel/cue/.kb"
                for path in (root, good, bad):
                    path.mkdir(parents=True)
                parent = synthetic(boundaries={"self": {"id": "context-resolver", "path": ".", "selectors": []}, "good": {"id": "code-intel-python", "path": "../../code-intel/python/.kb", "selectors": []}, "bad": {"id": "code-intel-cue", "path": "../../code-intel/cue/.kb", "selectors": []}})
                called = []

                def exporter(path):
                    called.append(path.resolve())
                    if path.resolve() == root.resolve():
                        return parent
                    if path.resolve() == good.resolve():
                        return synthetic()
                    raise RuntimeError("excluded boundary exported")

                request = normalize({"prompt": "python", "repo_root": str(repo), "scope": {"boundaries": ["code-intel-python"]}})
                loaded, errors = load(request, exporter)
                assert not errors and set(loaded) == {"context-resolver", "code-intel-python"}
                assert bad.resolve() not in called

        def unresolved_boundary():
            with tempfile.TemporaryDirectory() as temporary:
                repo = Path(temporary)
                root = repo / "marimo/profiles/context-resolver/.kb"
                bad = repo / "marimo/profiles/code-intel/cue/.kb"
                root.mkdir(parents=True)
                bad.mkdir(parents=True)
                (root / "source.txt").write_text("synthetic")
                parent = synthetic(
                    boundaries={
                        "self": {
                            "id": "context-resolver",
                            "path": ".",
                            "selectors": ["synthetic"],
                        },
                        "bad": {
                            "id": "code-intel-cue",
                            "path": "../../code-intel/cue/.kb",
                            "selectors": ["cue"],
                        },
                    }
                )

                def exporter(path):
                    if path.resolve() == root.resolve():
                        return parent
                    raise RuntimeError("synthetic child export failure")

                request = normalize(
                    {"prompt": "synthetic", "repo_root": str(repo)}
                )
                loaded, errors = load(request, exporter)
                assert set(loaded) == {"context-resolver"}
                assert errors and errors[0]["boundary"] == "code-intel-cue"
                packet = project(request, loaded, select(loaded, request), errors)
                assert packet["admitted"] is False
                assert any(
                    item.get("boundary") == "code-intel-cue"
                    for item in packet["unresolved_context"]
                )

        def exact_token_matching():
            request = normalize({"prompt": "py", "repo_root": "."})
            boundaries = {
                "context-resolver": {
                    "path": ".",
                    "selectors": ["python"],
                    "output": synthetic(),
                }
            }
            selection = select(boundaries, request)
            assert selection["seeds"]
            assert all(seed["score"] == 0 for seed in selection["seeds"])
            assert all(not seed["matched"] for seed in selection["seeds"])

        def failure(kind):
            with tempfile.TemporaryDirectory() as temporary:
                base = Path(temporary)
                repo = base / "repo"
                root = repo / "marimo/profiles/context-resolver/.kb"
                root.mkdir(parents=True)
                source = root / "source.txt"
                source.write_text("x" * 100_000)
                output = synthetic(source=str(base / "outside.txt") if kind == "source" else "source.txt", count=8 if kind == "nodes" else 1)
                budget = {"maxFragments": 1, "maxSteps": 1, "maxNodes": 4 if kind == "nodes" else 8, "maxTokens": 256 if kind == "tokens" else 6000}
                request = normalize({"prompt": "synthetic", "repo_root": str(repo), "budget": budget})
                boundaries = {"context-resolver": {"path": str(root), "selectors": ["synthetic"], "output": output}}
                packet = project(request, boundaries, select(boundaries, request), [])
                assert packet["admitted"] is False
                if kind == "source":
                    assert any(item.get("fragment") for item in packet["unresolved_context"])
                elif kind == "nodes":
                    assert packet["context_graph"]["truncated"] and len(packet["context_graph"]["nodes"]) <= 4
                else:
                    measured = (len(dump(packet).encode()) + 3) // 4
                    assert packet["metrics"]["estimatedTokens"] == measured
                    assert "maxTokens" in packet["metrics"]["truncationReasons"]

        def malformed():
            values = [
                {"hook_event_name": "Other", "prompt": "valid"},
                {"hook_event_name": "UserPromptSubmit", "prompt": " "},
                {"hook_event_name": "UserPromptSubmit", "prompt": "valid", "unknown": True},
            ]
            for value in values:
                try:
                    HookEvent.model_validate(value)
                except ValidationError:
                    continue
                raise AssertionError("malformed hook envelope accepted")

        case("property-normalization-and-budgets", budget_property)
        case("scoped-boundary-success", scoped)
        case("unresolved-boundary-fails-closed", unresolved_boundary)
        case("exact-token-matching", exact_token_matching)
        case("source-escape-fails-closed", lambda: failure("source"))
        case("max-nodes-fails-closed", lambda: failure("nodes"))
        case("max-tokens-final-measurement", lambda: failure("tokens"))
        case("malformed-hook-envelope-rejected", malformed)
        return ValidationReport(
            schema="factory.context-resolver.validation.v0",
            passed=all(item["status"] == "pass" for item in cases),
            cases=cases,
        ).model_dump(mode="json")

    return load, mo, normalize, project, select, validate_suite


@app.cell
def _():
    workbook_request = {
        "schema": "factory.context-request.v0",
        "event": "interactive",
        "prompt": "context resolver",
        "repo_root": ".",
        "scope": {"boundaries": []},
        "budget": {"maxFragments": 12, "maxSteps": 8, "maxNodes": 48, "maxTokens": 6000},
    }
    validation_mode = False
    return validation_mode, workbook_request


@app.cell
def _(normalize, workbook_request):
    normalized_request = normalize(workbook_request)
    return (normalized_request,)


@app.cell
def _(load, normalized_request):
    loaded_boundaries, boundary_errors = load(normalized_request)
    available_context_graph = {
        boundary: {"context": item["output"]["context"], "workflow": item["output"]["workflow"]}
        for boundary, item in loaded_boundaries.items()
    }
    return available_context_graph, boundary_errors, loaded_boundaries


@app.cell
def _(loaded_boundaries, normalized_request, select):
    filtered_context_graph = select(loaded_boundaries, normalized_request)
    return (filtered_context_graph,)


@app.cell
def _(boundary_errors, filtered_context_graph, loaded_boundaries, normalized_request, project):
    workbook_result = project(normalized_request, loaded_boundaries, filtered_context_graph, boundary_errors)
    return (workbook_result,)


@app.cell
def _(validate_suite, validation_mode, workbook_result):
    validation_report = None
    if validation_mode:
        validation_report = validate_suite()
        integration = {
            "id": "live-cue-workbook-integration",
            "status": "pass" if workbook_result.get("admitted") else "fail",
            "detail": "" if workbook_result.get("admitted") else "live workbook result was not admitted",
        }
        validation_report["cases"].append(integration)
        validation_report["passed"] &= integration["status"] == "pass"
        validation_report = ValidationReport.model_validate(validation_report).model_dump(mode="json")
    return (validation_report,)


@app.cell
def _(mo, validation_report, workbook_result):
    sections = [
        mo.md("# Context resolver"),
        mo.md("Pydantic contracts validate the runtime surface; Hypothesis properties execute in validation mode."),
        mo.json(workbook_result),
    ]
    if validation_report is not None:
        sections += [mo.md("## Validation"), mo.json(validation_report)]
    mo.vstack(sections)
    return


def _read_hook_event() -> HookEvent:
    return HookEvent.model_validate(json.load(sys.stdin))


def _summarize_rejection(result: dict[str, Any]) -> str:
    details = []
    for item in result.get("unresolved_context") or []:
        label = item.get("boundary") or item.get("fragment") or item.get("kind")
        if item.get("reason"):
            details.append(f"{label}: {item['reason']}" if label else item["reason"])
    for item in result.get("checks") or []:
        if item.get("status") in {"fail", "blocked"}:
            details.append(f"{item.get('id', 'check')}: {item['status']}")
    for item in result.get("gates") or []:
        if item.get("satisfied") is False:
            details.append(f"{item.get('id', 'gate')}: unsatisfied")
    return "; ".join(details[:3]) or "no diagnostic details available"


def _run_hook(repo_root: Path) -> int:
    event = _read_hook_event()
    request = {
        "schema": "factory.context-request.v0",
        "event": "UserPromptSubmit",
        "prompt": event.prompt,
        "repo_root": str(repo_root.resolve()),
        "scope": {"boundaries": []},
        "budget": {"maxFragments": 12, "maxSteps": 8, "maxNodes": 48, "maxTokens": 6000},
    }
    _, definitions = app.run(defs={"workbook_request": request, "validation_mode": False})
    result = ContextPacket.model_validate(definitions.get("workbook_result")).model_dump(mode="json")
    if not result["admitted"]:
        raise RuntimeError(f"workbook context packet was not admitted: {_summarize_rejection(result)}")
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": json.dumps(result, ensure_ascii=False, separators=(",", ":")),
            }
        },
        sys.stdout,
        ensure_ascii=False,
        separators=(",", ":"),
    )
    sys.stdout.write("\n")
    return 0


def _run_validation(repo_root: Path) -> int:
    request = {
        "schema": "factory.context-request.v0",
        "event": "validation",
        "prompt": "validate context resolver workbook",
        "repo_root": str(repo_root.resolve()),
        "scope": {"boundaries": ["context-resolver"]},
        "budget": {"maxFragments": 12, "maxSteps": 8, "maxNodes": 48, "maxTokens": 6000},
    }
    _, definitions = app.run(defs={"workbook_request": request, "validation_mode": True})
    report = ValidationReport.model_validate(definitions.get("validation_report"))
    json.dump(report.model_dump(mode="json"), sys.stdout, ensure_ascii=False, separators=(",", ":"))
    sys.stdout.write("\n")
    return 0 if report.passed else 1


def _main() -> int:
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--codex-hook", action="store_true")
    mode.add_argument("--validate", action="store_true")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    args, marimo_args = parser.parse_known_args()
    if args.codex_hook:
        return _run_hook(args.repo_root)
    if args.validate:
        return _run_validation(args.repo_root)
    sys.argv = [sys.argv[0], *marimo_args]
    app.run()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(_main())
    except Exception as exc:
        print(f"factory context resolver: {exc}", file=sys.stderr)
        raise SystemExit(2) from exc
