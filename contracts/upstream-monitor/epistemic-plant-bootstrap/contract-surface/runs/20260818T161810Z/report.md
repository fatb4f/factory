# epistemic-plant-bootstrap upstream impact report

- Run: `20260818T161810Z`
- Terminal state: `terminal_success`
- Qualification state: `executable_validated`
- Decision: `blocking-gate`
- Severity: `critical`

## Control invariants

- Pinned source remains admission oracle: `true`
- GUAC remains observation-only: `true`
- CUE remains qualification authority: `true`
- Operational failure remains inconclusive: `true`

This run compares against admitted run `20260815T160543Z`. It is **not** a bootstrap baseline. Current factory authority was acquired at `da08ab9c69e11689134bfee8f931c8e9996dbd84`; the worker/profile authority is semantically unchanged from the prior run. Subject semantic context remains exactly `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`.

The preserved plant lineage remains:

`pinned SourceDocument → declared dependency pair → GUAC IsDependency observation → normalized ObservedRelationship → graph-generation receipt → Python admission proposal → CUE source-declaration qualification → Gemara evaluation evidence → admission receipt → EpistemicObservation → fresh-run determinism comparison`

## Source observations

| Source | Channel | Mode | Ref | Strong Git head | Delta from admitted run | Observed surface | Status |
|---|---|---|---|---|---|---|---|
| guac | pinned | active-baseline | `v1.1.0` | `a399a54801bf` | unchanged | IsDependency + coordinates + runtime | resolved |
| guac | main | forecast | `main` | `51d9b1c420f2` | +9 commits | candidate production + query/assembler behavior | resolved |
| gemara | pinned | pinned-authority | `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b` | `4822ce0071b1` | unchanged | #Evidence/#Result/#Datetime | resolved |
| gemara | main | forecast | `main` | `9d36c253484d` | unchanged | #Evidence + assessment/result constraints | resolved |
| cue | pinned | pinned-authority | `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3` | `fc6c0b2ecd36` | unchanged | cue vet + admission closure | resolved |
| cue | master | forecast | `master` | `f356f8f46ced` | unchanged | cue vet/comprehension/reference semantics | resolved |
| cyclonedx | master | release-watch | `master` | `e02a34ae42a4` | unchanged | dependency closure release-watch | resolved |
| golang | pinned | active-baseline | `go1.25.0` | `6e676ab2b809` | unchanged | GUAC build identity | resolved |
| golang | master | forecast | `master` | `601d28a5b00d` | +29 commits | optional toolchain forecast | resolved |
| uv | pinned | active-baseline | `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e` | `b88d7c5c46cb` | unchanged | frozen/locked environment | resolved |
| uv | main | release-watch | `main` | `392e0a0aa39f` | +25 commits | resolver/lock release-watch | resolved |

Pinned and forecast/release-watch channels remain distinct. No forecast head is treated as replacing a pinned subject dependency by recency.

### Incremental source delta

- **GUAC:** the new 9-commit delta changes scorecard collection/certification, dependencies, Ent package sorting, and supporting tests. It does not change the checked `IsDependency` schema, which remains Git blob `8837ccd3adce68e19a3ad78831bd75250bfbfa2d`. Ent/package sorting may alter backend/result ordering, but ordering is explicitly excluded from stable semantic identity. The previously observed CycloneDX 1.7 candidate-production expansion remains in current `main` ancestry.
- **Go:** the optional forecast moved 29 commits, dominated by compiler/SSA reorganization and assembler/runtime work. No change was demonstrated on the profile-declared local `go install` / `go version -m` / `GOBIN` contract used to construct pinned GUAC v1.1.0.
- **uv:** the release-watch moved 25 commits and includes resolver/lock implementation changes. The subject still pins uv 0.12.0 and its checked-in `uv.lock`/`uv_build>=0.12,<0.13` contract is unchanged; no executable effect on the admitted frozen/locked environment is established.

## Impact items

### critical-guac-forecast-candidate-production

**GUAC main remains capable of broader IsDependency candidate production than the v1.1.0 baseline**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `guac/main@51d9b1c420f2f65db1d15793da64a981bad9dfcd` |
| Graph nodes | `guac-ingestion`, `guac-graphql-contract`, `guac-coordinate-normalizer`, `graph-generation`, `admission-policy`, `cue-qualification` |

