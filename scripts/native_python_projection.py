"""Compile the bounded CUE native-object binding into disposable Python code."""
from __future__ import annotations

import ast
import keyword
from pprint import pformat
import subprocess

from python_api_facts import ROOT, BindingError, canonical, digest, repository_file, verify, vet
from cue_model_introspection import PACKAGE_RE, _sanitize


def identifier(name):
    if not isinstance(name, str) or not name.isascii() or not name.isidentifier() or keyword.iskeyword(name) or name.startswith("_"):
        raise BindingError(f"invalid public Python identifier: {name!r}")
    return name


def qualify(plan, facts):
    identifier(plan["cuePackage"])
    vet({"plan": plan, "facts": facts}, "#NativePythonBinding")
    verify(facts, plan["apiSource"])
    source = repository_file(plan["source"])
    if digest(source.read_bytes()) != plan["sourceDigest"]:
        raise BindingError("CUE source digest drift; review and update the binding")
    package = PACKAGE_RE.search(_sanitize(source.read_text(encoding="utf-8")))
    if package is None or package[1] != plan["cuePackage"]:
        raise BindingError("CUE package identity mismatch")
    expression = "{" + ",".join(f"root{i}: {t['cueType']}" for i, t in enumerate(plan["types"])) + "}"
    resolved = subprocess.run(["cue", "eval", *map(str, sorted(source.parent.glob("*.cue"))),
                               "-e", expression, "--out", "cue"],
                              cwd=ROOT, capture_output=True, text=True)
    if resolved.returncode:
        raise BindingError("CUE projection roots do not resolve: " + resolved.stderr)
    names = [identifier(t["name"]) for t in plan["types"]]
    reserved = {"builtins", "dataclasses", "typing", "UNSET", "UnsetType", "semantic_type",
                "PROJECTION_PLAN", "PLAN_DIGEST", "API_FACTS_DIGEST"}
    if reserved.intersection(names):
        raise BindingError("projected type shadows generated infrastructure")
    if len(names) != len(set(names)) or len({t["cueType"] for t in plan["types"]}) != len(names):
        raise BindingError("duplicate projected type identity")
    for fact in facts["symbols"].values():
        if fact["module"] not in {"builtins", "dataclasses", "typing"}:
            raise BindingError("native module outside this qualified slice")
        identifier(fact["symbol"])
    decorator = facts["symbols"][plan["decorator"]["api"]]
    if (decorator["module"], decorator["symbol"]) != ("dataclasses", "dataclass"):
        raise BindingError("unsupported native object constructor")
    options = plan["decorator"]["keywords"]
    compatible = []
    for declaration in decorator["declarations"]:
        params = {p["name"]: p for p in declaration["parameters"]}
        if all(k in params and params[k]["kind"] in {"keyword-only", "positional-or-keyword"}
               and params[k]["annotation"] == "bool" and type(v) is bool for k, v in options.items()) and not any(
                   p["required"] and p["name"] not in options for p in params.values()):
            compatible.append(declaration)
    if not compatible:
        raise BindingError("no compatible dataclass decorator overload")
    if (facts["symbols"][plan["tupleAPI"]]["module"], facts["symbols"][plan["tupleAPI"]]["symbol"]) != ("builtins", "tuple"):
        raise BindingError("tuple target mismatch")
    if (facts["symbols"][plan["literalAPI"]]["module"], facts["symbols"][plan["literalAPI"]]["symbol"]) != ("typing", "Literal"):
        raise BindingError("literal target mismatch")
    for item in plan["types"]:
        fields = [identifier(f["name"]) for f in item["fields"]]
        if reserved.intersection(fields):
            raise BindingError("projected field shadows generated infrastructure")
        if len(fields) != len(set(fields)):
            raise BindingError("duplicate projected field")
        for field in item["fields"]:
            annotation = field["annotation"]
            element = annotation["item"] if annotation["kind"] == "tuple" else annotation
            if element["kind"] == "api":
                fact = facts["symbols"][element["api"]]
                if (fact["module"], fact["symbol"]) not in {("builtins", "str"), ("builtins", "int")}:
                    raise BindingError("unsupported scalar codec target")


def annotation(value, facts):
    if value["kind"] == "api":
        target = facts["symbols"][value["api"]]
        return f"{target['module']}.{target['symbol']}"
    if value["kind"] == "local":
        return identifier(value["name"])
    if value["kind"] == "tuple":
        return f"builtins.tuple[{annotation(value['item'], facts)}, ...]"
    if value["kind"] == "literal":
        return "typing.Literal[" + ", ".join(repr(v) for v in value["values"]) + "]"
    raise BindingError("unsupported structured annotation")


def render_native(plan, facts):
    qualify(plan, facts)
    chunks = ["# Generated from CUE native bindings and pinned typeshed evidence. Do not edit.\n",
              "from __future__ import annotations\n\nimport builtins\nimport dataclasses\nimport typing\n\n",
              "from runtime.native_binding import UNSET, UnsetType\n",
              "from runtime.semantic_metadata import semantic_type\n\n",
              f"PROJECTION_PLAN = {pformat(plan, sort_dicts=False, width=100)}\n",
              f"PLAN_DIGEST = {digest(canonical(plan))!r}\n",
              f"API_FACTS_DIGEST = {digest(canonical(facts))!r}\n\n"]
    options = ", ".join(f"{k}={v!r}" for k, v in sorted(plan["decorator"]["keywords"].items()))
    for item in plan["types"]:
        chunks.append(f"@semantic_type(cue_package={plan['cuePackage']!r}, cue_type={item['cueType']!r}, space={item['space']!r}, source={plan['source']!r})\n")
        chunks.append(f"@dataclasses.dataclass({options})\nclass {item['name']}:\n")
        for field in item["fields"]:
            target = annotation(field["annotation"], facts)
            if field["optional"]:
                target += " | UnsetType = UNSET"
            chunks.append(f"    {field['name']}: {target}\n")
        chunks.append("\n")
    result = "".join(chunks).rstrip() + "\n"
    ast.parse(result)
    return result
