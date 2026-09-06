from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any, Iterable, Mapping, Protocol, Sequence

from .generated.semantic_context import SemanticRef

PLANES = frozenset({"semantic", "documentary", "operational", "structural", "evidential"})


class RuntimeBoundaryError(RuntimeError):
    pass


class AdmissionBoundaryError(RuntimeBoundaryError):
    pass


class CapabilityGap(RuntimeBoundaryError):
    pass


def _canonical(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def _semantic_dict(ref: SemanticRef | Mapping[str, Any]) -> dict[str, Any]:
    if isinstance(ref, SemanticRef):
        result: dict[str, Any] = {"authority": dict(ref.authority), "subject": ref.subject}
        if ref.kind is not None:
            result["kind"] = ref.kind
        return result
    return dict(ref)


def _semantic_key(ref: SemanticRef | Mapping[str, Any]) -> str:
    return _canonical(_semantic_dict(ref))


def _node_key(ref: Mapping[str, Any]) -> tuple[str, str]:
    kind = ref.get("kind")
    if kind == "semantic":
        return ("semantic", _semantic_key(ref["semantic"]))
    if kind == "artifact":
        return ("artifact", str(ref["artifact"]["id"]))
    raise RuntimeBoundaryError(f"unsupported node reference kind: {kind!r}")


def semantic_ref(value: Mapping[str, Any]) -> SemanticRef:
    return SemanticRef(authority=dict(value["authority"]), subject=str(value["subject"]), kind=value.get("kind"))


@dataclass(frozen=True, slots=True)
class DerivationProvenance:
    snapshot: str
    operation: str
    plane: str | None
    sources: tuple[str, ...]


class LookupAdapter(Protocol):
    @property
    def snapshot_digest(self) -> str: ...
    def subject(self, ref: Mapping[str, Any]) -> Mapping[str, Any] | None: ...
    def artifact(self, artifact_id: str) -> Mapping[str, Any] | None: ...
    def relations(self, plane: str) -> Sequence[Mapping[str, Any]]: ...
    def semantic_relations(self) -> Sequence[Mapping[str, Any]]: ...


class SnapshotLookupAdapter:
    def __init__(self, snapshot: Mapping[str, Any]):
        self._snapshot_digest = str(snapshot["identity"]["digest"])
        self._subjects = {_semantic_key(item): item for item in snapshot.get("subjects", [])}
        self._artifacts = {str(item["id"]): item for item in snapshot.get("artifacts", [])}
        self._context_relations = tuple(snapshot.get("contextRelations", []))
        self._semantic_relations = tuple(snapshot.get("semanticRelations", []))

    @property
    def snapshot_digest(self) -> str:
        return self._snapshot_digest

    def subject(self, ref: Mapping[str, Any]) -> Mapping[str, Any] | None:
        return self._subjects.get(_semantic_key(ref))

    def artifact(self, artifact_id: str) -> Mapping[str, Any] | None:
        return self._artifacts.get(artifact_id)

    def relations(self, plane: str) -> Sequence[Mapping[str, Any]]:
        if plane == "semantic":
            return self._semantic_relations
        return tuple(relation for relation in self._context_relations if relation.get("plane") == plane)

    def semantic_relations(self) -> Sequence[Mapping[str, Any]]:
        return self._semantic_relations


@dataclass(frozen=True, slots=True)
class SemanticObject:
    runtime: "SemanticRuntime"
    ref: SemanticRef

    @property
    def snapshot(self) -> str:
        return self.runtime.snapshot_digest

    def adjacent(self, plane: str) -> tuple["RuntimeObject", ...]:
        return self.runtime.adjacent(self, plane)

    def traverse(self, plane: str, max_depth: int) -> tuple["RuntimeObject", ...]:
        return self.runtime.traverse(self, plane, max_depth)

    def provenance(self, operation: str = "lookup", plane: str | None = None) -> DerivationProvenance:
        return self.runtime.provenance(operation=operation, plane=plane, sources=(_semantic_key(self.ref),))


@dataclass(frozen=True, slots=True)
class ContextObject:
    runtime: "SemanticRuntime"
    artifact_id: str

    @property
    def snapshot(self) -> str:
        return self.runtime.snapshot_digest

    @property
    def artifact(self) -> Mapping[str, Any]:
        artifact = self.runtime.adapter.artifact(self.artifact_id)
        if artifact is None:
            raise KeyError(self.artifact_id)
        return artifact

    @property
    def occurrence(self) -> Mapping[str, Any]:
        return self.artifact["occurrence"]

    def adjacent(self, plane: str) -> tuple["RuntimeObject", ...]:
        return self.runtime.adjacent(self, plane)

    def traverse(self, plane: str, max_depth: int) -> tuple["RuntimeObject", ...]:
        return self.runtime.traverse(self, plane, max_depth)

    def provenance(self, operation: str = "lookup", plane: str | None = None) -> DerivationProvenance:
        return self.runtime.provenance(operation=operation, plane=plane, sources=(self.artifact_id,))


RuntimeObject = SemanticObject | ContextObject


class SemanticRuntime:
    def __init__(self, snapshot: Mapping[str, Any], adapter: LookupAdapter | None = None):
        digest = str(snapshot["identity"]["digest"])
        if not digest.startswith("sha256:") or len(digest) != 71:
            raise RuntimeBoundaryError("runtime requires an immutable sha256 snapshot identity")
        self._snapshot = snapshot
        self.adapter: LookupAdapter = adapter or SnapshotLookupAdapter(snapshot)
        if self.adapter.snapshot_digest != digest:
            raise RuntimeBoundaryError("lookup adapter is bound to a different snapshot")
        self._admitted_semantic_relation_keys = {_canonical(item) for item in snapshot.get("semanticRelations", [])}

    @property
    def snapshot_digest(self) -> str:
        return str(self._snapshot["identity"]["digest"])

    def semantic(self, ref: SemanticRef | Mapping[str, Any]) -> SemanticObject:
        mapping = _semantic_dict(ref)
        if self.adapter.subject(mapping) is None:
            raise KeyError(_semantic_key(mapping))
        return SemanticObject(self, semantic_ref(mapping))

    def context(self, artifact_id: str) -> ContextObject:
        if self.adapter.artifact(artifact_id) is None:
            raise KeyError(artifact_id)
        return ContextObject(self, artifact_id)

    def _runtime_object_from_ref(self, ref: Mapping[str, Any]) -> RuntimeObject:
        key = _node_key(ref)
        if key[0] == "semantic":
            return self.semantic(ref["semantic"])
        return self.context(key[1])

    def _object_key(self, obj: RuntimeObject) -> tuple[str, str]:
        if isinstance(obj, SemanticObject):
            return ("semantic", _semantic_key(obj.ref))
        return ("artifact", obj.artifact_id)

    def adjacent(self, obj: RuntimeObject, plane: str) -> tuple[RuntimeObject, ...]:
        if plane not in PLANES:
            raise CapabilityGap(f"unsupported relation plane: {plane!r}")
        wanted = self._object_key(obj)
        result: dict[tuple[str, str], RuntimeObject] = {}
        for relation in self.adapter.relations(plane):
            source = relation.get("source")
            target = relation.get("target")
            if plane == "semantic":
                source = {"kind": "semantic", "semantic": source}
                target = {"kind": "semantic", "semantic": target}
            if not source or not target:
                continue
            source_key = _node_key(source)
            target_key = _node_key(target)
            if source_key == wanted:
                other = self._runtime_object_from_ref(target)
                result[self._object_key(other)] = other
            elif target_key == wanted:
                other = self._runtime_object_from_ref(source)
                result[self._object_key(other)] = other
        return tuple(result[key] for key in sorted(result))

    def traverse(self, start: RuntimeObject, plane: str, max_depth: int) -> tuple[RuntimeObject, ...]:
        if not isinstance(max_depth, int) or max_depth < 1 or max_depth > 32:
            raise CapabilityGap("bounded traversal requires max_depth in [1, 32]")
        visited = {self._object_key(start)}
        frontier = [start]
        discovered: dict[tuple[str, str], RuntimeObject] = {}
        for _ in range(max_depth):
            next_frontier: list[RuntimeObject] = []
            for current in frontier:
                for other in self.adjacent(current, plane):
                    key = self._object_key(other)
                    if key in visited:
                        continue
                    visited.add(key)
                    discovered[key] = other
                    next_frontier.append(other)
            frontier = next_frontier
            if not frontier:
                break
        return tuple(discovered[key] for key in sorted(discovered))

    def provenance(self, *, operation: str, plane: str | None, sources: Iterable[str]) -> DerivationProvenance:
        if plane is not None and plane not in PLANES:
            raise CapabilityGap(f"unsupported relation plane: {plane!r}")
        return DerivationProvenance(snapshot=self.snapshot_digest, operation=operation, plane=plane, sources=tuple(sources))

    def serialize_admitted_semantic_relation(self, relation: Mapping[str, Any]) -> dict[str, Any]:
        key = _canonical(relation)
        if key not in self._admitted_semantic_relation_keys:
            raise AdmissionBoundaryError("Python-created or inferred semantic relations cannot be serialized as admitted state")
        return json.loads(key)
