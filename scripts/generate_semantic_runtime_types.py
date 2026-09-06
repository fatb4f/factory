#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

HEADER = """# Generated from Factory CUE projection. Do not edit by hand.\nfrom __future__ import annotations\n\nfrom dataclasses import dataclass\nfrom typing import Any, Mapping\n\nfrom runtime.semantic_metadata import semantic_relation, semantic_type\n\n"""


def render(projection: dict[str, Any]) -> str:
    chunks = [HEADER]
    source = str(projection["source"])
    for item in projection["types"]:
        chunks.append(
            f"@semantic_type(cue_package={item['cuePackage']!r}, cue_type={item['cueType']!r}, space={item['space']!r}, source={source!r})\n"
        )
        for relation in reversed(item.get("relations", [])):
            chunks.append(
                "@semantic_relation("
                f"name={relation['name']!r}, target_cue_type={relation['targetCueType']!r}, "
                f"via_field={relation['viaField']!r}, cardinality={relation.get('cardinality', 'one')!r})\n"
            )
        chunks.append("@dataclass(frozen=True, slots=True)\n")
        chunks.append(f"class {item['name']}:\n")
        for field in item["fields"]:
            default = " = None" if field.get("optional") else ""
            chunks.append(f"    {field['name']}: {field['pythonType']}{default}\n")
        chunks.append("\n")
    return "".join(chunks)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("projection", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    projection = json.loads(args.projection.read_text(encoding="utf-8"))
    content = render(projection)
    if args.output:
        args.output.write_text(content, encoding="utf-8")
    else:
        print(content, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
