from __future__ import annotations

import hashlib
import json
from dataclasses import MISSING, dataclass, fields, is_dataclass
from typing import Any, Iterable


class SemanticMetadataError(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class SemanticTypeMetadata:
    cue_package: str
    cue_type: str
    space: str
    source: str

    @property
    def cue_node(self) -> str:
        return f"cue:{self.cue_package}:{self.cue_type}"


@dataclass(frozen=True, slots=True)
class SemanticRelationMetadata:
    name: str
    target_cue_type: str
    via_field: str
    cardinality: str = "one"


def semantic_type(*, cue_package: str, cue_type: str, space: str, source: str):
    metadata = SemanticTypeMetadata(cue_package=cue_package, cue_type=cue_type, space=space, source=source)

    def decorate(cls: type[Any]) -> type[Any]:
        setattr(cls, "__factory_semantic__", metadata)
        return cls

    return decorate


def semantic_relation(*, name: str, target_cue_type: str, via_field: str, cardinality: str = "one"):
    if cardinality not in {"one", "many"}:
        raise SemanticMetadataError(f"unsupported relation cardinality: {cardinality!r}")
    relation = SemanticRelationMetadata(
        name=name,
        target_cue_type=target_cue_type,
        via_field=via_field,
        cardinality=cardinality,
    )

    def decorate(cls: type[Any]) -> type[Any]:
        current = tuple(getattr(cls, "__factory_relations__", ()))
        setattr(cls, "__factory_relations__", current + (relation,))
        return cls

    return decorate


def type_metadata(value: type[Any] | Any) -> SemanticTypeMetadata:
    cls = value if isinstance(value, type) else type(value)
    metadata = getattr(cls, "__factory_semantic__", None)
    if not isinstance(metadata, SemanticTypeMetadata):
        raise SemanticMetadataError(f"{cls.__module__}.{cls.__qualname__} lacks Factory semantic type metadata")
    return metadata


def relation_metadata(value: type[Any] | Any) -> tuple[SemanticRelationMetadata, ...]:
    cls = value if isinstance(value, type) else type(value)
    relations = tuple(getattr(cls, "__factory_relations__", ()))
    if not all(isinstance(item, SemanticRelationMetadata) for item in relations):
        raise SemanticMetadataError(f"{cls.__module__}.{cls.__qualname__} has invalid Factory relation metadata")
    return tuple(sorted(relations, key=lambda item: (item.via_field, item.name, item.target_cue_type)))


def _canonical(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def _digest(value: Any) -> str:
    return "sha256:" + hashlib.sha256(_canonical(value)).hexdigest()


def _type_id(cls: type[Any]) -> str:
    return f"python:{cls.__module__}.{cls.__qualname__}"


def _edge_id(relation: str, source: str, target: str, label: str | None = None) -> str:
    seed = f"{relation}\0{source}\0{target}\0{label or ''}".encode()
    return "edge:" + hashlib.sha256(seed).hexdigest()


def project_python_model(types: Iterable[type[Any]]) -> dict[str, Any]:
    classes = sorted(set(types), key=lambda cls: (cls.__module__, cls.__qualname__))
    if not classes:
        raise SemanticMetadataError("at least one decorated Python type is required")

    metadata_by_class = {cls: type_metadata(cls) for cls in classes}
    class_by_cue = {(meta.cue_package, meta.cue_type): cls for cls, meta in metadata_by_class.items()}
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, Any]] = []
    source_cue_nodes: set[str] = set()

    for cls in classes:
        meta = metadata_by_class[cls]
        type_id = _type_id(cls)
        source_cue_nodes.add(meta.cue_node)
        nodes.append({
            "id": type_id,
            "space": "python",
            "kind": "type",
            "name": cls.__name__,
            "qualifiedName": f"{cls.__module__}.{cls.__qualname__}",
            "cueNode": meta.cue_node,
            "semanticSpace": meta.space,
            "source": meta.source,
        })
        edges.append({
            "id": _edge_id("projects-from", type_id, meta.cue_node),
            "relation": "projects-from",
            "source": type_id,
            "target": meta.cue_node,
            "basis": [meta.source, meta.cue_node],
        })

        if not is_dataclass(cls):
            raise SemanticMetadataError(f"{cls.__module__}.{cls.__qualname__} is not a dataclass")
        field_names: set[str] = set()
        for field in fields(cls):
            field_names.add(field.name)
            field_id = f"{type_id}.{field.name}"
            annotation = cls.__annotations__.get(field.name, Any)
            annotation_text = annotation if isinstance(annotation, str) else getattr(annotation, "__name__", repr(annotation))
            required = field.default is MISSING and field.default_factory is MISSING
            nodes.append({
                "id": field_id,
                "space": "python",
                "kind": "field",
                "name": field.name,
                "qualifiedName": f"{cls.__module__}.{cls.__qualname__}.{field.name}",
                "annotation": str(annotation_text),
                "required": required,
                "source": meta.source,
            })
            edges.append({
                "id": _edge_id("contains", type_id, field_id),
                "relation": "contains",
                "source": type_id,
                "target": field_id,
                "basis": [meta.cue_node],
            })

        for relation in relation_metadata(cls):
            if relation.via_field not in field_names:
                raise SemanticMetadataError(
                    f"relation {relation.name!r} references missing field {relation.via_field!r} on {cls.__qualname__}"
                )
            field_id = f"{type_id}.{relation.via_field}"
            target_cls = class_by_cue.get((meta.cue_package, relation.target_cue_type))
            target = _type_id(target_cls) if target_cls is not None else f"cue:{meta.cue_package}:{relation.target_cue_type}"
            source_cue_nodes.add(f"cue:{meta.cue_package}:{relation.target_cue_type}")
            edges.append({
                "id": _edge_id("relates-to", field_id, target, relation.name),
                "relation": "relates-to",
                "label": relation.name,
                "source": field_id,
                "target": target,
                "cardinality": relation.cardinality,
                "basis": [meta.cue_node, f"field:{relation.via_field}"],
            })

    payload = {
        "apiVersion": "factory.introspection/v1",
        "kind": "PythonModelProjection",
        "sourceCueNodes": sorted(source_cue_nodes),
        "nodes": sorted(nodes, key=lambda item: item["id"]),
        "edges": sorted(edges, key=lambda item: item["id"]),
    }
    result = dict(payload)
    result["digest"] = _digest(payload)
    return result
