"""Owner-bound Review Desk action for the invented M1 case. Run behind the Desk Worker."""

import argparse
from contextlib import closing, contextmanager
import hmac
import inspect
import json
import logging
import os
from pathlib import Path
import re
from wsgiref.simple_server import make_server

from ivac_legal_units import Schedule, Scope, Snapshot, workbench
from ivac_review_transform import (
    CONTRACT_VERSION, ROOT, TRANSFORM, ReviewDeskTransforms, validate_links,
)
from runtime.transform_execution import TransformSpec, digest, semantic_json
from runtime.typed_transform import TransformRejected, TransformResult


ACTION_PATH = "/api/review-desk/action"
UNIT = "4.1"
HISTORICAL_VERSION = "0.0.1-synthetic"
MAX_BODY = 16 * 1024
FIELDS = {
    "context": set(), "run": {"unitNumber"}, "rehearse": set(), "history": set(),
    "replay": {"invocationID"}, "report": {"invocationID", "note"}, "verify": {"feedbackID"},
}


def omitted_links(view, *, context):
    """Historical synthetic defect retained solely for the M1 feedback rehearsal."""
    return TransformResult([], (), context.input_digests)


class Pilot:
    """Bind the verified public schedule and an invented case at startup."""

    def __init__(self, history_path, version, approved_digest):
        self.history_path = history_path
        self.version = version
        self.approved_digest = approved_digest
        self.schedule = Schedule.load()
        self.unit = self.schedule.unit(UNIT)
        fixture = ROOT / "personal/ivac/workbench"
        pack = json.loads((fixture / "synthetic-workbench.json").read_text())
        text = fixture / "synthetic.txt"
        corpus = ROOT / "personal/ivac/regulatory/fixtures/synthetic.txt"
        workbench.verify(
            pack, evidence_paths={key: text for key in pack["evidence"]},
            anchor_text_paths={key: text for key in pack["anchors"]},
            corpus_paths={"synthetic-2021": (corpus, corpus)},
        )
        anchor = pack["anchors"]["clinical"]
        evidence_id = "clinical-" + digest(semantic_json(anchor)).split(":")[1]
        self.sources = {}
        for piece in self.unit.source_pieces:
            key = self.schedule.version + ":" + piece["id"]
            citation = piece["citation"]
            self._add_source(key, "schedule", citation["locator"], citation)
        self._add_source("evidence:" + evidence_id, "evidence", "Invented clinical report, page 1", anchor)
        snapshot = pack["snapshots"]["initial"]
        self.scope = Scope(
            snapshot["caseID"], snapshot["id"], frozenset({"review-link"}),
            frozenset({"review-observation"}), frozenset({evidence_id}), frozenset({"subject"}),
        )
        self.snapshot = Snapshot({
            "sourceVersion": self.schedule.version, "snapshot": snapshot,
            "observations": {"review-observation": {
                "id": "review-observation", "kind": "clinical-observation", "observationKind": "context",
                "subject": {"id": "subject"}, "concept": "invented-reported-class",
                "value": {"kind": "categorical", "value": "X"}, "temporal": {"status": "unknown"},
                "provenance": {"basis": "source-documented", "evidence": [{"id": evidence_id}]},
            }},
            "relationships": {"review-link": {
                "id": "review-link", "kind": "linked-observation", "snapshotID": snapshot["id"],
                "unitNumber": UNIT, "observationID": "review-observation",
            }},
        }, lambda *_: self.scope, synthetic=True)
        # A UI or service-only change must not reidentify the retained historical transform.
        self.historical_digest = digest(semantic_json({
            "transform": TRANSFORM, "version": HISTORICAL_VERSION,
            "fixture": inspect.getsource(omitted_links),
        }))

    def _add_source(self, key, kind, label, citation):
        self.sources[key] = {"id": key, "kind": kind, "label": label,
                             **{field: citation[field] for field in ("start", "end", "exactText")}}

    @contextmanager
    def session(self, caller_id):
        with closing(ReviewDeskTransforms(
            self.schedule, self.snapshot, policy_version="owner-synthetic/v1",
            history_path=self.history_path, caller_id=caller_id,
        )) as desk:
            desk.enable_installed(version=self.version, approved_digest=self.approved_digest)
            desk._executor.enable(TransformSpec(TRANSFORM, HISTORICAL_VERSION, self.historical_digest,
                                                CONTRACT_VERSION, omitted_links, validate_links))
            yield desk

    def action(self, caller_id, payload):
        if not isinstance(payload, dict) or not isinstance(payload.get("action"), str):
            raise ValueError("expected an action")
        action = payload["action"]
        if action not in FIELDS or set(payload) != {"action"} | FIELDS[action]:
            raise ValueError("unknown action or unexpected fields")
        if any(not isinstance(payload[key], str) or not payload[key].strip() for key in FIELDS[action]):
            raise ValueError("expected nonempty text")
        with self.session(caller_id) as desk:
            return self._perform(desk, action, payload)

    def _perform(self, desk, action, payload):
        self.snapshot._scope()
        if action == "context":
            return {"unitNumber": UNIT, "label": self.unit.leaf.label.exactText.strip(),
                    "snapshotID": self.scope.snapshot_id}
        if action == "history":
            return {"receipts": desk.list_receipts(), "feedback": desk.list_feedback()}
        if action == "report":
            return desk.report_feedback(payload["invocationID"], payload["note"])
        if action == "verify":
            return desk.verify_feedback(payload["feedbackID"], candidate_version=self.version)
        if action == "replay":
            result = desk.replay(payload["invocationID"])
        elif action == "rehearse":
            result = desk.run(self.unit, version=HISTORICAL_VERSION)
        else:
            if payload["unitNumber"] != UNIT:
                raise ValueError("unknown pilot unit")
            result = desk.run(self.unit, version=self.version)
        receipt = result.receipt
        return {"receipt": receipt, "links": json.loads(result.semantic_output),
                "sources": [self.sources[ref] for ref in receipt["provenanceRefs"]]}


