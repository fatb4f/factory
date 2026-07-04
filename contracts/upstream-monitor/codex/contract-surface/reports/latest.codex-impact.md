# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_main_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260704T045454Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: 98d28aab54ed86714901b6619400598598876dd0
workspace_version: 0.0.0
previous_recorded_head: da4c8ca57d40b074bdc1b5b1218851100150c56b
change_since_previous_evidence: ahead-by-4
changed_files_since_previous_evidence: 26
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: 5969673277a19410d0dd84fc607d65095703b90d
relation_to_main: diverged; ahead-by-1; behind-by-4
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.35
channel_relation: distinct-from-main
change_since_previous_evidence: identical
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### openai/codex main: plugin availability protocol field

```text
impact: contract-update
class: app-server-protocol-schema
severity: high
channel: main
```

`PluginSummary` now includes an `availability` field backed by the `PluginAvailability` enum. The enum exposes `AVAILABLE` and `DISABLED_BY_ADMIN`, with `ENABLED` accepted as an alias for backend compatibility. This changes the app-server v2 plugin list/read/share response contract surface and generated JSON/TypeScript schemas.

Evidence paths observed in the `main` delta include:

```text
codex-rs/app-server-protocol/src/protocol/v2/plugin.rs
codex-rs/app-server-protocol/schema/json/codex_app_server_protocol.schemas.json
codex-rs/app-server-protocol/schema/json/codex_app_server_protocol.v2.schemas.json
codex-rs/app-server-protocol/schema/json/v2/PluginInstalledResponse.json
codex-rs/app-server-protocol/schema/json/v2/PluginListResponse.json
codex-rs/app-server-protocol/schema/json/v2/PluginReadResponse.json
codex-rs/app-server-protocol/schema/json/v2/PluginShareListResponse.json
codex-rs/app-server-protocol/schema/typescript/v2/PluginSummary.ts
```

## Notes

### Feedback request/auth tag expansion

```text
impact: telemetry-surface-update
class: feedback-diagnostics
severity: note
channel: main
```

The feedback crate now declares structured request/auth feedback tag fields and emits them through a dedicated `feedback_tags` tracing target, including auth header attachment/name, auth mode, retry/recovery flags, request IDs, Cloudflare Ray, auth errors, follow-up status, and auth environment buckets. This is observability-facing and does not mutate local contract authority.

### Release-note generator cleanup

```text
impact: release-process-documentation-cleanup
class: non-contract-cleanup
severity: note
channel: main
```

`cliff.toml` was removed because upstream release notes are now built from tagged commit messages and the old TypeScript CLI changelog tooling is no longer referenced.

### Installer script/test changes

```text
impact: installer-surface-update
class: install-script-maintenance
severity: note
channel: main
```

Install script changes and a new `scripts/install/test_install_sh.py` were observed. No local contract mutation was admitted from this evidence.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260704T045454Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260704T045454Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` remain unresolved via the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

## Control action

```text
action: publish-contract-local-main-impact-run-and-latest-report
reason: upstream main advanced by 4 commits; latest-alpha-cli unchanged but diverged from current main
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
