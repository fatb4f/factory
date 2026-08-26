# Codex Upstream-Monitor Run Summary

## Run identity

- Run: `20260722T042107Z`
- Profile: `factory`
- Terminal state: `terminal_success`
- Target revision: `a80569adc33287c56805dd5549ba6d062e747b08`

## Correction lineage

None.

## Channel delta

- `main`: `0b175e6439a8608ba7726ee153fd8590619e8f34` → `21db216db05d13713f09189fc44872d22cf47fc4`; ahead 40, behind 0; workspace `0.0.0`.
- `latest-alpha-cli`: `5d724b1bc65073572298c78b031e3b7e4dc2724e` → `3b61fac9b7d7b003183ff1b73c28df6abeb062a4`; divergent, ahead 8 and behind 150; workspace `0.145.0-alpha.30`.

## Impact decisions

- Critical / blocking-gate: 2
- High / contract-update: 3
- Notes: 1
- No local action: 0

New evidence intersects instruction/skill injection, permissions and sandbox projection, managed configuration composition, MCP sampling bindings, code-mode yield timing, thread-item rollout persistence, and release-channel state.

## Run bundle

- Bundle: `contracts/upstream-monitor/codex/contract-surface/runs/20260722T042107Z/`
- Manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260722T042107Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`

## Validation

All declared surfaces were scanned on both channels and every admitted match has a classified observation, typed binding, and claim. Markdown is projected from `evidence.json`. No issue target was declared. The GitHub App cannot execute CUE, so executable CUE validation was not run.
