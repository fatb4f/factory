# Codex Upstream-Monitor Run Summary

## Run identity

- Run ID: `20260721T152304Z`
- Profile: `factory`
- Terminal state: `terminal_success`
- Factory authority revision: `2d629302eeb1074f83dd7faed1917cfed223438e`

## Correction lineage

- Supersedes: `20260721T135622Z`
- Reason: Re-evaluate the original channel baselines under the strengthened typed-evidence contract, correct omitted account and hook-configuration evidence, and include main changes through the current head.

## Channel delta

- `main`: `0b175e6439a8608ba7726ee153fd8590619e8f34`; 165 ahead and 0 behind baseline `726b6378d2513c25e5e59b1371326be2fe194be4`; workspace version `0.0.0`.
- `latest-alpha-cli`: `5d724b1bc65073572298c78b031e3b7e4dc2724e`; 163 ahead and 1 behind baseline `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`; workspace version `0.145.0-alpha.29`.

## Impact decisions

- Critical / blocking gate: 2
- High / contract update: 6
- Notes: 1
- No local action: 0

The blocking gates cover instruction and skill loading plus account, authentication, permission, and approval contracts. Contract updates cover hook lifecycle and context spill, response items, MCP and connector runtime behavior, realtime delegation, and thread-history or rollout lineage.

## Run bundle

- Directory: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T152304Z/`
- Manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T152304Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`

## Validation

Typed evidence, observation-ledger coverage, per-surface coverage, claim bindings, channel isolation, correction lineage, co-location, manifest sealing, and pointer-only latest publication are recorded in `evidence.json`. CUE execution remains unavailable to the GitHub App actuator.
