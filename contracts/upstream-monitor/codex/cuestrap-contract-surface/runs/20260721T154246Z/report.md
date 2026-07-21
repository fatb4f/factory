# CUEstrap Codex Contract-Surface Impact Report

## Run identity

- Run ID: `20260721T154246Z`
- Terminal state: `terminal_success`
- Factory revision used for acquisition: `e22da74cdaa4fdebda1023f372a3bdaec046cf70`
- CUEstrap revision: `781801e6500bcef92169b8748ae82166bae56c88`
- Signal: `loop_bootstrap_request`
- Profile: `cuestrap`
- Tracking identity: `cuestrap-codex-contract-surface/20260721T154246Z`

## CUEstrap context state

- Every required context path was resolved and reread at `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88`.
- CUEstrap advanced 90 commits from the previously sealed context revision `34d179bf014b09e988fb1e5256a255b64c178e8e`.
- The supervisory controller now uses closed CUE and Pydantic v2 models, phase-specific target IDs, durable pre/post evidence, explicit routing, and a replayable reducer.
- The local ingress still models `PreToolUse` and `PostToolUse`; the current upstream hook lifecycle additionally includes `SessionEnd` and context-limit behavior.
- The workbook remains a gopy-backed Marimo qualification surface and now also includes constrained code-mode and MCP adapter components.
- CUEstrap repository state was used only as subject context and was not treated as monitor authority.

## Channel state: main

- Status: `resolved`
- Prior CUEstrap-profile head: `5331d20f6ef9b80ee4153132a70d4989780d916d`
- Current head: `0b175e6439a8608ba7726ee153fd8590619e8f34`
- Delta: 161 commits ahead, 0 behind.
- Workspace version: `0.0.0`
- Main-only additions after the prior baseline include thread-scoped MCP refresh, MCP binding clients, inherited thread-history paging, and rollout-reference protection.

## Channel state: latest-alpha-cli

- Status: `resolved`
- Prior CUEstrap-profile head: `f84f9a6406cc55b210395f71b4c6aed236fc7ebb`
- Current head: `5d724b1bc65073572298c78b031e3b7e4dc2724e`
- Delta: 150 commits ahead, 1 behind.
- Workspace version: `0.145.0-alpha.29`
- Alpha was acquired and classified independently; no main state was substituted.

## Purpose impact: supervisory session controller

- Decision: **`blocking-gate`**
- Requalify the current CUEstrap v2 supervisor against expanded hook lifecycle, permission and approval schemas, instruction context, tool routing, MCP refresh, and session identity before claiming compatibility.
- Matched surfaces: `codex-hook-ingress`, `session-turn-identity`, `tool-dispatch-classification`, `permission-sandbox-approval`, `mcp-code-mode`, `tool-result-error-semantics`, `instruction-skill-policy`, `context-turn-lifecycle`, `multi-agent-session-control`, `release-channel`.

## Purpose impact: idiomatic CUE workbook harness

- Decision: **`contract-update`**
- Update workbook MCP, code-mode, structured-result, and context-lifecycle qualification against current app, connector, and runtime projections.
- Matched surfaces: `mcp-code-mode`, `tool-result-error-semantics`, `instruction-skill-policy`, `context-turn-lifecycle`, `release-channel`.

## Critical

- `hook-ingress-and-session-end-expansion` — **`blocking-gate`**: Both channels change hook metadata and add SessionEnd and context-limit behavior, while CUEstrap's closed ingress currently models only PreToolUse and PostToolUse.
  - Surfaces: `codex-hook-ingress`, `session-turn-identity`
  - Local impact: Requalify supported hook events, common hook identity fields, end-of-session reduction, and context-spill behavior before claiming current Codex hook coverage.
  - Evidence:
    - `codex-rs/config/src/hook_config.rs`
    - `codex-rs/app-server-protocol/schema/json/v2/HookStartedNotification.json`
    - `codex-rs/app-server-protocol/schema/json/v2/HookCompletedNotification.json`
    - `codex-rs/app-server/tests/suite/v2/session_end.rs`
    - `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88: src/cue-workbook/supervisory_hooks/contracts.cue models only PreToolUse and PostToolUse`
