# Codex Upstream-Monitor Run Summary

## Run identity

- Run: `20260717T161922Z`
- Profile: `factory`
- Terminal state: `terminal_success`

## Channel delta

- `main`: exact current head unresolved; concrete compare is 25 commits ahead and 0 behind prior head `726b6378d2513c25e5e59b1371326be2fe194be4`.
- `latest-alpha-cli`: exact current head unresolved; concrete compare is 27 commits ahead and 1 behind prior head `dd1363c67cbf530e362ea8e4c623d66fe97a5bc5`.

## Impact decisions

- Critical / blocking-gate: 1
- High / contract-update: 4
- Notes: 1
- No local action: 0

The highest-impact finding is changed environment-aware AGENTS and skill-loading behavior. Additional contract updates cover installed-app runtime projection, execution capability discovery, realtime multi-agent lifecycle, and alpha-specific protocol/permissions/MCP changes.

## Run bundle

`contracts/upstream-monitor/codex/contract-surface/runs/20260717T161922Z/`

Required artifacts: `report.md`, `summary.md`, `evidence.json`, and sealing `manifest.json`. Discovery pointer: `contracts/upstream-monitor/codex/contract-surface/latest.json`.

## Validation

Factory-local CUE remained authority; upstream was evidence only. Channels were kept distinct and exact heads were not inferred. The GitHub App cannot execute CUE validation commands. No issue target was declared, so no issue was updated.