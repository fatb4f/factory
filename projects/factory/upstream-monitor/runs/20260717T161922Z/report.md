# Codex Contract-Surface Impact Report

## Run identity

- Run: `20260717T161922Z`
- Signal: `loop_bootstrap_request`
- Profile: `factory`
- Target repository: `fatb4f/factory`
- Target revision: unresolved; GitHub App file reads did not expose the branch commit SHA
- Actuator: `chatgpt` via `github_app`

## Channel state: main

- Ref: `openai/codex@main`
- Status: `unresolved`
- Prior resolved head: `726b6378d2513c25e5e59b1371326be2fe194be4`
- Concrete delta: branch compares 25 commits ahead and 0 behind the prior head.
- Exact current head SHA was not exposed by the adapter and was not inferred.

## Channel state: latest-alpha-cli

- Ref: `openai/codex@latest-alpha-cli`
- Status: `unresolved`
- Prior resolved head: `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`
- Concrete delta: branch diverged from the prior head, with 27 commits ahead and 1 behind; merge base `800715d201651a2a07c2706dca10400109dae3d3`.
- Exact current head SHA was not exposed by the adapter and was not inferred.

## Critical

### Instruction and skill-loading environment semantics changed

- ID: `channel-instruction-environment-loading`
- Channels: `main`, `latest-alpha-cli`
- Decision: `blocking-gate`
- Surface: `instructions`
- Evidence includes changes to `codex-rs/core/src/agents_md.rs`, `codex-rs/core-skills/src/loader/environment.rs`, environment loader tests, and multi-agent instruction context.
- Local contract impact: validate the factory instruction-chain and skill-discovery assumptions before adopting either channel; environment-derived skill and AGENTS behavior intersects the monitor's highest-floor policy surface.

## High

### Installed-app and connector runtime projection expanded

- ID: `channel-installed-app-runtime-projection`
- Channels: `main`
- Decision: `contract-update`
- Surface: `mcp-tools`
- Evidence includes new `AppsInstalledParams`, `AppsInstalledResponse`, `InstalledApp`, installed-app request processing, connector `runtime_projection`, and app-tool policy changes.
- Local contract impact: extend MCP/connector lifecycle projections beyond app-read metadata to installed-app state and runtime tool projection.

### Capability discovery entered the execution-server protocol

- ID: `main-exec-capability-discovery`
- Channels: `main`
- Decision: `contract-update`
- Surfaces: `mcp-tools`, `configuration`
- Evidence includes new `exec-server` capability discovery and cache modules plus protocol additions.
- Local contract impact: review adapter contracts that assume static capability availability or discovery only at process bootstrap.

### Realtime delegation and multi-agent lifecycle changed

- ID: `main-realtime-delegation-lifecycle`
- Channels: `main`
- Decision: `contract-update`
- Surfaces: `agent-messages`, `context-fragments`
- Evidence includes new realtime delegation context, substantial realtime conversation changes, agent spawn-control updates, subagent notification changes, and thread/session routing changes.
- Local contract impact: review agent envelope, delegation lifecycle, ownership, notification, and context-projection contracts.

### Alpha carries protocol, permissions, and MCP changes on its independent line

- ID: `alpha-protocol-permissions-mcp-delta`
- Channels: `latest-alpha-cli`
- Decision: `contract-update`
- Surfaces: `mcp-tools`, `authentication`, `response-items`
- Evidence includes app-read protocol schemas, connector metadata, permissions changes, MCP executor discovery, response-completed notification changes, and image-generation response behavior.
- Local contract impact: preserve alpha-specific review of protocol, authorization, and response-item projections; do not substitute main conclusions.

## Notes

### Channel divergence increased and both current heads remain unresolved

- ID: `release-channel-divergence-unresolved-heads`
- Channels: `main`, `latest-alpha-cli`
- Decision: `note`
- Surface: `release-channel`
- Evidence: main is 25 commits ahead of its prior head; alpha is 27 ahead and 1 behind its prior head.
- Local contract impact: retain separate baselines and require concrete ref evidence before recording new head SHAs.

## No local action

No admitted no-local-action items were recorded.

## Publication

- Run bundle: `contracts/upstream-monitor/codex/contract-surface/runs/20260717T161922Z/`
- Bundle manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260717T161922Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`
- Export unit: `directory`
- Bundle complete: `true`

## Validation notes

- Shared vocabulary, factory profile CUE files, compatibility instruction chain, fixed report template, summary template, and publication plan were read.
- Input signal matched exactly and `operational: true` was confirmed.
- `main` and `latest-alpha-cli` were acquired and classified independently.
- All forbidden attractors were checked structurally; unresolved heads were not inferred, legacy paths were not written, and no issue update was attempted because `issueTargets` is empty.
- The GitHub App cannot execute CUE; `cue fmt`, `cue vet`, and `cue export` were not run.
- Report, summary, and evidence are co-located; the manifest is written only after their blob identities are fetched, followed by the pointer update.