def application(pilot, token):
    """Only the authenticated owner Worker supplies the stable opaque principal."""
    if not token or not token.isascii():
        raise ValueError("a service bearer credential is required")

    def serve(environ, start_response):
        def reply(status, body):
            data = semantic_json(body)
            start_response(status, [("Content-Type", "application/json"), ("Cache-Control", "private, no-store"),
                                    ("Content-Length", str(len(data)))])
            return [data]

        if environ["PATH_INFO"] != ACTION_PATH:
            return reply("404 Not Found", {})
        if environ["REQUEST_METHOD"] != "POST":
            return reply("405 Method Not Allowed", {})
        authorization = environ.get("HTTP_AUTHORIZATION", "")
        caller_id = environ.get("HTTP_X_DESK_PRINCIPAL", "")
        if (not authorization.isascii() or not hmac.compare_digest(authorization, "Bearer " + token)
                or not re.fullmatch(r"owner:[0-9a-f]{64}", caller_id)):
            return reply("403 Forbidden", {})
        if environ.get("CONTENT_TYPE", "").partition(";")[0].strip().lower() != "application/json":
            return reply("415 Unsupported Media Type", {})
        try:
            length = int(environ.get("CONTENT_LENGTH", ""))
            if length < 1 or length > MAX_BODY:
                return reply("413 Payload Too Large", {})
            payload = json.loads(environ["wsgi.input"].read(length).decode("utf-8"))
            result = pilot.action(caller_id, payload)
        except PermissionError:
            return reply("403 Forbidden", {"error": "This record is unavailable."})
        except TransformRejected:
            return reply("409 Conflict", {"error": "The pinned execution could not be verified."})
        except (ValueError, RecursionError):
            return reply("400 Bad Request", {"error": "Invalid pilot action."})
        except Exception:
            logging.exception("Review Desk pilot execution failed")
            return reply("500 Internal Server Error", {"error": "Pilot execution failed."})
        return reply("200 OK", result)

    return serve


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--history", type=Path, required=True)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--version", required=True)
    parser.add_argument("--approved-digest", required=True)
    args = parser.parse_args()
    pilot = Pilot(args.history, args.version, args.approved_digest)
    app = application(pilot, os.environ.get("FACTORY_REVIEW_TOKEN"))
    with make_server("127.0.0.1", args.port, app) as server:
        print(f"Serving the synthetic Review Desk action on 127.0.0.1:{server.server_port}", flush=True)
        server.serve_forever()


if __name__ == "__main__":
    main()
