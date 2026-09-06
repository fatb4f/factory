#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any, Iterable

PACKAGE_RE = re.compile(r"(?m)^package\s+([A-Za-z_][A-Za-z0-9_]*)\s*$")
TOP_LEVEL_LABEL_RE = re.compile(r"(?m)^([#A-Za-z_][A-Za-z0-9_]*)\s*:")
FIELD_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)(\?)?\s*:")
LOCAL_REF_RE = re.compile(r"(?<![A-Za-z0-9_.])#([A-Za-z_][A-Za-z0-9_]*)")
QUALIFIED_REF_RE = re.compile(r"(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)\.#([A-Za-z_][A-Za-z0-9_]*)")
IMPORT_SINGLE_RE = re.compile(r'(?m)^import\s+(?:(?P<alias>[A-Za-z_][A-Za-z0-9_]*)\s+)?"(?P<path>[^"]+)"\s*$')
IMPORT_BLOCK_RE = re.compile(r'(?ms)^import\s*\((?P<body>.*?)^\)\s*$')
IMPORT_ITEM_RE = re.compile(r'(?m)^\s*(?:(?P<alias>[A-Za-z_][A-Za-z0-9_]*)\s+)?"(?P<path>[^"]+)"\s*$')


class CueModelError(RuntimeError):
    pass


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def sha256_uri(data: bytes) -> str:
    return "sha256:" + hashlib.sha256(data).hexdigest()


