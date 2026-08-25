from __future__ import annotations

import datetime as dt
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
from types import SimpleNamespace
import unittest


ROOT = Path(__file__).resolve().parents[3]
RUNTIME_PATH = ROOT / ".agents/dispatcher/dispatcher.py"
SPEC = importlib.util.spec_from_file_location("factory_dispatcher", RUNTIME_PATH)
assert SPEC and SPEC.loader
runtime = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runtime)


class ScheduleTests(unittest.TestCase):
    def registration(self, **schedule_updates: object) -> dict[str, object]:
        schedule: dict[str, object] = {
            "epoch": "2026-08-24",
            "cadence": {"unit": "days", "every": 3},
            "window": {"notBefore": "00:00", "notAfter": "23:59"},
        }
        schedule.update(schedule_updates)
        return {
            "id": "projects.ctrl.upstream-monitor",
            "timezone": "America/Toronto",
            "schedule": schedule,
        }

    def test_three_day_topology(self) -> None:
        values = runtime.scheduled_dates(self.registration(), dt.date(2026, 8, 30))
        self.assertEqual(
            [(index, value.isoformat()) for index, value in values],
            [(0, "2026-08-24"), (1, "2026-08-27"), (2, "2026-08-30")],
        )
        self.assertNotIn("2026-08-25", [value.isoformat() for _, value in values])

    def test_weekly_weekday_qualification(self) -> None:
        registration = self.registration(
            epoch="2026-08-24",
            cadence={"unit": "weeks", "every": 1},
            weekday="Monday",
        )
        values = runtime.scheduled_dates(registration, dt.date(2026, 9, 7))
        self.assertEqual([value.strftime("%A") for _, value in values], ["Monday"] * 3)

    def test_invalid_date_weekday_and_window_are_rejected(self) -> None:
        with self.assertRaises(ValueError):
            runtime.scheduled_dates(self.registration(epoch="2026-02-31"), dt.date(2026, 3, 1))
        with self.assertRaises(runtime.DispatchError):
            runtime.scheduled_dates(
                self.registration(cadence={"unit": "weeks", "every": 1}), dt.date(2026, 9, 1)
            )
        with self.assertRaises(runtime.DispatchError):
            runtime.occurrence(
                self.registration(window={"notBefore": "18:00", "notAfter": "09:00"}),
                0,
                dt.date(2026, 8, 24),
                "a" * 64,
            )

    def test_toronto_dst_windows(self) -> None:
        registration = self.registration()
        winter = runtime.occurrence(registration, 0, dt.date(2026, 3, 7), "a" * 64)
        spring = runtime.occurrence(registration, 1, dt.date(2026, 3, 8), "a" * 64)
        fall = runtime.occurrence(registration, 2, dt.date(2026, 11, 1), "a" * 64)
        self.assertEqual(winter["windowStart"], "2026-03-07T05:00:00Z")
        self.assertEqual(spring["windowEnd"], "2026-03-09T04:00:00Z")
        self.assertEqual(fall["windowEnd"], "2026-11-02T05:00:00Z")


