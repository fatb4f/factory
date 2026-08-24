# epistemic-plant-bootstrap upstream impact report

## Run identity

- Run ID: `20260824T161302Z`
- Monitor state: `terminal_success`
- Qualification state: `executable_validated`
- Authority revision: `f97d97ea3e8aa9477b0605af51f402e99535addd`
- Publication revision: `not-yet-sealed`
- Subject revision: `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`
- Bootstrap baseline: `false`

## Subject authority

`fatb4f/epistemic-plant-bootstrap@main` is unchanged from the previous admitted run. `BOOTSTRAP_SPEC.md`, `HYPOTHESIS_PROBLEM_STATEMENT.md`, `spec/schema.cue`, `spec/poc.cue`, and the pinned fixture corpus remain subject semantic authority. Pinned source bytes remain the admission oracle; GUAC remains observation-only; Python remains proposal-only; CUE remains qualification authority; operational failure remains `INCONCLUSIVE` rather than semantic rejection.

The scheduler signal was admitted using the current profile field names `target_repo` and `context_repo`; stale aliases in the invocation did not override current repository authority.

## Source state

Every profile-declared channel resolved independently:

- GUAC pinned v1.1.0 remains `a399a54801bfbffc36bc8748dd97d2d2b3bea378`; `main` advanced from `a9129548f714885b79cdc27169e1100eadb1af1d` to `41b90b26d78f69865a3e6b0fd04dda54bd665890`.
- Gemara pinned `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b` and forecast `9d36c253484d14922010252bfffe58bdcd49a144` are unchanged.
- CUE pinned `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3` and forecast `2920479eca26e8377d4ae06a4c4d857e578095e3` are unchanged.
- CycloneDX master advanced to `4d1842b78fb394c9bf7f6c49398513adebaa0a9b`; the incremental change is CI dependency maintenance, not dependency-closure schema semantics.
- Go pinned 1.25.0 remains `6e676ab2b809d46623acb5988248d95d1eb7939c`; master advanced to `562cc25fec0b71ad1e277317deb417421b46d440` without demonstrated impact on the subject's pinned GUAC construction contract.
- uv pinned 0.12.0 remains `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e`; main advanced to `32f256a6bec4d7ee840a8e71a40ff723df038359` without changing the checked-in lock or frozen/locked subject contract.

## Graph projection and correlation

The profile graph was traversed only through declared relationships: pinned source documents -> extraction/ingestion -> GUAC GraphQL candidate observations -> coordinate normalization -> graph generation -> admission -> CUE qualification -> receipts/observations -> determinism -> bootstrap/promotion gates.

The incremental GUAC delta includes a breaking REST artifact-digest correction requiring `<algorithm>:<digest>`, but the subject consumes the pinned GraphQL `IsDependency` package relationship path, not those artifact REST endpoints. The current delta therefore does not establish a new subject-path contract break. Existing pin-to-main GUAC candidate-production divergence remains a blocking consideration before any pin advance.

## Upstream tests and local probes

The declared gate order remains `source-closure`, `guac-contract`, `admission-contract`, `qualification-contract`, `experiment-contract`, with bootstrap/quality/vet/eval/qualify probes. No new local execution was performed by the GitHub adapter. Because the subject revision, fixture closure, and all active pinned semantics are identical to the previously admitted executable-validated state, that exact-revision evidence remains applicable; forecast-only changes do not rewrite it.

## Critical

### GUAC forecast candidate-production gate remains open

GUAC main continues to differ from the pinned v1.1.0 baseline. The new incremental REST artifact-identity fix does not traverse the subject's declared `IsDependency` path, but it also does not close the existing forecast divergence. Keep the GUAC pin fixed until the digest-pinned corpus is replayed through the declared graph and gates against a proposed new pin.

### Gemara forecast vocabulary remains distinct

Gemara main is unchanged and remains semantically distinct from the pinned v1.4.1 evidence vocabulary. No forecast state becomes admitted vocabulary without re-specialization and CUE qualification.

### CUE forecast remains distinct from pinned evaluator semantics

CUE master is unchanged at `2920479eca26e8377d4ae06a4c4d857e578095e3`; pinned v0.17.1 remains the evaluator selected by the subject. Forecast evaluator semantics cannot replace the pin without requalification.

## High

No new high-impact contract update was established by the incremental source deltas.

## Notes

- CycloneDX master moved only through CI dependency maintenance in the observed increment; it cannot rewrite digest-pinned fixture bytes.
- Go master movement is forecast-only; the subject still builds GUAC with exact Go 1.25.0.
- uv main movement is release-watch only; the subject still pins uv 0.12.0 and the existing `uv.lock`/frozen workflow.

## Authority separation

GUAC candidate/provenance output remains evidence below admission. Backend identifiers remain excluded from stable semantic identity. CUE remains the qualifier. A failed GUAC/source operation would remain `INCONCLUSIVE`; no such unresolved acquisition occurred in this monitor run.

## Publication

- Bundle: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260824T161302Z/`
- Manifest: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/20260824T161302Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/latest.json`
- Export unit: directory

## Validation notes

Worker/profile authority, compatibility projection, subject semantic authority/context, source graph, correlation, execution graph and publication plan were read. All declared channels resolved. No subject repository write, issue update, or copied subject evidence was performed. The exact subject/pin state is unchanged from the admitted executable-validated run; current forecast/release-watch observations do not invalidate that sealed qualification evidence.
