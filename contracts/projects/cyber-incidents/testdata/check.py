"""Exercise the starter contract with a synthetic fixture and narrow mutations."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
SCHEMA = HERE.parent
FIXTURE = json.loads((HERE / "replay.json").read_text())


def update(value, path, replacement):
    for field in path[:-1]:
        value = value[field]
    value[path[-1]] = replacement


def vet(instance):
    with tempfile.TemporaryDirectory() as temp:
        test = Path(temp) / "fixture.json"
        test.write_text(json.dumps(instance))
        return subprocess.run(
            [os.environ.get("CUE", "cue"), "vet", "-c", "-d", "#IncidentBundle",
             "./" + str(SCHEMA.relative_to(SCHEMA.parents[2])), str(test)],
            cwd=SCHEMA.parents[2], capture_output=True, text=True, check=False,
        )


def main():
    good = vet(FIXTURE)
    if good.returncode:
        raise SystemExit(good.stderr)
    cases = [
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
        fixture = copy.deepcopy(FIXTURE)
        update(fixture, path, replacement)
        result = vet(fixture)
        if not result.returncode or diagnostic not in result.stderr + result.stdout:
            raise SystemExit(f"{name}: unexpected validation result\n{result.stderr}")
    print(f"Passed one accepted fixture and {len(cases)} rejection cases.")


if __name__ == "__main__":
    main()
