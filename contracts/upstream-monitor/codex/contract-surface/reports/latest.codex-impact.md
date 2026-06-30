# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_main_upstream_impact_alpha_unchanged_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260630T165352Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: 020828170fb2224f0d7a7a243a1f7d21cc3df5ee
workspace_version: 0.0.0
previous_recorded_head: cfead68e5d3984b247cf0758e3e53b19165de848
change_since_previous_evidence: ahead-by-1
changed_files_since_previous_evidence: 2
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: 8f86689795ac656373b3291eb38513de8fa2259d
relation_to_main: diverged-from-current-main; ahead-by-1; behind-by-2
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.31
channel_relation: distinct-from-main
change_since_previous_evidence: unchanged
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: safety access biological notice wording shortened

```text
id: openai/codex#30645
upstream_repo: openai/codex
kind: commit/merged-pr-evidence
status: admitted
severity: high
classes: ui, safety-surface, policy-copy
channels: main
refs:
- 020828170fb2224f0d7a7a243a1f7d21cc3df5ee
- openai/codex#30645
```

Impact: upstream changed the biological safety access block body text by removing the second sentence about researchers at approved organizations. The Trusted Access URL, Learn more URL, Cyber safety block body, and display/raw line structure remain unchanged.

Local reason: this intersects the declared contract surface because safety access block copy is a user-facing policy projection in the TUI history cell surface. Local report, UI snapshot, or adapter contracts that encode exact safety block text may be stale.

Suggested local targets:

```text
contracts/upstream-monitor/codex/contract-surface/report.cue
contracts/upstream-monitor/codex/contract-surface/publication.cue
contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
```

## Notes

### latest-alpha-cli: alpha channel unchanged

```text
id: latest-alpha-cli-release-0.143.0-alpha.31
upstream_repo: openai/codex
kind: branch/ref-evidence
status: admitted
severity: note
classes: release, alpha-channel
channels: latest-alpha-cli
refs:
- 8f86689795ac656373b3291eb38513de8fa2259d
```

Impact: `latest-alpha-cli` remains at workspace version `0.143.0-alpha.31`. Its delta from current `main` is still limited to `codex-rs/Cargo.toml` workspace version metadata.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260630T165352Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260630T165352Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface that explicitly admit report/evidence publication, as recorded by prior latest evidence.

## Control action

```text
action: publish-contract-local-new-main-impact-run-and-latest-report
reason: upstream main advanced by 1 commit with a safety access block wording change; latest-alpha-cli remained unchanged as a distinct alpha evidence channel
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
