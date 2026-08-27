# epistemic-plant-bootstrap upstream monitor summary

## Run identity

- Run: `20260827T160601Z`
- Monitor state: `terminal_success`
- Qualification state: `executable_validated`
- Authority: `69db2720357f1f6d68771085e3b69022ea641ffe`
- Subject: `fatb4f/epistemic-plant-bootstrap@9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`

## Baseline

The subject and all active pinned experiment/toolchain revisions are unchanged from the previous admitted run. Current factory authority is the flattened `contracts/workers/upstream-monitor/` + project-local publication layout.

## Decisions

- Critical / blocking-gate: **3** — GUAC main, Gemara main, and CUE master remain forecast state distinct from their admitted pins.
- High / contract-update: **0**.
- Notes: optional Go/uv forecast movement does not establish pinned-toolchain impact.

## Authority separation

Pinned source closure remains the admission oracle; GUAC remains observation-only; Gemara remains evidence vocabulary; CUE remains qualification authority; operational failures remain inconclusive rather than semantic rejection.

## Qualification state

`executable_validated`. Exact subject commit `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb` has an independent successful GitHub Actions `qualify` execution using the pinned uv 0.12.0, Go 1.25.0 and CUE v0.17.1 toolchain. It ran bootstrap resolution, quality/type checks, 23 unit tests, CUE vet and experiment evaluation with `verdict: supported`.

## Subject executable validation

This validation applies only to the unchanged pinned subject chain. It does not close or validate the GUAC/Gemara/CUE forecast promotion gates.

## Bundle

`projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260827T160601Z/`
