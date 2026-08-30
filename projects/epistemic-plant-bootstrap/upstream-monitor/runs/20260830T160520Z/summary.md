# epistemic-plant-bootstrap upstream monitor summary

## Run identity

- Run ID: `20260830T160520Z`
- Monitor state: `terminal_success`
- Qualification state: `executable_validated`
- Subject revision: `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`

## Baseline

Delta from admitted run `20260827T160601Z`. The subject revision and all pinned semantic/toolchain identities are unchanged.

## Decisions

- Critical / blocking-gate: 2 — GUAC forecast changed directly on the P0 keyvalue `IsDependency` surface; CUE forecast changed materially across evaluator/reference/closedness/unification surfaces.
- High / contract-update: 0.
- Notes: Gemara forecast changed only in compatibility/release tooling; CycloneDX, Go and uv forecasts do not alter pinned experiment meaning.

## Authority separation

Pinned CycloneDX source declarations remain the admission oracle; GUAC remains observation-only; CUE v0.17.1 remains semantic qualification authority; operational failures remain inconclusive.

## Qualification state

`executable_validated` is retained from executable evidence tied to the exact unchanged subject revision. The current GitHub-App monitor itself did not execute local probes and does not promote forecast revisions.

## Subject executable validation

GitHub CI for subject commit `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb` completed successfully with the declared `just qualify` chain and pinned uv 0.12.0, Go 1.25.0 and CUE v0.17.1.

## Bundle

`projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260830T160520Z/`