def _line_for(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def _sanitize(text: str) -> str:
    """Blank comments and string contents while preserving offsets/newlines."""
    chars = list(text)
    i = 0
    n = len(chars)
    while i < n:
        if i + 1 < n and chars[i] == "/" and chars[i + 1] == "/":
            j = i
            while j < n and chars[j] != "\n":
                chars[j] = " "
                j += 1
            i = j
            continue
        if i + 1 < n and chars[i] == "/" and chars[i + 1] == "*":
            chars[i] = chars[i + 1] = " "
            j = i + 2
            while j + 1 < n and not (chars[j] == "*" and chars[j + 1] == "/"):
                if chars[j] != "\n":
                    chars[j] = " "
                j += 1
            if j + 1 >= n:
                raise CueModelError("unterminated block comment")
            chars[j] = chars[j + 1] = " "
            i = j + 2
            continue
        if chars[i] == '"':
            triple = i + 2 < n and chars[i:i+3] == ['"', '"', '"']
            width = 3 if triple else 1
            for k in range(i, min(i + width, n)):
                chars[k] = " "
            j = i + width
            while j < n:
                if not triple and text[j] == "\\":
                    if chars[j] != "\n":
                        chars[j] = " "
                    if j + 1 < n and chars[j + 1] != "\n":
                        chars[j + 1] = " "
                    j += 2
                    continue
                if triple and text[j:j+3] == '"""':
                    for k in range(j, j + 3):
                        chars[k] = " "
                    j += 3
                    break
                if not triple and text[j] == '"':
                    chars[j] = " "
                    j += 1
                    break
                if chars[j] != "\n":
                    chars[j] = " "
                j += 1
            else:
                raise CueModelError("unterminated string")
            i = j
            continue
        i += 1
    return "".join(chars)


def _default_import_alias(path: str) -> str:
    tail = path.rsplit("/", 1)[-1]
    if ":" in tail:
        tail = tail.rsplit(":", 1)[-1]
    return re.sub(r"[^A-Za-z0-9_]", "_", tail)


def _imports(text: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for match in IMPORT_SINGLE_RE.finditer(text):
        path = match.group("path")
        alias = match.group("alias") or _default_import_alias(path)
        if alias in result and result[alias] != path:
            raise CueModelError(f"import alias {alias!r} maps to multiple paths")
        result[alias] = path
    for block in IMPORT_BLOCK_RE.finditer(text):
        for match in IMPORT_ITEM_RE.finditer(block.group("body")):
            path = match.group("path")
            alias = match.group("alias") or _default_import_alias(path)
            if alias in result and result[alias] != path:
                raise CueModelError(f"import alias {alias!r} maps to multiple paths")
            result[alias] = path
    return result


def _definition_spans(sanitized: str) -> list[tuple[str, int, int]]:
    declarations = list(TOP_LEVEL_LABEL_RE.finditer(sanitized))
    spans: list[tuple[str, int, int]] = []
    for index, match in enumerate(declarations):
        name = match.group(1)
        if not name.startswith("#"):
            continue
        start = match.end()
        end = declarations[index + 1].start() if index + 1 < len(declarations) else len(sanitized)
        spans.append((name, start, end))
    return spans


def _field_spans(expr_sanitized: str, expr_start: int) -> list[tuple[str, bool, int, int]]:
    lines = expr_sanitized.splitlines(keepends=True)
    cursor = 0
    brace_depth = 0
    candidates: list[tuple[str, bool, int]] = []
    for line in lines:
        start_depth = brace_depth
        if start_depth == 1:
            match = FIELD_RE.match(line)
            if match:
                candidates.append((match.group(1), bool(match.group(2)), cursor + match.end()))
        brace_depth += line.count("{") - line.count("}")
        if brace_depth < 0:
            raise CueModelError("unbalanced closing brace")
        cursor += len(line)
    if brace_depth != 0:
        raise CueModelError("unbalanced object braces")
    fields: list[tuple[str, bool, int, int]] = []
    for index, (name, optional, value_start) in enumerate(candidates):
        value_end = candidates[index + 1][2] if index + 1 < len(candidates) else len(expr_sanitized)
        fields.append((name, optional, expr_start + value_start, expr_start + value_end))
    return fields


def _node_id(package: str, symbol: str) -> str:
    return f"cue:{package}:{symbol}"


def _field_id(package: str, definition: str, field: str) -> str:
    return f"cue:{package}:{definition}.{field}"


def _external_node_id(import_path: str, symbol: str) -> str:
    return f"cue-import:{import_path}:{symbol}"


def _edge_id(relation: str, source: str, target: str) -> str:
    return "edge:" + hashlib.sha256(f"{relation}\0{source}\0{target}".encode()).hexdigest()


def _source(path: str, text: str, start: int, end: int, digest: str) -> dict[str, Any]:
    return {
        "path": path,
        "lineStart": _line_for(text, start),
        "lineEnd": _line_for(text, max(start, end - 1)),
        "digest": digest,
    }


def _merge_source(node: dict[str, Any], source: dict[str, Any]) -> None:
    sources = node.setdefault("sources", [])
    key = (source["path"], source["lineStart"], source["lineEnd"], source["digest"])
    if key not in {(s["path"], s["lineStart"], s["lineEnd"], s["digest"]) for s in sources}:
        sources.append(source)
        sources.sort(key=lambda s: (s["path"], s["lineStart"], s["lineEnd"]))


def _add_edge(edges: dict[str, dict[str, Any]], relation: str, source: str, target: str, basis: dict[str, Any]) -> None:
    edge_id = _edge_id(relation, source, target)
    edge = edges.get(edge_id)
    if edge is None:
        edges[edge_id] = {"id": edge_id, "relation": relation, "source": source, "target": target, "basis": [basis]}
        return
    existing = {(b["path"], b["lineStart"], b["lineEnd"], b["digest"]) for b in edge["basis"]}
    key = (basis["path"], basis["lineStart"], basis["lineEnd"], basis["digest"])
    if key not in existing:
        edge["basis"].append(basis)
        edge["basis"].sort(key=lambda b: (b["path"], b["lineStart"], b["lineEnd"]))


def _refs(fragment: str, imports: dict[str, str]) -> Iterable[tuple[str, str, int, int]]:
    occupied: list[tuple[int, int]] = []
    for match in QUALIFIED_REF_RE.finditer(fragment):
        alias, symbol = match.group(1), "#" + match.group(2)
        if alias not in imports:
            continue
        occupied.append(match.span())
        yield "external", _external_node_id(imports[alias], symbol), match.start(), match.end()
    for match in LOCAL_REF_RE.finditer(fragment):
        if any(start <= match.start() < end for start, end in occupied):
            continue
        yield "local", "#" + match.group(1), match.start(), match.end()


def compile_cue_model(config: dict[str, Any], root: Path) -> dict[str, Any]:
    repository = str(config["repository"])
    revision = str(config["revision"])
    files = sorted(str(item) for item in config.get("files", []))
    if not files:
        raise CueModelError("at least one CUE file is required")

    nodes: dict[str, dict[str, Any]] = {}
    edges: dict[str, dict[str, Any]] = {}
    file_records: list[dict[str, Any]] = []
    parsed: list[tuple[str, str, str, str, dict[str, str], list[tuple[str, int, int]]]] = []
    packages: set[str] = set()

    for relpath in files:
        path = root / relpath
        data = path.read_bytes()
        text = data.decode("utf-8")
        digest = sha256_uri(data)
        sanitized = _sanitize(text)
        package_match = PACKAGE_RE.search(sanitized)
        if package_match is None:
            raise CueModelError(f"{relpath}: missing package declaration")
        package = package_match.group(1)
        packages.add(package)
        imports = _imports(text)
        spans = _definition_spans(sanitized)
        file_records.append({"path": relpath, "package": package, "digest": digest})
        parsed.append((relpath, text, sanitized, package, imports, spans))

        package_id = _node_id(package, "package")
        package_node = nodes.setdefault(package_id, {
            "id": package_id,
            "space": "cue",
            "kind": "package",
            "name": package,
            "qualifiedName": package,
            "sources": [],
        })
        _merge_source(package_node, _source(relpath, text, package_match.start(), package_match.end(), digest))

        for alias, import_path in sorted(imports.items()):
            import_id = f"cue:{package}:import:{alias}"
            import_node = nodes.setdefault(import_id, {
                "id": import_id,
                "space": "cue",
                "kind": "import",
                "name": alias,
                "qualifiedName": import_path,
                "sources": [],
            })
            import_source = _source(relpath, text, 0, len(text), digest)
            _merge_source(import_node, import_source)
            _add_edge(edges, "imports", package_id, import_id, import_source)

    local_defs = {(package, name) for _, _, _, package, _, spans in parsed for name, _, _ in spans}

    for relpath, text, sanitized, package, imports, spans in parsed:
        digest = sha256_uri(text.encode("utf-8"))
        package_id = _node_id(package, "package")
        for definition, start, end in spans:
            def_id = _node_id(package, definition)
            def_source = _source(relpath, text, start, end, digest)
            def_node = nodes.setdefault(def_id, {
                "id": def_id,
                "space": "cue",
                "kind": "definition",
                "name": definition,
                "qualifiedName": f"{package}.{definition}",
                "sources": [],
            })
            _merge_source(def_node, def_source)
            expression = text[start:end].strip()
            if expression:
                expressions = def_node.setdefault("expressions", [])
                if expression not in expressions:
                    expressions.append(expression)
                    expressions.sort()
            _add_edge(edges, "contains", package_id, def_id, def_source)

            expr = sanitized[start:end]
            field_ranges = _field_spans(expr, start)
            field_offsets = {(field_start, field_end) for _, _, field_start, field_end in field_ranges}
            for field_name, optional, field_start, field_end in field_ranges:
                field_id = _field_id(package, definition, field_name)
                field_source = _source(relpath, text, field_start, field_end, digest)
                field_node = nodes.setdefault(field_id, {
                    "id": field_id,
                    "space": "cue",
                    "kind": "field",
                    "name": field_name,
                    "qualifiedName": f"{package}.{definition}.{field_name}",
                    "required": not optional,
                    "sources": [],
                })
                if field_node.get("required") != (not optional):
                    field_node["required"] = bool(field_node.get("required")) or (not optional)
                _merge_source(field_node, field_source)
                _add_edge(edges, "contains", def_id, field_id, field_source)

                fragment = sanitized[field_start:field_end]
                for ref_kind, target_value, ref_start, ref_end in _refs(fragment, imports):
                    if ref_kind == "local":
                        target = _node_id(package, target_value)
                        if (package, target_value) not in local_defs:
                            nodes.setdefault(target, {
                                "id": target,
                                "space": "cue",
                                "kind": "external-definition",
                                "name": target_value,
                                "qualifiedName": f"{package}.{target_value}",
                                "sources": [],
                            })
                    else:
                        target = target_value
                        nodes.setdefault(target, {
                            "id": target,
                            "space": "cue",
                            "kind": "external-definition",
                            "name": target.rsplit(":", 1)[-1],
                            "qualifiedName": target.removeprefix("cue-import:"),
                            "sources": [],
                        })
                    basis = _source(relpath, text, field_start + ref_start, field_start + ref_end, digest)
                    _add_edge(edges, "references", field_id, target, basis)

            for ref_kind, target_value, ref_start, ref_end in _refs(expr, imports):
                absolute = start + ref_start
                if any(field_start <= absolute < field_end for field_start, field_end in field_offsets):
                    continue
                if ref_kind == "local":
                    target = _node_id(package, target_value)
                    if (package, target_value) not in local_defs:
                        nodes.setdefault(target, {
                            "id": target,
                            "space": "cue",
                            "kind": "external-definition",
                            "name": target_value,
                            "qualifiedName": f"{package}.{target_value}",
                            "sources": [],
                        })
                else:
                    target = target_value
                    nodes.setdefault(target, {
                        "id": target,
                        "space": "cue",
                        "kind": "external-definition",
                        "name": target.rsplit(":", 1)[-1],
                        "qualifiedName": target.removeprefix("cue-import:"),
                        "sources": [],
                    })
                basis = _source(relpath, text, start + ref_start, start + ref_end, digest)
                vicinity = expr[max(0, ref_start - 3): min(len(expr), ref_end + 3)]
                relation = "conjoins" if "&" in vicinity else "references"
                _add_edge(edges, relation, def_id, target, basis)

    payload = {
        "apiVersion": "factory.introspection/v1",
        "kind": "LogicalModelProjection",
        "repository": repository,
        "revision": revision,
        "packages": sorted(packages),
        "files": sorted(file_records, key=lambda item: item["path"]),
        "nodes": sorted(nodes.values(), key=lambda item: item["id"]),
        "edges": sorted(edges.values(), key=lambda item: item["id"]),
    }
    result = dict(payload)
    result["digest"] = sha256_uri(canonical_json_bytes(payload))
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("config", type=Path)
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    config = json.loads(args.config.read_text(encoding="utf-8"))
    result = compile_cue_model(config, args.root)
    encoded = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(encoded, encoding="utf-8")
    else:
        print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