- `permission-approval-and-sandbox-contracts` — **`blocking-gate`**: Approval response schemas and permission world-state paths changed on both channels against CUEstrap's fixed permission-mode vocabulary and fail-closed policy.
  - Surfaces: `permission-sandbox-approval`
  - Local impact: Requalify the CUE and Pydantic permission vocabulary, approval response projection, and sandbox admission rules against each channel independently.
  - Evidence:
    - `codex-rs/app-server-protocol/schema/json/ApplyPatchApprovalResponse.json`
    - `codex-rs/app-server-protocol/schema/json/ExecCommandApprovalResponse.json`
    - `codex-rs/core/src/context/world_state/permissions.rs`
    - `codex-rs/core/src/context/world_state/permissions_tests.rs`
    - `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88: #PermissionMode remains default|acceptEdits|plan|dontAsk|bypassPermissions`
- `instruction-skill-and-context-policy` — **`blocking-gate`**: AGENTS processing, environment-scoped skill loading, collaboration context, and realtime delegation changed across the current channels.
  - Surfaces: `instruction-skill-policy`, `context-turn-lifecycle`
  - Local impact: Requalify repository instruction loading, phase isolation, environment-scoped skill selection, and collaboration/realtime context boundaries.
  - Evidence:
    - `codex-rs/core/src/agents_md.rs`
    - `codex-rs/core-skills/src/loader/environment.rs`
    - `codex-rs/core/src/context/world_state/collaboration_mode.rs`
    - `codex-rs/core/src/context/realtime_delegation.rs`
    - `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88: .codex/AGENTS.md closes the repository phase and tool-use contract`
- `tool-dispatch-and-mcp-routing` — **`blocking-gate`**: MCP connection management, dynamic tools, code-mode values, and main thread-scoped MCP refresh changed while CUEstrap now closes target IDs and phase-specific routing.
  - Surfaces: `tool-dispatch-classification`, `mcp-code-mode`
  - Local impact: Requalify canonical tool classification, target-ID routing, MCP refresh semantics, and pending-operation correlation before adopting either channel.
  - Evidence:
    - `codex-rs/codex-mcp/src/connection_manager.rs`
    - `codex-rs/app-server/src/dynamic_tools.rs`
    - `codex-rs/code-mode/src/runtime/value.rs`
    - `main: codex-rs/app-server/src/mcp_refresh.rs`
    - `main: codex-rs/codex-mcp/src/binding_clients.rs`
    - `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88: supervisory target IDs and routing are closed in contracts.cue, policy.py, and routing.py`

## High

- `tool-result-error-and-additional-context` — **`contract-update`**: Dynamic tool responses, code-mode result values, hook context limits, and result projection changed against CUEstrap's returned/reported-error reducer and PostToolUse additionalContext response.
  - Surfaces: `tool-result-error-semantics`
  - Local impact: Update and test result normalization, reported-error detection, context-size handling, and post-tool guidance serialization.
  - Evidence:
    - `codex-rs/app-server-protocol/schema/json/DynamicToolCallResponse.json`
    - `codex-rs/code-mode-protocol/src/response.rs`
    - `codex-rs/code-mode/src/runtime/value.rs`
    - `codex-rs/config/src/hook_config.rs`
    - `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88: Supervisor emits PostToolUse additionalContext and reduces returned|reported-error|not-dispatched|reducer-error`
- `session-thread-and-rollout-lifecycle` — **`contract-update`**: Thread and turn schemas changed on both channels; main additionally introduced inherited history paging and rollout-reference protection.
  - Surfaces: `session-turn-identity`, `context-turn-lifecycle`
  - Local impact: Requalify session/run/attempt binding, turn continuity, transcript identity, and any replay assumptions used by the durable supervisory ledger.
  - Evidence:
    - `codex-rs/app-server-protocol/src/protocol/v2/thread.rs`
    - `codex-rs/app-server-protocol/src/protocol/v2/turn.rs`
    - `codex-rs/app-server-protocol/src/protocol/thread_history.rs`
    - `main: codex-rs/thread-store/src/local/thread_history/segment_paging.rs`
    - `main: codex-rs/rollout/src/rollout_reference_index.rs`
