# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_no_new_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260628T165523Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: bdd282f3bbd55df3a869a5438519cd948c134d4d
workspace_version: 0.0.0
previous_recorded_head: bdd282f3bbd55df3a869a5438519cd948c134d4d
change_since_previous_evidence: none
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: e4198a095c36a9f8f703b61be900f66df85e0984
relation_to_main: ahead-by-1
changed_files_from_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.29
channel_relation: distinct-from-main
change_since_previous_evidence: none
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No new critical upstream impact was admitted in this run.

Previously recorded critical items remain in the latest evidence baseline:

```text
- openai/codex#30292-#30296 — MCP lifecycle coordination stack
- openai/codex#30282 / #30283 / #30188 — canonical TurnItem rollout lifecycle stack
```

## High

No new high upstream impact was admitted in this run.

Previously recorded high items remain in the latest evidence baseline:

```text
- openai/codex#29691 — marketplace source policy runtime enforcement
- openai/codex#30384 — app-server currentTime/read timeout increase
- openai/codex#30327 — stable synthesized call output IDs
- openai/codex#30314 — structured app-server JSON shutdown logs
- latest-alpha-cli — CLI alpha version channel
```

## Notes

No new note-level upstream impact was admitted in this run.

Previously recorded note items remain in the latest evidence baseline:

```text
- openai/codex#27999 — image generation error history
- openai/codex#27249 / #27968 — session segmentation and rollout reference histories
- openai/codex#27815 / #27824 / #27836 — pending environment lifecycle
```

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No new local target update was admitted because both observed upstream evidence channels match the prior recorded heads.

## Suggested local targets

```text
contracts/upstream-monitor/codex/contract-surface/AGENTS.md
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
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
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/public.cue
```

Publication admission observed:

```text
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260628T165523Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260628T165523Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface that explicitly admit report/evidence publication.

## Control action

```text
action: publish-contract-local-no-new-impact-run-and-latest-report
reason: upstream evidence from main and latest-alpha-cli resolved to the same channel heads recorded in the previous evidence artifact
next_state: continue scheduled observation; align contract-surface AGENTS initial-gate text with the admitted Z4 report publication slice
```
