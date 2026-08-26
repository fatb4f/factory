from __future__ import annotations

import contextlib
import copy
import datetime as dt
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock


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
                self.registration(cadence={"unit": "weeks", "every": 1}),
                dt.date(2026, 9, 1),
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


class DispatcherTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.executions = Path(self.temporary.name) / "executions"
        self.original_executions = runtime.EXECUTIONS
        runtime.EXECUTIONS = self.executions
        self.addCleanup(setattr, runtime, "EXECUTIONS", self.original_executions)
        self.original_registry = runtime.registry
        self.original_now = runtime.utc_now
        self.revision = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
        ).strip()

    def enabled_registry(self) -> dict[str, object]:
        values = copy.deepcopy(self.original_registry())
        for registration in values.values():
            registration["enabled"] = True
            registration["activationDate"] = "2026-08-24"
        return values

    @contextlib.contextmanager
    def enabled_at(self, now: dt.datetime):
        registrations = self.enabled_registry()
        runtime.registry = lambda: copy.deepcopy(registrations)
        runtime.utc_now = lambda: now
        try:
            yield registrations
        finally:
            runtime.registry = self.original_registry
            runtime.utc_now = self.original_now

    def archive(self, now: dt.datetime, output: Path) -> dict[str, object]:
        preflight = runtime.build_input(now, now, self.revision)
        plan = runtime.cue_export(
            "(#PlanAdmission & {input: preflight}).plan", {"preflight": preflight}
        )
        archive = {"plan": plan, "planDigest": runtime.digest(plan)}
        output.write_text(json.dumps(archive))
        return archive

    def test_production_registrations_are_inert_and_authoritative(self) -> None:
        registrations = self.original_registry()
        self.assertTrue(all(value["enabled"] is False for value in registrations.values()))
        self.assertTrue(all("activationDate" not in value for value in registrations.values()))
        self.assertEqual(
            registrations["projects.ctrl.upstream-monitor"]["authority"],
            "contracts/factory/workers/upstream-monitor/profiles_ctrl/contract.cue",
        )
        now = dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC)
        plan = runtime.cue_export(
            "(#PlanAdmission & {input: preflight}).plan",
            {"preflight": runtime.build_input(now, now, self.revision)},
        )
        self.assertEqual(plan["dispatch"], [])
        self.assertEqual(plan["dispositions"], [])

    def test_claim_is_freshly_admitted_and_duplicate_is_non_actionable(self) -> None:
        now = dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC)
        output = Path(self.temporary.name) / "plan.json"
        with self.enabled_at(now):
            archive = self.archive(now, output)
            item = archive["plan"]["dispatch"][0]
            rendered = io.StringIO()
            with contextlib.redirect_stdout(rendered):
                runtime.command_claim(
                    SimpleNamespace(archive=output, occurrence_id=item["occurrenceID"])
                )
            self.assertEqual(json.loads(rendered.getvalue())["status"], "created")
            rendered = io.StringIO()
            with contextlib.redirect_stdout(rendered):
                runtime.command_claim(
                    SimpleNamespace(archive=output, occurrence_id=item["occurrenceID"])
                )
            self.assertEqual(json.loads(rendered.getvalue())["status"], "already_claimed")
            self.assertEqual(len(runtime.attempt_paths(item["taskID"], item["scheduledDate"])), 1)

    def test_old_plan_cannot_claim_after_later_occurrence_supersedes_it(self) -> None:
        planned = dt.datetime(2026, 8, 27, 16, 5, tzinfo=runtime.UTC)
        consumed = dt.datetime(2026, 8, 30, 16, 5, tzinfo=runtime.UTC)
        output = Path(self.temporary.name) / "plan.json"
        with self.enabled_at(planned):
            archive = self.archive(planned, output)
            item = archive["plan"]["dispatch"][0]
            runtime.utc_now = lambda: consumed
            with self.assertRaises(runtime.DispatchError):
                runtime.command_claim(
                    SimpleNamespace(archive=output, occurrence_id=item["occurrenceID"])
                )
            self.assertEqual(runtime.attempt_paths(item["taskID"], item["scheduledDate"]), [])

    def test_retry_plan_cannot_claim_after_prior_attempt_becomes_terminal(self) -> None:
        first_tick = dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC)
        retry_tick = first_tick + dt.timedelta(hours=7)
        first_path = Path(self.temporary.name) / "first-plan.json"
        retry_path = Path(self.temporary.name) / "retry-plan.json"
        with self.enabled_at(first_tick):
            first = self.archive(first_tick, first_path)
            item = first["plan"]["dispatch"][0]
            with contextlib.redirect_stdout(io.StringIO()):
                runtime.command_claim(
                    SimpleNamespace(archive=first_path, occurrence_id=item["occurrenceID"])
                )
            runtime.utc_now = lambda: retry_tick
            retry = self.archive(retry_tick, retry_path)
            retry_item = next(
                candidate for candidate in retry["plan"]["dispatch"]
                if candidate["occurrenceID"] == item["occurrenceID"]
            )
            self.assertEqual(retry_item["attemptOrdinal"], 2)
            attempt_one = (
                runtime.EXECUTIONS / item["taskID"] / item["scheduledDate"] / "attempt-1"
            )
            claim = json.loads((attempt_one / "claim.json").read_text())
            invocation = claim["attempt"]["invocation"]
            reference = {"path": "evidence.json", "digest": "f" * 64}
            terminal = {
                "taskID": invocation["taskID"],
                "occurrenceID": invocation["occurrenceID"],
                "attemptID": invocation["attemptID"],
                "state": "success",
                "completedAt": runtime.timestamp(retry_tick),
                "duePlanDigest": invocation["duePlanDigest"],
                "repositoryRevision": invocation["repositoryRevision"],
                "snapshotDigest": invocation["snapshotDigest"],
                "registryDigest": invocation["registryDigest"],
                "publications": [],
                "taskAdmission": {
                    "contract": self.enabled_registry()[item["taskID"]]["adapter"]["contract"],
                    "evidence": reference,
                    "manifest": reference,
                },
            }
            (attempt_one / "result.json").write_text(json.dumps(terminal))
            with mock.patch.object(runtime, "project_task_result", return_value=terminal):
                with self.assertRaises(runtime.DispatchError):
                    runtime.command_claim(
                        SimpleNamespace(
                            archive=retry_path,
                            occurrence_id=retry_item["occurrenceID"],
                        )
                    )
            self.assertFalse(
                (
                    runtime.EXECUTIONS / item["taskID"] / item["scheduledDate"]
                    / "attempt-2/claim.json"
                ).exists()
            )

    def test_dispositions_recompute_current_ledger_between_appends(self) -> None:
        now = dt.datetime(2026, 8, 30, 16, 5, tzinfo=runtime.UTC)
        output = Path(self.temporary.name) / "plan.json"
        with self.enabled_at(now):
            archive = self.archive(now, output)
            self.assertEqual(len(archive["plan"]["dispositions"]), 4)
            with contextlib.redirect_stdout(io.StringIO()):
                runtime.command_dispositions(SimpleNamespace(archive=output))
            for item in archive["plan"]["dispositions"]:
                path = runtime.EXECUTIONS / item["taskID"] / item["scheduledDate"] / "disposition.json"
                self.assertTrue(path.is_file())

    def test_mislocated_disposition_is_rejected(self) -> None:
        now = dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC)
        with self.enabled_at(now) as registrations:
            registration = registrations["projects.ctrl.upstream-monitor"]
            resolved = runtime.occurrence(registration, 0, dt.date(2026, 8, 24), "a" * 64)
            path = runtime.EXECUTIONS / resolved["taskID"] / resolved["scheduledDate"] / "disposition.json"
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({
                "apiVersion": "factory.dispatcher.disposition/v1",
                "taskID": resolved["taskID"],
                "occurrenceID": f"{resolved['taskID']}/2026-08-27",
                "scheduledDate": "2026-08-27",
                "disposition": {
                    "state": "coalesced",
                    "classifiedAt": runtime.timestamp(now),
                    "planDigest": "b" * 64,
                },
            }))
            with self.assertRaises(runtime.DispatchError):
                runtime.ledger_state(resolved, now, registration)

    def test_mislocated_claim_is_rejected(self) -> None:
        now = dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC)
        with self.enabled_at(now) as registrations:
            registration = registrations["projects.ctrl.upstream-monitor"]
            expected = runtime.occurrence(registration, 0, dt.date(2026, 8, 24), "a" * 64)
            misplaced = runtime.occurrence(registration, 1, dt.date(2026, 8, 27), "a" * 64)
            attempt_id = f"{misplaced['id']}/attempt-1"
            claim = {
                "apiVersion": "factory.dispatcher.claim/v1",
                "occurrence": misplaced,
                "attempt": {
                    "id": attempt_id,
                    "ordinal": 1,
                    "claimedAt": runtime.timestamp(now),
                    "staleAt": runtime.timestamp(now + dt.timedelta(hours=6)),
                    "invocation": {
                        "taskID": misplaced["taskID"],
                        "occurrenceID": misplaced["id"],
                        "attemptID": attempt_id,
                        "attemptOrdinal": 1,
                        "scheduledAt": misplaced["windowStart"],
                        "invokedAt": runtime.timestamp(now),
                        "duePlanDigest": "b" * 64,
                        "repositoryRevision": "c" * 40,
                        "snapshotDigest": "d" * 64,
                        "registryDigest": misplaced["registryDigest"],
                    },
                },
            }
            path = (
                runtime.EXECUTIONS / expected["taskID"] / expected["scheduledDate"]
                / "attempt-1/claim.json"
            )
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps(claim))
            with self.assertRaises(runtime.DispatchError):
                runtime.ledger_state(expected, now, registration)

    def projection_data(self, reportable: bool = True) -> tuple[Path, dict[str, object]]:
        root = ROOT / "contracts/upstream-monitor/ctrl/contract-surface"
        run_id = "20260824T161301Z"
        evidence = json.loads((root / f"runs/{run_id}/evidence.json").read_text())
        manifest = json.loads((root / f"runs/{run_id}/manifest.json").read_text())
        context = {
            "task_id": "projects.ctrl.upstream-monitor",
            "scheduled_date": "2026-08-24",
            "occurrence_id": "projects.ctrl.upstream-monitor/2026-08-24",
            "attempt_ordinal": 1,
            "attempt_id": "projects.ctrl.upstream-monitor/2026-08-24/attempt-1",
            "due_plan_digest": "d" * 64,
        }
        evidence["dispatcher"] = context
        manifest["dispatcher"] = context
        if not reportable:
            for item in evidence["items"]:
                item["decision"] = "none"
        invocation = {
            "taskID": context["task_id"],
            "occurrenceID": context["occurrence_id"],
            "attemptID": context["attempt_id"],
            "attemptOrdinal": 1,
            "scheduledAt": "2026-08-24T04:00:00Z",
            "invokedAt": "2026-08-25T16:05:00Z",
            "duePlanDigest": context["due_plan_digest"],
            "repositoryRevision": "a" * 40,
            "snapshotDigest": "b" * 64,
            "registryDigest": "c" * 64,
        }
        run_root = f"contracts/upstream-monitor/ctrl/contract-surface/runs/{run_id}"
        reference = lambda path: {"path": path, "digest": "e" * 64}
        completion = {
            "apiVersion": "factory.dispatcher.task-completion/v1",
            "taskID": context["task_id"],
            "occurrenceID": context["occurrence_id"],
            "attemptID": context["attempt_id"],
            "scheduledDate": context["scheduled_date"],
            "completedAt": "2026-08-25T17:00:00Z",
            "evidence": reference(f"{run_root}/evidence.json"),
            "manifest": reference(f"{run_root}/manifest.json"),
            "publications": [
                reference(f"{run_root}/report.md"),
                reference(f"{run_root}/summary.md"),
                reference(f"{run_root}/evidence.json"),
                reference(f"{run_root}/manifest.json"),
            ],
        }
        observations = []
        manifest_blobs = {
            artifact["filename"]: artifact["gitBlobSHA"]
            for artifact in manifest["artifacts"]
        }
        for publication in completion["publications"]:
            filename = publication["path"].rsplit("/", 1)[-1]
            observations.append({
                **publication,
                "gitBlobSHA": manifest_blobs.get(filename, "f" * 40),
            })
        return ROOT / "projects/ctrl/upstream-monitor", {
            "invocation": invocation,
            "completion": completion,
            "evidenceDocument": evidence,
            "manifestDocument": manifest,
            "publicationObservations": observations,
        }

    def test_task_contract_derives_common_state_from_local_evidence(self) -> None:
        target, data = self.projection_data(reportable=True)
        projected = runtime.cue_admit("#DispatcherResultProjection", data, target)
        self.assertEqual(projected["result"]["state"], "success")
        target, data = self.projection_data(reportable=False)
        projected = runtime.cue_admit("#DispatcherResultProjection", data, target)
        self.assertEqual(projected["result"]["state"], "no_change")
        for terminal_state, expected in (
            ("terminal_abort", "failed"),
            ("terminal_deferred", "deferred"),
            ("coverage_gap", "coverage_gap"),
        ):
            with self.subTest(terminal_state=terminal_state):
                target, data = self.projection_data(reportable=True)
                data["evidenceDocument"]["terminal_state"] = terminal_state
                data["evidenceDocument"]["monitor_state"] = terminal_state
                data["manifestDocument"]["terminal_state"] = terminal_state
                projected = runtime.cue_admit("#DispatcherResultProjection", data, target)
                self.assertEqual(projected["result"]["state"], expected)
        target, data = self.projection_data(reportable=False)
        del data["evidenceDocument"]["dispatcher"]
        with self.assertRaises(runtime.DispatchError):
            runtime.cue_admit("#DispatcherResultProjection", data, target)
        target, data = self.projection_data(reportable=True)
        data["manifestDocument"]["artifacts"][0]["gitBlobSHA"] = "0" * 40
        with self.assertRaises(runtime.DispatchError):
            runtime.cue_admit("#DispatcherResultProjection", data, target)

    def test_claimant_due_field_is_rejected(self) -> None:
        now = dt.datetime(2026, 8, 25, 16, 5, tzinfo=runtime.UTC)
        output = Path(self.temporary.name) / "plan.json"
        with self.enabled_at(now):
            archive = self.archive(now, output)
            archive["plan"]["due"] = True
            archive["planDigest"] = runtime.digest(archive["plan"])
            output.write_text(json.dumps(archive))
            with self.assertRaises(runtime.DispatchError):
                runtime.load_archive(output)


class QualificationTests(unittest.TestCase):
    def test_root_and_worker_packages_vet(self) -> None:
        commands = [
            (["cue", "vet", "./..."], ROOT),
            (["cue", "vet", "./contracts/factory/workers/upstream-monitor/..."], ROOT),
            (["cue", "vet", "-c=false", "./..."], ROOT / "contracts/factory/workers/codex/upstream-monitor"),
        ]
        for command, cwd in commands:
            with self.subTest(command=command):
                completed = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
                self.assertEqual(completed.returncode, 0, completed.stderr)


if __name__ == "__main__":
    unittest.main()
