# ctrl upstream impact report

## Run identity

- Run ID: `20260815T155602Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `0c5195d718d48baf1a787d36e1de4e6d20d67351`
- Publication revision: recorded in `latest.json` after manifest seal
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Prior sealed run: `20260815T140000Z`
- Bootstrap baseline: `false`

The authority revision is the pre-publication factory snapshot evaluated by this run. `fatb4f/factory@main` advanced once during acquisition to add a sibling upstream-monitor profile; the shared compatibility ingress was re-read, and no selected `profiles_ctrl` CUE or ctrl compatibility/template file changed in that intervening commit.

## Subject context

`fatb4f/ctrl@main` remains `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`, identical to the previous admitted run. `spec/` and CUE remain the subject's sole qualification semantic authority. `control/components.cue` preserves component-local ownership and `control/source-imports.cue` preserves explicit imported source revisions/tree identity; sibling checkout paths are not dependency or assembly authority. Python runtime is 3.14 and workspace/lock configuration is unchanged with the subject revision.

## Project topology and ownership

The selected `topology.cue` is architecture/ownership context only:

- **ctrl**: concrete mutation-control and qualification system; `ctrl/spec` + CUE own qualification semantics.
- **python-intel**: observation/evaluation architecture, not analyzer or qualification authority.
- **PyPI/wheel/PEP pipeline**: first python-intel materialization: acquire -> normalize -> analyze -> correlate -> evaluate -> Arrow -> DuckDB -> Ibis -> Marimo.
- **semagrams**: future mutation-graph substrate; non-authoritative until admitted into `ctrl/spec`.

Adapters observe; CUE derives and gates. Component-local ownership is preserved. Federation is limited to explicitly declared pins, contract references, compatibility/federation evaluations, and assembly commands.

## Source state

Every declared source/channel was resolved independently. Channels with the same name remain distinct observations.

| Source | Channel | Ref | Resolved revision | Observed surface/state |
|---|---|---|---|---|
| `codex` | `main` | `main` | `c4941302c73c6322b153bba13ac0a9f4396301d6` | Codex protocol/tool-policy/rollout surfaces; changed; no admitted reportable closure |
| `codex` | `latest-alpha-cli` | `latest-alpha-cli` | `334c6ed7fd26cb96d9aa2849cf384ec8fb218f34` | Codex alpha forecast; unchanged |
| `cpython` | `3.14` | `3.14` | `3192cfdff70ef0771f39d2da046186d01951259c` | CPython active semantic/runtime surfaces; unchanged |
| `cpython` | `main` | `main` | `948fd7e5c084274c3945d2004a7fffd19c907a15` | CPython forecast surfaces; unchanged |
| `astral-python` | `main` | `main` | `52ec0cf408d3cabbfc180434db750187c55d82d7` | type semantics + IDE observation; changed |
| `scip` | `main` | `main` | `5890b2ac1c0970c5606b71c833b733cffd091c90` | SCIP semantic identity; newly admitted channel baseline |
| `otel-python-core` | `main` | `main` | `aa8e7dbdfa4bd35c1d780d8c4cd5c7d6e3983ea8` | OTel runtime; unchanged |
| `otel-python-contrib` | `main` | `main` | `1192425cdc7be548a1f50e59cef0c13424fdfbad` | OTel contrib providers; unchanged |
| `otel-genai-semconv` | `main` | `main` | `30182acd5ed78ab5f619041eaec5e95a4eb83a48` | GenAI semantic model; unchanged |
| `otel-python-genai` | `main` | `main` | `ae0343175a418e4d661e2508eec17dbd887ad5a3` | GenAI Python realization; unchanged |
| `otel-arrow` | `main` | `main` | `5abeaf8efbd37b6c8519fc8edcd519281e988bbd` | OTAP/dataflow; unchanged |
| `dlt` | `devel` | `devel` | `a4243c994b9fade227d23e4bb18dab70037507cf` | external observation acquisition; unchanged |
| `arrow` | `main` | `main` | `e611f48081ec927e18e5bcb72fbd071c15c76b08` | typed relations; new release-watch baseline |
| `duckdb` | `main` | `main` | `f8e1c96a535d54c6a2785a0b13c6fcdb148c067b` | relational substrate; new release-watch baseline |
| `ibis` | `main` | `main` | `799a2a9594060e2a14aa83a8c47d9ec22b8d9a81` | semantic query projection; new release-watch baseline |
| `marimo` | `main` | `main` | `9e31b27eef6c3d35782513614382821f2f6bb97e` | diagnostic projection; new release-watch baseline |
| `pydantic-graph` | `main` | `main` | `25a70926cfafdfc63b3d32c1b5f2c7f139e2c58c` | replaceable execution graph; new release-watch baseline |
| `cue` | `pinned` | `806821e40fae070318600a264d311517e596353b` | `806821e40fae070318600a264d311517e596353b` | pinned evaluator authority; unchanged |
| `cue` | `master` | `master` | `f356f8f46cedb8e853ed200fb46ab49a68bfe357` | evaluator forecast; unchanged |
| `uv` | `main` | `main` | `f1a42680ff5272232d65748acf338b19778dde24` | reproducibility; unchanged |
| `jj` | `main` | `main` | `7fa941edb45b62efdadff6b01f6f8674dbad9063` | agent change-control release-watch; unchanged |

`scip/main`, `arrow/main`, `duckdb/main`, `ibis/main`, `marimo/main`, and `pydantic-graph/main` were added to the selected profile after the previous admitted run. This run therefore establishes **per-channel onboarding baselines** for them; it does not invent historical deltas. The run itself is not a bootstrap run because `20260815T140000Z` is a prior admitted bundle.

## Codex projection graph

`codex/main` advanced two commits from `a7edf37cb46b5fc4d50bd03df8e5999a86f602eb` to `c4941302c73c6322b153bba13ac0a9f4396301d6`.

Observed changes include:

- optional workload identity context forwarding, redaction, session-fingerprint separation, and removal from model-reachable child environments;
- persistent `codex exec` threads requesting paginated history with legacy fallback.

No Codex report item is promoted. The persistent-history implementation changes are under `codex-rs/exec/`, which is not a declared Codex graph-node path in the current profile. The workload-identity change touches `codex-rs/protocol/src/shell_environment.rs`, but it does not complete an admitted monitored-surface -> graph relationship -> local obligation trace under the current surface catalogue. The contract forbids inferring propagation from names/imports alone.

## Python semantic and operational graph

CPython `3.14` and `main` are unchanged, so there is no compiler/runtime semantic delta.

Astral `main` advanced two commits from `36cc91ffb72adde11f0c4dfb76330a07481f6153` to `52ec0cf408d3cabbfc180434db750187c55d82d7`. The material semantic change is ty's modeling of exception-suppressing synchronous and asynchronous context managers. It maps explicitly:

```text
astral-python/main observation
-> astral-type-semantics surface
-> astral-ty-core + astral-ty-semantic
-> astral-core-ty-semantic
-> astral-ty-correlation
-> astral-cpython-correlation
-> packages/qualification-workflow + spec/profiles
-> note
```

Decision: `note`.

This remains **forecast analyzer evidence**. The subject revision and lock state did not change, and no executable Astral/CPython correlation or local probe ran. CPython remains semantic/runtime authority; Ruff/ty remain analyzer observations.

SCIP is now an explicitly declared identity provider, but `scip/main` has no prior admitted channel observation to compare. No SCIP change claim is emitted. The current graph catalogue also has no explicit SCIP upstream node, so future SCIP deltas cannot be promoted until the required surface -> graph-node path exists; this unresolved graph-binding coverage is preserved rather than inferred through python-intel topology.

## Observation and acquisition graph

OpenTelemetry core, contrib, GenAI semantic conventions, Python GenAI instrumentation, OTel-Arrow, and dlt heads are unchanged from the previous admitted run.

Authority remains:

```text
OpenTelemetry -> execution / causal observations
dlt           -> external observation acquisition
ctrl probes   -> local executable witnesses
CUE           -> qualification derivation / gating
```

No telemetry, dlt, or OTel-Arrow change is promoted.

## Relational and diagnostic projection

Arrow, DuckDB, Ibis, Marimo, and pydantic-graph are newly declared release-watch/projector channels, so their current heads are baseline observations only.

Their roles remain non-authoritative:

```text
Arrow          typed interchange
DuckDB         relational substrate
Ibis           semantic relational projection
Marimo         interactive diagnostic projection only
pydantic-graph replaceable execution-graph implementation
```

The current graph catalogue exposes `ctrl-relational-ingress` but does not declare upstream graph nodes for these five projector implementations. Because no prior admitted channel baseline exists, no historical delta is manufactured; future reportable changes require explicit graph binding before impact propagation.

## Correlation carrier policy

No upstream correlation-policy source changed. The selected profile still requires semantic identity to remain distinct from trace/span identity:

```text
repository revision
-> agent turn
-> tool / MCP call
-> mutation
-> test attempt / probe
-> symbol / source occurrence
-> runtime observation
-> evidence
-> qualification
```

Missing semantic identity may not be manufactured from telemetry. Baggage remains deny-by-default and sensitive/source payloads remain out of telemetry carriers.

## P0 executable frontier

No executable validation was available through the GitHub App actuator.

- CUE validation: not executed.
- CPython regrtest: not executed.
- ctrl probes: not executed.
- Astral/CPython correlation: not executed.
- SCIP correlation: not executed.
- OpenTelemetry pipeline: not executed.
- OTLP/OTAP trace round-trip: not executed.
- Arrow/DuckDB/Ibis relational projection: not executed.

Accordingly, qualification remains `observation_only`. `terminal_success` means only that the monitor loop and publication admission completed; it is not an executable qualification verdict.

## Critical

None.

## High

None.

## Notes

1. **Astral ty context-manager suppression semantics** — `note`. Track the forecast analyzer change for later CPython/probe correlation; do not promote it to runtime truth or qualification authority.

## No local action

- Codex `main` changed, but the observed paths do not complete the profile's required admitted surface/graph/local-consumer trace, so no action is manufactured.
- CPython, OpenTelemetry families, OTel-Arrow, dlt, CUE, uv, and jj are unchanged.
- Newly declared SCIP and relational/projector channels are baselined without retroactive delta claims.
- Optional release-watch/projector sources remain non-blocking absent a declared local consumer/gate and a source-qualified impact path.

## Publication

- Bundle: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T155602Z/`
- Manifest: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T155602Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/ctrl/contract-surface/latest.json`
- Export unit: directory
- Write order: `report.md` -> `summary.md` -> `evidence.json` -> `manifest.json` -> `latest.json`

## Validation notes

- Worker authority, all selected `profiles_ctrl` CUE, `topology.cue`, compatibility entrypoint, fixed template, graph, correlation, evidence, assertions, and publication plan: read.
- Current subject context required by the profile: read.
- Project topology treated as architecture/ownership context only.
- Every declared source/channel: independently resolved.
- Previous admitted run: `20260815T140000Z`; no bootstrap substitution.
- Report/summary: projections of `evidence.json`.
- Executable qualification: unavailable to GitHub App; preserved as `observation_only`.
- Unresolved coverage preserved: no explicit SCIP or Arrow/DuckDB/Ibis/Marimo/pydantic-graph upstream graph nodes in the current graph catalogue.
- Cross-repository writes and issue updates: none.
