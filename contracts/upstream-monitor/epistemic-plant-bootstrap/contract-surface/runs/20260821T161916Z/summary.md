# epistemic-plant-bootstrap run summary

## Run identity

- Run: `20260821T161916Z`
- Monitor state: `terminal_success`
- Qualification state: `executable_validated`
- Authority revision: `69c9689c88fe0daa2bab879dc4366e12549366f7`
- Subject revision: `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`

## Baseline

Compared with admitted run `20260818T161810Z`; this is not a bootstrap baseline. The subject revision and pinned GUAC, Gemara, CUE, Go, and uv semantics remain unchanged.

## Decisions

- Critical / blocking gates: **3** — GUAC forecast candidate-production breadth, Gemara forecast evidence-vocabulary divergence, CUE forecast evaluator evolution.
- Notes: **1** — uv release-watch changed resolver/lock/build internals without demonstrated effect on pinned uv 0.12.0.
- No local action: Go optional forecast advanced without demonstrated impact on the pinned GUAC construction contract; CycloneDX release-watch is unchanged.

Current moving heads: GUAC `a9129548f714885b79cdc27169e1100eadb1af1d`, Gemara `9d36c253484d14922010252bfffe58bdcd49a144`, CUE `2920479eca26e8377d4ae06a4c4d857e578095e3`, CycloneDX `e02a34ae42a48239f54e04f75280b9000b29f1fb`, Go `f85791f6df0a17520de11df55b5cf5185f2a41fa`, uv `244bc3b99fcf24432a4ae2b5f0c437adb7487e90`.

## Authority separation

Pinned source declarations remain the admission oracle. GUAC remains observation-only, Gemara remains the pinned evidence/result vocabulary, and CUE v0.17.1 remains qualification authority. Moving forecast/release-watch heads do not acquire authority by recency. Operational failure remains `INCONCLUSIVE`.

## Qualification state

Exact-revision CI job `93478571495` was re-resolved and still records successful checkout/tool setup, locked uv sync, `just qualify`, evidence upload, and completion for the unchanged subject revision. The GitHub actuator did not execute CUE/GUAC locally.

## Subject executable validation

The checked-in `just qualify` dependency chain remains `bootstrap-check → check → vet → eval`. Its success establishes executable validation of the experiment, not a supported hypothesis verdict. `just promote` was not invoked.

## Bundle

Publication is admitted because source-qualified observations differ from the prior sealed run. Bundle: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260821T161916Z/`.