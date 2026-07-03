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
run_id: 20260703T045247Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: da4c8ca57d40b074bdc1b5b1218851100150c56b
workspace_version: 0.0.0
previous_recorded_head: 6ff670bd030f7f94ce956d8a176c226deb427666
change_since_previous_evidence: ahead-by-5
changed_files_since_previous_evidence: 35
```

### latest-alpha-cli

```text
status: resolved
repo: openai/codex
ref: latest-alpha-cli
head_commit: 5969673277a19410d0dd84fc607d65095703b90d
relation_to_main: ahead-by-1; behind-by-0
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.35
channel_relation: distinct-from-main
change_since_previous_evidence: advanced-from-0.143.0-alpha.33-to-0.143.0-alpha.35
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### openai/codex#30493 — configurable multi-agent mode hint text

```text
channels: main
impact: high
classes: contract-update, config-schema, app-server-schema, multi-agent-policy, prompt-contract-surface
surface: codex-rs/core/src/session/multi_agents.rs, codex-rs/protocol/src/config_types.rs, codex-rs/app-server-protocol/schema/json/*, codex-rs/core/config.schema.json
```

Upstream added `features.multi_agent_v2.multi_agent_mode_hint_text` as a configurable delegation-policy body for Multi-Agent V2. When the setting is present, including an empty string, the effective mode becomes `custom` and replaces the built-in explicit-only/proactive policies. When absent, existing effort-derived behavior remains: Ultra maps to proactive, other efforts map to explicit-request-only.

The `MultiAgentMode` contract changed shape: legacy `none` is now deserialized as `Custom("")`, while current variants are `Custom(String)`, `ExplicitRequestOnly`, and `Proactive`. Generated app-server and config schemas moved from a string enum including `none` to a schema shape that admits either built-in string values or an object-style custom value.

Local interpretation: any CUE/schema/projection surface that models Codex multi-agent mode must not treat `none` as an active current enum. It should model `custom` as a policy-text-carrying mode, preserve empty-string override semantics, and keep compatibility handling for legacy serialized `none` as `custom("")` when reading existing state.

## Notes

The `main` channel advanced by five commits from the previous recorded evidence head. The admitted surface intersection is concentrated in multi-agent V2 policy selection, configuration schema, app-server schema, and turn-context durability/comparison semantics.

The `latest-alpha-cli` channel advanced independently to `0.143.0-alpha.35`. Relative to current `main`, it is ahead by one release-version commit and changes only `codex-rs/Cargo.toml`. Alpha evidence is therefore a release-channel state update, not an additional contract-surface change beyond the current `main` evidence.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260703T045247Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260703T045247Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` were previously unresolved via the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

## Control action

```text
action: publish-contract-local-new-impact-run-and-latest-report
reason: upstream main advanced from the previous recorded evidence and latest-alpha-cli advanced as a distinct release channel
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