- `workbook-mcp-app-projection` — **`contract-update`**: Installed-app, app-read, connector runtime projection, MCP resources, and code-mode service behavior changed while CUEstrap added a workbook MCP server and constrained code-mode client.
  - Surfaces: `mcp-code-mode`
  - Local impact: Compare current MCP/app envelopes with workbook transaction, session resolution, structured observations, and browserless qualification behavior.
  - Evidence:
    - `codex-rs/app-server-protocol/schema/json/v2/AppsInstalledResponse.json`
    - `codex-rs/app-server-protocol/schema/json/v2/AppsReadResponse.json`
    - `codex-rs/connectors/src/runtime_projection.rs`
    - `codex-rs/app-server/tests/suite/v2/mcp_resource.rs`
    - `codex-rs/code-mode/src/service.rs`
    - `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88: workbook_mcp_server.py and code_mode_client.py are current adapter surfaces`

## Notes

- `multi-agent-ownership-boundary` — **`note`**: Agent spawning, role, notification, and realtime delegation changed while CUEstrap still binds one supervisory session/run/attempt and has no cross-agent ownership protocol.
  - Surfaces: `multi-agent-session-control`
  - Local impact: Keep cross-agent ownership, delegated approvals, and attempt correlation unsupported until a separate contract is designed.
  - Evidence:
    - `codex-rs/core/src/agent/control/spawn.rs`
    - `codex-rs/core/src/context/realtime_delegation.rs`
    - `codex-rs/core/src/context/multi_agent_mode_instructions.rs`
    - `codex-rs/app-server/src/request_processors/thread_lifecycle.rs`
- `release-channel-divergence` — **`note`**: Main advanced 161 commits from its prior CUEstrap baseline; latest-alpha-cli diverged 150 commits ahead and one behind and now declares 0.145.0-alpha.29.
  - Surfaces: `release-channel`
  - Local impact: Preserve separate support claims, fixtures, and qualification evidence for main and latest-alpha-cli.
  - Evidence:
    - `prior main head 5331d20f6ef9b80ee4153132a70d4989780d916d`
    - `current main head 0b175e6439a8608ba7726ee153fd8590619e8f34`
    - `prior alpha head f84f9a6406cc55b210395f71b4c6aed236fc7ebb`
    - `current alpha head 5d724b1bc65073572298c78b031e3b7e4dc2724e`
    - `codex-rs/Cargo.toml main workspace.package.version = 0.0.0`
    - `codex-rs/Cargo.toml alpha workspace.package.version = 0.145.0-alpha.29`

## No local action

- No additional matched item was classified as `none`.

## Publication

- Canonical factory bundle: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T154246Z/`
- Report: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T154246Z/report.md`
- Summary: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T154246Z/summary.md`
- Evidence: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T154246Z/evidence.json`
- Manifest: `contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260721T154246Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/cuestrap-contract-surface/latest.json`
- No report, summary, evidence, manifest, or pointer was written to `fatb4f/cuestrap`.

## Tracking issue

- Target: `fatb4f/cuestrap#9`
- Policy: `every_run`
- Mutation: append-only comment
- Dedupe identity: `cuestrap-codex-contract-surface/20260721T154246Z`
- The issue body remains unchanged.

## Validation notes

- Exact accepted input and profile were admitted.
- Shared authority and all selected `profiles_cuestrap` files were read.
- All required current CUEstrap context paths were resolved.
- Prior state was read only through the factory `latest.json`, manifest, and bundled evidence.
- Both upstream channel heads were independently and concretely resolved.
- All declared forbidden attractors were checked against the actions taken.
- The factory artifacts are co-located in one immutable run directory; the manifest is written after the three primary artifacts and the pointer is updated afterward.
- No CUEstrap repository artifact or actuator plumbing is written.
- GitHub App CUE execution is unavailable; this run does not claim `cue fmt`, `cue vet`, or `cue export` execution.
