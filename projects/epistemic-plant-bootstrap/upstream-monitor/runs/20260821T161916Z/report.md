# epistemic-plant-bootstrap upstream impact report

- Run: `20260821T161916Z`
- Terminal state: `terminal_success`
- Qualification state: `executable_validated`
- Decision: `blocking-gate`
- Severity: `critical`

## Control invariants

- Pinned source remains admission oracle: `true`
- GUAC remains observation-only: `true`
- CUE remains qualification authority: `true`
- Operational failure remains inconclusive: `true`

This run compares against admitted run `20260818T161810Z`. It is **not** a bootstrap baseline. The pre-publication factory authority snapshot is `69c9689c88fe0daa2bab879dc4366e12549366f7`. Subject semantic context remains exactly `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`; the selected profile CUE blobs are unchanged from the admitted run.

The preserved plant lineage is:

`pinned SourceDocument → declared dependency pair → GUAC IsDependency observation → normalized ObservedRelationship → graph-generation receipt → Python admission proposal → CUE source-declaration qualification → Gemara evaluation evidence → admission receipt → EpistemicObservation → fresh-run determinism comparison`

## Source observations

| Source | Channel | Mode | Ref | Strong Git head | Delta from admitted run | Observed surface | Status |
|---|---|---|---|---|---|---|---|
| guac | pinned | active-baseline | `v1.1.0` | `a399a54801bf` | unchanged | IsDependency + coordinates + runtime | resolved |
| guac | main | forecast | `main` | `a9129548f714` | +2 commits | candidate production + query/assembler behavior | resolved |
| gemara | pinned | pinned-authority | `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b` | `4822ce0071b1` | unchanged | #Evidence/#Result/#Datetime | resolved |
| gemara | main | forecast | `main` | `9d36c253484d` | unchanged | #Evidence + assessment/result constraints | resolved |
| cue | pinned | pinned-authority | `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3` | `fc6c0b2ecd36` | unchanged | cue vet + admission closure | resolved |
| cue | master | forecast | `master` | `2920479eca26` | +44 commits | evaluator/compile/unification-adjacent semantics | resolved |
| cyclonedx | master | release-watch | `master` | `e02a34ae42a4` | unchanged | dependency closure release-watch | resolved |
| golang | pinned | active-baseline | `go1.25.0` | `6e676ab2b809` | unchanged | GUAC build identity | resolved |
| golang | master | forecast | `master` | `f85791f6df0a` | +44 commits | optional toolchain forecast | resolved |
| uv | pinned | active-baseline | `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e` | `b88d7c5c46cb` | unchanged | frozen/locked environment | resolved |
| uv | main | release-watch | `main` | `244bc3b99fcf` | +47 commits | resolver/lock/build release-watch | resolved |

Pinned and forecast/release-watch channels remain distinct. No moving channel is allowed to rewrite a pinned subject dependency by recency.

### Incremental source delta

- **GUAC:** `main` advanced two commits from `51d9b1c420f2f65db1d15793da64a981bad9dfcd` to `a9129548f714885b79cdc27169e1100eadb1af1d`. The delta changes dependency metadata and emitter code/tests, not the declared IsDependency query/normalization surface. The current `IsDependency` schema remains Git blob `8837ccd3adce68e19a3ad78831bd75250bfbfa2d`, so no new stable candidate-identity change is established by this incremental delta. The previously admitted pin-to-forecast candidate-production expansion remains in current ancestry.
- **CUE:** `master` advanced 44 commits from `f356f8f46cedb8e853ed200fb46ab49a68bfe357` to `2920479eca26e8377d4ae06a4c4d857e578095e3`. The delta touches evaluator-adjacent implementation including `internal/core/compile/predeclared.go`, command/filetype unification/registry code, parser and encoding paths. This is forecast evidence only; it does not change the subject's pinned v0.17.1 evaluator, but it strengthens the requirement to re-run CUE qualification before any pin advance.
- **Go:** optional `master` advanced 44 commits. The delta is dominated by compiler/SSA, assembler, runtime, TLS/network and SIMD work. No effect is demonstrated on the declared local `go install` / `go version -m` / `GOBIN` construction contract for pinned GUAC v1.1.0.
- **uv:** release-watch `main` advanced 47 commits and touches resolver, lock, build-backend, metadata and configuration internals. The subject remains pinned to uv 0.12.0 with a checked-in lock and frozen/locked invocations; no effect on that admitted realization is established.
- **Gemara and CycloneDX:** moving heads are unchanged from the admitted run.

## Impact items

### critical-guac-forecast-candidate-production

