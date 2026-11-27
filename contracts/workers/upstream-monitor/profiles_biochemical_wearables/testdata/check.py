"""Exercise the biochemical wearable evidence contract using fictional sources and devices."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile


HERE = Path(__file__).resolve().parent
PROFILE = HERE.parent
ROOT = PROFILE.parents[3]


def check(name, run, expected_error=None):
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "evidence.json"
        path.write_text(json.dumps(run))
        result = subprocess.run(
            ["cue", "vet", "-c", "-d", "#RunEvidence", f"./{PROFILE.relative_to(ROOT)}", str(path)],
            cwd=ROOT, capture_output=True, text=True,
        )
    if expected_error is None and result.returncode:
        raise SystemExit(f"{name}: unexpected rejection\n{result.stderr}")
    if expected_error and (result.returncode == 0 or expected_error not in result.stderr):
        raise SystemExit(f"{name}: expected rejection containing {expected_error!r}\n{result.stderr}")


def main():
    run = json.loads((HERE / "synthetic-run.json").read_text())
    check("three streams", run)
    check("known coverage gap without items", {**run, "items": {}, "records": {}})

    retail = ("items", "retail")
    measurement = (*retail, "device", "measurements", 0)
    record = ("records", "second-study")
    cases = [
        ("wrong source/channel combination", (*record, "channel"), "shop", "_sourceExists"),
        ("impossible calendar date", (*record, "sourceDate"), "2026-02-30", "_validDate"),
        ("unknown device study", ("items", "pilot", "device", "ref"), "missing", "_exists"),
        ("unknown offer record", (*retail, "offers", "US", "ref"), "missing", "_seller"),
        ("unknown measurement record", (*measurement, "ref"), "missing", "_exists"),
        ("study used for sale", (*retail, "offers", "US", "ref"), "first-study", "_seller"),
        ("all markets unknown", (*retail, "offers", "US"), {"region": "US", "status": "unknown"}, "_hasMarketEvidence"),
        ("US listing recycled as Canadian availability", (*retail, "offers", "CA"),
         {"region": "CA", "status": "orderable", "ref": "offer"}, "_regionSupported"),
        ("offer for a different hardware generation", ("records", "offer", "offerScope", "models"),
         ["Synthetic S2"], "_modelSupported"),
        ("solver cannot invent a sale scope", ("records", "offer", "offerScope"), None, "_offerScopePresent"),
        ("Canadian assessment omitted", (*retail, "offers", "CA"), None, "offers.CA"),
        ("study cited for fulfillment", (*retail, "offers", "US", "shipping", "ref"), "first-study", "_fulfillment"),
        ("wrong region", (*retail, "offers", "US", "region"), "CA", "offers.US.region"),
        ("unsupported CSV claim", (*retail, "telemetry", "csvExport", "ref"), "missing", "_access"),
        ("reversed cadence range", (*retail, "telemetry", "exportInterval", "channels", "sodium", "maxSeconds"),
         15, "maxSeconds"),
        ("cadence without channel", (*retail, "telemetry", "exportInterval", "channels"), {}, "MinFields"),
        ("omitted data-access evidence", (*retail, "telemetry", "api"),
         {"status": "documented", "detail": "Public API asserted."}, "ref"),
        ("temperature-only device", (*retail, "device", "measurements"),
         [{"quantity": "skin-temperature", "basis": "measured", "target": "skin",
           "unit": "Cel", "ref": "manual"}], "_hasSensingOutput"),
        ("direct whole-body measurement", (*measurement, "target"), "whole-body", "basis"),
        ("direct fatigue measurement", (*measurement, "quantity"), "fatigue", "basis"),
        ("single-input fatigue score", measurement,
         {"quantity": "fatigue", "basis": "inferred", "target": "whole-body", "unit": "score",
          "inputs": ["temperature", "temperature"], "ref": "manual"}, "UniqueItems"),
        ("sweat assay used for a blood-equivalent value", measurement,
         {"quantity": "glucose", "target": "blood-equivalent", "basis": "inferred", "unit": "mmol/L",
          "ref": "manual", "validation": {"ref": "first-study", "matrix": "sweat", "comparator": "sweat assay",
              "population": "eight adults", "conditions": "exercise", "result": "local agreement only"}}, "matrix"),
        ("vendor literature used as clinical validation", ("items", "pilot", "device", "comparisons", 0, "ref"),
         "manual", "_study"),
        ("vendor pilot without study", ("items", "pilot", "device", "ref"), "manual", "_demonstration"),
        ("syndicated record", (*record, "origin"), "example-lab-one", "_independent"),
        ("same original record", (*record, "record"), "A", "_independent"),
        ("reversed trend", (*record, "sourceDate"), "2026-07-01", "_chronological"),
        ("undated trend", (*record, "sourceDate"), None, "_sourceDatePresent"),
        ("missing trend record", ("items", "replication", "trend", "earlier"), "missing", "_exists"),
        ("unknown gap channel", ("coverageGaps", 0, "channel"), "missing", "_gapExists"),
    ]
    for name, path, value, error in cases:
        case = copy.deepcopy(run)
        parent = case
        for segment in path[:-1]:
            parent = parent[segment]
        if value is None:
            del parent[path[-1]]
        else:
            parent[path[-1]] = value
        check(name, case, error)
    check("empty run without gap", {**run, "items": {}, "coverageGaps": []}, "MinFields")
    print(f"Biochemical wearables: 2 accepted runs, {len(cases) + 1} expected rejections.")


if __name__ == "__main__":
    main()
