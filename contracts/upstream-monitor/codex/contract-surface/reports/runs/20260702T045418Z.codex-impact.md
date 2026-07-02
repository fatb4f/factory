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
run_id: 20260702T045418Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: 129ea2aaf5fb426d8ba683ee53f290742f41dd31
workspace_version: 0.0.0
previous_recorded_head: db887d03e1f907467e33271572dffb73bceecd6b
change_since_previous_evidence: ahead-by-4
changed_files_since_previous_evidence: 24
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: ad4928ca532f4b27586e8a32f90276974aeb49fb
relation_to_main: ahead-by-1; behind-by-0
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.33
channel_relation: distinct-from-main
change_since_previous_evidence: diverged-from-previous-alpha; advanced-to-release-0.143.0-alpha.33
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### openai/codex#30867 / #30872 — multi-agent v2 communication lifecycle and logging surface

```text
channels: main
impact: high
classes: contract-update, observability, multi-agent-v2, telemetry-shape
surface: codex-rs/core/src/agent/*, codex-rs/core/src/agent_communication.rs, multi-agent handlers/tests
```

Upstream consolidated multi-agent v2 outbound communication paths through `submit_inter_agent_communication`, then added structured lifecycle logging for spawn, message, follow-up, and result communications. This affects the local contract-surface view because communication submission, context pairing, and observable event shape are now upstream protocol/runtime surface.

Local interpretation: adapters or contracts that reason about subagent spawn/message/result flows should treat communication context and lifecycle event shape as explicit upstream evidence, not as an inferred side channel.

### openai/codex#30643 — bounded Rendezvous WebSocket liveness

```text
channels: main
impact: high
classes: contract-update, remote-exec, websocket-liveness, reconnect-observability
surface: codex-rs/exec-server/src/noise_relay/*, codex-rs/exec-server/src/relay.rs, codex-rs/exec-server/src/websocket_pong_watchdog.rs
```

Upstream added an explicit Pong deadline for established Noise Rendezvous WebSockets, bounded steady-state writes/event delivery, and classified executor disconnect reasons into reconnect metrics/logging. This affects the local contract-surface view because remote execution transport liveness is now enforced by a concrete watchdog path rather than implicit TCP timeout behavior.

Local interpretation: remote-exec monitors should distinguish this liveness contract from prior Nagle/latency work and track disconnect reason taxonomy separately from generic transport failure.

### latest-alpha-cli release channel — 0.143.0-alpha.33

```text
channels: latest-alpha-cli
impact: high
classes: release-channel, alpha-version, distinct-evidence-channel
surface: codex-rs/Cargo.toml
```

The alpha channel advanced to `0.143.0-alpha.33` and remains exactly one commit ahead of current `main`, with only `codex-rs/Cargo.toml` changed relative to `main`.

Local interpretation: this is alpha release evidence only. It does not collapse into `main` and must not be used as main-channel contract evidence.

## Notes

The `main` channel advanced by four commits from the previous recorded evidence head. The admitted surface intersection is concentrated in multi-agent communication lifecycle/logging and remote exec-server Rendezvous WebSocket liveness.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260702T045418Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260702T045418Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

## Control action

```text
action: publish-contract-local-new-impact-run-and-latest-report
reason: upstream main and latest-alpha-cli advanced from the previous recorded evidence; channels remain distinct
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
