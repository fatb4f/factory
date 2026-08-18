# ctrl upstream impact report

## Run identity

- Run ID: `20260818T160440Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `13fa7714653df86fd6367570fe8fe1e493c39ce8`
- Publication revision: `not-yet-sealed`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Prior sealed run: `20260815T155602Z`
- Bootstrap baseline: `false`

`authority_revision` is the pre-publication factory contract snapshot evaluated by this run. `publication_revision` is recorded in `latest.json` after `manifest.json` is sealed and denotes the manifest-seal commit, not the later pointer update.

## Subject context

`fatb4f/ctrl@main` remains unchanged at `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`. `spec/` remains the qualification semantic authority. Component roots remain explicitly declared by `control/components.cue`; `control/source-imports.cue` remains the provenance record for imported component revisions and trees. The root workspace still targets Python 3.14 and declares Ruff/ty only as quality tooling, not semantic authority.

## Project topology and ownership

The Living Architecture remains context only:

- `ctrl`: concrete mutation-control and qualification system; `ctrl/spec` + CUE own qualification meaning.
- `python-intel`: observation/evaluation architecture, not an analyzer or qualification authority.
- PyPI/wheel/PEP pipeline: first python-intel materialization through acquire -> normalize -> analyze -> correlate -> evaluate -> Arrow -> DuckDB -> Ibis -> Marimo.
- `semagrams`: future mutation-graph substrate until explicitly admitted into `ctrl/spec`.

Component-local ownership is preserved. No dependency or assembly identity is inferred from sibling checkout paths. ctrl federation is limited to declared pins, contract references, federation evaluations, compatibility scenarios, and assembly commands.

## Source state

Every source/channel was resolved independently:

- `codex/main`: `76ceaddb29444388fbbbae07c46f7e8849f9658b`
- `codex/latest-alpha-cli`: `deb7b8341349146516c324f81a66698db085c0ea`
- `cpython/3.14`: `90a1f02b7da0c356d10a23f1faee7dc063f887ed`
- `cpython/main`: `c612fd4cf363cf1af28bb67f11b4a11dca57507f`
- `astral-python/main`: `ce46a36be796faff60d1ad5734e571bb1223c0a7`
- `scip/main`: `8b8c4fc0dea66a4592f03c0d81b632780d49eed0`
- `otel-python-core/main`: `c49f6f456406e3b2fe4dd993a007abe5bb5b3eb1`
- `otel-python-contrib/main`: `7b794faf874169d78ad56ba0f4da8365aee75b5c`
- `otel-genai-semconv/main`: `a685613a207a580163353b8e48a7ad88967e7b42`
- `otel-python-genai/main`: `8d11494c5417d13a1007f1546f1f16d5cae558df`
- `otel-arrow/main`: `7c4fb9a42b7f858d6e97bf08d8ffb2889a04f8e0`
- `dlt/devel`: `989d11d0cb69f8b014aa1868311e81726a599ec9`
- `arrow/main`: `892c73dc194dbc8e8881e9b90381029d1e956a57`
- `duckdb/main`: `a9ddce5a2ff36ee40aed4e38d0e76d7b5218e0eb`
- `ibis/main`: `799a2a9594060e2a14aa83a8c47d9ec22b8d9a81`
- `marimo/main`: `c092a6722578d7ad500445fb3e89efbd656d88bc`
- `pydantic-graph/main`: `679756763ab85bff9e747ec6d5079c78a8af656c`
- `cue/pinned`: `806821e40fae070318600a264d311517e596353b`
- `cue/master`: `f356f8f46cedb8e853ed200fb46ab49a68bfe357`
- `uv/main`: `392e0a0aa39f7f03e2efb688e500ec23a1930d36`
- `jj/main`: `a73aaa540b9c8fb80068b67f09dd809e490f2d7d`

The CUE pinned evaluator and CUE master forecast remain unchanged and distinct. Ibis is unchanged. SCIP moved only through dependency/build metadata and did not change the admitted symbol/occurrence semantic surface.

## Codex projection graph

Two distinct Codex impacts are admitted.

First, the app-server protocol and its generated JSON/config projections changed substantially since `c4941302...`: new project-change and strict-review notifications were added, thread/project fields changed, MCP resource types changed, and generated schemas moved in lockstep. This closes through `codex-rust-protocol -> codex-json-schema` and reaches `spec/.codex`, `integrations/openai`, and TDD consumers. Decision: `contract-update`.

Second, permission, sandbox, approval, exec-policy, and MCP-facing implementation/protocol surfaces changed. In particular the v2 file-system permission conversion now supports Path URI semantics and preserves legacy read/write projection only when the richer entry set is legacy-compatible; deny/non-compatible entries no longer collapse into the old read/write representation. Because the profile explicitly assigns tool interception, permission, sandbox, approval, and MCP boundaries a `blocking-gate` floor, this is a critical compatibility gate for the current local Codex policy contract. No local executable compatibility validation was available in this run.

## Python semantic and operational graph

CPython 3.14 and CPython main moved independently. Both deltas touch declared CPython nodes, including `Lib/test/libregrtest/`, `Lib/importlib/`, frame/runtime sources, and flowgraph/compiler-adjacent code.

The reportable active-baseline change is the regrtest evidence shape: `TestResults` now retains per-test environment-change reasons, carries them during result accumulation, and renders individual reasons in the result display. That is upstream behavioral evidence, not qualification, but it changes the information available to the local `RunRegrtestSlice`/normalization path. Decision: `contract-update`. CPython main records the same family as forecast evidence and remains distinct from the 3.14 active baseline.

No regrtest slice or ctrl probe was executed. The changed source/runtime nodes therefore remain source-qualified observations with local executable coverage outstanding.

Astral `main` advanced from `52ec0cf...` to `ce46a36...` across `ty_python_core`, `ty_python_semantic`, resolver, AST, IDE, and server surfaces. The current tip simplifies generic protocol inference. This is analyzer evidence only and is projected through the declared Astral correlation graph; it cannot override CPython evidence. Decision: `note`.

SCIP remains the cross-file symbol/source-occurrence identity spine. Its delta was dependency/build-only; no SCIP semantic-identity contract change is admitted.

## Observation and acquisition graph

OpenTelemetry source families moved but no core semantic/correlation contract update was admitted from this interval. The Python core tip fixes Jaeger propagator typing and empty baggage extraction; the relevant file is outside the profile's core API/SDK/exporter graph path. Contrib moved within provider instrumentation, but the observed changes do not establish a declared ctrl domain-probe obligation and are not promoted to qualification impact.

GenAI semantic-convention reference scenarios updated to OpenAI v3 dependencies without changing the admitted semantic-convention model. Python GenAI realization changed independently and remains provider instrumentation evidence.

OTel-Arrow changed materially under `rust/otap-dataflow/`: OTAP receiver/exporter internal metrics were renamed and reorganized around bounded `signal`, `outcome`, and `error.type` attributes, with timing moved to fixed-memory aggregation. The semantic OTAP node is defined by `docs/otap-spec.md` and `docs/data_model.md`, which were not the basis of this change. The change therefore binds to `otel-arrow-dataflow`, not to the OTAP semantic-preservation contract. Decision: `note`.

dlt changed incremental acquisition so a persisted `last_value == 0` is no longer mistaken for absence when applying lag; forward-only cursor progression is preserved. dlt remains optional external-observation acquisition, and this behavior remains evidence-only until admission. Decision: `note`.

## Relational and diagnostic projection

Arrow, DuckDB, Marimo, pydantic-graph, uv, and jj all moved; Ibis did not. Their exact heads are retained as independent release-watch observations. The current ctrl graph still lacks source graph nodes for Arrow, DuckDB, Ibis, Marimo, and pydantic-graph themselves, so no change from those channels is promoted by directory or naming inference. This is an explicit graph-coverage gap, not an inferred local impact.

Arrow remains typed interchange, DuckDB relational substrate, Ibis semantic query projection, Marimo diagnostic projection, and pydantic-graph a replaceable executor implementation. None can derive qualification verdicts.

## Correlation carrier policy

The admitted semantic identity / telemetry carrier policy is unchanged. Trace/span identity remains causal identity, not semantic identity. Baggage remains deny-by-default; source text, prompt content, credentials, and large evidence payloads remain forbidden carriers. Operation/probe/symbol/source-occurrence/evidence identities remain semantic joins projected only through declared carrier policy.

## P0 executable frontier

The P0 frontier remains unchanged: one RunProbe operation, normalized CPython observation + OTel trace/event, OTLP -> OTAP -> Arrow/Parquet, relational ingress, and one correlation query, qualified by `otel-causal-correlation` and the traces-only `otlp-otap-roundtrip` witness.

Neither executable witness ran. CUE, regrtest, local probes, Astral/SCIP correlation, OpenTelemetry pipeline, OTLP/OTAP round-trip, and relational projections were unavailable to the GitHub App actuator. Qualification therefore remains `observation_only`.

## Critical

1. **Codex tool/permission policy compatibility gate** — `blocking-gate`. Permission/sandbox/approval/exec-policy surfaces changed across the declared Codex protocol/runtime boundary. The local `spec/.codex` and TDD policy contract must not silently adopt the upstream behavior without executable compatibility validation.

## High

1. **Codex app-server protocol/schema projection** — `contract-update`. New notifications and protocol/schema fields require the local Codex contract/projection assumptions to be reviewed against the new source-qualified schema state.
2. **CPython regrtest environment-change evidence** — `contract-update`. Regrtest now preserves and renders per-test environment-change reasons; local behavioral-evidence normalization must preserve or explicitly discard that new evidence dimension.

## Notes

1. **Astral ty analyzer semantics** — generic/type inference and related analyzer machinery advanced; keep as forecast static-analysis evidence pending CPython/probe correlation.
2. **OTel-Arrow dataflow telemetry** — breaking internal receiver/exporter metric naming/attribute changes are admitted at the dataflow implementation node, not the OTAP semantic node.
3. **dlt incremental acquisition** — zero-valued persisted cursors now remain forward-only under lag; useful acquisition correctness evidence, not fact or qualification authority.

## No local action

No report item is manufactured for source movement that lacks a complete declared surface -> graph -> local-consumer trace. This includes current Arrow/DuckDB/Marimo/pydantic-graph release-watch changes under the present graph model and the SCIP dependency-only delta.

## Publication

- Bundle: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260818T160440Z/`
- Manifest: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260818T160440Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/ctrl/contract-surface/latest.json`
- Export unit: directory

## Validation notes

- Factory worker/profile authority: read from pre-publication revision `13fa7714653df86fd6367570fe8fe1e493c39ce8`.
- ctrl context: read at `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`; component roots/source imports and workspace configuration unchanged.
- Project topology/ownership: read and preserved as architectural context only.
- Required sources/channels: resolved independently; optional channels also resolved.
- Graph/surface model: read; source-qualified graph binding applied.
- CUE execution: not available to GitHub App.
- CPython regrtest/local probes: not executed.
- Astral/CPython and SCIP correlation: not executed.
- OpenTelemetry pipeline: not executed.
- OTLP/OTAP trace round-trip: not executed.
- Relational projection: not executed.
- Report/summary: projections from `evidence.json`.
- Qualification state: `observation_only`.
- Cross-repository writes and issue updates: none.
