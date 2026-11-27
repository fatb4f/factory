"""Stage or verify a Cyber Incident Watch run from the repository root."""

import argparse
from datetime import datetime, timezone
import fcntl
import json
from pathlib import Path
import os
import subprocess
import tempfile

PROJECT = Path("projects/cyber-incidents")
WATCH = PROJECT / "upstream-monitor"
POINTER = WATCH / "latest.json"
PROFILE = Path("contracts/workers/upstream-monitor/profiles_cyber_incidents")
STREAMS = ("global-major-cyber", "canadian-surveillance")


def encode(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode()


def vet(value, definition):
    with tempfile.NamedTemporaryFile(suffix=".json") as handle:
        handle.write(encode(value))
        handle.flush()
        subprocess.run(["cue", "vet", "-c", *sorted(PROFILE.glob("*.cue")),
                        handle.name, "-d", definition], check=True)


def read_json(path):
    return json.loads(path.read_bytes())


def blob(content):
    return subprocess.check_output(["git", "hash-object", "--stdin"], input=content).decode().strip()


def item_lines(key, item):
    lines = [f"### {item['title']}", "", f"`{key}` · {item['status']} · {item['jurisdiction']}",
             "", item["delta"], ""]
    for fact in item["facts"]:
        links = " · ".join(f"[{ref['record']}]({ref['url']})" for ref in fact["citations"])
        lines.append(f"- {fact['statement']} {links}")
    if item["unknowns"]:
        lines += ["", "Open questions", "", *["- " + question for question in item["unknowns"]]]
    return lines + ["", "Next check — " + item["next"], ""]


def project(evidence):
    run = evidence["run_id"]
    directory = WATCH / "runs" / run
    headings = [s for s in (PROJECT / ".agents/report-template.md").read_text().splitlines() if s]
    title, global_heading, canadian_heading, gaps_heading = headings
    report = [title, "", evidence["checkedAt"], ""]
    summary = [title, "", evidence["checkedAt"], ""]
    views = {}
    for stream, heading in zip(STREAMS, (global_heading, canadian_heading), strict=True):
        items = {k: v for k, v in evidence["items"].items() if v["stream"] == stream}
        report += [heading, ""]
        if not items:
            report += ["No item recorded for this stream in this run.", ""]
            continue
        section = []
        for key, item in items.items():
            section += item_lines(key, item)
            summary.append(f"- **{item['title']}** ({item['disposition']}) — {item['delta']}")
        report += section
        link = f"../../upstream-monitor/runs/{run}/evidence.json"
        page = [heading.replace("## ", "# ", 1), "", f"[Run evidence]({link}) · {run}", "", *section]
        views[PROJECT / stream / "watch" / f"{run}.md"] = markdown(page)
    report += [gaps_heading, ""]
    for gap in evidence["coverageGaps"]:
        report.append(f"- **{gap['source']} / {gap['channel']}** — {gap['reason']} Next check — {gap['next']}")
    if not evidence["coverageGaps"]:
        report.append("No coverage gaps recorded for this run.")
    summary += ["", f"Recorded coverage gaps — {len(evidence['coverageGaps'])}. [Full report](report.md)"]
    artifacts = {"report.md": markdown(report), "summary.md": markdown(summary), "evidence.json": encode(evidence)}
    manifest = dict(apiVersion="factory.upstream-monitor.run-bundle/v3", kind="UpstreamMonitorRunBundle",
                    profile_id=evidence["profile_id"], run_id=run, authority_revision=evidence["authority_revision"],
                    subject_revision=evidence["authority_revision"], export_unit="directory",
                    terminal_state="coverage_gap" if evidence["coverageGaps"] else "terminal_success",
                    qualification_state="observation_only", artifacts=[
                        dict(kind=Path(name).stem, filename=name, gitBlobSHA=blob(body),
                             mediaType="application/json" if name.endswith(".json") else "text/markdown")
                        for name, body in artifacts.items()])
    pointer = dict(apiVersion="factory.upstream-monitor.latest-run/v2", kind="LatestUpstreamMonitorRun",
                   profile_id=evidence["profile_id"], run_id=run, authority_revision=evidence["authority_revision"],
                   bundle_path=str(directory), manifest_path=str(directory / "manifest.json"))
    vet(manifest, "#Manifest")
    vet(pointer, "#Pointer")
    return {**{directory / k: v for k, v in artifacts.items()}, **views,
            directory / "manifest.json": encode(manifest)}, pointer


def markdown(lines):
    return ("\n".join(lines).rstrip() + "\n").encode()


def checked_run(evidence):
    vet(evidence, "#RunEvidence")
    run = evidence["run_id"]
    previous = evidence["previous_run"]
    checked = datetime.fromisoformat(evidence["checkedAt"]).astimezone(timezone.utc)
    if checked.strftime("%Y%m%dT%H%M%SZ") != run or (previous and previous >= run):
        raise ValueError("run ID must match the UTC check time and follow its predecessor")
    return project(evidence)


def execute(path, check):
    latest = read_json(POINTER) if POINTER.exists() else None
    if latest:
        vet(latest, "#Pointer")
    if check:
        if not latest:
            raise ValueError("latest pointer missing")
        path = Path(latest["bundle_path"]) / "evidence.json"
    evidence = read_json(path)
    files, pointer = checked_run(evidence)
    current = latest["run_id"] if latest else None
    if check or current == evidence["run_id"]:
        if latest != pointer or any(p.read_bytes() != data for p, data in files.items()):
            raise ValueError("publication differs from its sealed projection")
        return
    if evidence["previous_run"] != current:
        raise ValueError("stale comparison baseline; reacquire against the latest run")
    if current:
        # A new pointer must never obscure a corrupted or partially published predecessor.
        execute(None, True)
    for p, data in files.items():
        if p.exists() and p.read_bytes() != data:
            raise ValueError(f"immutable path already differs: {p}")
    for p, data in files.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        if not p.exists():
            p.write_bytes(data)
    with tempfile.NamedTemporaryFile(dir=WATCH, delete=False) as handle:
        handle.write(encode(pointer))
    os.replace(handle.name, POINTER)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("evidence", nargs="?", type=Path)
    group.add_argument("--check", action="store_true")
    args = parser.parse_args()
    lock = subprocess.check_output(["git", "rev-parse", "--git-path", "cyber-watch.lock"], text=True).strip()
    with open(lock, "a") as handle:
        fcntl.flock(handle, fcntl.LOCK_EX)
        execute(args.evidence, args.check)
