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
    print(f"Validated {len(cases)} graph relationship fixtures")


if __name__ == "__main__":
    main()
