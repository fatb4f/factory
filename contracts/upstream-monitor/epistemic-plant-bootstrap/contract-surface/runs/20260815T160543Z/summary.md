# epistemic-plant-bootstrap upstream-monitor summary

## Run identity

| Field | Value |
|---|---|
| Run | `20260815T160543Z` |
| Profile | `epistemic-plant-bootstrap` |
| Terminal state | `terminal_success` |
| Qualification state | `executable_validated` |
| Authority revision | `0c5195d718d48baf1a787d36e1de4e6d20d67351` |
| Subject revision | `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb` |

## Baseline

This is the bootstrap baseline. No previously admitted run or `latest.json` existed for this profile when the monitor acquired publication state.

Required source heads all resolved:

| Source/channel | Strong Git head |
|---|---|
| GUAC pinned / main | `a399a54801bfbffc36bc8748dd97d2d2b3bea378` / `19a71cacecd2fcbecdb4c619f2822e5cffb2a8a6` |
| Gemara pinned / main | `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b` / `9d36c253484d14922010252bfffe58bdcd49a144` |
| CUE pinned / master | `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3` / `f356f8f46cedb8e853ed200fb46ab49a68bfe357` |
| Go pinned / master | `6e676ab2b809d46623acb5988248d95d1eb7939c` / `72aa6db7943024b48c4d41c1fbc32b57b9fa036e` |
| uv pinned / main | `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e` / `f1a42680ff5272232d65748acf338b19778dde24` |
| CycloneDX master | `e02a34ae42a48239f54e04f75280b9000b29f1fb` |

## Decisions

| Decision | Count |
|---|---:|
| `blocking-gate` / `critical` | 3 |
| `contract-update` / `high` | 0 |
| `note` | 0 |
| `none` report items | 0 |

The three blocking gates concern GUAC forecast candidate production, Gemara forecast evidence-vocabulary drift, and CUE forecast lineage/semantic-validator drift. They block pin advancement, not the current subject baseline.

## Authority separation

Pinned source declarations remain the admission oracle; GUAC observations/provenance/backend state remain evidence-only; CUE remains semantic qualification authority; operational failures remain `INCONCLUSIVE`.

## Qualification state

`executable_validated`. Exact-revision GitHub Actions run `31395890416` / job `93478571495` successfully executed the subject qualification chain. `just qualify` success is recorded as valid execution, not used as an oracle for hypothesis support.

## Subject executable validation

Repository CI exercised `bootstrap-check`, quality checks, `vet`, `eval`, and `qualify`; 23 tests passed and the separate experiment evaluation printed `verdict: supported`. `just promote` was not invoked.

## Bundle

Bundle directory: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260815T160543Z/`

Artifacts: `report.md`, `summary.md`, `evidence.json`; `manifest.json` is written only after those artifacts are complete. The manifest-seal commit is the publication revision. `latest.json` is updated only afterward and never self-references its own commit.
