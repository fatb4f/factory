# CUEstrap Codex Contract-Surface Impact Report

## Run identity

- Run ID: `20260721T155431Z`
- Terminal state: `terminal_success`
- Factory revision used for acquisition: `eca447be3a264d44c3cca575cf48ced69abb32cc`
- CUEstrap revision: `781801e6500bcef92169b8748ae82166bae56c88`
- Signal: `loop_bootstrap_request`
- Profile: `cuestrap`
- Tracking identity: `cuestrap-codex-contract-surface/20260721T155431Z`

## CUEstrap context state

- Every required path was reread at `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88`.
- CUEstrap advanced 90 commits from prior context `34d179bf014b09e988fb1e5256a255b64c178e8e`.
- The current subject has closed CUE/Pydantic v2 models, phase-specific routing, durable pre/post evidence, constrained code-mode, and workbook MCP surfaces.
- CUEstrap state was subject context only, never monitor authority.

## Channel state: main

- Prior head: `5331d20f6ef9b80ee4153132a70d4989780d916d`
- Current head: `0b175e6439a8608ba7726ee153fd8590619e8f34`
- Delta: 161 ahead, 0 behind.
- Workspace version: `0.0.0`

## Channel state: latest-alpha-cli

- Prior head: `f84f9a6406cc55b210395f71b4c6aed236fc7ebb`
- Current head: `5d724b1bc65073572298c78b031e3b7e4dc2724e`
- Delta: 150 ahead, 1 behind.
- Workspace version: `0.145.0-alpha.29`
- Alpha was resolved and classified independently.

## Purpose impact: supervisory session controller

- Decision: **`blocking-gate`**
- Requalify hook lifecycle, permission/approval, instruction context, tool routing, MCP refresh, result handling, and session identity before compatibility claims.

## Purpose impact: idiomatic CUE workbook harness

- Decision: **`contract-update`**
- Update MCP, code-mode, structured-result, context, and replay qualification against current projections.

## Critical

- `hook-ingress-session-end` — **`blocking-gate`**: Both channels change hook metadata and add SessionEnd/context-limit behavior, while CUEstrap models only PreToolUse and PostToolUse.
  - Surfaces: `codex-hook-ingress`, `session-turn-identity`
  - Local impact: Requalify supported events, common identity fields, session-end reduction, and context-spill behavior.
  - Evidence: `codex-rs/config/src/hook_config.rs`; `codex-rs/app-server-protocol/schema/json/v2/HookStartedNotification.json`; `codex-rs/app-server-protocol/schema/json/v2/HookCompletedNotification.json`; `codex-rs/app-server/tests/suite/v2/session_end.rs`; `cuestrap contracts.cue: PreToolUse and PostToolUse only`
- `permission-approval-sandbox` — **`blocking-gate`**: Approval responses and permission world-state paths changed against CUEstrap's fixed permission vocabulary and fail-closed policy.
  - Surfaces: `permission-sandbox-approval`
  - Local impact: Requalify permission vocabulary, approval projection, and sandbox admission independently for both channels.
  - Evidence: `codex-rs/app-server-protocol/schema/json/ApplyPatchApprovalResponse.json`; `codex-rs/app-server-protocol/schema/json/ExecCommandApprovalResponse.json`; `codex-rs/core/src/context/world_state/permissions.rs`; `cuestrap #PermissionMode: default|acceptEdits|plan|dontAsk|bypassPermissions`
- `instruction-skill-context` — **`blocking-gate`**: AGENTS processing, environment-scoped skill loading, collaboration state, and realtime delegation changed.
  - Surfaces: `instruction-skill-policy`, `context-turn-lifecycle`
  - Local impact: Requalify instruction loading, phase isolation, skill selection, and collaboration/realtime context boundaries.
  - Evidence: `codex-rs/core/src/agents_md.rs`; `codex-rs/core-skills/src/loader/environment.rs`; `codex-rs/core/src/context/world_state/collaboration_mode.rs`; `codex-rs/core/src/context/realtime_delegation.rs`; `cuestrap .codex/AGENTS.md phase contract`
