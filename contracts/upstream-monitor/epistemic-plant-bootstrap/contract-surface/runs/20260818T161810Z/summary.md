# epistemic-plant-bootstrap upstream-monitor summary

## Run identity

| Field | Value |
|---|---|
| Run | `20260818T161810Z` |
| Profile | `epistemic-plant-bootstrap` |
| Terminal state | `terminal_success` |
| Qualification state | `executable_validated` |
| Authority revision | `da08ab9c69e11689134bfee8f931c8e9996dbd84` |
| Subject revision | `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb` |
| Previous admitted run | `20260815T160543Z` |

## Baseline

This is a delta run against the previously admitted bundle, not a bootstrap baseline. Worker/profile authority and subject semantic authority are unchanged; observed source heads changed for GUAC main, Go master, and uv main.

Current source heads:

| Source/channel | Strong Git head | Delta |
|---|---|---|
| GUAC pinned / main | `a399a54801bfbffc36bc8748dd97d2d2b3bea378` / `51d9b1c420f2f65db1d15793da64a981bad9dfcd` | main +9 |
| Gemara pinned / main | `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b` / `9d36c253484d14922010252bfffe58bdcd49a144` | unchanged |
| CUE pinned / master | `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3` / `f356f8f46cedb8e853ed200fb46ab49a68bfe357` | unchanged |
| Go pinned / master | `6e676ab2b809d46623acb5988248d95d1eb7939c` / `601d28a5b00dd633b3c3aca6b7a11a058bf1179b` | master +29 |
| uv pinned / main | `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e` / `392e0a0aa39f7f03e2efb688e500ec23a1930d36` | main +25 |
| CycloneDX master | `e02a34ae42a48239f54e04f75280b9000b29f1fb` | unchanged |

## Decisions

| Decision | Count |
|---|---:|
| `blocking-gate` / `critical` | 3 |
| `contract-update` / `high` | 0 |
| `note` report items | 0 |
| `none` report items | 0 |

The same three blocking gates remain: GUAC forecast candidate-production breadth, Gemara forecast evidence-vocabulary drift, and CUE forecast evaluator-line drift. They block pin advancement, not the current subject baseline.

GUAC's new 9-commit delta does not change the `IsDependency` schema and does not demonstrate a new stable identity change. Go's optional forecast delta has no demonstrated local consumer impact. uv's release-watch touches lock/resolver internals, but no effect is established on the pinned uv 0.12.0 frozen/locked subject realization, so it is retained as source observation rather than promoted into an unbound report item.

## Authority separation

Pinned source declarations remain the admission oracle; GUAC observations/provenance/backend state remain evidence-only; CUE remains qualification authority; operational failures remain `INCONCLUSIVE`.

## Qualification state

`executable_validated`. The subject revision is unchanged, and exact-revision CI job `93478571495` still records successful locked environment setup and `just qualify`. Successful qualification is retained as valid execution evidence, not as an oracle for hypothesis support.

## Subject executable validation

The declared command chain remains `bootstrap-check → check → vet → eval → qualify`. `just promote` was not invoked. The GitHub App did not execute local CUE/GUAC itself; executable evidence was produced by repository CI.

## Bundle

Bundle directory: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260818T161810Z/`

`report.md`, `summary.md`, and `evidence.json` are written before `manifest.json`. The manifest-seal commit is the publication revision. `latest.json` is updated only afterward and must reference the manifest-seal commit rather than its own pointer commit.
