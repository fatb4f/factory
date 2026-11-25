"""Validate synthetic graph relationship fixtures with CUE."""
from copy import deepcopy
import json
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent


def fixture():
    return {
        "apiVersion": "shadow-graph.relationship/0.1.0",
        "id": "edge", "revision": "v1",
        "kind": "supports",
        "valid": {"start": 10, "end": 20},
        "knowledge": {"start": 30},
        "from": {"rail": "technical", "id": "obs", "revision": "1", "concept": "observation"},
        "to": {"rail": "strategic", "id": "claim", "revision": "2", "concept": "claim"},
        "provenance": [{"rail": "technical", "capture": "sha256:" + "a" * 64,
                        "revision": "1", "locator": "/records/0"}],
        "boundaries": {"link_admits_evidence": False,
                       "reconciliation_merges_identity": False,
                       "link_establishes_attribution": False},
    }


def main():
    valid = fixture()
    reconciliation = deepcopy(valid)
    reconciliation.update(kind="reconciles", reconciliation={"status": "disputed", "rationale": "Distinct sources"})
    cases = [
        ("support", valid, True),
        ("contradiction", {**valid, "kind": "contradicts"}, True),
        ("candidate alignment", reconciliation, True),
        ("same rail", {**reconciliation, "to": {**valid["to"], "rail": "technical"}}, False),
        ("invalid endpoints", {**valid, "from": {**valid["from"], "concept": "actor"}}, False),
        ("zero-length valid time", {**valid, "valid": {"start": 10, "end": 10}}, False),
        ("reversed knowledge time", {**valid, "knowledge": {"start": 30, "end": 29}}, False),
        ("missing provenance", {**valid, "provenance": []}, False),
        ("attribution inference", {**valid, "boundaries": {**valid["boundaries"],
                                                            "link_establishes_attribution": True}}, False),
        ("unexpected field", {**valid, "unknown": True}, False),
    ]
    subprocess.run(["cue", "vet", "-c=false", str(HERE / "graph.cue")], check=True)
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "relationship.json"
        for name, payload, expected in cases:
            path.write_text(json.dumps(payload), encoding="utf-8")
            result = subprocess.run(
                ["cue", "vet", "-c", str(path), str(HERE / "graph.cue"), "-d", "#RelationshipRevision"],
                capture_output=True, text=True,
            )
            if (result.returncode == 0) != expected:
                raise SystemExit(f"{name}: unexpected result\n{result.stderr}")
        before = {**valid, "knowledge": {"start": 30, "end": 40}}
        corrected = {**valid, "revision": "v2", "knowledge": {"start": 40}}
        replay = [
            (before, 10, 39, True),
            (before, 10, 40, False),
            (corrected, 10, 39, False),
            (corrected, 10, 40, True),
            (corrected, 20, 40, False),
            (corrected, 9, 40, False),
            (corrected, 10, 40, False),  # Deliberately assert the wrong visibility.
        ]
        for index, (relationship, valid_at, known_at, visible) in enumerate(replay):
            path.write_text(json.dumps({
                "relationship": relationship, "validAt": valid_at,
                "knownAt": known_at, "visible": visible,
            }), encoding="utf-8")
            result = subprocess.run(
                ["cue", "vet", "-c", str(path), str(HERE / "graph.cue"), "-d", "#ReplayProbe"],
                capture_output=True, text=True,
            )
            expected = index < len(replay) - 1
            if (result.returncode == 0) != expected:
                raise SystemExit(f"replay fixture {index}: unexpected result\n{result.stderr}")
    print(f"Validated {len(cases)} relationship and {len(replay)} replay fixtures")


if __name__ == "__main__":
    main()
