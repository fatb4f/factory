#!/usr/bin/env python3
"""Thin runtime binding for the CUE-authoritative Factory dispatcher."""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import datetime as dt
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from typing import Any
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "contracts/factory/dispatcher"
EXECUTIONS = ROOT / ".agents/dispatcher/executions"
WORKFLOW = ROOT / ".github/workflows/dispatcher-preflight.yml"
CUE_DATA_TEMP = ROOT / ".agents/dispatcher"
UTC = dt.timezone.utc


class DispatchError(RuntimeError):
    pass


def canonical_bytes(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()


def digest(value: Any) -> str:
    return hashlib.sha256(canonical_bytes(value)).hexdigest()


def parse_timestamp(value: str) -> dt.datetime:
    parsed = dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise DispatchError(f"timestamp lacks an offset: {value}")
    return parsed


def timestamp(value: dt.datetime) -> str:
    return value.astimezone(UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def utc_now() -> dt.datetime:
    return dt.datetime.now(UTC).replace(microsecond=0)


def run(*args: str, input_bytes: bytes | None = None) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        args,
        cwd=ROOT,
        input=input_bytes,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def required_output(*args: str) -> bytes:
    completed = run(*args)
    if completed.returncode:
        raise DispatchError(completed.stderr.decode().strip() or "command failed")
    return completed.stdout


def cue_cli_path(path: Path) -> str:
    try:
        relative = path.resolve().relative_to(ROOT.resolve())
    except ValueError as exc:
        raise DispatchError(f"CUE input is outside the repository: {path}") from exc
    return f"./{relative}"


def cue_export(
    expression: str,
    data: dict[str, Any] | None = None,
    target: Path = CONTRACT,
) -> Any:
    paths = ["cue", "export", cue_cli_path(target), "-e", expression, "--out", "json"]
    temporary: Path | None = None
    try:
        if data is not None:
            with tempfile.NamedTemporaryFile(
                mode="wb", suffix=".json", dir=CUE_DATA_TEMP, delete=False
            ) as handle:
                handle.write(canonical_bytes(data))
                temporary = Path(handle.name)
            paths.insert(3, cue_cli_path(temporary))
        return json.loads(required_output(*paths))
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def cue_vet(schema: str, data: dict[str, Any], target: Path = CONTRACT) -> None:
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="wb", suffix=".json", dir=CUE_DATA_TEMP, delete=False
        ) as handle:
            handle.write(canonical_bytes(data))
            temporary = Path(handle.name)
        completed = run(
            "cue", "vet", cue_cli_path(target), cue_cli_path(temporary), "-d", schema
        )
        if completed.returncode:
            raise DispatchError(completed.stderr.decode().strip() or f"CUE rejected {schema}")
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def cue_identity() -> str:
    return required_output("cue", "version").decode().splitlines()[0]


def git_value(*args: str) -> str:
    return required_output("git", *args).decode().strip()


def registry() -> dict[str, Any]:
    registrations = cue_export("Registry")
    for task_id, registration in registrations.items():
        if registration.get("id") != task_id:
            raise DispatchError(f"registry key/id mismatch: {task_id}")
        paths = {
            "authority": registration["authority"],
            "adapter contract": registration["adapter"]["contract"],
            "adapter procedure": registration["adapter"]["procedure"],
        }
        for field, value in paths.items():
            path = ROOT / value
            if not path.is_file():
                raise DispatchError(f"registered {field} does not exist: {value}")
    return registrations


def cue_admit(schema: str, data: dict[str, Any], target: Path = CONTRACT) -> dict[str, Any]:
    cue_vet(schema, data, target)
    admitted = cue_export(f"({schema} & data)", {"data": data}, target)
    if admitted.get("admission") is not True:
        raise DispatchError(f"CUE admission was not literally true: {schema}")
    return admitted


def repository_file(path_text: str) -> Path:
    path = (ROOT / path_text).resolve()
    try:
        path.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise DispatchError(f"repository path escapes the checkout: {path_text}") from exc
    if not path.is_file():
        raise DispatchError(f"referenced repository file does not exist: {path_text}")
    return path


def verify_reference(reference: dict[str, Any]) -> Path:
    path = repository_file(reference["path"])
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != reference["digest"]:
        raise DispatchError(f"publication digest mismatch: {reference['path']}")
    return path


def publication_observation(reference: dict[str, Any]) -> dict[str, Any]:
    path = verify_reference(reference)
    content = path.read_bytes()
    header = f"blob {len(content)}\0".encode()
    return {
        "path": reference["path"],
        "digest": reference["digest"],
        "gitBlobSHA": hashlib.sha1(header + content).hexdigest(),
    }


def project_task_result(
    registration: dict[str, Any],
    invocation: dict[str, Any],
    completion: dict[str, Any],
) -> dict[str, Any]:
    cue_vet("#TaskCompletion", completion)
    observations = [
        publication_observation(publication)
        for publication in completion["publications"]
    ]
    evidence_path = verify_reference(completion["evidence"])
    manifest_path = verify_reference(completion["manifest"])
    target = repository_file(registration["adapter"]["contract"]).parent
    data = {
        "invocation": invocation,
        "completion": completion,
        "evidenceDocument": json.loads(evidence_path.read_text()),
        "manifestDocument": json.loads(manifest_path.read_text()),
        "publicationObservations": observations,
    }
    projected = cue_admit("#DispatcherResultProjection", data, target)
    return projected["result"]


def completion_from_result(
    result: dict[str, Any], scheduled_date: str
) -> dict[str, Any]:
    admission = result["taskAdmission"]
    return {
        "apiVersion": "factory.dispatcher.task-completion/v1",
        "taskID": result["taskID"],
        "occurrenceID": result["occurrenceID"],
        "attemptID": result["attemptID"],
        "scheduledDate": scheduled_date,
        "completedAt": result["completedAt"],
        "evidence": admission["evidence"],
        "manifest": admission["manifest"],
        "publications": result["publications"],
    }


def scheduled_dates(registration: dict[str, Any], through: dt.date) -> list[tuple[int, dt.date]]:
    schedule = registration["schedule"]
    epoch = dt.date.fromisoformat(schedule["epoch"])
    if through < epoch:
        return []
    cadence = schedule["cadence"]
    step_days = cadence["every"] * (7 if cadence["unit"] == "weeks" else 1)
    expected_weekday = schedule.get("weekday")
    if cadence["unit"] == "weeks" and expected_weekday is None:
        raise DispatchError("weekly cadence requires weekday qualification")
    if expected_weekday is not None and epoch.strftime("%A") != expected_weekday:
        raise DispatchError("schedule epoch does not match weekday qualification")
    values: list[tuple[int, dt.date]] = []
    index = 0
    current = epoch
    while current <= through:
        if expected_weekday is None or current.strftime("%A") == expected_weekday:
            values.append((index, current))
        index += 1
        current = epoch + dt.timedelta(days=index * step_days)
    return values


def occurrence(registration: dict[str, Any], index: int, date: dt.date, registry_digest: str) -> dict[str, Any]:
    try:
        zone = ZoneInfo(registration["timezone"])
    except ZoneInfoNotFoundError as exc:
        raise DispatchError(f"unknown IANA timezone: {registration['timezone']}") from exc
    window = registration["schedule"]["window"]
    start_time = dt.time.fromisoformat(window["notBefore"])
    end_time = dt.time.fromisoformat(window["notAfter"])
    if end_time < start_time:
        raise DispatchError("execution window is reversed")
    start = dt.datetime.combine(date, start_time, zone)
    # The declared minute is inclusive; the resolved window ends one minute later.
    end = dt.datetime.combine(date, end_time, zone) + dt.timedelta(minutes=1)
    task_id = registration["id"]
    date_text = date.isoformat()
    return {
        "taskID": task_id,
        "id": f"{task_id}/{date_text}",
        "epochIndex": index,
        "registryDigest": registry_digest,
        "scheduledDate": date_text,
        "timezone": registration["timezone"],
        "windowStart": timestamp(start),
        "windowEnd": timestamp(end),
    }


def attempt_paths(task_id: str, date: str) -> list[Path]:
    base = EXECUTIONS / task_id / date
    if not base.is_dir():
        return []
    paths = [path for path in base.iterdir() if path.is_dir() and path.name.startswith("attempt-")]
    try:
        return sorted(paths, key=lambda path: int(path.name.removeprefix("attempt-")))
    except ValueError as exc:
        raise DispatchError(f"invalid attempt directory under {base}") from exc


def ledger_state(
    item: dict[str, Any], ci_now: dt.datetime, registration: dict[str, Any]
) -> dict[str, Any]:
    task_id = item["taskID"]
    date = item["scheduledDate"]
    base = EXECUTIONS / task_id / date
    attempts = attempt_paths(task_id, date)
    terminal = False
    last_stale_at: str | None = None
    for ordinal, path in enumerate(attempts, start=1):
        if terminal:
            raise DispatchError(f"attempt exists after a terminal result under {base}")
        if path.name != f"attempt-{ordinal}":
            raise DispatchError(f"non-contiguous attempts under {base}")
        claim_path = path / "claim.json"
        if not claim_path.is_file():
            raise DispatchError(f"missing claim: {claim_path}")
        claim = json.loads(claim_path.read_text())
        cue_admit("#ClaimLocationAdmission", {
            "taskID": task_id,
            "occurrenceID": item["id"],
            "scheduledDate": date,
            "record": claim,
        })
        if claim["attempt"]["ordinal"] != ordinal:
            raise DispatchError(f"claim identity mismatch: {claim_path}")
        last_stale_at = claim["attempt"]["staleAt"]
        claimed_at = parse_timestamp(claim["attempt"]["claimedAt"])
        if parse_timestamp(last_stale_at) != claimed_at + dt.timedelta(hours=6):
            raise DispatchError(f"claim has an invalid stale boundary: {claim_path}")
        result_path = path / "result.json"
        if result_path.exists():
            result = json.loads(result_path.read_text())
            projected = project_task_result(
                registration,
                claim["attempt"]["invocation"],
                completion_from_result(result, date),
            )
            if projected != result:
                raise DispatchError(f"stored result differs from task projection: {result_path}")
            cue_admit("#ResultAdmission", {
                "registration": registration,
                "occurrence": claim["occurrence"],
                "invocation": claim["attempt"]["invocation"],
                "result": result,
            })
            if terminal:
                raise DispatchError(f"duplicate terminal result under {base}")
            terminal = True
    disposed = (base / "disposition.json").exists()
    if disposed:
        cue_admit("#DispositionAdmission", {
            "occurrence": item,
            "record": json.loads((base / "disposition.json").read_text()),
        })
    if disposed and attempts:
        raise DispatchError(f"disposition coexists with attempts under {base}")
    state: dict[str, Any] = {
        "attemptCount": len(attempts),
        "terminal": terminal,
        "disposed": disposed,
        "dispatchAfter": item["windowStart"],
    }
    if attempts and not terminal:
        if last_stale_at is None:
            raise DispatchError(f"missing stale boundary under {base}")
        # Parse here as an independent fail-fast check; CUE compares it to the CI tick.
        parse_timestamp(last_stale_at)
        state["dispatchAfter"] = last_stale_at
    return state


def build_input(observed: dt.datetime, ci_now: dt.datetime, revision: str) -> dict[str, Any]:
    registrations = registry()
    registry_digest = digest(registrations)
    tree = git_value("rev-parse", f"{revision}^{{tree}}")
    snapshot_digest = hashlib.sha256(f"git-tree:{tree}".encode()).hexdigest()
    workflow_digest = hashlib.sha256(WORKFLOW.read_bytes()).hexdigest()
    candidates: list[dict[str, Any]] = []
    for task_id, registration in sorted(registrations.items()):
        zone = ZoneInfo(registration["timezone"])
        local_now = ci_now.astimezone(zone)
        for index, date in scheduled_dates(registration, local_now.date()):
            value = occurrence(registration, index, date, registry_digest)
            candidates.append(
                {
                    "registration": registration,
                    "occurrence": value,
                    **ledger_state(value, ci_now, registration),
                }
            )
    local = ci_now.astimezone(ZoneInfo("America/Toronto"))
    return {
        "apiVersion": "factory.dispatcher.preflight/v1",
        "repositoryRevision": revision,
        "snapshotDigest": snapshot_digest,
        "registryDigest": registry_digest,
        "workflowDigest": workflow_digest,
        "cueIdentity": cue_identity(),
        "tick": {
            "observedAt": timestamp(observed),
            "ciObservedAt": timestamp(ci_now),
            "localDate": local.date().isoformat(),
            "localTime": local.strftime("%H:%M"),
            "timezone": "America/Toronto",
        },
        "registry": registrations,
        "candidates": candidates,
    }


def atomic_append(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    encoded = json.dumps(value, indent=2, sort_keys=True).encode() + b"\n"
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    try:
        with temporary.open("xb") as handle:
            handle.write(encoded)
            handle.flush()
            os.fsync(handle.fileno())
        os.link(temporary, path)
    except FileExistsError as exc:
        raise DispatchError(f"append-only target already exists: {path}") from exc
    finally:
        temporary.unlink(missing_ok=True)


def display_path(path: Path) -> Path:
    try:
        return path.relative_to(ROOT)
    except ValueError:
        return path


@contextmanager
def task_transition_lock(task_id: str):
    directory = EXECUTIONS / task_id
    directory.mkdir(parents=True, exist_ok=True)
    descriptor = os.open(directory, os.O_RDONLY)
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX)
        yield
    finally:
        fcntl.flock(descriptor, fcntl.LOCK_UN)
        os.close(descriptor)


def current_input(plan: dict[str, Any], now: dt.datetime) -> dict[str, Any]:
    return build_input(now, now, plan["repositoryRevision"])


def load_archive(path: Path) -> dict[str, Any]:
    archive = json.loads(path.read_text())
    if set(archive) != {"plan", "planDigest"}:
        raise DispatchError("due-plan archive has unexpected fields")
    plan = archive["plan"]
    expected_plan_fields = {
        "apiVersion", "repositoryRevision", "snapshotDigest", "registryDigest",
        "workflowDigest", "cueIdentity", "tick", "dispatch", "dispositions", "admission",
    }
    if set(plan) != expected_plan_fields:
        raise DispatchError("due-plan has unexpected or missing fields")
    if plan.get("admission") is not True:
        raise DispatchError("due-plan admission is not literally true")
    if digest(plan) != archive["planDigest"]:
        raise DispatchError("due-plan digest mismatch")
    cue_vet("#DuePlan", plan)
    validated = cue_export("(#DuePlan & data)", {"data": plan})
    if validated.get("admission") is not True:
        raise DispatchError("due-plan failed CUE validation")
    revision = git_value("rev-parse", "HEAD")
    if plan["repositoryRevision"] != revision:
        raise DispatchError("due-plan repository revision does not match HEAD")
    tree = git_value("rev-parse", f"{revision}^{{tree}}")
    snapshot_digest = hashlib.sha256(f"git-tree:{tree}".encode()).hexdigest()
    if plan["snapshotDigest"] != snapshot_digest:
        raise DispatchError("due-plan snapshot digest mismatch")
    if plan["registryDigest"] != digest(registry()):
        raise DispatchError("due-plan registry digest mismatch")
    if plan["workflowDigest"] != hashlib.sha256(WORKFLOW.read_bytes()).hexdigest():
        raise DispatchError("due-plan workflow digest mismatch")
    if plan["cueIdentity"] != cue_identity():
        raise DispatchError("due-plan CUE identity mismatch")
    return archive


def command_plan(args: argparse.Namespace) -> None:
    observed = parse_timestamp(args.observed_at)
    ci_now = parse_timestamp(args.ci_observed_at) if args.ci_observed_at else utc_now()
    if observed > ci_now + dt.timedelta(minutes=5) or ci_now - observed > dt.timedelta(hours=24):
        raise DispatchError("observed tick is outside the admitted CI observation interval")
    revision = args.revision or git_value("rev-parse", "HEAD")
    if revision != git_value("rev-parse", revision):
        raise DispatchError("repository revision must be a full commit SHA")
    preflight = build_input(observed, ci_now, revision)
    plan = cue_export("(#PlanAdmission & {input: preflight}).plan", {"preflight": preflight})
    if plan.get("admission") is not True:
        raise DispatchError("CUE admission export was not literally true")
    archive = {"plan": plan, "planDigest": digest(plan)}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(json.dumps(archive, indent=2, sort_keys=True).encode() + b"\n")
    print(json.dumps(archive, sort_keys=True))


def command_verify(args: argparse.Namespace) -> None:
    archive = load_archive(args.archive)
    print(f"admitted {archive['planDigest']} ({len(archive['plan']['dispatch'])} dispatch)")


def selected_dispatch(archive: dict[str, Any], occurrence_id: str) -> dict[str, Any]:
    matches = [item for item in archive["plan"]["dispatch"] if item["occurrenceID"] == occurrence_id]
    if len(matches) != 1:
        raise DispatchError(f"occurrence is not uniquely admitted for dispatch: {occurrence_id}")
    return matches[0]


def command_claim(args: argparse.Namespace) -> None:
    archive = load_archive(args.archive)
    item = selected_dispatch(archive, args.occurrence_id)
    plan = archive["plan"]
    ordinal = item["attemptOrdinal"]
    attempt_id = f"{item['occurrenceID']}/attempt-{ordinal}"
    date = item["scheduledDate"]
    path = EXECUTIONS / item["taskID"] / date / f"attempt-{ordinal}" / "claim.json"
    with task_transition_lock(item["taskID"]):
        if path.exists():
            existing = json.loads(path.read_text())
            ledger_state(item["occurrence"], utc_now(), registry()[item["taskID"]])
            if (
                existing.get("occurrence") == item["occurrence"]
                and existing.get("attempt", {}).get("ordinal") == ordinal
                and existing.get("attempt", {}).get("invocation", {}).get("duePlanDigest")
                == archive["planDigest"]
            ):
                print(json.dumps({"status": "already_claimed", "path": str(display_path(path))}))
                return
            raise DispatchError(f"conflicting append-only claim already exists: {path}")
        now = utc_now()
        invocation = {
            "taskID": item["taskID"],
            "occurrenceID": item["occurrenceID"],
            "attemptID": attempt_id,
            "attemptOrdinal": ordinal,
            "scheduledAt": item["occurrence"]["windowStart"],
            "invokedAt": timestamp(now),
            "duePlanDigest": archive["planDigest"],
            "repositoryRevision": plan["repositoryRevision"],
            "snapshotDigest": plan["snapshotDigest"],
            "registryDigest": plan["registryDigest"],
        }
        claim = {
            "apiVersion": "factory.dispatcher.claim/v1",
            "occurrence": item["occurrence"],
            "attempt": {
                "id": attempt_id,
                "ordinal": ordinal,
                "claimedAt": timestamp(now),
                "staleAt": timestamp(now + dt.timedelta(hours=6)),
                "invocation": invocation,
            },
        }
        cue_admit("#ClaimAdmission", {
            "archivedPlan": plan,
            "planDigest": archive["planDigest"],
            "currentInput": current_input(plan, now),
            "item": item,
            "claim": claim,
        })
        atomic_append(path, claim)
        print(json.dumps({"status": "created", "path": str(display_path(path))}))


def command_dispositions(args: argparse.Namespace) -> None:
    archive = load_archive(args.archive)
    for item in archive["plan"]["dispositions"]:
        path = EXECUTIONS / item["taskID"] / item["scheduledDate"] / "disposition.json"
        with task_transition_lock(item["taskID"]):
            now = utc_now()
            fresh = current_input(archive["plan"], now)
            occurrences = [
                candidate["occurrence"] for candidate in fresh["candidates"]
                if candidate["occurrence"]["id"] == item["occurrenceID"]
            ]
            if len(occurrences) != 1:
                raise DispatchError(f"current occurrence is not uniquely resolved: {item['occurrenceID']}")
            if path.exists():
                existing = json.loads(path.read_text())
                if (
                    existing.get("taskID") == item["taskID"]
                    and existing.get("occurrenceID") == item["occurrenceID"]
                    and existing.get("disposition", {}).get("state") == item["state"]
                    and existing.get("disposition", {}).get("planDigest") == archive["planDigest"]
                ):
                    print(json.dumps({"status": "already_disposed", "path": str(display_path(path))}))
                    continue
                raise DispatchError(f"conflicting append-only disposition already exists: {path}")
            record = {
                "apiVersion": "factory.dispatcher.disposition/v1",
                "taskID": item["taskID"],
                "occurrenceID": item["occurrenceID"],
                "scheduledDate": item["scheduledDate"],
                "disposition": {
                    "state": item["state"],
                    "classifiedAt": timestamp(now),
                    "planDigest": archive["planDigest"],
                },
            }
            cue_admit("#DispositionTransitionAdmission", {
                "archivedPlan": archive["plan"],
                "planDigest": archive["planDigest"],
                "currentInput": fresh,
                "item": item,
                "occurrence": occurrences[0],
                "record": record,
            })
            atomic_append(path, record)
            print(json.dumps({"status": "created", "path": str(display_path(path))}))


def command_result(args: argparse.Namespace) -> None:
    archive = load_archive(args.archive)
    item = selected_dispatch(archive, args.occurrence_id)
    ordinal = item["attemptOrdinal"]
    base = EXECUTIONS / item["taskID"] / item["scheduledDate"] / f"attempt-{ordinal}"
    result_target = base / "result.json"
    with task_transition_lock(item["taskID"]):
        claim_path = base / "claim.json"
        if not claim_path.is_file():
            raise DispatchError(f"validated claim does not exist: {claim_path}")
        claim = json.loads(claim_path.read_text())
        completion = json.loads(args.completion.read_text())
        registration = registry()[item["taskID"]]
        result = project_task_result(registration, claim["attempt"]["invocation"], completion)
        if result_target.exists():
            if json.loads(result_target.read_text()) == result:
                print(display_path(result_target))
                return
            raise DispatchError(f"conflicting terminal result already exists: {result_target}")
        now = utc_now()
        current = ledger_state(item["occurrence"], now, registration)
        cue_admit("#ResultTransitionAdmission", {
            "registration": registration,
            "occurrence": claim["occurrence"],
            "invocation": claim["attempt"]["invocation"],
            "result": result,
            "current": {
                "registration": registration,
                "occurrence": claim["occurrence"],
                **current,
            },
        })
        atomic_append(result_target, result)
        print(display_path(result_target))


def command_summary(args: argparse.Namespace) -> None:
    archive = load_archive(args.archive)
    plan = archive["plan"]
    states: dict[str, int] = {}
    for item in plan["dispatch"]:
        base = EXECUTIONS / item["taskID"] / item["scheduledDate"] / f"attempt-{item['attemptOrdinal']}"
        result_path = base / "result.json"
        state = json.loads(result_path.read_text())["state"] if result_path.exists() else "unclaimed_or_incomplete"
        states[state] = states.get(state, 0) + 1
    rendered = ", ".join(f"{key}={states[key]}" for key in sorted(states)) or "no due tasks"
    print(f"{plan['tick']['localDate']}: {rendered}; dispositions={len(plan['dispositions'])}")


def command_validate_ledger(_args: argparse.Namespace) -> None:
    registrations = registry()
    registry_digest = digest(registrations)
    if EXECUTIONS.is_dir():
        unknown = [
            path.name for path in EXECUTIONS.iterdir()
            if path.is_dir() and path.name not in registrations
        ]
        if unknown:
            raise DispatchError(f"execution ledger contains unknown tasks: {', '.join(sorted(unknown))}")
    count = 0
    now = utc_now()
    for task_id, registration in sorted(registrations.items()):
        task_root = EXECUTIONS / task_id
        if not task_root.is_dir():
            continue
        for date_root in sorted(path for path in task_root.iterdir() if path.is_dir()):
            scheduled_date = dt.date.fromisoformat(date_root.name)
            matches = [
                (index, value) for index, value in scheduled_dates(registration, scheduled_date)
                if value == scheduled_date
            ]
            if len(matches) != 1:
                raise DispatchError(f"ledger date is not a scheduled occurrence: {date_root}")
            resolved = occurrence(
                registration, matches[0][0], scheduled_date, registry_digest
            )
            ledger_state(resolved, now, registration)
            count += 1
    print(f"validated {count} ledger occurrences")


def parser() -> argparse.ArgumentParser:
    value = argparse.ArgumentParser(description=__doc__)
    commands = value.add_subparsers(dest="command", required=True)
    plan = commands.add_parser("plan")
    plan.add_argument("--observed-at", required=True)
    plan.add_argument("--ci-observed-at")
    plan.add_argument("--revision")
    plan.add_argument("--output", type=Path, required=True)
    plan.set_defaults(handler=command_plan)
    verify = commands.add_parser("verify-plan")
    verify.add_argument("archive", type=Path)
    verify.set_defaults(handler=command_verify)
    claim = commands.add_parser("claim")
    claim.add_argument("archive", type=Path)
    claim.add_argument("occurrence_id")
    claim.set_defaults(handler=command_claim)
    dispositions = commands.add_parser("apply-dispositions")
    dispositions.add_argument("archive", type=Path)
    dispositions.set_defaults(handler=command_dispositions)
    result = commands.add_parser("record-result")
    result.add_argument("archive", type=Path)
    result.add_argument("occurrence_id")
    result.add_argument("completion", type=Path)
    result.set_defaults(handler=command_result)
    summary = commands.add_parser("summary")
    summary.add_argument("archive", type=Path)
    summary.set_defaults(handler=command_summary)
    ledger = commands.add_parser("validate-ledger")
    ledger.set_defaults(handler=command_validate_ledger)
    return value


def main() -> int:
    args = parser().parse_args()
    try:
        args.handler(args)
    except (DispatchError, json.JSONDecodeError, KeyError, ValueError, OSError) as exc:
        print(f"dispatcher: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
