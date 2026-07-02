# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260702T165315Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: 6ff670bd030f7f94ce956d8a176c226deb427666
workspace_version: 0.0.0
previous_recorded_head: 129ea2aaf5fb426d8ba683ee53f290742f41dd31
change_since_previous_evidence: ahead-by-1
changed_files_since_previous_evidence: 3
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: ad4928ca532f4b27586e8a32f90276974aeb49fb
relation_to_main: diverged; ahead-by-1; behind-by-1
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.33
channel_relation: distinct-from-main
change_since_previous_evidence: unchanged
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### openai/codex#30883 — per-request TTFT completion telemetry

```text
channels: main
impact: high
classes: contract-update, observability, telemetry-shape, response-stream-lifecycle
surface: codex-rs/core/src/client.rs, codex-rs/otel/src/events/session_telemetry.rs, codex-rs/core/tests/suite/otel.rs
```

Upstream added a per-request `ttft_ms` field to completion telemetry. Timing starts when each mapped Responses stream begins, latches on the first `response.output_item.added`, including empty hidden-reasoning items, and is emitted on the existing `codex.sse_event` / `response.completed` telemetry record.

Local interpretation: contracts or adapters that consume Codex telemetry should treat `ttft_ms` as a per-inference-request response stream lifecycle field, not as turn-level TTFT and not as a server raw-token timestamp. This is a telemetry surface update and should remain distinct from the earlier removal of full WebSocket request-text tracing.

## Notes

The `main` channel advanced by one commit from the previous recorded evidence head. The admitted surface intersection is concentrated in telemetry schema/semantics for response stream lifecycle and hidden-reasoning start approximation.

The `latest-alpha-cli` channel did not advance from the previous recorded alpha evidence. Relative to current `main`, it is now diverged because `main` advanced independently while alpha still carries only the workspace version change in `codex-rs/Cargo.toml`.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260702T165315Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260702T165315Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` returned 404 in this run. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

## Control action

```text
action: publish-contract-local-new-impact-run-and-latest-report
reason: upstream main advanced from the previous recorded evidence; latest-alpha-cli remains distinct and unchanged
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
