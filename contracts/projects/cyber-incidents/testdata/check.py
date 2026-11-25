"""Validate both synthetic stream examples and reject invalid bundle mutations."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile

SCHEMA = Path(__file__).resolve().parents[1]
ROOT = SCHEMA.parents[2]
EXAMPLES = ROOT / "projects" / "cyber-incidents"


def update(value, path, replacement):
    for field in path[:-1]:
        value = value[field]
    value[path[-1]] = replacement


def vet(instance, definition="#IncidentBundle"):
    with tempfile.TemporaryDirectory() as temp:
        test = Path(temp) / "fixture.json"
        test.write_text(json.dumps(instance))
        return subprocess.run(
            [os.environ.get("CUE", "cue"), "vet", "-c", "-d", definition,
             "./" + str(SCHEMA.relative_to(ROOT)), str(test)],
            cwd=ROOT, capture_output=True, text=True, check=False,
        )


def main():
    replay = json.loads((EXAMPLES / "global-major-cyber" / "replay.json").read_text())
    review = json.loads((EXAMPLES / "canadian-surveillance" / "review.json").read_text())
    examples = {"global-major-cyber": replay, "canadian-surveillance": review}
    for stream, example in examples.items():
        if example["incident"]["stream"] != stream:
            raise SystemExit(f"The {stream} example has the wrong stream.")
        good = vet(example)
        if good.returncode:
            raise SystemExit(f"{stream}: {good.stderr}")
    later_review = copy.deepcopy(replay)
    later_review["view"] = {"mode": "review"}
    later_review["incident"]["hypotheses"]["objective"]["assessedAt"] = "2027-01-04T12:00:00Z"
    good = vet(later_review)
    if good.returncode:
        raise SystemExit(f"later assessment in review mode: {good.stderr}")
    cases = [
        ("post-cutoff assessment", ("incident", "hypotheses", "objective", "assessedAt"),
         "2027-01-04T12:00:00Z", "_replayAssessmentCutoff"),
        ("unknown stream", ("incident", "stream"), "unknown-stream", "stream"),
        ("cutoff", ("view", "asOf"), "2026-01-02T12:00:00Z", "_replayCutoff"),
        ("missing source", ("acquisition", "captures", "dispatch", "sourceID"),
         "missing", "_capturesResolve"),
        ("missing capture", ("incident", "publicClaims", "outage-report",
                             "citations", 0, "captureID"), "missing", "_citationsResolve"),
        ("unknown availability", ("acquisition", "captures", "dispatch", "availability"),
         {"state": "unknown", "reason": "Publication date missing"}, "_citationDated"),
        ("later source revision", ("acquisition", "captures", "dispatch", "availability", "at"),
         "2026-01-04T12:00:00Z", "_claimOrder"),
        ("wrong rail", ("incident", "hypotheses", "objective", "evidence", 0, "rail"),
         "public", "_hypothesisPublicRef"),
        ("premature hypothesis", ("incident", "hypotheses", "objective", "assessedAt"),
         "2026-01-02T12:00:00Z", "_hypothesisTechnicalOrder"),
        ("unreviewed attribution", ("incident", "hypotheses", "objective", "state"),
         "confirmed", "state"),
    ]
    for name, path, replacement, diagnostic in cases:
        fixture = copy.deepcopy(replay)
        update(fixture, path, replacement)
        result = vet(fixture)
        if not result.returncode or diagnostic not in result.stderr + result.stdout:
            raise SystemExit(f"{name}: unexpected validation result\n{result.stderr}")
    print(f"Passed {len(examples) + 1} acceptance cases and {len(cases)} rejection cases.")

    directory = EXAMPLES / "global-major-cyber" / "incidents"
    entry = json.loads((directory / "wannacry" / "bundle.json").read_text())
    for path, replacement, diagnostic in [
        (("incident", "catalogDate", "day"), "2017-02-30", "_validDay"),
        (("incident", "catalogDate", "publicClaimID"), "missing", "_catalogClaimResolves"),
        (("incident", "stream"), "canadian-surveillance", "stream"),
        (("view", "mode"), "historical-replay", "mode"),
        (("acquisition", "captures", "report", "locator"), "file:report", "locator"),
    ]:
        fixture = copy.deepcopy(entry)
        update(fixture, path, replacement)
        result = vet(fixture, "#CatalogBundle")
        if not result.returncode or diagnostic not in result.stderr:
            raise SystemExit(f"catalog {path}: unexpected validation result\n{result.stderr}")
    print("Passed five directory rejection cases.")


if __name__ == "__main__":
    main()
