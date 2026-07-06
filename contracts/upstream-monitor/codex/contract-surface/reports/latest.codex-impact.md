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
run_id: 20260706T165617Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: 8917244f7dcc1a945f3d5eba3dea53f6dbb16349
workspace_version: 0.0.0
previous_recorded_head: be33f80bc65159c094ecd06bf155afa3061ce23d
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 3
behind_by: 0
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: diverged; ahead-by-1; behind-by-3 from current main
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.143.0-alpha.36
channel_relation: distinct-from-main
previous_recorded_workspace_version: 0.143.0-alpha.36
change_since_previous_evidence: unchanged by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: interleaved response-item and reasoning-summary lifecycle

```text
id: openai-codex-main-8917244-interleaved-response-items
channel: main
commit: 8917244f7dcc1a945f3d5eba3dea53f6dbb16349
upstream_pr: openai/codex#30876
impact: high
surface: response event mapping, reasoning summary streaming, TUI/event replay, turn-item lifecycle
```

Upstream `main` now preserves reasoning-summary `item_id` on `response.reasoning_summary_part.added` and `response.reasoning_summary_text.delta`, tracks streamed response items by ID, and supports reasoning summaries continuing after later items begin. This changes the local contract-relevant assumptions for response-item identity, interleaved stream ordering, and reasoning-summary event projection.

Evidence anchors:

```text
- codex-rs/codex-api/src/sse/responses.rs: ResponseEvent::ReasoningSummaryDelta and ReasoningSummaryPartAdded now carry item_id.
- codex-rs/core/src/session/turn.rs: reasoning summary deltas/section breaks are emitted by explicit streamed item_id rather than the prior active-item assumption.
- codex-rs/core/tests/suite/items.rs: upstream tests now exercise interleaved reasoning summary, function-call, and assistant-message items.
```

Local contract targets to review:

```text
- any response-event schema that models reasoning summary delta or reasoning section-break events
- event replay assumptions that bind reasoning deltas to the single current active item
- context/reasoning UI projections that assume non-interleaved reasoning and assistant output
- test fixtures for streamed item identity and interleaved output ordering
```

### main: plugin instructions move into world-state diff section

```text
id: openai-codex-main-8917244-plugin-instructions-world-state
channel: main
commit: 8917244f7dcc1a945f3d5eba3dea53f6dbb16349
impact: high
surface: plugin instructions, context fragments, world-state retained-fragment matching
```

Upstream `main` adds a `plugins_instructions` world-state section. Generic plugin usage guidance is now controlled as world-state diff/retained-fragment state, rather than only as an available-plugin instruction fragment. This intersects the local plugin/context-fragment contract surface because availability, retained-fragment matching, and previous-state snapshots now influence whether plugin instructions are re-rendered.

Evidence anchors:

```text
- codex-rs/core/src/context/world_state/mod.rs imports and exports PluginsInstructionsState.
- codex-rs/core/src/context/world_state/plugins_instructions.rs defines ID = "plugins_instructions", bool snapshots, legacy/retained fragment matching, and diff rendering through AvailablePluginsInstructions.
```

Local contract targets to review:

```text
- plugin instruction rendering contracts
- world-state section catalogues and generated schema/type surfaces
- retained-fragment/legacy-fragment matching fixtures
- no-widening tests around plugin availability and instruction rendering
```

## Notes

No note-only impacts admitted in this run.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
- Add/adjust CUE fixtures for response.reasoning_summary_* events carrying item_id.
- Add interleaving negative fixtures: reasoning summary delta for an unstreamed item_id must remain invalid/unhandled.
- Model plugin instructions as a world-state section, distinct from raw available-plugin instruction text.
- Add retained-fragment matcher expectations for plugin instructions.
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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260706T165617Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260706T165617Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for configured/known terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` remain unresolved via the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

Caveat: `latest-alpha-cli` exact branch head SHA was not exposed by connector responses. It is kept unresolved; only concrete branch-content evidence and the `0.143.0-alpha.36` version are recorded.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: new admitted upstream impact on main; recurring observation run still admitted report/evidence publication
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