Current GUAC main retains the previously observed CycloneDX 1.7-to-`IsDependency` candidate-production expansion while the checked GraphQL `IsDependency` schema remains byte-identical to v1.1.0. The incremental package-sorting change does not alter stable semantic identity because response ordering/backend identifiers are excluded before normalization.

**Local contract impact:** Do not advance the GUAC pin from v1.1.0 without replaying the digest-pinned corpus through `guac-contract → coordinate normalization → graph generation → admission-policy → CUE qualification → fresh-run determinism`.

**GUAC authority questions**

1. Candidate set or identity: **candidate set can change** across the pin-to-current forecast because current main includes broader CycloneDX candidate production. No new stable candidate-identity change is established by the incremental 9-commit delta.
2. GUAC/provenance/backend as semantic authority: **no** under the current subject contract. Pinned source declarations and CUE-qualified admission remain above GUAC observations, provenance witnesses, backend IDs, and response ordering. Any future change crossing this boundary remains blocking even if tests pass.

### critical-gemara-forecast-evidence-vocabulary

**Gemara main still differs from the pinned v1.4.1 evidence vocabulary**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `gemara/main@9d36c253484d14922010252bfffe58bdcd49a144` |
| Graph nodes | `gemara-evidence`, `admission-policy`, `cue-qualification` |

The forecast head is unchanged from the admitted run. It still changes `#Evidence` by adding an optional evidence source mapping and changes assessment start-time validation through a strict wrapper. These semantics feed the declared `gemara-evidence → admission-policy → cue-qualification` path.

**Local contract impact:** Keep Gemara v1.4.1 pinned. A pin advance requires re-specialization and the declared bootstrap/CUE/experiment gates.

### critical-cue-master-not-linear-pin-advance

**CUE master remains a non-linear forecast relative to the pinned v0.17.1 evaluator**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `cue/master@f356f8f46cedb8e853ed200fb46ab49a68bfe357` |
| Graph nodes | `cue-qualification`, `admission-receipts`, `fresh-run-determinism`, `promotion-gate` |

The CUE forecast head is unchanged from the admitted run. It cannot be substituted for v0.17.1 by ref recency; the prior comparison established a divergent line and semantic-validator changes on `cue vet`, comprehension, and reference-resolution surfaces.

**Local contract impact:** Resolve an explicit release-line candidate before any CUE pin advance, then rerun source-closure qualification and fresh-run determinism before promotion.

## Executable validation

The subject revision is unchanged at `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`. Exact-revision repository CI job `93478571495` remains valid executable evidence: setup, locked uv sync, and `just qualify` all completed successfully. The subject command contract expands `just qualify` in the required order:

`just bootstrap-check → just check → just vet → just eval → just qualify`

The GitHub App actuator did not execute local CUE/GUAC itself; this is recorded as execution elsewhere. Qualification remains `executable_validated`. `just qualify` success is evidence of valid evaluation only, not an admission oracle for the POC hypothesis. `just promote` was not invoked.

## Operator conclusion

`terminal_success` / `executable_validated`.

The current pinned subject baseline remains coherent. The same three critical **forecast adoption gates** remain active: GUAC candidate-production breadth, Gemara imported evidence semantics, and CUE evaluator-line semantics. None represents semantic rejection of the pinned experiment.

Since the admitted run, GUAC, Go, and uv forecast/release-watch heads moved. GUAC's incremental changes do not create a new semantic-identity finding; Go has no demonstrated graph-bound local impact; uv changes lock/resolver internals but the subject's pinned 0.12.0 frozen/locked realization remains unchanged. These observations are retained without promoting optional forecast churn into blocking dependencies.

All required channels resolved and no acquisition gap was converted into “no impact.” The bundle differs from the admitted run through its authority revision and observed source heads, so publication admission succeeds.

Publication target: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260818T161810Z/`. `manifest.json` must seal the exact report/summary/evidence blobs last; only that manifest-seal commit may become `publication_revision` in `latest.json`.
