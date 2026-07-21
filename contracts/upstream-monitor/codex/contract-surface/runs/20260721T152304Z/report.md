# Codex Contract-Surface Impact Report

## Run identity

- Run: `20260721T152304Z`
- Signal: `loop_bootstrap_request`
- Profile: `factory`
- Target repository: `fatb4f/factory`
- Target revision: `2d629302eeb1074f83dd7faed1917cfed223438e`
- Terminal state: `terminal_success`
- Actuator: `chatgpt` via `github_app`

## Correction lineage

- Supersedes run: `20260721T135622Z`
- Superseded bundle: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T135622Z/`
- Superseded manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T135622Z/manifest.json`
- Reason: Re-evaluate the original channel baselines under the strengthened typed-evidence contract, correct omitted account and hook-configuration evidence, and include main changes through the current head.

## Channel state: main

- Status: `resolved`
- Head: `0b175e6439a8608ba7726ee153fd8590619e8f34`
- Workspace version: `0.0.0`
- Baseline: `726b6378d2513c25e5e59b1371326be2fe194be4`
- Delta: 165 commits ahead and 0 behind.

## Channel state: latest-alpha-cli

- Status: `resolved`
- Head: `5d724b1bc65073572298c78b031e3b7e4dc2724e`
- Workspace version: `0.145.0-alpha.29`
- Baseline: `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`
- Delta: 163 commits ahead and 1 behind.

## Critical

### Instruction and skill-loading contracts changed

- ID: `instruction-skill-environment-contracts`
- Channels: `main`, `latest-alpha-cli`
- Decision: `blocking-gate`
- Surfaces: `instructions`
- Summary: AGENTS processing, environment-scoped skill loading, and multi-agent instruction injection changed across the independently evaluated channels.
- Claim: Both channels changed AGENTS processing and environment-scoped skill loading, so factory instruction-chain and skill-discovery assumptions require requalification before either channel is adopted.
- Evidence:
  - `main` — `codex-rs/core/src/agents_md.rs`: Main changes AGENTS processing and instruction construction.
  - `main` — `codex-rs/core-skills/src/loader/environment.rs`: Main changes environment-scoped skill loading.
  - `latest-alpha-cli` — `codex-rs/core/src/agents_md.rs`: Latest alpha changes AGENTS processing and instruction construction.
  - `latest-alpha-cli` — `codex-rs/core-skills/src/loader/environment.rs`: Latest alpha changes environment-scoped skill loading.
- Local impact: Requalify the factory instruction chain, environment selection, skill discovery, and multi-agent instruction assumptions.
- Suggested local targets: `contracts/upstream-monitor/AGENTS.md`, `contracts/upstream-monitor/codex/AGENTS.md`, `contracts/factory/workers/codex/upstream-monitor/`

### Account, permission, and approval contracts changed

- ID: `authentication-account-permission-contracts`
- Channels: `main`, `latest-alpha-cli`
- Decision: `blocking-gate`
- Surfaces: `authentication`
- Summary: Account credential representation, approval response schemas, and permission protocol paths changed.
- Claim: Both channels changed account credential representation and approval or permission envelopes, requiring independent requalification of account, authorization, sandbox, and approval projections.
- Evidence:
  - `main` — `codex-rs/app-server-protocol/schema/json/v2/GetAccountResponse.json`: Main replaces the Amazon Bedrock account credential-source representation with the managed-credentials boolean representation.
  - `latest-alpha-cli` — `codex-rs/app-server-protocol/schema/json/v2/GetAccountResponse.json`: Latest alpha replaces the Amazon Bedrock account credential-source representation with the managed-credentials boolean representation.
  - `main` — `codex-rs/app-server-protocol/schema/json/ApplyPatchApprovalResponse.json`: Main changes apply-patch approval response envelopes.
  - `latest-alpha-cli` — `codex-rs/app-server-protocol/src/protocol/v2/permissions.rs`: Latest alpha changes the v2 permission protocol.
