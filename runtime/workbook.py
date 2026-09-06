from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import Any, Mapping, Protocol, Sequence

from .semantic_runtime import ContextObject, RuntimeObject, SemanticObject, SemanticRuntime


class WorkbookBoundaryError(RuntimeError):
    pass


class DirectoryBindingError(WorkbookBoundaryError):
    pass


class WorkbookCapabilityGap(WorkbookBoundaryError):
    pass


class AnalyticalExecutor(Protocol):
    def execute(self, request: Mapping[str, Any], *, snapshot: str, subject: Mapping[str, Any]) -> Mapping[str, Any]: ...


def _canonical(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def _digest_id(prefix: str, value: Any) -> str:
    return prefix + hashlib.sha256(_canonical(value).encode("utf-8")).hexdigest()


def _semantic_mapping(value: Any) -> dict[str, Any]:
    if hasattr(value, "authority") and hasattr(value, "subject"):
        result = {"authority": dict(value.authority), "subject": value.subject}
        if getattr(value, "kind", None) is not None:
            result["kind"] = value.kind
        return result
    return dict(value)


def _semantic_key(value: Any) -> str:
    return _canonical(_semantic_mapping(value))


def _node_ref_id(ref: Mapping[str, Any]) -> str:
    if ref.get("kind") == "semantic":
        return _digest_id("semantic:", ref["semantic"])
    if ref.get("kind") == "artifact":
        return str(ref["artifact"]["id"])
    raise WorkbookBoundaryError(f"unsupported relation node reference: {ref!r}")


@dataclass(frozen=True, slots=True)
class WorkbookScope:
    binding: Mapping[str, Any]
    primary: Mapping[str, Any]
    includes: tuple[Mapping[str, Any], ...]
    snapshot: str


class Workbook:
    def __init__(self, *, scope: WorkbookScope, runtime: SemanticRuntime, analytical_executor: AnalyticalExecutor | None = None):
        if scope.snapshot != runtime.snapshot_digest:
            raise WorkbookBoundaryError("workbook scope and semantic runtime reference different snapshots")
        self.scope = scope
        self.runtime = runtime
        self.analytical_executor = analytical_executor

    @classmethod
    def here(
        cls,
        file_path: str,
        *,
        snapshot: Mapping[str, Any],
        bindings: Sequence[Mapping[str, Any]],
        runtime: SemanticRuntime,
        subject: Mapping[str, Any] | None = None,
        includes: Sequence[Mapping[str, Any]] = (),
        analytical_executor: AnalyticalExecutor | None = None,
    ) -> "Workbook":
        directory = PurePosixPath(file_path).parent.as_posix()
        matches = [binding for binding in bindings if str(binding["directory"]["path"]) == directory]
        if len(matches) == 0:
            raise DirectoryBindingError(f"no admitted DirectoryBinding for {directory}")
        if len(matches) > 1:
            raise DirectoryBindingError(f"multiple admitted DirectoryBinding records for {directory}")
        binding = matches[0]
        candidates = list(binding.get("subjects", []))
        if subject is None:
            if len(candidates) != 1:
                raise DirectoryBindingError(f"binding {binding['id']} has {len(candidates)} subjects; explicit subject required")
            primary = dict(candidates[0])
        else:
            wanted = _semantic_key(subject)
            admitted = {_semantic_key(candidate): candidate for candidate in candidates}
            if wanted not in admitted:
                raise DirectoryBindingError("explicit subject is not admitted by the directory binding")
            primary = dict(admitted[wanted])
        runtime.semantic(primary)
        normalized_includes = tuple(dict(item) for item in includes)
        for item in normalized_includes:
            runtime.semantic(item)
        scope = WorkbookScope(
            binding=dict(binding),
            primary=primary,
            includes=normalized_includes,
            snapshot=str(snapshot["identity"]["digest"]),
        )
        return cls(scope=scope, runtime=runtime, analytical_executor=analytical_executor)

    def child(self, *, subject: Mapping[str, Any], includes: Sequence[Mapping[str, Any]] = ()) -> "Workbook":
        allowed = {_semantic_key(item) for item in self.scope.binding.get("subjects", [])}
        allowed.update(_semantic_key(item) for item in self.scope.includes)
        if _semantic_key(subject) not in allowed:
            raise DirectoryBindingError("child subject must be explicitly present in the admitted/composed scope")
        self.runtime.semantic(subject)
        normalized_includes = tuple(dict(item) for item in includes)
        for item in normalized_includes:
            self.runtime.semantic(item)
        return Workbook(
            scope=WorkbookScope(
                binding=self.scope.binding,
                primary=dict(subject),
                includes=normalized_includes,
                snapshot=self.scope.snapshot,
            ),
            runtime=self.runtime,
            analytical_executor=self.analytical_executor,
        )

    def evaluate(self, view: Mapping[str, Any]) -> dict[str, Any]:
        source = view["source"]
        if source["kind"] == "bounded-navigation":
            return self._evaluate_navigation(view)
        if source["kind"] == "analytical":
            return self._evaluate_analytical(view)
        raise WorkbookCapabilityGap(f"unsupported workbook view source: {source['kind']!r}")

    def _object_node(self, obj: RuntimeObject) -> dict[str, Any]:
        if isinstance(obj, SemanticObject):
            mapping = _semantic_mapping(obj.ref)
            return {
                "space": "semantic",
                "id": _digest_id("semantic:", mapping),
                "semantic": mapping,
                "provenance": [self.scope.snapshot],
            }
        if isinstance(obj, ContextObject):
            artifact = obj.artifact
            occurrence = artifact["occurrence"]
            provenance = [str(occurrence["id"])]
            if occurrence.get("locator"):
                provenance.append(str(occurrence["locator"]))
            return {
                "space": "context",
                "id": obj.artifact_id,
                "artifact": {"id": obj.artifact_id},
                "plane": str(artifact["plane"]),
                "provenance": provenance,
            }
        raise WorkbookBoundaryError(f"unknown runtime object: {obj!r}")

    def _evaluate_navigation(self, view: Mapping[str, Any]) -> dict[str, Any]:
        source = view["source"]
        root = self.runtime.semantic(source["root"])
        objects = [root, *root.traverse(str(source["plane"]), int(source["maxDepth"]))]
        nodes: dict[str, dict[str, Any]] = {}
        for obj in objects:
            node = self._object_node(obj)
            nodes[node["id"]] = node
        node_ids = set(nodes)
        edges: list[dict[str, Any]] = []
        for relation in self.runtime.adapter.relations(str(source["plane"])):
            if source["plane"] == "semantic":
                source_ref = {"kind": "semantic", "semantic": relation["source"]}
                target_ref = {"kind": "semantic", "semantic": relation["target"]}
                relation_name = str(relation["predicate"]["id"])
            else:
                source_ref = relation["source"]
                target_ref = relation["target"]
                relation_name = str(relation["relation"])
            source_id = _node_ref_id(source_ref)
            target_id = _node_ref_id(target_ref)
            if source_id not in node_ids or target_id not in node_ids:
                continue
            basis = tuple(str(item) for item in relation.get("basis", {}).get("occurrences", []))
            projected_edge: dict[str, Any] = {
                "id": _digest_id("edge:", relation),
                "plane": str(relation["plane"]),
                "relation": relation_name,
                "source": source_id,
                "target": target_id,
                "basis": list(basis),
                "provenance": list(basis) or [self.scope.snapshot],
            }
            if source["plane"] == "semantic":
                projected_edge["relationAuthority"] = dict(relation["authority"])
                projected_edge["admittedSnapshot"] = dict(relation["snapshot"])
            edges.append(projected_edge)
        return {
            "apiVersion": "factory.workbook/v1",
            "kind": "ProjectionResult",
            "viewID": str(view["id"]),
            "presentation": str(view["presentation"]),
            "snapshot": self.scope.snapshot,
            "subject": dict(self.scope.primary),
            "nodes": [nodes[key] for key in sorted(nodes)],
            "edges": sorted(edges, key=lambda item: item["id"]),
            "rows": [],
            "points": [],
            "provenance": [self.scope.snapshot],
        }

    def _evaluate_analytical(self, view: Mapping[str, Any]) -> dict[str, Any]:
        if self.analytical_executor is None:
            raise WorkbookCapabilityGap("analytical view requires an injected factory.analytics-ir executor")
        request = view["source"]["request"]
        payload = self.analytical_executor.execute(request, snapshot=self.scope.snapshot, subject=self.scope.primary)
        return {
            "apiVersion": "factory.workbook/v1",
            "kind": "ProjectionResult",
            "viewID": str(view["id"]),
            "presentation": str(view["presentation"]),
            "snapshot": self.scope.snapshot,
            "subject": dict(self.scope.primary),
            "nodes": list(payload.get("nodes", [])),
            "edges": list(payload.get("edges", [])),
            "rows": list(payload.get("rows", [])),
            "points": list(payload.get("points", [])),
            "provenance": [self.scope.snapshot, f"analytics:{request['id']}"],
        }
