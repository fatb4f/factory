from __future__ import annotations

import hashlib
import json
from collections import deque
from dataclasses import dataclass
from typing import Any, Mapping


class IntrospectionError(RuntimeError):
    pass


class InspectionCapabilityGap(IntrospectionError):
    pass


def _canonical(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def _digest(value: Any) -> str:
    return "sha256:" + hashlib.sha256(_canonical(value)).hexdigest()


def _edge_id(role: str, relation: str, source: str, target: str, label: str | None = None) -> str:
    seed = f"{role}\0{relation}\0{source}\0{target}\0{label or ''}".encode()
    return "edge:" + hashlib.sha256(seed).hexdigest()


def _source_token(source: Mapping[str, Any]) -> str:
    return f"{source['path']}:{source['lineStart']}-{source['lineEnd']}@{source['digest']}"


def _attributes(node: Mapping[str, Any], excluded: set[str]) -> list[dict[str, str]]:
    result: list[dict[str, str]] = []
    for key in sorted(set(node) - excluded):
        value = node[key]
        if value is None or value == []:
            continue
        if isinstance(value, (str, int, float, bool)):
            encoded = str(value).lower() if isinstance(value, bool) else str(value)
        else:
            encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
        result.append({"key": str(key), "value": encoded})
    return result


def _normalize_logical(projection: Mapping[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, Any]] = []
    for item in projection.get("nodes", []):
        sources = list(item.get("sources", []))
        nodes.append({
            "id": str(item["id"]),
            "space": "cue",
            "kind": str(item["kind"]),
            "label": str(item.get("name") or item["id"]),
            **({"qualifiedName": str(item["qualifiedName"])} if item.get("qualifiedName") else {}),
            "attributes": _attributes(item, {"id", "space", "kind", "name", "qualifiedName", "sources"}),
            "provenance": sorted(_source_token(source) for source in sources),
        })
    role_by_relation = {
        "contains": "structural",
        "imports": "structural",
        "references": "model",
        "conjoins": "model",
    }
    for item in projection.get("edges", []):
        relation = str(item["relation"])
        role = role_by_relation.get(relation)
        if role is None:
            raise IntrospectionError(f"unsupported logical-model edge relation: {relation!r}")
        basis = sorted(_source_token(source) for source in item.get("basis", []))
        edges.append({
            "id": _edge_id(role, relation, str(item["source"]), str(item["target"])),
            "role": role,
            "relation": relation,
            "source": str(item["source"]),
            "target": str(item["target"]),
            "basis": basis,
            "provenance": basis,
        })
    return nodes, edges


def _normalize_python(projection: Mapping[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, Any]] = []
    for item in projection.get("nodes", []):
        source = str(item.get("source") or "python-model-projection")
        nodes.append({
            "id": str(item["id"]),
            "space": "python",
            "kind": str(item["kind"]),
            "label": str(item.get("name") or item["id"]),
            **({"qualifiedName": str(item["qualifiedName"])} if item.get("qualifiedName") else {}),
            "attributes": _attributes(item, {"id", "space", "kind", "name", "qualifiedName", "source"}),
            "provenance": [source],
        })
    for item in projection.get("edges", []):
        native_relation = str(item["relation"])
        source = str(item["source"])
        target = str(item["target"])
        label = item.get("label")
        if native_relation == "projects-from":
            role, relation = "lineage", "projects-to"
            source, target = target, source
        elif native_relation == "contains":
            role, relation = "structural", native_relation
        elif native_relation == "relates-to":
            role, relation = "model", native_relation
        else:
            raise IntrospectionError(f"unsupported Python-model edge relation: {native_relation!r}")
        basis = sorted(str(value) for value in item.get("basis", []))
        edges.append({
            "id": _edge_id(role, relation, source, target, str(label) if label else None),
            "role": role,
            "relation": relation,
            **({"label": str(label)} if label else {}),
            "source": source,
            "target": target,
            "basis": basis,
            "provenance": basis,
        })
    return nodes, edges


def _normalize_analytics(projection: Mapping[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, Any]] = []
    for item in projection.get("nodes", []):
        if item.get("space") != "analytics":
            raise IntrospectionError(f"analytics projection emitted non-analytics node: {item.get('id')!r}")
        nodes.append({
            "id": str(item["id"]),
            "space": "analytics",
            "kind": str(item["kind"]),
            "label": str(item.get("name") or item["id"]),
            **({"qualifiedName": str(item["qualifiedName"])} if item.get("qualifiedName") else {}),
            "attributes": [
                {"key": str(attribute["key"]), "value": str(attribute["value"])}
                for attribute in item.get("attributes", [])
            ],
            "provenance": sorted(str(value) for value in item.get("provenance", [])),
        })
    for item in projection.get("edges", []):
        role = str(item["role"])
        if role not in {"analytical", "lineage"}:
            raise IntrospectionError(f"unsupported analytics edge role: {role!r}")
        relation = str(item["relation"])
        source = str(item["source"])
        target = str(item["target"])
        label = item.get("label")
        basis = sorted(str(value) for value in item.get("basis", []))
        provenance = sorted(str(value) for value in item.get("provenance", []))
        edges.append({
            "id": _edge_id(role, relation, source, target, str(label) if label else None),
            "role": role,
            "relation": relation,
            **({"label": str(label)} if label else {}),
            "source": source,
            "target": target,
            "basis": basis,
            "provenance": provenance,
        })
    return nodes, edges


def _merge_node(existing: dict[str, Any], incoming: Mapping[str, Any]) -> None:
    for field in ("space", "kind", "label", "qualifiedName"):
        a = existing.get(field)
        b = incoming.get(field)
        if a is not None and b is not None and a != b:
            raise IntrospectionError(f"node {existing['id']} has conflicting {field}: {a!r} != {b!r}")
        if a is None and b is not None:
            existing[field] = b
    attrs = {(item["key"], item["value"]) for item in existing.get("attributes", [])}
    attrs.update((item["key"], item["value"]) for item in incoming.get("attributes", []))
    existing["attributes"] = [{"key": key, "value": value} for key, value in sorted(attrs)]
    existing["provenance"] = sorted(set(existing.get("provenance", [])) | set(incoming.get("provenance", [])))


@dataclass(frozen=True, slots=True)
class LineagePath:
    source: str
    target: str
    nodes: tuple[str, ...]
    edges: tuple[str, ...]


class IntrospectionGraph:
    def __init__(self, projection: Mapping[str, Any]):
        self._projection = dict(projection)
        self._nodes = {str(item["id"]): dict(item) for item in projection.get("nodes", [])}
        self._edges = {str(item["id"]): dict(item) for item in projection.get("edges", [])}
        self._outgoing: dict[str, list[dict[str, Any]]] = {node_id: [] for node_id in self._nodes}
        self._incoming: dict[str, list[dict[str, Any]]] = {node_id: [] for node_id in self._nodes}
        for edge in self._edges.values():
            source = str(edge["source"])
            target = str(edge["target"])
            if source not in self._nodes or target not in self._nodes:
                raise IntrospectionError(f"dangling inspection edge {edge['id']}: {source!r} -> {target!r}")
            self._outgoing[source].append(edge)
            self._incoming[target].append(edge)
        for index in (self._outgoing, self._incoming):
            for values in index.values():
                values.sort(key=lambda item: item["id"])

    @classmethod
    def from_projections(cls, *projections: Mapping[str, Any]) -> "IntrospectionGraph":
        if not projections:
            raise IntrospectionError("at least one source projection is required")
        nodes: dict[str, dict[str, Any]] = {}
        edges: dict[str, dict[str, Any]] = {}
        source_digests: set[str] = set()
        for projection in sorted(projections, key=lambda item: (str(item.get("kind")), str(item.get("digest")))):
            kind = projection.get("kind")
            digest = projection.get("digest")
            if not isinstance(digest, str) or not digest.startswith("sha256:"):
                raise IntrospectionError(f"source projection {kind!r} lacks immutable digest")
            source_digests.add(digest)
            if kind == "LogicalModelProjection":
                source_nodes, source_edges = _normalize_logical(projection)
            elif kind == "PythonModelProjection":
                source_nodes, source_edges = _normalize_python(projection)
            elif kind == "AnalyticsModelProjection":
                source_nodes, source_edges = _normalize_analytics(projection)
            else:
                raise InspectionCapabilityGap(f"unsupported source projection kind: {kind!r}")
            for node in source_nodes:
                node_id = node["id"]
                if node_id in nodes:
                    _merge_node(nodes[node_id], node)
                else:
                    nodes[node_id] = node
            for edge in source_edges:
                existing = edges.get(edge["id"])
                if existing is not None and existing != edge:
                    raise IntrospectionError(f"inspection edge id collision: {edge['id']}")
                edges[edge["id"]] = edge

        payload = {
            "apiVersion": "factory.introspection/v1",
            "kind": "InspectionProjection",
            "sourceDigests": sorted(source_digests),
            "nodes": [nodes[key] for key in sorted(nodes)],
            "edges": [edges[key] for key in sorted(edges)],
        }
        result = dict(payload)
        result["digest"] = _digest(payload)
        return cls(result)

    @property
    def projection(self) -> dict[str, Any]:
        return json.loads(json.dumps(self._projection, sort_keys=True))

    def node(self, node_id: str) -> dict[str, Any]:
        if node_id not in self._nodes:
            raise KeyError(node_id)
        return json.loads(json.dumps(self._nodes[node_id], sort_keys=True))

    def inspect(self, request: Mapping[str, Any]) -> dict[str, Any]:
        roots = tuple(str(value) for value in request.get("roots", []))
        if not roots:
            raise InspectionCapabilityGap("inspection requires at least one root")
        for root in roots:
            if root not in self._nodes:
                raise KeyError(root)
        direction = str(request.get("direction", "both"))
        if direction not in {"outgoing", "incoming", "both"}:
            raise InspectionCapabilityGap(f"unsupported inspection direction: {direction!r}")
        max_depth = int(request.get("maxDepth", 1))
        if max_depth < 1 or max_depth > 32:
            raise InspectionCapabilityGap("maxDepth must be in [1, 32]")
        spaces = {str(value) for value in request.get("spaces", [])}
        relations = {str(value) for value in request.get("relations", [])}
        roles = {str(value) for value in request.get("roles", [])}

        visited = set(roots)
        selected_edges: dict[str, dict[str, Any]] = {}
        frontier = list(roots)
        for _ in range(max_depth):
            next_frontier: list[str] = []
            for node_id in frontier:
                candidates: list[tuple[dict[str, Any], str]] = []
                if direction in {"outgoing", "both"}:
                    candidates.extend((edge, str(edge["target"])) for edge in self._outgoing[node_id])
                if direction in {"incoming", "both"}:
                    candidates.extend((edge, str(edge["source"])) for edge in self._incoming[node_id])
                for edge, other in sorted(candidates, key=lambda pair: pair[0]["id"]):
                    if relations and edge["relation"] not in relations:
                        continue
                    if roles and edge["role"] not in roles:
                        continue
                    other_node = self._nodes[other]
                    if spaces and other_node["space"] not in spaces:
                        continue
                    selected_edges[edge["id"]] = edge
                    if other not in visited:
                        visited.add(other)
                        next_frontier.append(other)
            frontier = sorted(set(next_frontier))
            if not frontier:
                break

        selected_nodes = {node_id: self._nodes[node_id] for node_id in visited}
        selected_edges = {
            edge_id: edge
            for edge_id, edge in selected_edges.items()
            if edge["source"] in selected_nodes and edge["target"] in selected_nodes
        }
        payload = {
            "apiVersion": "factory.introspection/v1",
            "kind": "InspectionResult",
            "projectionDigest": self._projection["digest"],
            "requestID": str(request["id"]),
            "roots": list(roots),
            "nodes": [selected_nodes[key] for key in sorted(selected_nodes)],
            "edges": [selected_edges[key] for key in sorted(selected_edges)],
        }
        result = dict(payload)
        result["digest"] = _digest(payload)
        return result

    def lineage_path(
        self,
        source: str,
        target: str,
        max_depth: int = 32,
        roles: tuple[str, ...] = ("lineage", "analytical", "render"),
    ) -> LineagePath:
        if source not in self._nodes:
            raise KeyError(source)
        if target not in self._nodes:
            raise KeyError(target)
        if max_depth < 1 or max_depth > 32:
            raise InspectionCapabilityGap("max_depth must be in [1, 32]")
        queue: deque[tuple[str, tuple[str, ...], tuple[str, ...]]] = deque([(source, (source,), ())])
        visited = {source}
        allowed_roles = set(roles)
        while queue:
            current, node_path, edge_path = queue.popleft()
            if current == target:
                return LineagePath(source=source, target=target, nodes=node_path, edges=edge_path)
            if len(edge_path) >= max_depth:
                continue
            for edge in self._outgoing[current]:
                if edge["role"] not in allowed_roles:
                    continue
                other = str(edge["target"])
                if other in visited:
                    continue
                visited.add(other)
                queue.append((other, node_path + (other,), edge_path + (str(edge["id"]),)))
        raise InspectionCapabilityGap(f"no lineage path from {source!r} to {target!r} within depth {max_depth}")
