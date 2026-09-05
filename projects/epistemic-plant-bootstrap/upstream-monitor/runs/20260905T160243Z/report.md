# epistemic-plant-bootstrap upstream impact report

## Run identity

- Run ID: `20260905T160243Z`
- Monitor state: `terminal_success`
- Terminal state: `terminal_success`
- Qualification state: `executable_validated`
- Authority revision: `09d2ee19594152354362f0024a061c31ef7be65b`
- Publication revision: `not-yet-sealed`
- Subject revision: `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`
- Bootstrap baseline: `false`

## Subject authority

The subject remains exactly at the previously qualified revision. Its P0 authority is unchanged: digest-pinned CycloneDX source declarations, GUAC v1.1.0/keyvalue as observation realization, Gemara v1.4.1 evidence vocabulary, and CUE v0.17.1 as admission/qualification authority. The exact-revision CI run remains completed with `success` and executes `just qualify` under the pinned Go 1.25.0, uv 0.12.0, and CUE v0.17.1 toolchain.

The subject repository provides context and subject-local semantic authority only where the selected profile declares it. It does not become Factory monitor authority.

## Source state

- GUAC pinned v1.1.0: `a399a54801bfbffc36bc8748dd97d2d2b3bea378`; active P0 baseline.
- GUAC main: `0f5cf3e81e6aab831439408d26102de6890bb4c9`; forecast. Five commits beyond the previous monitor; fresh changes are repository metadata/dependency and deferred Ent migration-container changes, not the P0 keyvalue/IsDependency contract.
- Gemara pinned v1.4.1: `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b`; pinned evidence vocabulary.
- Gemara main: `e74ec8a1f2bb81262dd643972602eca4c34348ad`; one workflow-dependency update beyond the previous monitor, with no evidence/result vocabulary change.
- CUE pinned v0.17.1: `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3`; subject qualification authority.
- CUE master: `eb886ed07a0864cc6bbc081bb8f1efa9fb834944`; 46 commits beyond the previous monitor, including parser, AST, function, cycle, compilation and internal evaluator changes.
- CycloneDX master: `595d98f16159bdf7463adc140509ded479130b8b`; unchanged from previous monitor. Pinned fixture bytes retain meaning.
- Go pinned 1.25.0: `6e676ab2b809d46623acb5988248d95d1eb7939c`; active GUAC build toolchain. Go master: `c5941983810b68ba93c30f0ef22c91ad63fb3e5c`; optional forecast with no demonstrated P0 pin impact.
- uv pinned 0.12.0: `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e`; frozen environment. uv main: `b73e597cb1aa3d962dd2df5c692718ba4d851969`; optional release forecast without demonstrated local pin impact.

## Authority separation

- Pinned source remains admission oracle: `true`
- GUAC remains observation-only: `true`
- CUE remains qualification authority: `true`
- Operational failure remains inconclusive: `true`

## Dependency and admission graph

The declared path remains pinned source documents -> GUAC ingestion/query -> coordinate normalization -> content-addressed graph generation -> Python admission proposal -> CUE source-closure qualification -> admission receipts -> epistemic observation -> fresh-run determinism -> promotion gate. No upstream forecast is promoted directly into subject semantics.

## Correlation lineage

Stable identity continues to be source-document SHA-256, GraphQL query digest, graph-generation digest, candidate/evaluation/receipt digests and epistemic-observation derivation digest. GUAC backend IDs, response ordering, runtime timestamps, process IDs and ports remain excluded.

## Critical

- **CUE forecast evaluator gate widened.** Master advanced 46 commits beyond the previous monitor across parser/AST, function syntax/semantics, cycle handling, compilation and `internal/core/adt` evaluator surfaces. Pinned v0.17.1 remains authoritative; migration requires replaying bootstrap, CUE vet, admission and fresh-run determinism under a proposed new pin.
- **GUAC forecast P0 migration gate remains open but did not widen.** The five fresh commits after `20b74e29` do not touch the P0 `keyvalue`/`IsDependency` query/normalization surfaces. The broader main-vs-v1.1.0 divergence still requires the declared source-closure/query/CUE/determinism migration qualification before a pin change.

## High

None newly established.

## Notes

None.

## No local action

Gemara main changed only reusable-workflow dependency metadata. CycloneDX master is unchanged. Current Go and uv forecast movement has no demonstrated consumer impact on the pinned P0 toolchain. GUAC's fresh Ent migration-container change is outside the deferred P0 keyvalue realization.

## Executable validation

- CUE execution: `executed_elsewhere`
- Bootstrap execution: `executed`
- Experiment execution: `executed`

The exact subject revision is unchanged and its exact-revision CI run remains successful, so the previously established executable qualification remains applicable. This does not qualify any forecast pin migration.

## Publication

- Bundle: `projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260905T160243Z/`
- Manifest: `projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260905T160243Z/manifest.json`
- Latest pointer: `projects/epistemic-plant-bootstrap/upstream-monitor/latest.json`
- Export unit: directory
