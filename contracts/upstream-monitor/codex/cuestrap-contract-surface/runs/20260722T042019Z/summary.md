# CUEstrap upstream-monitor run summary

## Run identity

- Run: `20260722T042019Z`
- Terminal state: `terminal_success`
- Factory acquisition revision: `a80569adc33287c56805dd5549ba6d062e747b08`
- Profile: `cuestrap`

## CUEstrap context

Current subject context was read at `fatb4f/cuestrap@781801e6500bcef92169b8748ae82166bae56c88`; all seven required paths were available.

## Channel delta

- `main`: `21db216db05d13713f09189fc44872d22cf47fc4` (`0.0.0`), 40 ahead and 0 behind prior main.
- `latest-alpha-cli`: `3b61fac9b7d7b003183ff1b73c28df6abeb062a4` (`0.145.0-alpha.30`), 8 ahead and 150 behind prior alpha.

The channels were acquired, scanned, and classified independently.

## Purpose decisions

- Supervisory session controller: **`blocking-gate`** — managed requirements/session replay, request-scoped MCP dispatch, skill/plugin projection, thread identity, and alpha unified-exec permission semantics require requalification.
- Idiomatic CUE workbook harness: **`contract-update`** — request-scoped MCP binding and alpha code-mode session/runtime changes require updated qualification.

Findings: 4 critical, 2 high, 1 note.

## Factory run bundle

- [Run directory](https://github.com/fatb4f/factory/tree/main/contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260722T042019Z)
- [Report](https://github.com/fatb4f/factory/blob/main/contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260722T042019Z/report.md)
- [Evidence](https://github.com/fatb4f/factory/blob/main/contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260722T042019Z/evidence.json)
- [Manifest](https://github.com/fatb4f/factory/blob/main/contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/20260722T042019Z/manifest.json)

## Tracking issue

Append exactly one deduplicated terminal comment to [fatb4f/cuestrap#9](https://github.com/fatb4f/cuestrap/issues/9) with identity `cuestrap-codex-contract-surface/20260722T042019Z`.

## Validation

Authority, current context, independent channel heads, templates, publication gates, bundle boundaries, and forbidden attractors were structurally checked. The GitHub App cannot execute CUE, so no `cue fmt`, `cue vet`, or `cue export` execution is claimed. No monitor artifact is written to CUEstrap.
