"""Exercise the CUE receipt contract using invented execution context."""

from copy import deepcopy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
DIGEST = "sha256:" + "a" * 64


class TransformInvocationTests(unittest.TestCase):
    def setUp(self):
        self.receipt = {
            "apiVersion": "factory.transforms/invocation-v1",
            "invocationID": "synthetic-invocation",
            "transformID": "legal.navigate",
            "transformVersion": "0.1.0",
            "extensionDigest": DIGEST,
            "contractVersion": "0.1.0",
            "contractDigest": DIGEST,
            "snapshotRef": {
                "id": "synthetic-snapshot",
                "digest": DIGEST,
                "sourceRevisionRefs": ["synthetic-schedule/revision-1"],
                "schemaVersion": "1",
            },
            "knowledgeCutoff": "2026-01-01T00:00:00Z",
            "authorizationReceipt": {
                "policyVersion": "1",
                "scopeDigest": DIGEST,
                "decision": "allowed",
            },
            "inputRefs": ["synthetic-unit/1"],
            "executionBackend": "in-process",
            "durationNS": 1,
            "outcome": "success",
            "outputDigest": DIGEST,
            "provenanceRefs": ["synthetic-source/span-1"],
        }

    def check(self, receipt, accepted):
        with tempfile.TemporaryDirectory() as tmp:
            fixture = Path(tmp) / "invocation.json"
            fixture.write_text(json.dumps(receipt), encoding="utf-8")
            result = subprocess.run(
                ["cue", "vet", "-c", "-d", "#TransformInvocation",
                 "./contracts/state:state", str(fixture)],
                cwd=ROOT, capture_output=True, text=True, check=False,
            )
        self.assertEqual(result.returncode == 0, accepted, result.stderr)

    def test_success_and_empty_require_provenance(self):
        for outcome in ("success", "empty"):
            self.receipt["outcome"] = outcome
            self.check(self.receipt, True)
            for field in ("inputRefs", "outputDigest", "provenanceRefs"):
                with self.subTest(outcome=outcome, field=field):
                    incomplete = deepcopy(self.receipt)
                    del incomplete[field]
                    self.check(incomplete, False)

    def test_denied_and_failed_cannot_publish_outputs(self):
        for outcome, decision in (("denied", "denied"), ("failed", "allowed")):
            with self.subTest(outcome=outcome):
                receipt = deepcopy(self.receipt)
                receipt["outcome"] = outcome
                receipt["authorizationReceipt"]["decision"] = decision
                self.check(receipt, False)
                del receipt["outputDigest"], receipt["provenanceRefs"]
                self.check(receipt, True)

    def test_success_requires_authorization_and_pinned_context(self):
        for field, value in (
            ("authorizationReceipt", {**self.receipt["authorizationReceipt"], "decision": "denied"}),
            ("snapshotRef", {**self.receipt["snapshotRef"], "sourceRevisionRefs": []}),
            ("extensionDigest", "unpinned"),
            ("knowledgeCutoff", "not-a-time"),
        ):
            with self.subTest(field=field):
                self.check({**self.receipt, field: value}, False)


if __name__ == "__main__":
    unittest.main()