class ContractTests(unittest.TestCase):
    def test_all_cue_packages_vet(self) -> None:
        completed = subprocess.run(
            ["cue", "vet", "./..."], cwd=ROOT, text=True, capture_output=True
        )
        self.assertEqual(completed.returncode, 0, completed.stderr)

    def test_due_plan_is_literal_true(self) -> None:
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "plan.json"
            completed = subprocess.run(
                [
                    "python3",
                    str(RUNTIME_PATH),
                    "plan",
                    "--observed-at",
                    "2026-08-25T16:05:00Z",
                    "--ci-observed-at",
                    "2026-08-25T16:05:30Z",
                    "--revision",
                    revision,
                    "--output",
                    str(output),
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr)
            archive = json.loads(output.read_text())
            self.assertIs(archive["plan"]["admission"], True)
            self.assertEqual(len(archive["plan"]["dispatch"]), 2)

    def test_claim_and_result_admission(self) -> None:
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            output = temporary / "plan.json"
            completed = subprocess.run(
                [
                    "python3", str(RUNTIME_PATH), "plan",
                    "--observed-at", "2026-08-25T16:05:00Z",
                    "--ci-observed-at", "2026-08-25T16:05:30Z",
                    "--revision", revision,
                    "--output", str(output),
                ],
                cwd=ROOT, text=True, capture_output=True,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr)
            archive = json.loads(output.read_text())
            item = archive["plan"]["dispatch"][0]
            prior_executions = runtime.EXECUTIONS
            runtime.EXECUTIONS = temporary / "executions"
            try:
                with contextlib.redirect_stdout(io.StringIO()):
                    runtime.command_claim(SimpleNamespace(archive=output, occurrence_id=item["occurrenceID"]))
                base = runtime.EXECUTIONS / item["taskID"] / item["scheduledDate"] / "attempt-1"
                claim = json.loads((base / "claim.json").read_text())
                invocation = claim["attempt"]["invocation"]
                result = {
                    "taskID": invocation["taskID"],
                    "occurrenceID": invocation["occurrenceID"],
                    "attemptID": invocation["attemptID"],
                    "state": "no_change",
                    "completedAt": runtime.timestamp(dt.datetime.now(runtime.UTC)),
                    "duePlanDigest": invocation["duePlanDigest"],
                    "repositoryRevision": invocation["repositoryRevision"],
                    "snapshotDigest": invocation["snapshotDigest"],
                    "registryDigest": invocation["registryDigest"],
                    "publications": [{
                        "path": "contracts/upstream-monitor/ctrl/contract-surface/latest.json",
                        "digest": hashlib.sha256(
                            (ROOT / "contracts/upstream-monitor/ctrl/contract-surface/latest.json").read_bytes()
                        ).hexdigest(),
                    }],
                    "evidence": {"localTerminalState": "terminal_success", "reportableItems": 0},
                }
                result_path = temporary / "result-input.json"
                result_path.write_text(json.dumps(result))
                with contextlib.redirect_stdout(io.StringIO()):
                    runtime.command_result(
                        SimpleNamespace(archive=output, occurrence_id=item["occurrenceID"], result=result_path)
                    )
                self.assertEqual(json.loads((base / "result.json").read_text())["state"], "no_change")
                with contextlib.redirect_stdout(io.StringIO()):
                    runtime.command_result(
                        SimpleNamespace(archive=output, occurrence_id=item["occurrenceID"], result=result_path)
                    )
                state = runtime.ledger_state(
                    item["occurrence"], dt.datetime(2026, 8, 25, 16, 6, tzinfo=runtime.UTC),
                    runtime.registry()[item["taskID"]],
                )
                self.assertTrue(state["terminal"])
                preflight = runtime.build_input(
                    dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC),
                    dt.datetime(2026, 8, 25, 16, 6, tzinfo=runtime.UTC),
                    revision,
                )
                replanned = runtime.cue_export(
                    "(#PlanAdmission & {input: preflight}).plan", {"preflight": preflight}
                )
                self.assertNotIn(item["occurrenceID"], {
                    due["occurrenceID"] for due in replanned["dispatch"]
                })
                self.assertEqual(len(replanned["dispatch"]), 1)
                result["state"] = "success"
                result["evidence"]["reportableItems"] = 1
                result_path.write_text(json.dumps(result))
                with self.assertRaises(runtime.DispatchError):
                    with contextlib.redirect_stdout(io.StringIO()):
                        runtime.command_result(SimpleNamespace(
                            archive=output, occurrence_id=item["occurrenceID"], result=result_path
                        ))
            finally:
                runtime.EXECUTIONS = prior_executions

    def test_claimant_due_field_is_rejected(self) -> None:
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "plan.json"
            completed = subprocess.run(
                [
                    "python3", str(RUNTIME_PATH), "plan",
                    "--observed-at", "2026-08-25T16:05:00Z",
                    "--ci-observed-at", "2026-08-25T16:05:30Z",
                    "--revision", revision,
                    "--output", str(output),
                ],
                cwd=ROOT, text=True, capture_output=True,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr)
            archive = json.loads(output.read_text())
            archive["plan"]["due"] = True
            archive["planDigest"] = runtime.digest(archive["plan"])
            output.write_text(json.dumps(archive))
            with self.assertRaises(runtime.DispatchError):
                runtime.load_archive(output)

    def test_coalesce_latest_disposes_older_occurrences(self) -> None:
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        with tempfile.TemporaryDirectory() as directory:
            prior_executions = runtime.EXECUTIONS
            runtime.EXECUTIONS = Path(directory) / "executions"
            try:
                now = dt.datetime(2026, 8, 30, 16, 5, tzinfo=runtime.UTC)
                preflight = runtime.build_input(now, now, revision)
                plan = runtime.cue_export(
                    "(#PlanAdmission & {input: preflight}).plan", {"preflight": preflight}
                )
                self.assertEqual(
                    {item["scheduledDate"] for item in plan["dispatch"]}, {"2026-08-30"}
                )
                self.assertEqual(len(plan["dispatch"]), 2)
                self.assertEqual(len(plan["dispositions"]), 4)
                self.assertEqual(
                    {item["state"] for item in plan["dispositions"]}, {"coalesced"}
                )
            finally:
                runtime.EXECUTIONS = prior_executions


if __name__ == "__main__":
    unittest.main()
