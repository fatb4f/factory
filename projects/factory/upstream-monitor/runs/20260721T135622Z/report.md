# Codex Contract-Surface Impact Report

## Run identity

- Run: `20260721T135622Z`
- Signal: `loop_bootstrap_request`
- Profile: `factory`
- Target repository: `fatb4f/factory`
- Target revision: `6ca2c062ab5e48e48e547c1b04278ec2e5c787d8`
- Actuator: `chatgpt` via `github_app`

## Channel state: main

Resolved independently at `6915bac7ba2753277cfb6679b547c03e4fe567ed`. Compared with its recorded baseline `726b6378d2513c25e5e59b1371326be2fe194be4`, main is 155 commits ahead and 0 behind.

## Channel state: latest-alpha-cli

Resolved independently at `5d724b1bc65073572298c78b031e3b7e4dc2724e` with workspace version `0.145.0-alpha.29`. Compared with its recorded baseline `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`, alpha is 163 commits ahead and 1 behind.

## Critical

### Instruction and skill-loading contracts changed

- Channels: `main`, `latest-alpha-cli`
- Decision: `blocking-gate`
- Surface: `instructions`
- Evidence: `codex-rs/core/src/agents_md.rs`, `codex-rs/core-skills/src/loader/environment.rs`, `codex-rs/core-skills/tests/environment_loader.rs`, and `codex-rs/core/src/context/multi_agent_mode_instructions.rs`
- Local impact: requalify the factory instruction chain, environment-scoped skill loading, and multi-agent instruction injection before adopting either channel.

### Permission, approval, and hook envelopes changed

- Channels: `main`, `latest-alpha-cli`
- Decision: `blocking-gate`
- Surface: `authentication`
- Evidence: `codex-rs/app-server-protocol/schema/json/ApplyPatchApprovalResponse.json`, `ExecCommandApprovalResponse.json`, `v2/HookStartedNotification.json`, `v2/HookCompletedNotification.json`, and alpha `codex-rs/app-server-protocol/src/protocol/v2/permissions.rs`
- Local impact: requalify authorization, sandbox, approval, and hook-policy assumptions independently on both channels.

## High

### Response, thread, and turn schemas expanded

- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surface: `response-items`
- Evidence: v2 item, thread, turn, realtime, raw-response, and thread-history schema and implementation paths changed across both comparisons.
- Local impact: update response-item, thread-history, and turn lifecycle projections.

### MCP, connector, installed-app, and code-mode runtime surfaces changed

- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `mcp-tools`, `configuration`
- Evidence: `codex-rs/codex-mcp/src/connection_manager.rs`, `codex-rs/codex-mcp/src/elicitation.rs`, `codex-rs/connectors/src/runtime_projection.rs`, `codex-rs/app-server/src/request_processors/apps_processor/installed.rs`, and `codex-rs/code-mode/src/runtime/value.rs`
- Local impact: extend connector projection, MCP lifecycle, elicitation, installed-app, and code-mode result contracts.

### Realtime delegation and agent/context lifecycle changed

- Channels: `main`, `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `agent-messages`, `context-fragments`
- Evidence: `codex-rs/core/src/context/realtime_delegation.rs`, world-state collaboration/realtime paths, agent spawn/control paths, and app-server realtime/thread paths.
- Local impact: review agent ownership, notification envelopes, delegation, compaction, and context boundaries.

## Notes

### Rollout and thread-store surfaces moved

Both comparisons include rollout, remote thread-store, thread inventory, and thread history changes. Keep replay and storage evidence contracts under observation.

### Release channels remain materially divergent

Main reports workspace version `0.0.0`; alpha reports `0.145.0-alpha.29`. Their exact heads and baselines remain independent.

## No local action

No admitted surface match was classified as `none`.

## Publication

- Run bundle: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T135622Z/`
- Bundle manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T135622Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`
- Export unit: `directory`
- Bundle complete: `true`

## Validation notes

- Shared vocabulary, factory profile authority, fixed report template, summary template, publication plan, assertions, and public export were structurally read.
- The accepted input matched exactly and `operational: true` was confirmed.
- Prior state was resolved through `latest.json`, its referenced manifest, and bundled `evidence.json`.
- `main` and `latest-alpha-cli` were resolved independently and never collapsed.
- Forbidden attractors were checked; no legacy path was written and no issue target was declared.
- The GitHub App actuator cannot execute `cue fmt`, `cue vet`, or `cue export`; no executable CUE-validation claim is made.
