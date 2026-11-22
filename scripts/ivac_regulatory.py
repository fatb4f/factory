#!/usr/bin/env python3
"""Pinned UTF-8 extraction/provenance adapter. CUE owns all domain validation."""
import argparse
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def digest(data):
    return "sha256:" + hashlib.sha256(data).hexdigest()


def exact_json(value):
    """Preserve exact Decimal numeric tokens across the CUE boundary."""
    if isinstance(value, Decimal):
        if not value.is_finite():
            raise ValueError("nonfinite decimal")
        return str(value)
    if isinstance(value, dict):
        return "{" + ",".join(json.dumps(k) + ":" + exact_json(v) for k, v in sorted(value.items())) + "}"
    if isinstance(value, list):
        return "[" + ",".join(map(exact_json, value)) + "]"
    return json.dumps(value, ensure_ascii=False, allow_nan=False)


def validate(value, definition):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "input.json"
        path.write_text(exact_json(value), encoding="utf-8")
        subprocess.run(["cue", "vet", "-c", str(path),
                        *map(str, (ROOT / "contracts/personal/ivac").glob("*.cue")),
                        "-d", definition], cwd=ROOT, check=True)


def read_snapshot(source, snapshot, origin):
    data = Path(snapshot).read_bytes()
    if digest(data) != source["snapshotDigest"]:
        raise ValueError("snapshot digest mismatch")
    if digest(Path(origin).read_bytes()) != source["origin"]["digest"]:
        raise ValueError("origin digest mismatch")
    # No newline translation, Unicode normalization, or whitespace rewriting.
    return data.decode("utf-8")


def verify_span(citation, text, version):
    if citation["sourceVersion"] != version:
        raise ValueError("citation source version mismatch")
    start, end = citation["start"], citation["end"]
    if not 0 <= start < end <= len(text):
        raise ValueError("citation offsets outside snapshot")
    if text[start:end] != citation["exactText"]:
        raise ValueError("citation text mismatch")


def citations(value):
    if isinstance(value, dict):
        if {"sourceVersion", "locator", "start", "end", "exactText"} <= value.keys():
            yield value
        else:
            for child in value.values():
                yield from citations(child)
    elif isinstance(value, list):
        for child in value:
            yield from citations(child)


def extract(source, plan, snapshot, origin):
    validate(source, "#RegulatorySourceVersion")
    text = read_snapshot(source, snapshot, origin)
    spans = []
    # The reviewed plan selects exact offsets, never guesses statutory semantics.
    for selection in plan:
        span = dict(selection)
        span["sourceVersion"] = source["id"]
        verify_span(span, text, source["id"])
        spans.append(span)
    result = {"format": "ivac.regulatory-extraction/v1", "status": "candidate",
              "sourceDigest": source["snapshotDigest"], "adapter": "utf8-spans/v1",
              "spans": spans}
    validate(result, "#RegulatoryExtraction")
    return result


def verify(compendium, snapshot, origin):
    validate(compendium, "#RegulatoryCompendium")
    source = compendium["source"]
    text = read_snapshot(source, snapshot, origin)
    for citation in citations(compendium["units"]):
        verify_span(citation, text, source["id"])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["extract", "verify"])
    parser.add_argument("document", type=Path, help="source version or compendium JSON")
    parser.add_argument("snapshot", type=Path)
    parser.add_argument("origin", type=Path)
    parser.add_argument("--plan", type=Path, help="exact citation spans for extraction")
    args = parser.parse_args()
    value = json.loads(args.document.read_text(encoding="utf-8"), parse_float=Decimal)
    if args.mode == "extract":
        if args.plan is None:
            parser.error("extract requires --plan")
        result = extract(value, json.loads(args.plan.read_text(encoding="utf-8")),
                         args.snapshot, args.origin)
        print(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2))
    else:
        verify(value, args.snapshot, args.origin)


if __name__ == "__main__":
    main()
