#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_INTROSPECTION_TMP="$tmpdir"

section() {
  printf '\n== %s ==\n' "$1"
}

section "CUE logical-model introspection"
python3 scripts/cue_model_introspection.py state/fixtures/introspection-model/config.json \
  --root state/fixtures/introspection-model --output "$tmpdir/model-a.json"
python3 scripts/cue_model_introspection.py state/fixtures/introspection-model/config.json \
  --root state/fixtures/introspection-model --output "$tmpdir/model-b.json"
cmp -s "$tmpdir/model-a.json" "$tmpdir/model-b.json"
cue vet -c=false "$tmpdir/model-a.json" ./contracts/state/*.cue -d '#LogicalModelProjection'

PYTHONPATH=scripts python3 - <<'PY1'
import json
import tempfile
from pathlib import Path

from cue_model_introspection import CueModelError, compile_cue_model

root = Path("state/fixtures/introspection-model")
config = json.loads((root / "config.json").read_text(encoding="utf-8"))
projection = compile_cue_model(config, root)
nodes = {item["id"]: item for item in projection["nodes"]}
edges = {(item["relation"], item["source"], item["target"]) for item in projection["edges"]}

project = nodes["cue:observatorymodel:#Project"]
assert len(project["sources"]) == 2
assert nodes["cue:observatorymodel:#Project.external"]["required"] is False
assert ("conjoins", "cue:observatorymodel:#Project", "cue:observatorymodel:#Entity") in edges
assert ("references", "cue:observatorymodel:#Project.owner", "cue:observatorymodel:#Organization") in edges
assert any(
    relation == "references" and target == "cue-import:example.com/external:model:#External"
    for relation, _, target in edges
)

with tempfile.TemporaryDirectory() as tmp:
    bad_root = Path(tmp)
    (bad_root / "bad.cue").write_text("#MissingPackage: {value: string}\n", encoding="utf-8")
    try:
        compile_cue_model(
            {"repository": "fixture", "revision": "fixture", "files": ["bad.cue"]},
            bad_root,
        )
    except CueModelError:
        pass
    else:
        raise AssertionError("CUE model introspection accepted a source without a package declaration")
PY1

section "Python semantic-model projection"
PYTHONPATH=. python3 - <<'PY2'
import json
import os
from dataclasses import dataclass
from pathlib import Path

from runtime.generated.semantic_context import (
    ContextArtifact,
    ContextArtifactRef,
    SemanticAuthorityRef,
    SemanticRef,
    SourceOccurrence,
)
from runtime.semantic_metadata import (
    SemanticMetadataError,
    project_python_model,
    relation_metadata,
    semantic_relation,
    semantic_type,
    type_metadata,
)

classes = [SemanticAuthorityRef, SemanticRef, SourceOccurrence, ContextArtifactRef, ContextArtifact]
assert type_metadata(SemanticRef).cue_node == "cue:state:#SemanticRef"
assert relation_metadata(SemanticRef)[0].name == "authority"
first = project_python_model(classes)
second = project_python_model(reversed(classes))
assert first == second
nodes = {item["id"]: item for item in first["nodes"]}
edges = {(item["relation"], item["source"], item["target"], item.get("label")) for item in first["edges"]}
semantic_ref_id = "python:runtime.generated.semantic_context.SemanticRef"
assert nodes[semantic_ref_id]["cueNode"] == "cue:state:#SemanticRef"
assert (
    "relates-to",
    semantic_ref_id + ".authority",
    "python:runtime.generated.semantic_context.SemanticAuthorityRef",
    "authority",
) in edges

@semantic_type(cue_package="fixture", cue_type="#Bad", space="semantic", source="fixture.cue")
@semantic_relation(name="broken", target_cue_type="#Target", via_field="missing")
@dataclass(frozen=True)
class Bad:
    value: str

try:
    project_python_model([Bad])
except SemanticMetadataError:
    pass
else:
    raise AssertionError("invalid Python semantic relation metadata did not fail closed")

Path(os.environ["OBS_INTROSPECTION_TMP"], "python-model.json").write_text(
    json.dumps(first, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
PY2
cue vet -c=false "$tmpdir/python-model.json" ./contracts/state/*.cue -d '#PythonModelProjection'

section "Unified semantic introspection lineage"
PYTHONPATH=.:scripts python3 - <<'PY3'
import json
import os
from pathlib import Path

from cue_model_introspection import compile_cue_model
from runtime.generated.semantic_context import (
    ContextArtifact,
    ContextArtifactRef,
    SemanticAuthorityRef,
    SemanticRef,
    SourceOccurrence,
)
from runtime.introspection import IntrospectionError, IntrospectionGraph
from runtime.semantic_metadata import project_python_model

cue_projection = compile_cue_model(
    {
        "repository": "github.com/fatb4f/factory",
        "revision": "fixture",
        "files": ["contracts/state/semantic-context.cue"],
    },
    Path("."),
)
python_projection = project_python_model(
    [SemanticAuthorityRef, SemanticRef, SourceOccurrence, ContextArtifactRef, ContextArtifact]
)
first = IntrospectionGraph.from_projections(cue_projection, python_projection)
second = IntrospectionGraph.from_projections(python_projection, cue_projection)
assert first.projection == second.projection
cue_ref = "cue:state:#SemanticRef"
python_ref = "python:runtime.generated.semantic_context.SemanticRef"
path = first.lineage_path(cue_ref, python_ref)
assert path.nodes == (cue_ref, python_ref)
assert len(path.edges) == 1
request = {
    "id": "semantic-ref-lineage",
    "roots": [cue_ref],
    "direction": "outgoing",
    "maxDepth": 2,
    "roles": ["lineage", "structural"],
}
result = first.inspect(request)
assert any(edge["relation"] == "projects-to" for edge in result["edges"])
assert any(node["id"] == python_ref for node in result["nodes"])

try:
    IntrospectionGraph.from_projections(python_projection)
except IntrospectionError:
    pass
else:
    raise AssertionError("dangling cross-layer Python lineage did not fail closed")

tmp = Path(os.environ["OBS_INTROSPECTION_TMP"])
(tmp / "inspection-projection.json").write_text(
    json.dumps(first.projection, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
(tmp / "inspection-result.json").write_text(
    json.dumps(result, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
PY3
cue vet -c=false "$tmpdir/inspection-projection.json" ./contracts/state/*.cue -d '#InspectionProjection'
cue vet -c=false "$tmpdir/inspection-result.json" ./contracts/state/*.cue -d '#InspectionResult'

echo "observatory introspection validation passed"
