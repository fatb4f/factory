# Codex Contract-Surface Impact Report

<!-- Projection source: evidence.json. Do not add claims absent from typed claims and observations. -->

## Run identity

- Run: `20260722T042107Z`
- Signal: `loop_bootstrap_request`
- Profile: `factory`
- Target repository: `fatb4f/factory`
- Target revision: `a80569adc33287c56805dd5549ba6d062e747b08`
- Actuator: `chatgpt` via `github_app`
- Terminal state: `terminal_success`

## Correction lineage

None. This run does not correct or supersede a sealed run.

## Channel state: main

Resolved independently at `21db216db05d13713f09189fc44872d22cf47fc4` with workspace version `0.0.0`. Relative to its own prior head `0b175e6439a8608ba7726ee153fd8590619e8f34`, the channel is ahead by 40 commits and behind by 0.

## Channel state: latest-alpha-cli

Resolved independently at `3b61fac9b7d7b003183ff1b73c28df6abeb062a4` with workspace version `0.145.0-alpha.30`. Relative to its own prior head `5d724b1bc65073572298c78b031e3b7e4dc2724e`, the channel is divergent: ahead by 8 and behind by 150.

## Critical

### Main skill-injection ownership changed

- Decision: `blocking-gate`
- Channels: `main`
- Surfaces: `instructions`
- Claim: Main changed host-skill prompt and catalog injection ownership, including duplicate suppression between legacy and extension-owned paths.
- Local contract impact: Requalify skill discovery, explicit skill injection, WorldState catalog ownership, and duplicate-suppression invariants.

### Permission, sandbox, and permission-instruction contracts changed

- Decision: `blocking-gate`
- Channels: `main`, `latest-alpha-cli`
- Surfaces: `authentication`, `instructions`
- Claim: Main changed effective approval, permission-profile, sandbox, filesystem, and network requirement structures; latest alpha changed the developer-instruction projection of permission, sandbox, denied-read, writable-root, and automatic-review state.
- Local contract impact: Requalify authorization, sandbox, approval, denied-read, writable-root, and permission-instruction projections independently for both channels.

## High

### Main managed-configuration composition changed

- Decision: `contract-update`
- Channels: `main`
- Surfaces: `configuration`
- Claim: Main changed composable requirements layers and domain-specific merging for rules, hooks, permissions, paths, and remote sandbox configuration.
- Local contract impact: Update configuration-layer provenance, composition, path materialization, remote-sandbox, and domain-merge contracts.

### MCP sampling bindings and alpha code-mode timing changed

- Decision: `contract-update`
- Channels: `main`, `latest-alpha-cli`
- Surfaces: `mcp-tools`
- Claim: Main introduced immutable per-sampling MCP bindings for exact catalogs, clients, metadata, and calls; latest alpha changed code-mode yield observation by adding a grace period for longer yields.
- Local contract impact: Extend MCP catalog/call binding and code-mode execute/wait timing contracts while keeping channel-specific behavior distinct.

### Main thread-item injection and rollout persistence changed

- Decision: `contract-update`
- Channels: `main`
- Surfaces: `response-items`, `rollout-trace`
- Claim: Main changed thread item injection ordering and persistence so injected raw response items are recorded in rollout history and sent between initial context and the next user prompt.
- Local contract impact: Update raw-response item, thread injection ordering, rollout persistence, replay, and next-turn projection contracts.

## Notes

### Release channels remain materially divergent

- Decision: `note`
- Channels: `main`, `latest-alpha-cli`
- Surfaces: `release-channel`
- Claim: Main is at `21db216db05d13713f09189fc44872d22cf47fc4` with workspace version `0.0.0`, while latest-alpha-cli is at `3b61fac9b7d7b003183ff1b73c28df6abeb062a4` with workspace version `0.145.0-alpha.30`.
- Local contract impact: Retain independent channel baselines and qualification decisions.

## No local action

No evidence-backed no-local-action items.

## Publication

- Run bundle: `contracts/upstream-monitor/codex/contract-surface/runs/20260722T042107Z/`
- Bundle manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260722T042107Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`
- Export unit: `directory`
- Bundle complete: `true`

## Validation notes

Authority and the factory profile publication plan were read; both channels were resolved and scanned separately; all ten catalogue surfaces have coverage entries; observations, bindings, and claims are typed and uniquely identified; Markdown is a projection of `evidence.json`; forbidden attractors were checked; run artifacts are co-located and the manifest is written after them; latest is pointer-only; no legacy path or issue is updated; this is not a correction; no cross-repository mutation occurred. CUE execution is not available to the GitHub App, so `cue vet` and `cue export` were not run.
