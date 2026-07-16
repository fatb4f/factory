# Codex Contract-Surface Impact Report

## Run identity

- Run: `20260716T162023Z`
- Signal: `loop_bootstrap_request`
- Target repository: `fatb4f/factory`
- Target revision: `4aa0ca5121038e2c5949d5cd55b9a10f9dbff0e4`
- Actuator: `chatgpt` via `github_app`

## Channel state: main

- Status: `resolved`
- Head commit: `41efc6333e3ed476ce824aa729656f97503c10b8`
- Baseline state: first restored baseline.
- Evidence: ten main-only commits relative to alpha, touching protocol permissions, configuration, multi-agent handlers, skill selection, context/compaction, MCP tests, and sandbox policy.

## Channel state: latest-alpha-cli

- Status: `resolved`
- Head commit: `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`
- Baseline state: first restored baseline.
- Evidence: alpha is one commit ahead and ten behind main; its unique observed path is `codex-rs/Cargo.toml`.

## Critical

- `main-instruction-skill-selection` — `blocking-gate`: dynamic skill-selection and implicit invocation surfaces changed; review instruction-chain and skill-discovery contracts.
- `main-auth-permissions-sandbox` — `blocking-gate`: protocol permissions, app-server schemas, sandbox transforms, config locking, and MCP tests changed; review authorization, approval, sandbox, and MCP lifecycle contracts.

## High

- `main-multi-agent-protocol` — `contract-update`: agent roles, jobs, spawn handlers, multi-agent tool specs, environment waiting, and subagent notifications changed.
- `main-config-context-compaction` — `contract-update`: config parsing/schema, context, turn state, and compaction surfaces changed.

## Notes

- `alpha-release-channel-divergence` — preserve separate main and alpha baselines; neither channel may be inferred from the other.

## No local action

- None.

## Validation notes

- Authority and publication plan read; `operational: true` confirmed.
- Exact input signal admitted.
- Both refs concretely resolved and kept distinct.
- Fixed template and bounded write paths used.
- No issue targets declared; no issue update attempted.
- Forbidden attractors checked structurally with none admitted.
- GitHub App cannot execute CUE; `cue fmt`, `cue vet`, and `cue export` were not claimed.
- Terminal state: `terminal_success`.
