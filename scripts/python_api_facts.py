#!/usr/bin/env python3
"""Extract pinned typeshed declarations without importing or executing stubs.

This bounded extractor resolves version guards for selected top-level symbols.
Unknown relevant guards fail closed; annotations are retained as declarations,
not evaluated or claimed to be runtime behavior.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


class BindingError(ValueError):
    pass


def digest(data: bytes) -> str:
    return "sha256:" + hashlib.sha256(data).hexdigest()


def canonical(value) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()


def encoded(value) -> bytes:
    return (json.dumps(value, sort_keys=True, ensure_ascii=False, indent=2) + "\n").encode()


def export(expression):
    return json.loads(subprocess.check_output(
        ["cue", "export", "./contracts/state:state", "-e", expression, "--out", "json"], cwd=ROOT))


def vet(value, definition):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "value.json"
        path.write_bytes(encoded(value))
        result = subprocess.run(["cue", "vet", "-c", str(path),
                                 *map(str, sorted((ROOT / "contracts/state").glob("*.cue"))),
                                 "-d", definition], cwd=ROOT, capture_output=True, text=True)
        if result.returncode:
            raise BindingError(result.stderr)


def repository_file(path):
    value = (ROOT / path).resolve()
    if not value.is_relative_to(ROOT):
        raise BindingError("API source path escapes repository")
    return value


def _guard_value(node, version):
    if isinstance(node, ast.Attribute) and ast.unparse(node) == "sys.version_info":
        # The real version_info has more than two elements: for example it is
        # greater than (3, 12), and never equal to that two-element tuple.
        return (*version, 0)
    if isinstance(node, ast.Tuple) and len(node.elts) == 2 and all(isinstance(x, ast.Constant) and type(x.value) is int for x in node.elts):
        return tuple(x.value for x in node.elts)
    raise BindingError(f"unsupported relevant guard operand: {ast.unparse(node)}")


def guard(node, version):
    if isinstance(node, ast.Compare) and len(node.ops) == 1:
        a, b = _guard_value(node.left, version), _guard_value(node.comparators[0], version)
        operations = {ast.GtE: lambda: a >= b, ast.Gt: lambda: a > b, ast.Lt: lambda: a < b,
                      ast.LtE: lambda: a <= b, ast.Eq: lambda: a == b, ast.NotEq: lambda: a != b}
        if type(node.ops[0]) in operations:
            return operations[type(node.ops[0])]()
    raise BindingError(f"unsupported relevant version guard: {ast.unparse(node)}")


def _named(node, name):
    return (isinstance(node, (ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)) and node.name == name
            or isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name) and node.target.id == name)


def _contains(body, name):
    return any(_named(n, name) or isinstance(n, ast.If) and (_contains(n.body, name) or _contains(n.orelse, name)) for n in body)


def declarations(body, name, version, guards=()):
    for node in body:
        if _named(node, name):
            yield node, guards
        elif isinstance(node, ast.If) and (_contains(node.body, name) or _contains(node.orelse, name)):
            selected = guard(node.test, version)
            description = ast.unparse(node.test)
            yield from declarations(node.body if selected else node.orelse, name, version,
                                    (*guards, description if selected else f"not ({description})"))


def parameters(node):
    if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
        return []
    args = node.args
    positional = [*args.posonlyargs, *args.args]
    required = len(positional) - len(args.defaults)
    result = []
    for i, arg in enumerate(positional):
        result.append({"name": arg.arg, "kind": "positional-only" if i < len(args.posonlyargs) else "positional-or-keyword",
                       "annotation": ast.unparse(arg.annotation) if arg.annotation else "", "required": i < required})
    for arg, default in zip(args.kwonlyargs, args.kw_defaults):
        result.append({"name": arg.arg, "kind": "keyword-only",
                       "annotation": ast.unparse(arg.annotation) if arg.annotation else "", "required": default is None})
    for arg, kind in [(args.vararg, "var-positional"), (args.kwarg, "var-keyword")]:
        if arg:
            result.append({"name": arg.arg, "kind": kind,
                           "annotation": ast.unparse(arg.annotation) if arg.annotation else "", "required": False})
    return result


def extract(source):
    vet(source, "#PythonAPISource")
    texts = {}
    for module, item in source["files"].items():
        data = repository_file(item["path"]).read_bytes()
        if digest(data) != item["digest"]:
            raise BindingError(f"API source digest mismatch: {module}")
        texts[module] = data.decode("utf-8")
    if digest(repository_file(source["license"]["path"]).read_bytes()) != source["license"]["digest"]:
        raise BindingError("typeshed license digest mismatch")
    version = (source["targetPython"]["major"], source["targetPython"]["minor"])
    symbols = {}
    for identity, request in source["requests"].items():
        module, name = request["module"], request["symbol"]
        if module not in texts:
            raise BindingError(f"missing source module: {module}")
        text = texts[module]
        selected = list(declarations(ast.parse(text).body, name, version))
        if not selected:
            raise BindingError(f"missing API declaration: {module}.{name}")
        kinds = {"class" if isinstance(n, ast.ClassDef) else "function" if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)) else "annotated-value" for n, _ in selected}
        if len(kinds) != 1:
            raise BindingError("inconsistent declaration kinds")
        rows = []
        lines = text.splitlines(keepends=True)
        for node, guards in selected:
            first = min([node.lineno, *[d.lineno for d in getattr(node, "decorator_list", [])]])
            segment = "".join(lines[first - 1:node.end_lineno])
            rows.append({"lineStart": first, "lineEnd": node.end_lineno, "textDigest": digest(segment.encode()),
                         "guards": list(guards), "parameters": parameters(node),
                         "returns": ast.unparse(node.returns) if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.returns else ""})
        symbols[identity] = {"module": module, "symbol": name, "kind": kinds.pop(),
                             "sourceDigest": source["files"][module]["digest"], "declarations": rows}
    result = {"apiVersion": "factory.python-api-facts/v1", "producer": "typeshed-ast/v1",
              "authority": "external-api-declarations-only", "source": source, "symbols": symbols,
              "behavior": "not-qualified"}
    vet(result, "#PythonAPIFacts")
    return result


def verify(facts, source):
    if facts != extract(source):
        raise BindingError("API facts differ from pinned declaration extraction")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", type=Path)
    args = parser.parse_args()
    result = extract(export("pythonAPISource"))
    if args.check:
        if json.loads(args.check.read_text()) != result:
            raise BindingError("API facts drift")
    else:
        print(encoded(result).decode(), end="")


if __name__ == "__main__":
    main()
