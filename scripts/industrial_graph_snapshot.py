#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


def canonical_bytes(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def sha256_uri(value: Any) -> str:
    return "sha256:" + hashlib.sha256(canonical_bytes(value)).hexdigest()


def seal_snapshot(payload: dict[str, Any]) -> dict[str, Any]:
    records = sorted(payload["records"], key=lambda record: (str(record.get("kind", "")), str(record.get("id", ""))))
    core = {
        "snapshotID": str(payload["snapshotID"]),
        "generatedAt": str(payload["generatedAt"]),
        "observedThrough": str(payload["observedThrough"]),
        "records": records,
    }
    return {**core, "digest": sha256_uri(core)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = seal_snapshot(json.loads(args.input.read_text(encoding="utf-8")))
    rendered = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
