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
run_id: 20260630T045510Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: cfead68e5d3984b247cf0758e3e53b19165de848
workspace_version: 0.0.0
previous_recorded_head: 80f54d1266b4571ef649e7e5ecc382dd4e670937
change_since_previous_evidence: ahead-by-3
changed_files_since_previous_evidence: 9
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: 8f86689795ac656373b3291eb38513de8fa2259d
relation_to_main: diverged-from-current-main; ahead-by-1; behind-by-1
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.31
channel_relation: distinct-from-main
change_since_previous_evidence: advanced-from-0.143.0-alpha.29-to-0.143.0-alpha.31
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: safety-buffering TUI prompt lifecycle and Help Center action

```text
id: openai/codex#30490/openai/codex#30491
upstream_repo: openai/codex
kind: commit/merged-pr-evidence
status: admitted
severity: high
classes: ui, safety-surface, adapter
channels: main
refs:
- 850da19dc4e12827b6dbe991d59cffafd4d032ec
- 9d13291955e6261e579466b67e48ff2dbe01993a
- openai/codex#30490
- openai/codex#30491
```

Impact: upstream changed safety-buffering UI behavior and copy. The prompt now remains visible while a safety-buffered turn is active, clears when the turn completes, and exposes a Learn more action. Bio/Cyber safety block copy and Trusted Access URLs were also refreshed.

Local reason: this intersects the declared contract surface because safety-buffering and safety-access events are user-facing policy/protocol projections across app-server/TUI surfaces. Local report, adapter, or UI projection contracts that encode safety-buffering prompt lifecycle, retry semantics, or safety/help URLs may be stale.

Suggested local targets:

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
```

### main: Rendezvous WebSocket Nagle behavior disabled

```text
id: openai/codex#30269
upstream_repo: openai/codex
kind: commit/merged-pr-evidence
status: admitted
severity: high
classes: transport, exec-server, latency
channels: main
refs:
- cfead68e5d3984b247cf0758e3e53b19165de848
- openai/codex#30269
```

Impact: upstream changed exec-server Rendezvous WebSocket connection setup to pass `disable_nagle=true` for both executor and harness connection paths, while keeping signed URL, protocol, and connection flow unchanged.

Local reason: this intersects the declared contract surface because the exec-server transport behavior affects adapter/runtime assumptions for latency-sensitive relay and JSON-RPC frames. It does not add a feature flag, rollout schema, or new path variant.

Suggested local targets:

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
```

### latest-alpha-cli: alpha release channel advanced to 0.143.0-alpha.31

```text
id: latest-alpha-cli-release-0.143.0-alpha.31
upstream_repo: openai/codex
kind: branch/ref-evidence
status: admitted
severity: high
classes: release, alpha-channel
channels: latest-alpha-cli
refs:
- 8f86689795ac656373b3291eb38513de8fa2259d
```

Impact: `latest-alpha-cli` advanced from the previously recorded alpha `0.143.0-alpha.29` to `0.143.0-alpha.31`. The branch remains a release-only evidence channel whose delta from current `main` is `codex-rs/Cargo.toml` workspace version metadata.

Local reason: this intersects the declared monitor surface only as a distinct channel/version observation. It must not be collapsed into `main`, and alpha evidence must not be used as main evidence.

## Notes

### main: issue-labeler AWS Bedrock update

```text
id: openai/codex#30607
upstream_repo: openai/codex
kind: commit/merged-pr-evidence
status: admitted
severity: note
classes: repo-automation, labels
channels: main
refs:
- 4808c162eeb767b389f13b7cb2730f32c8563dba
- openai/codex#30607
```

Impact: upstream issue labeler gained AWS Bedrock-specific label behavior.

Local reason: supporting evidence only. This is outside the immediate Codex runtime/contract-surface unless local issue automation mirrors upstream label taxonomy.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260630T045510Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260630T045510Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface that explicitly admit report/evidence publication.

## Control action

```text
action: publish-contract-local-new-main-and-alpha-impact-run-and-latest-report
reason: upstream main advanced by 3 commits with safety-buffering UI and exec-server transport impacts; latest-alpha-cli advanced to 0.143.0-alpha.31 as a distinct alpha evidence channel
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
