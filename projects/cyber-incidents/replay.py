"""Project explicitly selected, cutoff-eligible assertions for model input."""

import argparse
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SCHEMA = "./contracts/projects/cyber-incidents"


class ProjectionError(ValueError):
    """The requested projection cannot be validated safely."""


def _vet(bundle):
    with tempfile.TemporaryDirectory() as temp:
        path = Path(temp) / "bundle.json"
        path.write_text(json.dumps(bundle), encoding="utf-8")
        try:
            result = subprocess.run(
                [os.environ.get("CUE", "cue"), "vet", "-c", "-d", "#IncidentBundle", SCHEMA, str(path)],
                cwd=ROOT, capture_output=True, text=True, check=False,
            )
        except OSError as exc:
            raise ProjectionError(f"cannot execute CUE: {exc}") from exc
        if result.returncode:
            raise ProjectionError(f"CUE validation failed: {result.stderr.strip()}")


def project(bundle, cutoff, public_ids=(), technical_ids=()):
    """Return selected assertions and citations, after full and replay CUE checks.

    Selection is by ID within its rail. The returned object is not a source
    passage and does not attest that a source's content supports an assertion.
    """
    if not isinstance(bundle, dict):
        raise ProjectionError("bundle must be a JSON object")
    view = bundle.get("view")
    if not isinstance(view, dict) or (view != {"mode": "review"} and not (
        set(view) == {"mode", "asOf"} and view.get("mode") == "historical-replay"
    )):
        raise ProjectionError("invalid bundle view")
    review = copy.deepcopy(bundle)
    review["view"] = {"mode": "review"}
    _vet(review)

    selections = (("publicClaims", "public", list(public_ids)),
                  ("technicalObservations", "technical", list(technical_ids)))
    for field, _, ids in selections:
        if any(not isinstance(item, str) for item in ids):
            raise ProjectionError(f"{field}: IDs must be strings")
        if len(ids) != len(set(ids)):
            raise ProjectionError(f"{field}: duplicate ID")
        unknown = set(ids) - review["incident"][field].keys()
        if unknown:
            raise ProjectionError(f"{field}: unknown IDs: {', '.join(sorted(unknown))}")

    replay = copy.deepcopy(review)
    replay["view"] = {"mode": "historical-replay", "asOf": cutoff}
    incident = replay["incident"]
    incident.pop("catalogDate", None)  # Its supporting claim may be outside the selection.
    for field, _, ids in selections:
        incident[field] = {key: incident[field][key] for key in sorted(ids)}
    incident["hypotheses"] = {}
    incident["openQuestions"] = {}
    capture_ids = {ref["captureID"] for field, _, _ in selections
                   for assertion in incident[field].values() for ref in assertion["citations"]}
    acquisition = replay["acquisition"]
    acquisition["captures"] = {key: acquisition["captures"][key] for key in sorted(capture_ids)}
    source_ids = {capture["sourceID"] for capture in acquisition["captures"].values()}
    acquisition["sources"] = {key: acquisition["sources"][key] for key in sorted(source_ids)}
    acquisition["gaps"] = []
    _vet(replay)

    assertions = []
    for field, rail, _ in selections:
        for key, assertion in incident[field].items():
            projected = {"id": key, "rail": rail, "summary": assertion["summary"],
                         "knownAt": assertion["knownAt"]}
            if "eventAt" in assertion:
                projected["eventAt"] = assertion["eventAt"]
            projected["citations"] = []
            for ref in assertion["citations"]:
                capture = acquisition["captures"][ref["captureID"]]
                projected["citations"].append({"captureID": ref["captureID"],
                    "selector": ref["selector"], "revision": capture["revision"],
                    "contentSHA256": capture["contentSHA256"]})
            assertions.append(projected)
    return {"schema": "factory.cyber-incidents.replay-projection/v1",
            "asOf": cutoff, "assertions": assertions}


def _object_without_duplicates(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ProjectionError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=Path)
    parser.add_argument("--as-of", required=True, help="UTC cutoff, e.g. 2026-01-04T12:00:00Z")
    parser.add_argument("--public", action="append", default=[], metavar="ID")
    parser.add_argument("--technical", action="append", default=[], metavar="ID")
    args = parser.parse_args(argv)
    try:
        bundle = json.loads(args.bundle.read_text(encoding="utf-8"), object_pairs_hook=_object_without_duplicates)
        result = project(bundle, args.as_of, args.public, args.technical)
        print(json.dumps(result, sort_keys=True, ensure_ascii=False, indent=2))
    except (OSError, ValueError) as exc:
        print(f"replay projection: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