- `tool-dispatch-mcp-routing` — **`blocking-gate`**: MCP connection management, dynamic tools, code-mode values, and main thread-scoped MCP refresh changed against CUEstrap's closed target routing.
  - Surfaces: `tool-dispatch-classification`, `mcp-code-mode`
  - Local impact: Requalify tool classification, target routing, MCP refresh, and pending-operation correlation.
  - Evidence: `codex-rs/codex-mcp/src/connection_manager.rs`; `codex-rs/app-server/src/dynamic_tools.rs`; `codex-rs/code-mode/src/runtime/value.rs`; `main: codex-rs/app-server/src/mcp_refresh.rs`; `main: codex-rs/codex-mcp/src/binding_clients.rs`; `cuestrap contracts.cue/policy.py/routing.py target routing`

## High

- `result-context-thread-workbook` — **`contract-update`**: Dynamic results, additional-context limits, thread/turn history, app projections, connectors, MCP resources, and code-mode services changed.
  - Surfaces: `tool-result-error-semantics`, `session-turn-identity`, `context-turn-lifecycle`, `mcp-code-mode`
  - Local impact: Update result normalization, context sizing, replay identity, and workbook MCP/code-mode qualification.
  - Evidence: `codex-rs/app-server-protocol/schema/json/DynamicToolCallResponse.json`; `codex-rs/config/src/hook_config.rs`; `codex-rs/app-server-protocol/src/protocol/v2/thread.rs`; `codex-rs/app-server-protocol/src/protocol/v2/turn.rs`; `codex-rs/app-server-protocol/src/protocol/thread_history.rs`; `codex-rs/connectors/src/runtime_projection.rs`; `codex-rs/app-server/tests/suite/v2/mcp_resource.rs`; `codex-rs/code-mode/src/service.rs`; `main: codex-rs/thread-store/src/local/thread_history/segment_paging.rs`; `cuestrap supervisor.py/workbook_adapter.py/workbook_mcp_server.py`

## Notes

- `multi-agent-ownership-boundary` — **`note`**: Agent spawning, role, notification, and realtime delegation changed while CUEstrap still binds one supervisory session/run/attempt and has no cross-agent ownership protocol.
  - Surfaces: `multi-agent-session-control`
  - Local impact: Keep cross-agent ownership, delegated approvals, and attempt correlation unsupported until a separate contract is designed.
  - Evidence: `codex-rs/core/src/agent/control/spawn.rs`; `codex-rs/core/src/context/realtime_delegation.rs`; `codex-rs/core/src/context/multi_agent_mode_instructions.rs`; `codex-rs/app-server/src/request_processors/thread_lifecycle.rs`
- `release-channel-divergence` — **`note`**: Main advanced 161 commits from its prior CUEstrap baseline; latest-alpha-cli diverged 150 commits ahead and one behind and now declares 0.145.0-alpha.29.
  - Surfaces: `release-channel`
  - Local impact: Preserve separate support claims, fixtures, and qualification evidence for main and latest-alpha-cli.
  - Evidence: `prior main head 5331d20f6ef9b80ee4153132a70d4989780d916d`; `current main head 0b175e6439a8608ba7726ee153fd8590619e8f34`; `prior alpha head f84f9a6406cc55b210395f71b4c6aed236fc7ebb`; `current alpha head 5d724b1bc65073572298c78b031e3b7e4dc2724e`; `codex-rs/Cargo.toml main workspace.package.version = 0.0.0`; `codex-rs/Cargo.toml alpha workspace.package.version = 0.145.0-alpha.29`

## No local action

- None.

## Publication

- Bundle: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T155431Z/`
- Report: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T155431Z/report.md`
- Summary: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T155431Z/summary.md`
- Evidence: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T155431Z/evidence.json`
- Manifest: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T155431Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/cuestrap-contract-surface/latest.json`
- No monitor artifact was written to `fatb4f/cuestrap`.

## Tracking issue

- Target: `fatb4f/cuestrap#9`
- Mutation: one append-only comment
- Dedupe identity: `cuestrap-codex-contract-surface/20260721T155431Z`
- Issue body unchanged.

## Validation notes

- Exact signal/profile admitted; all selected authority and required CUEstrap context read.
- Prior state resolved only from factory `latest.json`, manifest, and bundled evidence.
- Both channel heads concretely resolved and kept distinct.
- Forbidden attractors checked.
- Artifacts co-located; manifest written after primary artifacts; pointer updated afterward.
- GitHub App cannot execute CUE; no `cue fmt`, `cue vet`, or `cue export` claim is made.
