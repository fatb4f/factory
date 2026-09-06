from __future__ import annotations

import ast
import hashlib
import importlib
import json
from dataclasses import dataclass
from typing import Any, Mapping


class IbisAdapterError(RuntimeError):
    pass


class IbisCapabilityGap(IbisAdapterError):
    pass


class IbisExpressionError(IbisAdapterError):
    pass


def _canonical(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def _digest(value: Any) -> str:
    return "sha256:" + hashlib.sha256(_canonical(value)).hexdigest()


def _edge_id(role: str, relation: str, source: str, target: str) -> str:
    return "edge:" + hashlib.sha256(f"{role}\0{relation}\0{source}\0{target}".encode()).hexdigest()


def _attributes(**values: Any) -> list[dict[str, str]]:
    result: list[dict[str, str]] = []
    for key in sorted(values):
        value = values[key]
        if value is None:
            continue
        if isinstance(value, str):
            encoded = value
        else:
            encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
        result.append({"key": key, "value": encoded})
    return result


def _grain_token(grain: Mapping[str, Any]) -> str:
    return json.dumps(dict(grain), sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def _basis_token(value: Any) -> str:
    if isinstance(value, str):
        return value
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def project_analytics_model(
    plan: Mapping[str, Any],
    *,
    upstream_node: str,
    target_version: str = "adapter-v1",
) -> dict[str, Any]:
    if plan.get("kind") != "RelationalPlan":
        raise IbisAdapterError("Ibis projection requires a factory.analytics-ir RelationalPlan")
    if not upstream_node:
        raise IbisAdapterError("analytical projection requires an explicit upstream inspection node")

    request = plan["request"]
    source = request["source"]
    plan_id = str(plan["id"])
    prefix = f"analytics:{plan_id}"
    source_id = f"{prefix}:source"
    request_id = f"{prefix}:request"
    output_id = f"{prefix}:output"
    ibis_id = f"{prefix}:ibis-expression"

    provenance = sorted(
        {
            *(str(item) for item in source.get("provenance", [])),
            *(str(item) for item in source.get("admissibility", {}).get("basis", [])),
            *(str(item) for item in plan.get("provenance", {}).get("basis", [])),
        }
    )
    nodes: list[dict[str, Any]] = [
        {
            "id": source_id,
            "space": "analytics",
            "kind": "source",
            "name": str(source["id"]),
            "qualifiedName": str(source["id"]),
            "attributes": _attributes(
                snapshotDigest=source["snapshotDigest"],
                semanticRef=source.get("semanticRef"),
                admissibility=source.get("admissibility"),
            ),
            "provenance": provenance or [str(source["snapshotDigest"])],
        },
        {
            "id": request_id,
            "space": "analytics",
            "kind": "request",
            "name": str(request["id"]),
            "qualifiedName": f"factory.analytics-ir:{request['id']}",
            "attributes": _attributes(inputGrain=request["grain"]),
            "provenance": provenance or [str(source["snapshotDigest"])],
        },
    ]
    edges: list[dict[str, Any]] = [
        {
            "id": _edge_id("lineage", "realizes-as", upstream_node, source_id),
            "role": "lineage",
            "relation": "realizes-as",
            "source": upstream_node,
            "target": source_id,
            "basis": sorted(
                {
                    f"snapshot:{source['snapshotDigest']}",
                    *(_basis_token(item) for item in source.get("provenance", [])),
                    *(
                        [_basis_token(source["semanticRef"])]
                        if source.get("semanticRef") is not None
                        else []
                    ),
                }
            ),
            "provenance": provenance or [str(source["snapshotDigest"])],
        },
        {
            "id": _edge_id("analytical", "feeds", source_id, request_id),
            "role": "analytical",
            "relation": "feeds",
            "source": source_id,
            "target": request_id,
            "basis": provenance or [str(source["snapshotDigest"])],
            "provenance": provenance or [str(source["snapshotDigest"])],
        },
    ]

    previous = request_id
    for index, operation in enumerate(plan.get("steps", [])):
        kind = str(operation["kind"])
        step_id = f"{prefix}:step:{index:03d}:{kind}"
        nodes.append(
            {
                "id": step_id,
                "space": "analytics",
                "kind": "operation",
                "name": kind,
                "qualifiedName": f"{plan_id}.steps[{index}]",
                "attributes": _attributes(index=index, operation=operation),
                "provenance": provenance,
            }
        )
        edges.append(
            {
                "id": _edge_id("analytical", "then", previous, step_id),
                "role": "analytical",
                "relation": "then",
                "source": previous,
                "target": step_id,
                "basis": [f"plan:{plan_id}:step:{index}"],
                "provenance": provenance,
            }
        )
        previous = step_id

    nodes.extend(
        [
            {
                "id": output_id,
                "space": "analytics",
                "kind": "output",
                "name": str(plan["outputGrain"]["unit"]),
                "qualifiedName": f"{plan_id}.output",
                "attributes": _attributes(outputGrain=plan["outputGrain"]),
                "provenance": provenance,
            },
            {
                "id": ibis_id,
                "space": "analytics",
                "kind": "ibis-expression",
                "name": "Ibis expression",
                "qualifiedName": f"{plan_id}.ibis",
                "attributes": _attributes(target="ibis", capabilityVersion=target_version),
                "provenance": provenance,
            },
        ]
    )
    edges.extend(
        [
            {
                "id": _edge_id("analytical", "produces", previous, output_id),
                "role": "analytical",
                "relation": "produces",
                "source": previous,
                "target": output_id,
                "basis": [f"grain:{_grain_token(plan['outputGrain'])}"],
                "provenance": provenance,
            },
            {
                "id": _edge_id("lineage", "lowers-to", output_id, ibis_id),
                "role": "lineage",
                "relation": "lowers-to",
                "source": output_id,
                "target": ibis_id,
                "basis": [f"target:ibis:{target_version}"],
                "provenance": provenance,
            },
        ]
    )

    payload = {
        "apiVersion": "factory.introspection/v1",
        "kind": "AnalyticsModelProjection",
        "planID": plan_id,
        "target": {"id": "ibis", "capabilityVersion": target_version},
        "upstreamNode": upstream_node,
        "sourceSnapshot": str(source["snapshotDigest"]),
        "inputGrain": dict(request["grain"]),
        "outputGrain": dict(plan["outputGrain"]),
        "provenance": provenance or [str(source["snapshotDigest"])],
        "nodes": sorted(nodes, key=lambda item: item["id"]),
        "edges": sorted(edges, key=lambda item: item["id"]),
    }
    result = dict(payload)
    result["digest"] = _digest(payload)
    return result


class _SafeExpressionCompiler(ast.NodeVisitor):
    def __init__(self, table: Any):
        self.table = table

    def compile(self, expression: str) -> Any:
        try:
            tree = ast.parse(expression, mode="eval")
        except SyntaxError as exc:
            raise IbisExpressionError(f"invalid analytical expression: {expression!r}") from exc
        return self.visit(tree.body)

    def visit_Name(self, node: ast.Name) -> Any:
        try:
            return self.table[node.id]
        except Exception as exc:
            raise IbisExpressionError(f"unknown analytical field: {node.id!r}") from exc

    def visit_Constant(self, node: ast.Constant) -> Any:
        if isinstance(node.value, (str, int, float, bool)) or node.value is None:
            return node.value
        raise IbisExpressionError(f"unsupported literal: {node.value!r}")

    def visit_BinOp(self, node: ast.BinOp) -> Any:
        left = self.visit(node.left)
        right = self.visit(node.right)
        operators = {
            ast.Add: lambda a, b: a + b,
            ast.Sub: lambda a, b: a - b,
            ast.Mult: lambda a, b: a * b,
            ast.Div: lambda a, b: a / b,
            ast.FloorDiv: lambda a, b: a // b,
            ast.Mod: lambda a, b: a % b,
            ast.Pow: lambda a, b: a**b,
        }
        handler = operators.get(type(node.op))
        if handler is None:
            raise IbisExpressionError(f"unsupported binary operator: {type(node.op).__name__}")
        return handler(left, right)

    def visit_UnaryOp(self, node: ast.UnaryOp) -> Any:
        value = self.visit(node.operand)
        if isinstance(node.op, ast.USub):
            return -value
        if isinstance(node.op, ast.UAdd):
            return +value
        if isinstance(node.op, ast.Not):
            return ~value
        raise IbisExpressionError(f"unsupported unary operator: {type(node.op).__name__}")

    def visit_BoolOp(self, node: ast.BoolOp) -> Any:
        values = [self.visit(value) for value in node.values]
        if not values:
            raise IbisExpressionError("boolean expression has no operands")
        result = values[0]
        if isinstance(node.op, ast.And):
            for value in values[1:]:
                result = result & value
            return result
        if isinstance(node.op, ast.Or):
            for value in values[1:]:
                result = result | value
            return result
        raise IbisExpressionError(f"unsupported boolean operator: {type(node.op).__name__}")

    def visit_Compare(self, node: ast.Compare) -> Any:
        left = self.visit(node.left)
        predicates: list[Any] = []
        handlers = {
            ast.Eq: lambda a, b: a == b,
            ast.NotEq: lambda a, b: a != b,
            ast.Lt: lambda a, b: a < b,
            ast.LtE: lambda a, b: a <= b,
            ast.Gt: lambda a, b: a > b,
            ast.GtE: lambda a, b: a >= b,
        }
        for operator, comparator in zip(node.ops, node.comparators, strict=True):
            right = self.visit(comparator)
            handler = handlers.get(type(operator))
            if handler is None:
                raise IbisExpressionError(f"unsupported comparison operator: {type(operator).__name__}")
            predicates.append(handler(left, right))
            left = right
        result = predicates[0]
        for predicate in predicates[1:]:
            result = result & predicate
        return result

    def generic_visit(self, node: ast.AST) -> Any:
        raise IbisExpressionError(f"unsupported analytical expression syntax: {type(node).__name__}")


def compile_expression(expression: str, table: Any) -> Any:
    return _SafeExpressionCompiler(table).compile(expression)


def _load_ibis() -> Any:
    try:
        return importlib.import_module("ibis")
    except ModuleNotFoundError as exc:
        raise IbisCapabilityGap(
            "Ibis lowering requires the optional 'ibis-framework' runtime dependency"
        ) from exc


def _aggregate_value(expr: Any, measure: Mapping[str, Any]) -> Any:
    op = str(measure["op"])
    field = measure.get("field")
    if op == "count" and field is None:
        return expr.count()
    if field is None:
        raise IbisCapabilityGap(f"aggregate {op!r} requires a field")
    value = expr[str(field)]
    method = getattr(value, op, None)
    if method is None or not callable(method):
        raise IbisCapabilityGap(f"Ibis value does not support aggregate {op!r}")
    return method()


def _ordered_values(expr: Any, keys: list[Mapping[str, Any]]) -> list[Any]:
    result: list[Any] = []
    for key in keys:
        value = expr[str(key["field"])]
        direction = str(key["direction"])
        if direction == "asc":
            result.append(value.asc())
        elif direction == "desc":
            result.append(value.desc())
        else:
            raise IbisCapabilityGap(f"unsupported ordering direction: {direction!r}")
    return result


def _window_value(ibis: Any, expr: Any, function: Mapping[str, Any], window: Any) -> Any:
    name = str(function["function"])
    field = function.get("field")
    if field is None:
        factory = getattr(ibis, name, None)
        if factory is None or not callable(factory):
            raise IbisCapabilityGap(f"unsupported Ibis window function: {name!r}")
        value = factory()
    else:
        column = expr[str(field)]
        factory = getattr(column, name, None)
        if factory is None or not callable(factory):
            raise IbisCapabilityGap(f"unsupported Ibis window function: {name!r}")
        value = factory()
    over = getattr(value, "over", None)
    if over is None or not callable(over):
        raise IbisCapabilityGap(f"Ibis expression for {name!r} cannot be windowed")
    return over(window)


@dataclass(frozen=True, slots=True)
class IbisLowering:
    expression: Any
    introspection: Mapping[str, Any]
    ibis_version: str


def lower_relational_plan(
    plan: Mapping[str, Any],
    tables: Mapping[str, Any],
    *,
    upstream_node: str,
    ibis_module: Any | None = None,
) -> IbisLowering:
    ibis = ibis_module if ibis_module is not None else _load_ibis()
    version = str(getattr(ibis, "__version__", "unknown"))
    if plan.get("kind") != "RelationalPlan":
        raise IbisAdapterError("Ibis lowering requires a RelationalPlan")

    request = plan["request"]
    source_id = str(request["source"]["id"])
    if source_id not in tables:
        raise IbisCapabilityGap(f"missing Ibis source relation for {source_id!r}")
    expr = tables[source_id]
    group_keys: list[str] | None = None

    for operation in plan.get("steps", []):
        kind = str(operation["kind"])
        if kind == "project":
            expr = expr.select(*[str(field) for field in operation["fields"]])
        elif kind == "filter":
            expr = expr.filter(compile_expression(str(operation["predicate"]), expr))
        elif kind == "join":
            right_source = operation["right"]
            right_id = str(right_source["id"])
            if right_id not in tables:
                raise IbisCapabilityGap(f"missing Ibis join relation for {right_id!r}")
            right = tables[right_id]
            predicates = [
                (str(key["left"]), str(key["right"]))
                for key in operation["on"]
            ]
            expr = expr.join(right, predicates, how=str(operation["joinType"]))
        elif kind == "group":
            group_keys = [str(key) for key in operation["keys"]]
        elif kind == "aggregate":
            metrics = {
                str(measure["id"]): _aggregate_value(expr, measure)
                for measure in operation["measures"]
            }
            if group_keys is None:
                expr = expr.aggregate(**metrics)
            else:
                expr = expr.group_by(*group_keys).aggregate(**metrics)
                group_keys = None
        elif kind == "grain-change":
            continue
        elif kind == "order":
            expr = expr.order_by(*_ordered_values(expr, list(operation["by"])))
        elif kind == "window":
            window = ibis.window(
                group_by=[expr[str(key)] for key in operation.get("partitionBy", [])],
                order_by=_ordered_values(expr, list(operation["orderBy"])),
            )
            mutations = {
                str(function["id"]): _window_value(ibis, expr, function, window)
                for function in operation["functions"]
            }
            expr = expr.mutate(**mutations)
        elif kind == "derive":
            for derived in operation["expressions"]:
                expr = expr.mutate(
                    **{
                        str(derived["id"]): compile_expression(
                            str(derived["expression"]), expr
                        )
                    }
                )
        else:
            raise IbisCapabilityGap(f"unsupported analytical operation: {kind!r}")

    if group_keys is not None:
        raise IbisCapabilityGap("group operation must be consumed by a following aggregate operation")

    introspection = project_analytics_model(
        plan,
        upstream_node=upstream_node,
        target_version=f"ibis-{version}",
    )
    return IbisLowering(expression=expr, introspection=introspection, ibis_version=version)
