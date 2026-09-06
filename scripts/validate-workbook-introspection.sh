#!/usr/bin/env bash
set -euo pipefail

cue vet -c=false ./contracts/state:state
cue vet -c=false ./state/fixtures:statefixtures

python3 - <<'PY'
from runtime.introspection import IntrospectionGraph
from runtime.semantic_runtime import SemanticRuntime
from runtime.workbook import (
    IntrospectionBindingError,
    Workbook,
    WorkbookCapabilityGap,
    WorkbookScope,
)

snapshot_digest = "sha256:" + "1" * 64
subject = {"authority": {"id": "fixture.authority"}, "subject": "fixture.subject"}
snapshot = {
    "identity": {"digest": snapshot_digest},
    "subjects": [subject],
    "artifacts": [],
    "contextRelations": [],
    "semanticRelations": [],
}
runtime = SemanticRuntime(snapshot)

logical = {
    "kind": "LogicalModelProjection",
    "digest": "sha256:" + "2" * 64,
    "nodes": [
        {
            "id": "cue:root",
            "space": "cue",
            "kind": "definition",
            "name": "Root",
            "qualifiedName": "fixture.Root",
            "sources": [],
        },
        {
            "id": "cue:other",
            "space": "cue",
            "kind": "definition",
            "name": "Other",
            "qualifiedName": "fixture.Other",
            "sources": [],
        },
    ],
    "edges": [
        {
            "id": "logical-edge",
            "relation": "references",
            "source": "cue:root",
            "target": "cue:other",
            "basis": [],
        }
    ],
}
graph = IntrospectionGraph.from_projections(logical)
binding = {
    "id": "inspection:fixture.subject",
    "subject": subject,
    "projection": graph.projection["digest"],
    "roots": ["cue:root"],
}
scope = WorkbookScope(
    binding={"id": "directory:fixture", "subjects": [subject]},
    primary=subject,
    includes=(),
    snapshot=snapshot_digest,
)
workbook = Workbook(
    scope=scope,
    runtime=runtime,
    introspection_graph=graph,
    introspection_bindings=[binding],
)
view = {
    "id": "logical-inspection",
    "presentation": "inspection",
    "source": {
        "kind": "introspection",
        "binding": binding["id"],
        "request": {
            "id": "inspect:fixture",
            "roots": ["cue:root"],
            "direction": "outgoing",
            "maxDepth": 2,
        },
    },
}
first = workbook.evaluate(view)
second = workbook.evaluate(view)
assert first == second
assert first["kind"] == "InspectionViewResult"
assert first["inspection"]["roots"] == ["cue:root"]
assert {node["id"] for node in first["inspection"]["nodes"]} == {"cue:root", "cue:other"}

navigation = workbook.evaluate(
    {
        "id": "existing-navigation",
        "presentation": "topology",
        "source": {"kind": "bounded-navigation", "root": subject, "plane": "semantic", "maxDepth": 1},
    }
)
assert navigation["kind"] == "ProjectionResult"
assert navigation["presentation"] == "topology"

try:
    Workbook(scope=scope, runtime=runtime, introspection_bindings=[binding]).evaluate(view)
except WorkbookCapabilityGap:
    pass
else:
    raise AssertionError("missing introspection graph must fail closed")

unknown = dict(view)
unknown["source"] = dict(view["source"], binding="inspection:missing")
try:
    workbook.evaluate(unknown)
except IntrospectionBindingError:
    pass
else:
    raise AssertionError("unknown introspection binding must fail closed")

wrong_subject = dict(binding)
wrong_subject["id"] = "inspection:wrong-subject"
wrong_subject["subject"] = {"authority": {"id": "fixture.authority"}, "subject": "other.subject"}
wrong_subject_workbook = Workbook(
    scope=scope,
    runtime=runtime,
    introspection_graph=graph,
    introspection_bindings=[wrong_subject],
)
wrong_subject_view = dict(view)
wrong_subject_view["source"] = dict(view["source"], binding=wrong_subject["id"])
try:
    wrong_subject_workbook.evaluate(wrong_subject_view)
except IntrospectionBindingError:
    pass
else:
    raise AssertionError("subject mismatch must fail closed")

wrong_projection = dict(binding)
wrong_projection["id"] = "inspection:wrong-projection"
wrong_projection["projection"] = "sha256:" + "3" * 64
wrong_projection_workbook = Workbook(
    scope=scope,
    runtime=runtime,
    introspection_graph=graph,
    introspection_bindings=[wrong_projection],
)
wrong_projection_view = dict(view)
wrong_projection_view["source"] = dict(view["source"], binding=wrong_projection["id"])
try:
    wrong_projection_workbook.evaluate(wrong_projection_view)
except IntrospectionBindingError:
    pass
else:
    raise AssertionError("projection mismatch must fail closed")

unbound = dict(view)
unbound["source"] = dict(view["source"])
unbound["source"]["request"] = dict(view["source"]["request"], roots=["cue:other"])
try:
    workbook.evaluate(unbound)
except IntrospectionBindingError:
    pass
else:
    raise AssertionError("unbound introspection root must fail closed")

print("Workbook introspection binding validation passed")
PY
