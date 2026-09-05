# epistemic-plant-bootstrap upstream-monitor summary

## Run identity
- Run: `20260905T160243Z`
- Monitor: `terminal_success`
- Qualification: `executable_validated`
- Authority: `09d2ee19594152354362f0024a061c31ef7be65b`
- Subject: `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`

## Baseline
Compared with admitted run `20260902T163500Z`.

## Decisions
- Critical: 2 — CUE master migration gate widened; GUAC migration gate remains open without a fresh P0-surface widening.
- High: 0.
- Notes: 0.

## Authority separation
Pinned source remains the oracle; GUAC is observation-only; CUE is admission authority; operational failure remains INCONCLUSIVE.

## Qualification state
`executable_validated`: subject revision and all subject pins remain unchanged, and the exact-revision CI qualification remains successful. Forecast upstream movement does not qualify a migration.

## Subject executable validation
Exact-revision CI executes `just qualify` under uv 0.12.0, Go 1.25.0 and CUE v0.17.1 and remains successful.

## Bundle
`projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260905T160243Z/`