- Local impact: Requalify account, authentication, authorization, sandbox, approval, and permission contracts independently for main and alpha.
- Suggested local targets: `contracts/factory/workers/codex/upstream-monitor/contract.cue`

## High

### Hook lifecycle and context-spill configuration changed

- ID: `hook-lifecycle-context-spill`
- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `hook-lifecycle`, `configuration`, `context-fragments`
- Summary: Session-end hooks, hook metadata, and additional-context spill configuration changed.
- Claim: Both channels add SessionEnd hook handling and additionalContextLimit context-spill configuration while changing hook notification metadata.
- Evidence:
  - `main` — `codex-rs/config/src/hook_config.rs`: Main adds SessionEnd hook handling and additionalContextLimit context-spill configuration.
  - `latest-alpha-cli` — `codex-rs/config/src/hook_config.rs`: Latest alpha adds SessionEnd hook handling and additionalContextLimit context-spill configuration.
  - `main` — `codex-rs/app-server-protocol/schema/json/v2/HookStartedNotification.json`: Main changes hook-start notification metadata.
  - `latest-alpha-cli` — `codex-rs/app-server-protocol/schema/json/v2/HookCompletedNotification.json`: Latest alpha changes hook-completion notification metadata.
- Local impact: Update hook event, metadata, policy, managed-layer, and context-spill projections.

### Response, thread, turn, realtime, and raw-response schemas changed

- ID: `response-thread-turn-schema-expansion`
- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `response-items`
- Summary: V2 response items, thread and turn structures, realtime items, raw-response notifications, and thread-history projections changed.
- Claim: Both channels changed v2 response-item projections, including raw-response and realtime item surfaces.
- Evidence:
  - `main` — `codex-rs/app-server-protocol/src/protocol/v2/item.rs`: Main changes v2 response item projections.
  - `latest-alpha-cli` — `codex-rs/app-server-protocol/src/protocol/v2/item.rs`: Latest alpha changes v2 response item projections.
  - `main` — `codex-rs/app-server-protocol/schema/json/v2/RawResponseItemCompletedNotification.json`: Main changes raw-response item completion notifications.
  - `latest-alpha-cli` — `codex-rs/app-server-protocol/src/protocol/v2/realtime.rs`: Latest alpha changes realtime item projections.
- Local impact: Update response-item, realtime-item, raw-response, thread-history, and turn-lifecycle projections.

### MCP, connector, installed-app, and code-mode runtime surfaces changed

- ID: `mcp-connector-code-mode-runtime`
- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `mcp-tools`
- Summary: MCP connection management and elicitation, connector runtime projection, installed-app handling, and code-mode values changed.
- Claim: Both channels changed MCP connection management and related connector, installed-app, and code-mode runtime projections.
- Evidence:
  - `main` — `codex-rs/codex-mcp/src/connection_manager.rs`: Main changes MCP connection management.
  - `latest-alpha-cli` — `codex-rs/codex-mcp/src/connection_manager.rs`: Latest alpha changes MCP connection management.
  - `main` — `codex-rs/connectors/src/runtime_projection.rs`: Main adds connector runtime projection.
  - `latest-alpha-cli` — `codex-rs/code-mode/src/runtime/value.rs`: Latest alpha changes code-mode runtime values.
- Local impact: Extend MCP lifecycle, connector projection, elicitation, installed-app, and code-mode result contracts.

### Main added thread-scoped MCP refresh and step-bound binding clients

- ID: `main-mcp-refresh-configuration`
- Channels: `main`
- Decision: `contract-update`
- Surfaces: `mcp-tools`, `configuration`
- Summary: Main now combines global MCP configuration with per-thread overrides and captures ready clients for a model step.
- Claim: Main added thread-scoped MCP refresh and step-bound binding clients, changing runtime configuration and client-capture boundaries.
- Evidence:
  - `main` — `codex-rs/app-server/src/mcp_refresh.rs`: Main adds thread-scoped MCP refresh that combines current global configuration with per-thread overrides.
  - `main` — `codex-rs/codex-mcp/src/binding_clients.rs`: Main extracts step-bound ready MCP binding clients from the connection manager.
