from __future__ import annotations

import copy
from typing import Any, Mapping


class PropertyGraphBoundaryError(RuntimeError):
    pass


def project(projection: Mapping[str, Any]) -> dict[str, Any]:
    """Project an admitted workbook result without inventing graph authority."""
    snapshot = str(projection["snapshot"])
    nodes: list[dict[str, Any]] = []
    for node in sorted(projection.get("nodes", []), key=lambda item: item["id"]):
        if node["space"] == "semantic":
            semantic = copy.deepcopy(node["semantic"])
            nodes.append(
                {
                    "id": str(node["id"]),
                    "class": "semantic",
                    "snapshot": snapshot,
                    "semantic": semantic,
                    "authority": copy.deepcopy(semantic["authority"]),
                    "provenance": copy.deepcopy(node["provenance"]),
                }
            )
        elif node["space"] == "context":
            nodes.append(
                {
                    "id": str(node["id"]),
                    "class": "context",
                    "snapshot": snapshot,
                    "artifact": copy.deepcopy(node["artifact"]),
                    "plane": str(node["plane"]),
                    "provenance": copy.deepcopy(node["provenance"]),
                }
            )
        else:
            raise PropertyGraphBoundaryError(f"unsupported projection node space: {node['space']!r}")

    edges: list[dict[str, Any]] = []
    for edge in sorted(projection.get("edges", []), key=lambda item: item["id"]):
        projected = {
            "id": str(edge["id"]),
            "snapshot": snapshot,
            "plane": str(edge["plane"]),
            "relation": str(edge["relation"]),
            "source": str(edge["source"]),
            "target": str(edge["target"]),
            "basis": copy.deepcopy(edge.get("basis", [])),
            "provenance": copy.deepcopy(edge.get("provenance", [])),
        }
        if edge["plane"] == "semantic":
            if "relationAuthority" not in edge or "admittedSnapshot" not in edge:
                raise PropertyGraphBoundaryError(
                    "semantic projection edge lacks admitted relation authority/snapshot metadata; refusing endpoint inference"
                )
            projected["relationAuthority"] = copy.deepcopy(edge["relationAuthority"])
            projected["admittedSnapshot"] = copy.deepcopy(edge["admittedSnapshot"])
        edges.append(projected)

    return {
        "apiVersion": "factory.property-graph/v1",
        "kind": "PropertyGraphProjection",
        "sourceViewID": str(projection["viewID"]),
        "sourcePresentation": str(projection["presentation"]),
        "snapshot": snapshot,
        "subject": copy.deepcopy(projection["subject"]),
        "direction": "factory-to-backend",
        "reverseAdmission": False,
        "nodes": nodes,
        "edges": edges,
        "provenance": copy.deepcopy(projection.get("provenance", [snapshot])),
    }


class Neo4jBatchAdapter:
    """Pure transport adapter producing driver-ready record batches only.

    It intentionally exposes no backend-to-Factory import/admission operation.
    """

    def __init__(self, *, target_id: str = "neo4j", version: str = "record-batch/v1") -> None:
        self.target = {"id": target_id, "version": version, "transport": "record-batch"}

    def load(self, property_graph: Mapping[str, Any]) -> dict[str, Any]:
        if property_graph.get("direction") != "factory-to-backend" or property_graph.get("reverseAdmission") is not False:
            raise PropertyGraphBoundaryError("property graph is not qualified for one-way Factory-to-backend transport")
        return {
            "apiVersion": "factory.property-graph/v1",
            "kind": "PropertyGraphLoadBundle",
            "target": copy.deepcopy(self.target),
            "direction": "factory-to-backend",
            "reverseAdmission": False,
            "source": {
                "viewID": str(property_graph["sourceViewID"]),
                "snapshot": str(property_graph["snapshot"]),
            },
            "nodes": copy.deepcopy(property_graph.get("nodes", [])),
            "edges": copy.deepcopy(property_graph.get("edges", [])),
        }
