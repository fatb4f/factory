"""Private SQLite records for the caller-bound Review Desk pilot."""

from dataclasses import asdict, dataclass
import json
import os
import sqlite3
from threading import RLock

from ivac_legal_units import Scope
from runtime.transform_execution import semantic_json


SCOPE_FIELDS = ("relationships", "observations", "evidence", "actors")


def scope_record(scope):
    record = asdict(scope)
    for field in SCOPE_FIELDS:
        record[field] = sorted(record[field])
    return record


@dataclass(frozen=True)
class HistoricalRun:
    unit_json: bytes
    scope: Scope
    receipt: dict

    @classmethod
    def from_row(cls, row):
        scope = json.loads(row["scope"])
        for field in SCOPE_FIELDS:
            scope[field] = frozenset(scope[field])
        return cls(row["unit"], Scope(**scope), json.loads(row["receipt"]))


class ReviewHistory:
    def __init__(self, path, caller, case, snapshot):
        if path is not None:
            if not isinstance(caller, str) or not caller.strip():
                raise ValueError("durable history requires a trusted caller ID")
            # Create private before SQLite opens it, including when two servers start together.
            fd = os.open(path, os.O_CREAT | os.O_RDWR, 0o600)
            try:
                if os.name == "posix" and os.fstat(fd).st_mode & 0o077:
                    raise PermissionError("history file must be accessible only to its owner")
            finally:
                os.close(fd)
        self._binding = (caller or "local", case, snapshot)
        self._lock = RLock()
        self._db = sqlite3.connect(path if path is not None else ":memory:", check_same_thread=False)
        self._db.row_factory = sqlite3.Row
        self._db.execute("PRAGMA foreign_keys = ON")
        self._db.executescript("""
            CREATE TABLE IF NOT EXISTS invocations (
                id TEXT PRIMARY KEY, caller TEXT NOT NULL, case_id TEXT NOT NULL,
                snapshot_id TEXT NOT NULL, unit BLOB NOT NULL, scope BLOB NOT NULL,
                receipt BLOB NOT NULL
            );
            CREATE INDEX IF NOT EXISTS invocation_owner ON invocations(caller, case_id, snapshot_id);
            CREATE TABLE IF NOT EXISTS feedback (
                id TEXT PRIMARY KEY, invocation TEXT NOT NULL REFERENCES invocations(id), note TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS comparisons (
                feedback_id TEXT NOT NULL REFERENCES feedback(id),
                replay_id TEXT NOT NULL REFERENCES invocations(id),
                candidate_id TEXT NOT NULL REFERENCES invocations(id),
                verification BLOB NOT NULL
            );
        """)

    def close(self):
        with self._lock:
            self._db.close()

    def save(self, unit, scope, receipt):
        with self._lock, self._db:
            self._db.execute(
                "INSERT INTO invocations (id, caller, case_id, snapshot_id, unit, scope, receipt) "
                "VALUES (?, ?, ?, ?, ?, ?, ?)",
                (receipt["invocationID"], *self._binding, semantic_json(unit.to_record()),
                 semantic_json(scope_record(scope)), semantic_json(receipt)),
            )

    def runs(self, invocation_id=None):
        sql = "SELECT unit, scope, receipt FROM invocations WHERE caller=? AND case_id=? AND snapshot_id=?"
        params = self._binding
        if invocation_id is not None:
            sql += " AND id=?"
            params += (invocation_id,)
        with self._lock:
            rows = self._db.execute(sql + " ORDER BY rowid DESC", params)
            return [HistoricalRun.from_row(row) for row in rows]

    def report(self, record):
        with self._lock, self._db:
            self._db.execute("INSERT INTO feedback(id, invocation, note) VALUES (?, ?, ?)",
                             (record["feedbackID"], record["invocationID"], record["note"]))

    def feedback(self, feedback_id=None):
        sql = """
            SELECT f.id, f.invocation, f.note,
                (SELECT verification FROM comparisons WHERE feedback_id=f.id ORDER BY rowid DESC LIMIT 1)
                AS verification
            FROM feedback AS f JOIN invocations AS i ON f.invocation=i.id
            WHERE i.caller=? AND i.case_id=? AND i.snapshot_id=?
        """
        params = self._binding
        if feedback_id is not None:
            sql += " AND f.id=?"
            params += (feedback_id,)
        with self._lock:
            rows = self._db.execute(sql + " ORDER BY f.rowid DESC", params)
            return [
                {
                    "feedbackID": row["id"],
                    "invocationID": row["invocation"],
                    "note": row["note"],
                    "verification": json.loads(row["verification"]) if row["verification"] else None,
                }
                for row in rows
            ]

    def compare(self, feedback_id, verification):
        with self._lock, self._db:
            self._db.execute(
                "INSERT INTO comparisons(feedback_id, replay_id, candidate_id, verification) VALUES (?, ?, ?, ?)",
                (feedback_id, verification["replayInvocationID"], verification["candidateInvocationID"],
                 semantic_json(verification)),
            )
