#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export OBS_IBIS_TMP="$tmpdir"

cue export ./state/fixtures:statefixtures -e relationalPlan --out json >"$tmpdir/plan.json"

PYTHONPATH=.:scripts python3 - <<'PY'
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
from runtime.ibis_adapter import (
    IbisExpressionError,
    compile_expression,
    lower_relational_plan,
    project_analytics_model,
)
from runtime.introspection import IntrospectionGraph
from runtime.semantic_metadata import project_python_model

tmp = Path(os.environ["OBS_IBIS_TMP"])
plan = json.loads((tmp / "plan.json").read_text(encoding="utf-8"))
upstream = "python:runtime.generated.semantic_context.SemanticRef"

analytics_a = project_analytics_model(plan, upstream_node=upstream, target_version="adapter-v1")
analytics_b = project_analytics_model(json.loads(json.dumps(plan)), upstream_node=upstream, target_version="adapter-v1")
assert analytics_a == analytics_b
(tmp / "analytics-model.json").write_text(json.dumps(analytics_a, indent=2, sort_keys=True) + "\n", encoding="utf-8")

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
graph = IntrospectionGraph.from_projections(cue_projection, python_projection, analytics_a)
analytics_source = f"analytics:{plan['id']}:source"
ibis_node = f"analytics:{plan['id']}:ibis-expression"
path = graph.lineage_path("cue:state:#SemanticRef", ibis_node)
assert path.nodes[0] == "cue:state:#SemanticRef"
assert upstream in path.nodes
assert analytics_source in path.nodes
assert path.nodes[-1] == ibis_node
(tmp / "analytics-inspection.json").write_text(
    json.dumps(graph.projection, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

class FakeValue:
    def __init__(self, name="value"):
        self.name = name
    def _new(self, suffix): return FakeValue(f"{self.name}:{suffix}")
    def __add__(self, other): return self._new("add")
    def __sub__(self, other): return self._new("sub")
    def __mul__(self, other): return self._new("mul")
    def __truediv__(self, other): return self._new("div")
    def __floordiv__(self, other): return self._new("floordiv")
    def __mod__(self, other): return self._new("mod")
    def __pow__(self, other): return self._new("pow")
    def __neg__(self): return self._new("neg")
    def __pos__(self): return self
    def __invert__(self): return self._new("not")
    def __and__(self, other): return self._new("and")
    def __or__(self, other): return self._new("or")
    def __eq__(self, other): return self._new("eq")
    def __ne__(self, other): return self._new("ne")
    def __lt__(self, other): return self._new("lt")
    def __le__(self, other): return self._new("le")
    def __gt__(self, other): return self._new("gt")
    def __ge__(self, other): return self._new("ge")
    def sum(self): return self._new("sum")
    def count(self): return self._new("count")
    def min(self): return self._new("min")
    def max(self): return self._new("max")
    def mean(self): return self._new("mean")
    def asc(self): return self._new("asc")
    def desc(self): return self._new("desc")
    def over(self, window): return self._new("over")

class FakeGrouped:
    def __init__(self, table): self.table = table
    def aggregate(self, **metrics):
        self.table.operations.append(("aggregate", sorted(metrics)))
        return self.table

class FakeTable:
    def __init__(self, name):
        self.name = name
        self.operations = []
    def __getitem__(self, key): return FakeValue(str(key))
    def select(self, *fields):
        self.operations.append(("select", list(fields))); return self
    def filter(self, predicate):
        self.operations.append(("filter", predicate.name)); return self
    def join(self, right, predicates, how="inner"):
        self.operations.append(("join", right.name, list(predicates), how)); return self
    def group_by(self, *keys):
        self.operations.append(("group_by", list(keys))); return FakeGrouped(self)
    def aggregate(self, **metrics):
        self.operations.append(("aggregate", sorted(metrics))); return self
    def count(self): return FakeValue("count")
    def order_by(self, *values):
        self.operations.append(("order_by", len(values))); return self
    def mutate(self, **values):
        self.operations.append(("mutate", sorted(values))); return self

class FakeIbis:
    __version__ = "fixture"
    @staticmethod
    def window(**kwargs): return ("window", kwargs)
    @staticmethod
    def row_number(): return FakeValue("row_number")

fake_plan = {
    "kind": "RelationalPlan",
    "id": "plan:fixture-all-ops",
    "request": {
        "id": "fixture-all-ops",
        "source": {
            "id": "left",
            "snapshotDigest": "sha256:" + "1" * 64,
            "semanticRef": {"authority": {"id": "fixture", "contract": "fixture.cue"}, "subject": "fixture"},
            "provenance": ["fixture-source"],
            "admissibility": {"state": "admitted", "authority": "fixture.cue", "basis": ["fixture-source"]},
        },
        "grain": {"keys": ["id"], "unit": "row"},
    },
    "steps": [
        {"kind": "project", "fields": ["id", "a", "b"]},
        {"kind": "filter", "predicate": "a > 0 and b < 10", "basis": ["fixture"]},
        {
            "kind": "join",
            "joinType": "inner",
            "right": {
                "id": "right",
                "snapshotDigest": "sha256:" + "2" * 64,
                "provenance": ["right-source"],
                "admissibility": {"state": "admitted", "authority": "fixture.cue", "basis": ["right-source"]},
            },
            "on": [{"left": "id", "right": "id"}],
        },
        {"kind": "group", "keys": ["id"]},
        {"kind": "aggregate", "measures": [{"id": "total", "op": "sum", "field": "a"}]},
        {"kind": "grain-change", "output": {"keys": ["id"], "unit": "summary"}},
        {"kind": "order", "by": [{"field": "total", "direction": "desc"}]},
        {
            "kind": "window",
            "partitionBy": ["id"],
            "orderBy": [{"field": "total", "direction": "desc"}],
            "functions": [{"id": "row_index", "function": "row_number"}],
        },
        {"kind": "derive", "expressions": [{"id": "half", "expression": "total / 2", "basis": ["total"]}]},
    ],
    "outputGrain": {"keys": ["id"], "unit": "summary"},
    "provenance": {"authority": "contracts/state/analytics-ir.cue", "basis": ["fixture-plan"]},
}
left = FakeTable("left")
right = FakeTable("right")
lowering = lower_relational_plan(
    fake_plan,
    {"left": left, "right": right},
    upstream_node=upstream,
    ibis_module=FakeIbis,
)
assert lowering.expression is left
assert lowering.ibis_version == "fixture"
kinds = [operation[0] for operation in left.operations]
for expected in ("select", "filter", "join", "group_by", "aggregate", "order_by", "mutate"):
    assert expected in kinds

try:
    compile_expression("__import__('os')", left)
except IbisExpressionError:
    pass
else:
    raise AssertionError("unsafe analytical expression was accepted")
PY

cue vet -c=false "$tmpdir/analytics-model.json" ./contracts/state/*.cue -d '#AnalyticsModelProjection'
cue vet -c=false "$tmpdir/analytics-inspection.json" ./contracts/state/*.cue -d '#InspectionProjection'

echo "Ibis introspection validation passed"
