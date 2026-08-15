# epistemic-plant-bootstrap upstream impact report

- Run: `20260815T160543Z`
- Terminal state: `terminal_success`
- Qualification state: `executable_validated`
- Decision: `blocking-gate`
- Severity: `critical`

## Control invariants

- Pinned source remains admission oracle: `true`
- GUAC remains observation-only: `true`
- CUE remains qualification authority: `true`
- Operational failure remains inconclusive: `true`

The run is a **bootstrap baseline**: no previously admitted `epistemic-plant-bootstrap` run or latest pointer existed at acquisition time. Authority was read from factory snapshot `0c5195d718d48baf1a787d36e1de4e6d20d67351`; subject semantic context was read from `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`. A later factory-only `ctrl` publication did not modify this worker/profile authority.

The preserved plant lineage is:

`pinned SourceDocument → declared dependency pair → GUAC IsDependency observation → normalized ObservedRelationship → graph-generation receipt → Python admission proposal → CUE source-declaration qualification → Gemara evaluation evidence → admission receipt → EpistemicObservation → fresh-run determinism comparison`

## Source observations

| Source | Channel | Mode | Ref | Strong Git head | Observed surface | Status |
|---|---|---|---|---|---|---|
| guac | pinned | active-baseline | `v1.1.0` | `a399a54801bf` | IsDependency + coordinates + runtime | resolved |
| guac | main | forecast | `main` | `19a71cacecd2` | IsDependency candidate production + query shape | resolved |
| gemara | pinned | pinned-authority | `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b` | `4822ce0071b1` | #Evidence/#Result/#Datetime | resolved |
| gemara | main | forecast | `main` | `9d36c253484d` | #Evidence + assessment/result constraints | resolved |
| cue | pinned | pinned-authority | `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3` | `fc6c0b2ecd36` | cue vet + admission closure | resolved |
| cue | master | forecast | `master` | `f356f8f46ced` | cue vet/comprehension/reference semantics | resolved |
| cyclonedx | master | release-watch | `master` | `e02a34ae42a4` | dependency closure release-watch | resolved |
| golang | pinned | active-baseline | `go1.25.0` | `6e676ab2b809` | GUAC build identity | resolved |
| golang | master | forecast | `master` | `72aa6db79430` | optional toolchain forecast | resolved |
| uv | pinned | active-baseline | `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e` | `b88d7c5c46cb` | frozen/locked environment | resolved |
| uv | main | release-watch | `main` | `f1a42680ff52` | frozen/locked release-watch | resolved |

Pinned and forecast/release-watch channels remain distinct. Optional CycloneDX, Go, and uv forecast observations do not alter current pinned subject semantics by ref recency alone.

## Impact items

### critical-guac-forecast-candidate-production

**GUAC main broadens IsDependency candidate production**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `guac/main@19a71cacecd2fcbecdb4c619f2822e5cffb2a8a6` |
| Graph nodes | `guac-ingestion`, `guac-graphql-contract`, `guac-coordinate-normalizer`, `graph-generation`, `admission-policy`, `cue-qualification` |

GUAC main can change the candidate set presented to the plant even though the checked IsDependency GraphQL schema is unchanged.

**Local contract impact:** Do not advance the GUAC pin from v1.1.0 without replaying the digest-pinned corpus through the declared GUAC contract, coordinate-normalization, CUE admission, and fresh-run determinism gates. Preserve GUAC/provenance/backend state as evidence-only.

**Claims**

- Condition 1 — candidate set or identity: YES for candidate set under forecast inputs because GUAC main adds CycloneDX 1.7-to-IsDependency coverage; no change to stable identity for the existing digest-pinned subject corpus is established by this observation, and the IsDependency query schema remains byte-identical.
- Condition 2 — semantic-authority leakage: NO in the current subject contract. GUAC candidates, provenance strings, backend IDs and ordering remain below pinned source declarations and CUE-qualified admission. Any future change that crosses this boundary is blocking even if upstream or local tests pass.

