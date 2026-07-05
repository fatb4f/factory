# Codex contract-surface impact report

```text
apiVersion: factory.upstream-monitor.codex/v0
kind: CodexImpactReport
loop: codex-contract-surface
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
run_result: terminal_success_new_admitted_upstream_impact_with_validation_caveats
channels: main, latest-alpha-cli
run_id: 20260705T045440Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: be33f80bc65159c094ecd06bf155afa3061ce23d
workspace_version: 0.0.0
previous_recorded_head: 98d28aab54ed86714901b6619400598598876dd0
change_since_previous_evidence: ahead
changed_files_since_previous_evidence: 5
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: ahead-by-1; behind-by-0 from current main by connector compare
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.36
channel_relation: distinct-from-main
change_since_previous_evidence: advanced by branch content/version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### Safety-buffering response-event contract changed

```text
impact: safety-buffering response-event contract changed
class: contract-update, stream-event, safety-buffering, ui-routing
severity: high
channel: main, latest-alpha-cli
evidence: openai/codex@be33f80bc65159c094ecd06bf155afa3061ce23d
upstream: [codex] Read buffering metadata from response events (#31064)
```

`SafetyBuffering.faster_model` is no longer skipped during serialization. Response-event `safety_buffering` payloads now control buffering UI visibility and faster-model selection before header fallback. Header metadata remains a compatibility fallback when the event omits `faster_model`.

Changed surfaces:

```text
codex-rs/codex-api/src/common.rs
codex-rs/codex-api/src/endpoint/responses_websocket.rs
codex-rs/codex-api/src/safety_buffering.rs
codex-rs/codex-api/src/sse/responses.rs
codex-rs/core/tests/suite/safety_buffering.rs
```

Local contract implication: any contract/projection that models `SafetyBuffering`, stream event payloads, or buffering UI/faster-model routing should treat event payload fields as primary and response headers as fallback metadata.

### Alpha release version advanced

```text
impact: alpha release version advanced
class: release-channel, distinct-evidence-channel
severity: high
channel: latest-alpha-cli
evidence: latest-alpha-cli content at codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.36
```

`latest-alpha-cli` advanced from `0.143.0-alpha.35` to `0.143.0-alpha.36`. It remains distinct from `main`, with only `codex-rs/Cargo.toml` changed relative to current `main`. The exact branch head SHA was not exposed by the connector response and is recorded as unresolved rather than inferred.

## Notes

No note-only impacts admitted in this run.

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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260705T045440Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260705T045440Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for the configured terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` remain unresolved via the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

Caveat: `latest-alpha-cli` exact branch head SHA was not exposed by connector responses. It is kept unresolved; only concrete branch-content evidence and the `0.143.0-alpha.36` version are recorded.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: upstream main advanced and latest-alpha-cli version advanced while remaining a distinct evidence channel
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
