# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_main_and_alpha_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260701T045517Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: db887d03e1f907467e33271572dffb73bceecd6b
workspace_version: 0.0.0
previous_recorded_head: 020828170fb2224f0d7a7a243a1f7d21cc3df5ee
change_since_previous_evidence: ahead-by-1
changed_files_since_previous_evidence: 1
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: 27e66837feac06197c7ad99dc53b3e27fbccd917
relation_to_main: ahead-by-1; behind-by-0
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.32
channel_relation: distinct-from-main
change_since_previous_evidence: advanced-from-0.143.0-alpha.31-to-0.143.0-alpha.32
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: websocket full request trace removed

```text
id: openai/codex#30757
upstream_repo: openai/codex
kind: commit/merged-pr-evidence
status: admitted
severity: high
classes: api, logging, privacy-surface, websocket
channels: main
refs:
- db887d03e1f907467e33271572dffb73bceecd6b
- openai/codex#30757
```

Impact: upstream removed a `trace!("websocket request: {request_text}")` statement and the corresponding `tracing::trace` import from `codex-rs/codex-api/src/endpoint/responses_websocket.rs`.

Local reason: this intersects the declared contract surface because websocket request logging is an adapter-observable protocol/runtime surface. Local evidence, report, privacy, logging, or trace expectations that assume full websocket request text can appear in traces may be stale.

Suggested local targets:

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
```

## Notes

### latest-alpha-cli: alpha channel advanced to 0.143.0-alpha.32

```text
id: latest-alpha-cli-release-0.143.0-alpha.32
upstream_repo: openai/codex
kind: branch/ref-evidence
status: admitted
severity: note
classes: release, alpha-channel
channels: latest-alpha-cli
refs:
- 27e66837feac06197c7ad99dc53b3e27fbccd917
```

Impact: `latest-alpha-cli` advanced to workspace version `0.143.0-alpha.32`. Its delta from current `main` is limited to `codex-rs/Cargo.toml` workspace version metadata.

Local reason: this is a distinct channel/version observation only. Alpha evidence must not be used as main evidence.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/public.cue
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
```

## Issue updates

No issue updates were performed.

Reason: `upstreamCodexPublicationPlan.issueTargets` is currently `{}`, so no concrete issue mutation target is admitted for this run.

## Validation notes

Static contract reads performed through the GitHub App:

```text
contracts/upstream-monitor/AGENTS.md
contracts/upstream-monitor/codex/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
```

Publication admission observed from the previous latest evidence/publication projection:

```text
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260701T045517Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260701T045517Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface that explicitly admit report/evidence publication, as recorded by prior latest evidence.

## Control action

```text
action: publish-contract-local-new-main-and-alpha-impact-run-and-latest-report
reason: upstream main advanced by 1 commit removing websocket full-request trace logging; latest-alpha-cli advanced to 0.143.0-alpha.32 as a distinct alpha evidence channel
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