### critical-gemara-forecast-evidence-vocabulary

**Gemara main changes the monitored evidence vocabulary**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `gemara/main@9d36c253484d14922010252bfffe58bdcd49a144` |
| Graph nodes | `gemara-evidence`, `admission-policy`, `cue-qualification` |

Gemara main changes #Evidence and assessment-log constraints that feed CUE-qualified admission evidence.

**Local contract impact:** Keep Gemara v1.4.1 pinned. Any pin advance must re-specialize the imported vocabulary and pass bootstrap-check, vet, eval and qualify before the new evidence shape can participate in admission.

**Claims**

- Gemara main is forecast evidence, not the subject's v1.4.1 vocabulary. Because the changed #Evidence/#Result-adjacent constraints feed gemara-evidence → admission-policy → cue-qualification, adoption is blocked on the declared CUE and experiment probes.

### critical-cue-master-not-linear-pin-advance

**CUE master is not a linear successor of the pinned evaluator**

| Field | Value |
|---|---|
| Decision | `blocking-gate` |
| Severity | `critical` |
| Source | `cue/master@f356f8f46cedb8e853ed200fb46ab49a68bfe357` |
| Graph nodes | `cue-qualification`, `admission-receipts`, `fresh-run-determinism`, `promotion-gate` |

The required CUE forecast channel diverges from the v0.17.1 pinned commit and contains changes on cue vet/comprehension/reference-resolution surfaces.

**Local contract impact:** Do not substitute CUE master for v0.17.1. Resolve an explicit release-line candidate first, then rerun CUE source-closure qualification and fresh-run determinism before any promotion.

**Claims**

- CUE master cannot be treated as 'the newer v0.17.1 evaluator' by ref recency. The semantic-validator node requires an explicit release-line candidate and executable requalification before its behavior can replace the pinned evaluator.

## Executable validation

Executable evidence exists for the **exact subject revision** `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb` in GitHub Actions run `31395890416`, job `93478571495`.

The repository CI executed the subject gate chain in declared order through `just qualify`:

`just bootstrap-check → just check → just vet → just eval → just qualify`

The log records Gemara v1.4.1/CUE v0.17.1/Go 1.25.0/uv 0.12.0 setup, successful bootstrap closure checks, Ruff/format/ty checks, `23 passed` tests, successful `cue vet ./spec`, and an experiment evaluation that printed `verdict: supported`.

Qualification is therefore `executable_validated`. This does **not** mean the monitor inferred hypothesis support from `just qualify` succeeding: the subject's evaluation output is retained as separate evidence, while monitor qualification means the contracted execution was validly exercised. `just promote` was not invoked.

The GitHub App actuator did not itself execute CUE or the subject process; execution occurred in repository CI and is recorded as `cueExecution=executed_elsewhere`.

## Operator conclusion

`terminal_success` / `executable_validated`.

The admitted subject baseline remains coherent at its pinned versions. The monitor found three **forecast adoption gates**, not a current semantic rejection:

1. GUAC main can broaden candidate production while leaving the IsDependency query schema unchanged; stable candidate identity for the existing pinned corpus is not shown to change.
2. Gemara main changes the explicitly monitored imported evidence vocabulary and assessment constraints.
3. CUE master is a divergent forecast line relative to the pinned v0.17.1 evaluator and intersects cue-vet/comprehension/reference semantic surfaces.

None of these observations elevates GUAC, provenance text, backend state, forecast refs, or generated monitor conclusions above pinned source declarations and CUE qualification. All required channels resolved, graph traversal is complete, and there is no unresolved acquisition to convert into a false “no impact” result.

Publication target: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260815T160543Z/`. `manifest.json` must seal the report/summary/evidence blobs last; only that manifest-seal commit may become the `publication_revision` in `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/latest.json`.
