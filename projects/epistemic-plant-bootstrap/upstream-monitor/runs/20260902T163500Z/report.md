# epistemic-plant-bootstrap upstream impact report

## Run identity

- Run ID: `20260902T163500Z`
- Monitor state: `terminal_success`
- Terminal state: `terminal_success`
- Qualification state: `executable_validated`
- Authority revision: `72534f558c3d9d00eba8ab4d1ef7b8647dd4e9b9`
- Publication revision: `not-yet-sealed`
- Subject revision: `9d8c1897a6617a5d3ec9cc42eb060ce4c2ac96fb`
- Bootstrap baseline: `false`

## Subject authority

The subject revision is unchanged. Pinned CycloneDX fixture bytes/digests, `BOOTSTRAP_SPEC.md`, `HYPOTHESIS_PROBLEM_STATEMENT.md`, `spec/schema.cue`, and `spec/poc.cue` remain subject-local semantic authority. CUE v0.17.1 remains the qualification authority; Python proposes evaluations; GUAC remains observation-only.

## Source state

- GUAC pinned v1.1.0: `a399a54801bfbffc36bc8748dd97d2d2b3bea378`, unchanged active baseline.
- GUAC main: `20b74e29c02e9d85cff6410ab1c60d51596d031f`, 11 commits ahead of the prior monitored forecast. Changes continue to touch the `keyvalue` backend used by P0, though the latest commit itself is Ent migration tooling.
- Gemara pinned v1.4.1: `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b`, unchanged.
- Gemara main: `322e7875165d9978415736c6409e82f40feeb8b0`; current movement is repository/workflow tooling with no established `#Evidence`/`#Result` vocabulary impact.
- CUE pinned v0.17.1: `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3`, unchanged.
- CUE master: `69d097ba2878cfe24c28f1e7012836f9b934ff08`, unchanged from the prior monitor; the previously observed evaluator divergence remains forecast evidence only.
- CycloneDX master: `595d98f16159bdf7463adc140509ded479130b8b`, changed in current specification/doc-generation work; pinned fixture bytes remain authoritative for P0.
- Go pinned 1.25.0 remains the active build toolchain. Go master is `8213feb42277dd335bbab97e8d97837d8634b0fc`, optional forecast only.
- uv pinned 0.12.0 remains the frozen environment baseline. uv main is `63ef84e362a7bee02bc54f0a0707523da24d41ea`, optional release-watch only.

## Authority separation

- Pinned source remains admission oracle: `true`
- GUAC remains observation-only: `true`
- CUE remains qualification authority: `true`
- Operational failure remains inconclusive: `true`

## Dependency and admission graph

The declared path remains pinned source documents → GUAC ingestion/IsDependency query → stable coordinate normalization → content-addressed graph generation → Python admission proposal → independent CUE source-closure qualification → admission receipt → epistemic observation → fresh-run determinism → promotion gate. No upstream repository state is promoted to monitor or subject semantic authority.

## Correlation lineage

Stable identity remains content-addressed: source document SHA-256, GraphQL query SHA-256, graph-generation digest, candidate/evaluation/receipt digests, transition receipts, and epistemic-observation derivation digest. GUAC internal IDs, ordering, runtime timestamps and backend-local identifiers remain excluded.

## Critical

### GUAC forecast remains behind an explicit migration gate

GUAC main advanced 11 commits beyond the previous forecast head and changed several `pkg/assembler/backends/keyvalue/` files, including backend/package/path/artifact surfaces. Because P0 explicitly consumes GUAC v1.1.0 `keyvalue`, main remains blocked from replacing the pin until the full source-closure → query/normalization → CUE admission → fresh-run determinism chain is replayed.

### CUE forecast evaluator gate remains open

CUE master has not advanced since the previous monitor, but its previously observed evaluator divergence from pinned v0.17.1 remains unresolved. The subject continues to pin v0.17.1 and must replay bootstrap, vet, admission and determinism before any evaluator migration.

## High

None newly admitted. Current CycloneDX master movement cannot rewrite digest-pinned fixture meaning, and optional Go/uv forecasts do not block without demonstrated local consumer impact.

## Notes

Gemara main moved through workflow/dependency maintenance without an established evidence-vocabulary impact. CycloneDX master moved, but P0 source meaning remains anchored to exact fixture bytes and digests.

## No local action

No pin is changed by this monitor. GUAC main, CUE master, Gemara main, CycloneDX master, Go master and uv main remain forecast/evidence channels under their declared roles.

## Executable validation

- CUE execution: `executed_elsewhere`
- Bootstrap execution: `executed`
- Experiment execution: `executed`

The exact unchanged subject revision has a completed successful GitHub Actions `qualify` job. That job executed the pinned uv 0.12.0 / Go 1.25.0 / CUE v0.17.1 environment, `uv sync --locked --group dev`, and `just qualify`, then uploaded POC evidence. Therefore the existing `executable_validated` qualification state remains supported; it is distinct from the POC hypothesis verdict.

## Publication

- Bundle: `projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260902T163500Z/`
- Manifest: `projects/epistemic-plant-bootstrap/upstream-monitor/runs/20260902T163500Z/manifest.json`
- Latest pointer: `projects/epistemic-plant-bootstrap/upstream-monitor/latest.json`
- Export unit: directory
