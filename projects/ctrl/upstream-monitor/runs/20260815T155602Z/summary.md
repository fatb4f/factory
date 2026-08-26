# ctrl upstream run summary

## Run identity

- Run ID: `20260815T155602Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority: `0c5195d718d48baf1a787d36e1de4e6d20d67351`
- ctrl: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Prior admitted run: `20260815T140000Z`
- Bootstrap: `false`

## Baseline

All declared source/channel identities resolved independently. Existing channels were compared with `20260815T140000Z`. Newly admitted `scip/main`, `arrow/main`, `duckdb/main`, `ibis/main`, `marimo/main`, and `pydantic-graph/main` were recorded as per-channel onboarding baselines, not retroactive deltas.

Meaningful upstream movement:

- `codex/main`: `a7edf37...` -> `c494130...` (2 commits), but no admitted surface+graph+consumer closure; decision `none`.
- `astral-python/main`: `36cc91f...` -> `52ec0cf...` (2 commits); ty context-manager suppression semantics changed; decision `note`.
- All previously admitted required/optional channels otherwise unchanged.

## Project topology

`ctrl/spec` + CUE retain qualification authority. python-intel remains observation/evaluation architecture; the PyPI/wheel/PEP pipeline remains its first materialization; semagrams remains future/non-authoritative. Component-local ownership and explicit federation boundaries are preserved.

## Decisions

- Critical / `blocking-gate`: **0**
- High / `contract-update`: **0**
- Notes / `note`: **1**
- Reportable `none`: **0**
- Non-promoted source changes: Codex `main` only.

The single note tracks Astral ty's new exception-suppressing context-manager reachability/type semantics as forecast analyzer evidence.

## Qualification state

`observation_only`.

No CUE execution, CPython regrtest/probes, Astral/CPython correlation, SCIP correlation, OpenTelemetry pipeline, OTLP/OTAP round-trip, or relational projection was executed. No adapter/model conclusion is substituted for those witnesses.

## Operationalization gap

The current profile declares SCIP and Arrow/DuckDB/Ibis/Marimo/pydantic-graph source/surface roles, but the graph catalogue has no corresponding upstream nodes for those implementations. No current delta is manufactured from that gap; future changes in those channels require explicit graph binding before promotion.

## Bundle

- `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T155602Z/report.md`
- `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T155602Z/summary.md`
- `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T155602Z/evidence.json`
- `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T155602Z/manifest.json`
- latest pointer updated only after manifest seal.

## Validation

Authority/context/topology/source/graph/correlation/publication reads completed. All channels resolved. Report and summary are evidence projections. Cross-repository writes and issue updates are forbidden and were not performed.
