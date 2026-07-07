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
run_id: 20260707T045606Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: cca16a10878202cb2f6e9666b6b4330329ea7e65
workspace_version: 0.0.0
previous_recorded_head: 8917244f7dcc1a945f3d5eba3dea53f6dbb16349
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 35
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
workspace_version: 0.143.0-alpha.38
previous_recorded_workspace_version: 0.143.0-alpha.36
change_since_previous_evidence: advanced by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: canonical tool item compatibility layer

```text
id: openai-codex-main-b9b934e-canonical-tool-items-legacy-mapping
channel: main
commit: b9b934e99b57aa1908a7cd83adee9faf6d0b8f7d
upstream_pr: openai/codex#31296
impact: high
surface: protocol items, legacy event mapping, rollout trace, dynamic tools, multi-agent events
```

Upstream `main` adds `TurnItem` to legacy `EventMsg` mappings for `CommandExecution`, `DynamicToolCall`, `CollabAgentToolCall`, and `SubAgentActivity`. The canonical item lifecycle is now the source of truth while raw-event consumers continue to receive begin/end-style compatibility events. This intersects local protocol/event-shape contracts and any fixtures that assume legacy events are the only runtime event form.

Evidence anchors:

```text
- protocol/src/legacy_events.rs adds mappings from canonical TurnItem variants to legacy EventMsg forms.
- core/src/codex_thread.rs records mapped legacy events in rollout trace while emitting legacy compatibility events.
- commit b9b934e99b57aa1908a7cd83adee9faf6d0b8f7d message: refactor(protocol): map canonical tool items to legacy events (#31296)
```

Local contract targets to review:

```text
- generated protocol item schemas and legacy-event compatibility projections
- fixtures that bind command/dynamic/multi-agent tool behavior only to legacy begin/end events
- rollout trace assertions for tool-runtime events
```

### main: canonical command execution item producer

```text
id: openai-codex-main-cca16a1-canonical-command-execution-items
channel: main
commit: cca16a10878202cb2f6e9666b6b4330329ea7e65
upstream_pr: openai/codex#31297
impact: high
surface: command execution lifecycle, app-server v2 item stream, shell tool events, user shell commands
```

Command execution now emits canonical `TurnItem::CommandExecution` lifecycle from shell tool and user `/shell` paths. App-server v2 consumes canonical command items directly and suppresses duplicate legacy command begin/end notifications while preserving a unified-exec carveout through `TerminalInteraction`.

Evidence anchors:

```text
- app-server bespoke event handling now processes ItemStarted/ItemCompleted command items and suppresses deprecated ExecCommandBegin/ExecCommandEnd for v2.
- core user-shell and shell runtime paths emit TurnItem::CommandExecution started/completed items.
- commit cca16a10878202cb2f6e9666b6b4330329ea7e65 message: feat(core): emit canonical command execution items (#31297)
```

Local contract targets to review:

```text
- command execution item schema/type generation
- app-server v2 item lifecycle contracts
- negative fixtures for duplicate command lifecycle emission
- unified-exec exception handling
```

### main: sequential cutoff reasoning summaries

```text
id: openai-codex-main-775ef7d-sequential-cutoff-reasoning-summaries
channel: main
commit: 775ef7dcc7d50069e759f3e11454f412a3e39d95
upstream_pr: openai/codex#31306
impact: high
surface: response stream options, reasoning summary events, feature flags, websocket/http request shape
```

OpenAI-provider requests can now send `stream_options.reasoning_summary_delivery = sequential_cutoff`, including WebSocket request conversion, and response parsing now admits `response.reasoning_summary_text.done` as `ReasoningSummaryDone` with `item_id`, `text`, and `summary_index`. This extends the prior reasoning-summary item-id surface into summary completion/cutoff semantics.

Evidence anchors:

```text
- codex-api common request types add StreamOptions and ReasoningSummaryDelivery::SequentialCutoff.
- SSE response parsing adds ResponseEvent::ReasoningSummaryDone for response.reasoning_summary_text.done.
- core ModelClient sends stream_options when the concurrent reasoning summaries feature is enabled for OpenAI.
- commit 775ef7dcc7d50069e759f3e11454f412a3e39d95 message: [codex] Support sequential cutoff reasoning summaries (#31306)
```

Local contract targets to review:

```text
- response-event schemas for response.reasoning_summary_text.done
- stream_options request schemas for HTTP and WebSocket
- reasoning summary completion/cancellation fixtures
- feature-gated provider-specific request-shape constraints
```

### main: Responses API system-proxy routing

```text
id: openai-codex-main-6afcf26-responses-api-system-proxy-routing
channel: main
commit: 6afcf26d5d76c2f88b9096caa758931ffa673745
upstream_pr: openai/codex#31335
impact: high
surface: HTTP client factory, proxy policy, Responses API transport, config feature resolution
```

Responses and remote-compaction HTTP calls now route through a required `HttpClientFactory` resolved from effective config, with `OutboundProxyPolicy::{ReqwestDefault, RespectSystemProxy}` and `ClientRouteClass::Api`. This changes transport construction from optional/fallback behavior to an explicit config-derived invariant.

Evidence anchors:

```text
- core ModelClient now requires an HttpClientFactory and builds Responses transports from route-aware policy.
- Config exposes http_client_factory() from effective respect_system_proxy state.
- commit 6afcf26d5d76c2f88b9096caa758931ffa673745 message: core: route Responses API through system proxy (#31335)
```

Local contract targets to review:

```text
- config/schema surfaces for respect_system_proxy and transport factory invariants
- request adapter contracts that assume default reqwest proxy behavior
- no-implicit-default tests for outbound proxy policy resolution
```

### alpha: release-channel version advance

```text
id: openai-codex-alpha-0.143.0-alpha.38-release-channel-version
channel: latest-alpha-cli
commit: unresolved
impact: high
surface: release channel tracking, alpha evidence channel, workspace package version
```

`latest-alpha-cli` advanced by concrete branch-content evidence from `0.143.0-alpha.36` to `0.143.0-alpha.38`. The branch remains distinct from `main`; connector compare reports it one commit ahead and three behind current `main`, with only `codex-rs/Cargo.toml` changed from current `main`.

Evidence anchors:

```text
- latest-alpha-cli codex-rs/Cargo.toml [workspace.package] version = "0.143.0-alpha.38".
- compare main..latest-alpha-cli: diverged; ahead_by=1; behind_by=3; changed file codex-rs/Cargo.toml.
```

Local contract targets to review:

```text
- release-channel state tracking for alpha versions
- unresolved exact-head SHA handling for latest-alpha-cli
- no-collapse invariant between alpha and main evidence channels
```

## Notes

No note-only impacts admitted in this run.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
- Add canonical TurnItem to legacy EventMsg compatibility fixtures for command, dynamic tool, collab-agent, and sub-agent activity items.
- Model command execution as canonical app-server v2 item lifecycle, with duplicate legacy begin/end suppression as a no-widening expectation.
- Add response.reasoning_summary_text.done schema/fixture coverage, including item_id + summary_index constraints.
- Model stream_options.reasoning_summary_delivery = sequential_cutoff as feature/provider-gated request shape.
- Add config-derived HttpClientFactory/proxy policy invariants for Responses API transports.
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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260707T045606Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260707T045606Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for configured/known terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` still return 404 via the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

Caveat: `latest-alpha-cli` exact branch head SHA was not exposed by connector responses. It is kept unresolved; only concrete branch-content evidence and the `0.143.0-alpha.38` version are recorded.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: new admitted upstream impact on main and latest-alpha-cli; recurring observation run still admitted report/evidence publication
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
