from dataclasses import replace
import io
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from ivac_review_desk import ACTION_PATH, MAX_BODY, Pilot, application
from ivac_review_transform import PACKAGE, TRANSFORM
from runtime.transform_discovery import installed_entry_digest


class DeskBoundaryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = TemporaryDirectory()
        cls.addClassCleanup(cls.temp.cleanup)
        version, identity, _, _ = installed_entry_digest(PACKAGE, TRANSFORM)
        cls.pilot = Pilot(Path(cls.temp.name) / "history.sqlite", version, identity)
        cls.server = staticmethod(application(cls.pilot, "test-only"))
        cls.caller = "owner:" + "a" * 64

    def request(self, payload, **options):
        # WSGI request produced by the trusted Worker. No user grants in the body.
        data = json.dumps(payload).encode()
        env = dict(PATH_INFO=ACTION_PATH, REQUEST_METHOD="POST", HTTP_AUTHORIZATION="Bearer test-only",
                   HTTP_X_DESK_PRINCIPAL=self.caller, CONTENT_TYPE="application/json",
                   CONTENT_LENGTH=str(len(data)), **{"wsgi.input": io.BytesIO(data)})
        env.update(options)
        statuses = []
        result = self.server(env, lambda status, headers: statuses.append(status))
        return int(statuses[0].split()[0]), json.loads(b"".join(result))

    def test_authenticated_source_navigation_uses_only_receipt_provenance(self):
        status, data = self.request({"action": "run", "unitNumber": "4.1"})
        self.assertEqual(status, 200)
        self.assertEqual([s["id"] for s in data["sources"]], data["receipt"]["provenanceRefs"])
        evidence, = (s for s in data["sources"] if s["kind"] == "evidence")
        self.assertEqual(evidence["exactText"], "Invented clinical report: class X, 2.5 percent.\n")
        self.assertEqual(data["links"][0]["provenance"]["evidence"][0]["id"], evidence["id"][9:])

        # Removing evidence access yields a bounded empty result and hides the historical receipt.
        scope = self.pilot.scope
        self.addCleanup(setattr, self.pilot, "scope", scope)
        self.pilot.scope = replace(scope, evidence=frozenset())
        status, restricted = self.request({"action": "run", "unitNumber": "4.1"})
        self.assertEqual((status, restricted["receipt"]["outcome"], restricted["links"]), (200, "empty", []))
        self.assertTrue(all(s["kind"] == "schedule" for s in restricted["sources"]))
        status, error = self.request({"action": "replay", "invocationID": data["receipt"]["invocationID"]})
        self.assertEqual(status, 403)
        self.assertNotIn("receipt", error)

    def test_rejected_requests(self):
        checks = [
            ({"action":"context"}, {"HTTP_AUTHORIZATION":""}, 403),
            ({"action":"history"}, {"HTTP_X_DESK_PRINCIPAL":""}, 403),
            ({"action":"context"}, {"CONTENT_TYPE":"text/plain"}, 415),
            ({"action":"context"}, {"REQUEST_METHOD":"GET"}, 405),
            ({"action":"context"}, {"CONTENT_LENGTH":str(MAX_BODY + 1)}, 413),
            ({"action":"run", "unitNumber":"4.1", "scope":{}}, {}, 400),
            ({"action":"run", "unitNumber":"unknown"}, {}, 400),
        ]
        for action, overrides, expected in checks:
            with self.subTest(action=action["action"], overrides=overrides):
                status, response = self.request(action, **overrides)
                self.assertEqual(status, expected)
                self.assertNotIn("links", response)

    def test_mismatched_operator_pin_rejects_execution(self):
        pin = self.pilot.approved_digest
        self.addCleanup(setattr, self.pilot, "approved_digest", pin)
        self.pilot.approved_digest = "sha256:" + "0" * 64
        self.assertEqual(self.request({"action": "run", "unitNumber": "4.1"})[0], 409)


if __name__ == "__main__":
    unittest.main(verbosity=2)
