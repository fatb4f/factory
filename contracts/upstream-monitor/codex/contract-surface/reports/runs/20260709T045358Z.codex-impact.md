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
run_id: 20260709T045358Z
```

## Channel resolution

### main

```text
status: resolved
repo: openai/codex
ref: main
head_commit: 3380969a29134630d56feb6218e8e8dcc5e8196d
workspace_version: 0.0.0
previous_recorded_head: a219b6fdb4e9f9655968adf20984916abc8b2290
change_since_previous_evidence: advanced
compare_status: ahead
ahead_by: 36
behind_by: 0
changed_files_count: 227 observed from connector compare file list
```

### latest-alpha-cli

```text
status: resolved-content; exact head sha unresolved through connector response
repo: openai/codex
ref: latest-alpha-cli
head_commit: unresolved
relation_to_main: ahead-by-1 from current main by connector compare
changed_files_from_current_main: codex-rs/Cargo.toml
workspace_version: 0.144.0-alpha.4
previous_recorded_workspace_version: 0.143.0
change_since_previous_evidence: advanced by concrete branch-content version evidence; exact ref sha unresolved
```

`latest-alpha-cli` remains a separate upstream evidence channel and is not collapsed into `main`.

## Critical

No critical impacts admitted in this run.

## High

### main: incremental thread-history change projection

```text
id: openai-codex-main-3380969-thread-history-change-projection
channel: main
commit: 3380969a29134630d56feb6218e8e8dcc5e8196d
impact: high
surface: app-server v2 thread history, TurnItemsView projection, rollout replay/resume
```

Upstream now exposes an incremental `ThreadHistoryChangeSet` path for rollout replay/current-turn handling. It records changed items, changed turns, and removed turn ids, coalesces repeated updates, and adds per-event/per-rollout-item change-producing handlers for resumed/rejoined running threads.

Evidence anchors:

```text
- codex-rs/app-server-protocol/src/protocol/thread_history.rs defines ThreadHistoryItemChange, ThreadHistoryTurnChange, ThreadHistoryChangeSet, and coalescing accumulator.
- ThreadHistoryBuilder now exposes handle_event_with_changes, handle_rollout_item_with_changes, and handle_rollout_items_with_changes.
```

Local contract targets to review:

```text
- incremental thread-history delta schema and ordering/coalescing invariants
- rollback removal semantics for turn/item change projections
- resumed running-thread projection fixtures
```

### main: exec-server JSON-RPC admission, timeout, and disconnect semantics

```text
id: openai-codex-main-3380969-exec-server-rpc-limits
channel: main
commit: 3380969a29134630d56feb6218e8e8dcc5e8196d
impact: high
surface: exec-server protocol, JSON-RPC client semantics, cleanup-call admission
```

Upstream now bounds regular in-flight executor RPC calls, reserves a cleanup-call lane, adds call timeouts, drains pending calls on transport close, and preserves ordered response-vs-disconnect handling. Requests now also carry W3C trace context through the JSON-RPC request payload.

Evidence anchors:

```text
- codex-rs/exec-server/src/rpc.rs defines MAX_IN_FLIGHT_REGULAR_CALLS, RESERVED_CLEANUP_CALLS, PendingRequestLimitExceeded, TimedOut, and cleanup-call admission behavior.
- call_inner registers pending requests atomically with disconnect checks, removes timed-out requests, and emits JSONRPCRequest.trace.
```

Local contract targets to review:

```text
- RPC pending-request limit/error schema
- cleanup admission lane and close-on-exhaustion behavior
- timeout/disconnect ordering invariants and trace propagation
```

### main: realtime conversation protocol surface expansion

```text
id: openai-codex-main-3380969-realtime-conversation-protocol
channel: main
commit: 3380969a29134630d56feb6218e8e8dcc5e8196d
impact: high
surface: realtime conversation protocol, generated TS/JSON schema, handoff/noop/audio items
```

Upstream expanded realtime protocol structures with output modality, transport/version overrides, typed voice sets/defaults, audio-frame item ids, response lifecycle events, handoff/noop request payloads, and conversation item added/done events.

Evidence anchors:

```text
- codex-rs/protocol/src/protocol.rs defines ConversationStartParams transport/version/output fields and RealtimeOutputModality/RealtimeVoice/RealtimeVoicesList.
- RealtimeEvent now includes response created/cancelled/done, ConversationItemAdded, ConversationItemDone, HandoffRequested, and NoopRequested shapes.
```

Local contract targets to review:

```text
- realtime protocol generated types and discriminants
- voice-list/default compatibility constraints
- handoff/noop/audio item id invariants
```

### main: route-aware remote model discovery telemetry

```text
id: openai-codex-main-3380969-models-endpoint-route-aware-telemetry
channel: main
commit: 3380969a29134630d56feb6218e8e8dcc5e8196d
impact: high
surface: model provider discovery, HTTP client factory routing, auth telemetry
```

Upstream routes `/models` discovery through a request-time HTTP client factory and records auth-mode/header/env/agent-identity telemetry for remote model discovery requests.

Evidence anchors:

```text
- codex-rs/model-provider/src/models_endpoint.rs builds transport through ModelsTransportBuilder and build_default_reqwest_client_for_route_async(..., ClientRouteClass::Api).
- ModelsRequestTelemetry emits auth header/env/mode, agent id/task id, request id, cf-ray, and auth error fields.
```

Local contract targets to review:

```text
- model discovery transport-route contract
- auth telemetry schema and optionality
- remote model refresh timeout/error projection
```

### main: external-agent session import rollout materialization

```text
id: openai-codex-main-3380969-external-agent-import-rollout
channel: main
commit: 3380969a29134630d56feb6218e8e8dcc5e8196d
impact: high
surface: external agent session import, rollout persistence, thread title/summary metadata
```

Upstream import logic now materializes external conversations as rollout items with explicit turn start/complete, user/assistant event messages, response items, token-count estimates, imported-session marker, content hash, and title fallback selection.

Evidence anchors:

```text
- codex-rs/external-agent-sessions/src/export.rs reads imported session content SHA, selects title candidates, and emits ImportedExternalAgentSession rollout_items.
- rollout_items_from_messages emits TurnStarted, UserMessage, ResponseItem, AgentMessage, TokenCount, and TurnComplete records.
```

Local contract targets to review:

```text
- external import rollout schema and marker semantics
- token-count estimate admissibility
- imported title/fallback/content-hash metadata projection
```

## Alpha channel impact

`latest-alpha-cli` advanced by concrete branch-content evidence from `0.143.0` to `0.144.0-alpha.4`. Connector compare against current `main` reports a single-file delta: `codex-rs/Cargo.toml`. Exact alpha branch head SHA remains unresolved through connector response and is not inferred.

## No local action

No issue updates were performed because `upstreamCodexPublicationPlan.issueTargets` is currently `{}`.

No contract authority was changed from upstream evidence.

No local contract mutation was performed; only admitted report/evidence projections were written.

## Suggested local targets

```text
- Add incremental ThreadHistoryChangeSet projection fixtures for item/turn/remove deltas.
- Model exec-server RPC pending limit, timeout, cleanup lane, and disconnect-drain invariants.
- Update realtime conversation generated type/schema fixtures for output modality, voice lists, response lifecycle, handoff/noop, and conversation item events.
- Add route-aware model discovery/auth telemetry contract checks.
- Add external-agent import rollout fixtures including imported marker, token estimate, title fallback, and content hash.
- Keep latest-alpha-cli version evidence distinct even when only Cargo.toml differs from main.
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
report run path: contracts/upstream-monitor/codex/contract-surface/reports/runs/20260709T045358Z.codex-impact.md
report latest path: contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md
evidence run path: contracts/upstream-monitor/codex/contract-surface/evidence/runs/20260709T045358Z.codex-impact.report.json
evidence latest path: contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json
issueTargets: {}
```

CUE commands were not executed in-repo by this run because the GitHub App adapter exposes repository content read/write operations, not a repo shell.

Expected local validation remains: vet the upstream-monitor CUE package, export `upstreamCodexImpactReportTemplate`, export `upstreamCodexPublicationPlan`, export `upstreamCodexScheduledTaskPrompt`, and run the configured forbidden-attractor text guard.

Forbidden-attractor GitHub code search for configured/known migrated-location terms returned no matches in `fatb4f/factory` during this run.

Caveat: direct GitHub content reads for `contracts/upstream-monitor/codex/contract-surface/publication.cue`, `public.cue`, and `report.cue` were previously recorded as 404 through the GitHub content API. This report therefore relies on the prior latest evidence/publication projection for admitted paths and issue target shape.

Caveat: the loop entrypoint still contains older initial-gate text forbidding upstream inspection/report creation before transition closure proof. This run proceeded under the loop-local public CUE scheduled task and publication surface recorded by prior latest evidence.

Caveat: `latest-alpha-cli` exact branch head SHA was not exposed by connector responses. It is kept unresolved; only concrete branch-content version evidence is recorded.

## Control action

```text
action: publish-contract-local-impact-run-and-latest-report
reason: new admitted upstream impact on main and latest-alpha-cli concrete version evidence advanced
next_state: continue scheduled observation; keep main and latest-alpha-cli evidence channels distinct
```