- Local impact: Update MCP refresh, per-thread override, and model-step client-binding contracts.

### Realtime delegation and agent/context lifecycle changed

- ID: `realtime-delegation-agent-context`
- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `agent-messages`, `context-fragments`
- Summary: Delegation fragments, collaboration and realtime world state, agent spawning, notifications, and thread routing changed.
- Claim: Both channels changed realtime delegation fragments and agent or thread lifecycle boundaries.
- Evidence:
  - `main` — `codex-rs/core/src/context/realtime_delegation.rs`: Main adds typed realtime delegation context fragments.
  - `latest-alpha-cli` — `codex-rs/core/src/context/realtime_delegation.rs`: Latest alpha adds typed realtime delegation context fragments.
  - `main` — `codex-rs/core/src/agent/control/spawn.rs`: Main changes agent spawning and control.
  - `latest-alpha-cli` — `codex-rs/app-server/src/request_processors/thread_lifecycle.rs`: Latest alpha changes thread lifecycle routing around agent and context state.
- Local impact: Review agent ownership, delegation, notification, spawning, compaction, and context-boundary contracts.

### Thread-history and rollout-lineage semantics changed

- ID: `thread-history-rollout-lineage`
- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `response-items`, `rollout-trace`
- Summary: Thread-history projection, remote storage, inherited fork paging, rollout references, deletion, and compression semantics changed.
- Claim: Both channels changed thread-history or remote-store behavior; main additionally pages inherited fork history and protects referenced rollouts during deletion and compression.
- Evidence:
  - `main` — `codex-rs/thread-store/src/local/thread_history/segment_paging.rs`: Main adds inherited parent, child, and nested-fork history paging.
  - `main` — `codex-rs/rollout/src/rollout_reference_index.rs`: Main adds rollout reference indexing used to protect referenced histories during deletion and compression.
  - `latest-alpha-cli` — `codex-rs/app-server-protocol/src/protocol/thread_history.rs`: Latest alpha changes thread-history projections.
  - `latest-alpha-cli` — `codex-rs/app-server/tests/suite/v2/remote_thread_store.rs`: Latest alpha changes remote thread-store behavior.
- Local impact: Update thread-history, inherited-lineage, rollout-reference, deletion, compression, replay, and storage contracts.

## Notes

### Release channels remain materially divergent

- ID: `release-channel-divergence`
- Channels: `main`, `latest-alpha-cli`
- Decision: `note`
- Surfaces: `release-channel`
- Summary: Main and latest-alpha-cli retain independent heads and workspace versions.
- Claim: Main is at 0b175e6439a8608ba7726ee153fd8590619e8f34 with workspace version 0.0.0, while latest-alpha-cli remains at 5d724b1bc65073572298c78b031e3b7e4dc2724e with workspace version 0.145.0-alpha.29.
- Evidence:
  - `main` — `codex-rs/Cargo.toml`: Main resolves at workspace version 0.0.0.
  - `latest-alpha-cli` — `codex-rs/Cargo.toml`: Latest alpha resolves at workspace version 0.145.0-alpha.29.
- Local impact: Retain separate channel baselines and qualification decisions.

## No local action

No typed observation was classified as `none`.

## Publication

- Run bundle: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T152304Z/`
- Bundle manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T152304Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`
- Export unit: `directory`
- Bundle complete: `true`

## Validation notes

- Authority read: `true`
- Channels kept distinct: `true`
- Publication plan read: `true`
- Forbidden attractors checked: `true`
- Typed evidence bound: `true`
- Observation ledger complete: `true`
- Surface coverage complete: `true`
- Projection-only rendering: `true`
- Run artifacts co-located: `true`
- Bundle manifest sealed: `true`
- Latest pointer only: `true`
- CUE execution: `not_available_to_github_app`
