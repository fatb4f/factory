# Codex Upstream-Monitor Run Summary

## Run identity

- Run ID: `20260721T135622Z`
- Profile: `factory`
- Terminal state: `terminal_success`
- Factory baseline revision: `6ca2c062ab5e48e48e547c1b04278ec2e5c787d8`

## Channel delta

- `main`: `6915bac7ba2753277cfb6679b547c03e4fe567ed`; 155 ahead and 0 behind baseline `726b6378d2513c25e5e59b1371326be2fe194be4`.
- `latest-alpha-cli`: `5d724b1bc65073572298c78b031e3b7e4dc2724e`; 163 ahead and 1 behind baseline `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`; workspace version `0.145.0-alpha.29`.

## Impact decisions

- Critical / blocking gate: 2
- High / contract update: 3
- Notes: 2
- No local action: 0

The blocking gates concern instruction/skill loading and permission/approval/hook envelopes. Contract updates concern response/thread items, MCP/connectors/code mode, and realtime delegation/context lifecycle.

## Run bundle

- Directory: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T135622Z/`
- Manifest: `contracts/upstream-monitor/codex/contract-surface/runs/20260721T135622Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`

## Validation

Authority and the publication plan were structurally read, channel heads were resolved independently, forbidden attractors were checked, and no issue update was declared. CUE execution is unavailable to the GitHub App actuator, so no `cue fmt`, `cue vet`, or `cue export` claim is made.