**GUAC main remains capable of broader IsDependency candidate production than the v1.1.0 baseline**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `guac/main@a9129548f714885b79cdc27169e1100eadb1af1d` |
| Graph nodes | `guac-ingestion`, `guac-graphql-contract`, `guac-coordinate-normalizer`, `graph-generation`, `admission-policy`, `cue-qualification` |

Current GUAC main retains the previously admitted broader CycloneDX-to-`IsDependency` candidate-production behavior relative to v1.1.0. The two-commit incremental delta does not touch the checked `IsDependency` schema or coordinate-normalization contract, and the schema blob remains unchanged.

**Local contract impact:** Do not advance the GUAC pin without replaying the digest-pinned corpus through query, normalization, graph generation, admission, CUE qualification, and fresh-run determinism.

**GUAC authority questions**

1. Candidate set or identity: **candidate set can change** across the pinned-to-current forecast; the new two-commit delta establishes no additional stable candidate-identity change.
2. GUAC/provenance/backend as semantic authority: **no** under the current subject contract. Pinned source declarations and CUE-qualified admission remain above GUAC observations, provenance witnesses, backend IDs, and response ordering.

### critical-gemara-forecast-evidence-vocabulary

**Gemara main still differs from the pinned v1.4.1 evidence vocabulary**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `gemara/main@9d36c253484d14922010252bfffe58bdcd49a144` |
| Graph nodes | `gemara-evidence`, `admission-policy`, `cue-qualification` |

The forecast head is unchanged. It still differs from the pinned v1.4.1 evidence/result vocabulary on declared admission inputs. Keep v1.4.1 pinned; a pin advance requires re-specialization and the declared bootstrap/CUE/experiment gates.

### critical-cue-forecast-evaluator-delta

**CUE master advanced across evaluator-adjacent surfaces while v0.17.1 remains the qualification authority**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `cue/master@2920479eca26e8377d4ae06a4c4d857e578095e3` |
| Graph nodes | `cue-qualification`, `admission-receipts`, `fresh-run-determinism`, `promotion-gate` |

The 44-commit forecast delta includes compile/predeclared and filetype unification/registry changes plus command, parser and encoding work. These are not admitted evaluator semantics, but they intersect the profile's CUE evaluation/closedness surface closely enough that a future pin advance remains a blocking gate.

**Local contract impact:** Keep v0.17.1 as the evaluator. Before any advance, select an explicit release-line revision and rerun bootstrap specialization, CUE vet/source closure, experiment evaluation, and determinism qualification.

### note-uv-release-watch

**uv main continues to move across lock/resolver/build internals without changing the pinned 0.12.0 subject realization**

| Field | Value |
|---|---|
| Decision | `note` |
| Severity | `note` |
| Source | `uv/main@244bc3b99fcf24432a4ae2b5f0c437adb7487e90` |
| Graph nodes | `bootstrap-gate` |

The release-watch delta intersects resolver/lock/build implementation, but the subject's exact uv 0.12.0 CI setup, checked-in `uv.lock`, `uv sync --locked`, and `--frozen --no-sync` command contract are unchanged. No adoption action is admitted.

## No local action

Go `master@f85791f6df0a17520de11df55b5cf5185f2a41fa` changed substantially, but no graph-bound effect is demonstrated on the pinned Go 1.25.0 GUAC construction/verification surface. CycloneDX `master@e02a34ae42a48239f54e04f75280b9000b29f1fb` is unchanged and cannot rewrite digest-pinned fixture meaning.

## Executable validation

The subject revision remains `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`. Exact-revision CI job `93478571495` was re-resolved during this run: checkout, uv setup, Go setup, CUE setup, `uv sync --locked --group dev`, `just qualify`, evidence upload, and job completion are all recorded as `completed/success`.

The checked-in command contract defines `just qualify` as `bootstrap-check → check → vet → eval`; therefore the repository's required gate order remains executable evidence for this unchanged subject revision and unchanged pinned CUE/Gemara/Go/uv semantics. The GitHub App actuator did not itself execute local CUE/GUAC. `just qualify` success establishes valid experiment evaluation, not a supported POC verdict. `just promote` was not invoked.

## Operator conclusion

`terminal_success` / `executable_validated`.

The pinned experiment remains coherent and authority separation is preserved. Three forecast adoption gates remain critical: GUAC candidate-production breadth, Gemara evidence-vocabulary evolution, and CUE evaluator evolution. None is semantic rejection of the pinned experiment.

The sealed bundle differs from `20260818T161810Z` because current source-qualified observations changed, most notably CUE master plus GUAC, Go, and uv moving heads. Publication admission therefore succeeds.

Publication target: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260821T161916Z/`. `manifest.json` seals exact report/summary/evidence blobs last; only its commit becomes `publication_revision`.