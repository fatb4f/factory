# ctrl upstream impact report

## Run identity

- Run ID: `20260821T160609Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `f3ca97ee98a9224dd05c4ed341e47f3fb74b84ee`
- Publication revision: recorded in `latest.json` after manifest seal
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Prior sealed run: `20260818T160440Z`
- Bootstrap baseline: `false`

The authority revision is the pre-publication factory state evaluated by this run. Factory changes since the previous run are prior monitor run bundles and pointers only; selected `profiles_ctrl` authority is unchanged.

## Subject context

`fatb4f/ctrl@main` remains unchanged at `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`. `ctrl/spec` remains qualification derivation and gating authority. Component ownership and imported-source identity remain explicit; no dependency or assembly identity is inferred from sibling checkout layout.

## Project topology and ownership

The Living Architecture topology remains architecture/ownership context only. `ctrl` continues to own concrete mutation-control and qualification semantics; python-intel remains observation/evaluation architecture; the PyPI/wheel/PEP pipeline remains its first materialization; semagrams remains non-authoritative until admitted into `ctrl/spec`.

## Source state

Required and optional channels were resolved independently and retained as distinct source/channel observations. Key current heads are:

- `codex/main`: `e482cc66aeeedcb9f333a1f5a0a554eb5aea4b36`
- `codex/latest-alpha-cli`: `0e015a7a0eef52047fea8ded24f8b32afbafd527`
- `cpython/3.14`: `d3fe3de54b50b96b9b96a18195128f55093d7c30`
- `cpython/main`: `9c48dfe9927249be0c73e533e387740742c4a95f`
- `astral-python/main`: `f856ab0f85127d366301d51e4300a79041cf86d9`
- `scip/main`: `02559b6181bcf7a53e93c80995a798457117c431`
- `otel-python-core/main`: `faea6f137002520165ffff30cb2122c512bee5c6`
- `otel-python-contrib/main`: `466ae4c00de77d1f54f77a9600f1d08eba2306b5`
- `otel-genai-semconv/main`: `eaefa142a94cefe5d199d47e4a73727dfbd825df`
- `otel-python-genai/main`: `fa8d8de6f80b3432a4b60abce6a56805504f1033`
- `otel-arrow/main`: `26b710aa0c6e5900e94523992c018104db6cfe24`
- `dlt/devel`: `d989cec3f5062f57a6aee0b56bb8584c4fd525d4`
- `arrow/main`: `ba5ca205d1617878cc6cca1350e406f51fc6654e`
- `duckdb/main`: `044a04a7cd39e6e8235f756597ae42dde084e5e5`
- `ibis/main`: `799a2a9594060e2a14aa83a8c47d9ec22b8d9a81`
- `marimo/main`: `cad0f45d8e697f3df6f1a9b9b62e9b52bb5680c5`
- `pydantic-graph/main`: `540b59d8bf9f07e5efbeac08f7ba48355cc1a32c`
- `cue/pinned`: `806821e40fae070318600a264d311517e596353b`
- `cue/master`: `2920479eca26e8377d4ae06a4c4d857e578095e3`
- `uv/main`: `244bc3b99fcf24432a4ae2b5f0c437adb7487e90`
- `jj/main`: `7007d08537a872dd708f112e2b289ca5a681c692`

## Codex projection graph

Decision: `contract-update`.

Codex `main` is 197 commits ahead of the prior admitted source head. App-server protocol and generated schema surfaces changed together, including MCP event-stream types, thread history/response shapes, configuration requirements, and additional protocol projections. This closes through the declared `codex-rust-protocol -> codex-json-schema` projection and its local consumers under `spec/.codex`, `agents/tdd/.codex`, and `integrations/openai`.

Separately, Codex changed the execution/policy boundary. Guardian review sessions now intentionally skip selected executor MCP-server projection, while normal executor contexts retain it. This intersects the admitted permission/sandbox/approval/MCP surface and therefore remains a blocking compatibility gate until the local policy consumer is executably checked.

## Python semantic and operational graph

CPython `3.14` and `main` both advanced, but the current tips are in `_io` and curses implementation behavior rather than the profile's declared parser/AST/symtable/compiler/code-object/bytecode/eval/frame/monitoring/importlib/inspect/regrtest surfaces. No propagation is inferred from repository-wide Python naming.

Astral `main` advanced materially across `ty_python_core`, `ty_python_semantic`, parser, module resolution, and IDE surfaces. The current tip fixes invariant gradual tuple materialization ranges. This remains analyzer evidence only and is classified as a note; no runtime or qualification truth is derived from it without CPython/local-probe correlation.

## Observation and acquisition graph

Decision: `contract-update` for OpenTelemetry core; `note` for GenAI realization and OTel-Arrow dataflow.

OpenTelemetry Python added stable `AlwaysRecordSampler`, which converts `DROP` decisions to `RECORD_ONLY` while leaving sampled/exported status unchanged. Because the profile uses the OTel API/SDK as the generic causal execution-observation substrate, this is a contract-relevant option for retaining processor-visible spans without forcing 100% export sampling. It does not self-authorize any ctrl qualification result.

OpenTelemetry Python GenAI tightened lower/upper dependency bounds and latest-test pins across instrumentations. This is provider-realization compatibility evidence for `integrations/openai` and `packages/runtime`, not semantic authority.

OTel-Arrow added a runtime-local retained-work accounting primitive in the dataflow engine. The upstream change explicitly excludes runtime wiring, metrics export, configuration, enforcement, and production charge sites, so it remains a note on the optional dataflow implementation rather than an OTAP semantic-contract update.

## Relational and diagnostic projection

Arrow, DuckDB, Marimo, uv, jj, and other release-watch channels moved independently. DuckDB, for example, changed identifier-case configuration semantics; however these projector/release-watch sources cannot become blocking dependencies without a declared graph consumer/gate. Ibis is unchanged. No projection engine is treated as qualification authority.

## Correlation carrier policy

No admitted change to ctrl correlation-carrier policy is established by this run. Trace/span identity remains distinct from semantic identity, sensitive payloads remain outside correlation carriers, and no analyzer, telemetry record, relational projection, or model conclusion self-authorizes a fact.

## P0 executable frontier

No local CUE execution, CPython probes/regrtest, Astral correlation, SCIP correlation, OTel pipeline, OTLP/OTAP roundtrip, or relational projection was executed by the GitHub App actuator. Qualification therefore remains `observation_only` and the executable coverage gap is explicit.

## Critical

1. **Codex Guardian/executor MCP policy boundary** — `blocking-gate`. Guardian review sessions now omit selected executor MCP-server projection. The changed upstream runtime/policy surface maps to `codex-live-runtime` and the local `spec/.codex` / TDD policy consumers. Do not silently absorb this behavior without executable compatibility evidence.

## High

1. **Codex app-server protocol/schema projection** — `contract-update`. Protocol and generated schema changed together across MCP, thread, and configuration surfaces.
2. **OpenTelemetry core recording semantics** — `contract-update`. `AlwaysRecordSampler` adds a stable RECORD_ONLY path that can preserve processor observations without increasing export sampling.

## Notes

1. **Astral analyzer semantics** — broad ty/parser/module/IDE movement, including invariant gradual tuple materialization fixes; analyzer evidence only.
2. **OpenTelemetry Python GenAI realization bounds** — instrumentation compatibility bounds and latest-test pins tightened.
3. **OTel-Arrow retained-work accounting** — internal dataflow accounting primitive added with no runtime wiring or exported-telemetry change.

## No local action

- CUE `master` advanced substantially, including parser, encoding, filetype, stdlib and internal compiler-adjacent changes, but `cue/pinned` remains unchanged at the profile's pinned semantic authority. Forecast movement is preserved without replacing the pinned evaluator.
- SCIP's current tip changes protocol-review governance, not `scip.proto` identity semantics.
- Current CPython tips do not intersect declared monitored nodes.
- Optional/release-watch source movement is not promoted without a declared local consumer and graph path.

## Publication

- Bundle: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260821T160609Z/`
- Manifest: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260821T160609Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/ctrl/contract-surface/latest.json`
- Export unit: directory

## Validation notes

- Authority and selected ctrl profile: read and rebound to current factory head.
- Subject context: read; `ctrl@main` unchanged.
- Required source channels: all resolved independently.
- Optional source channels: resolved independently.
- Project topology/ownership, graph model, surfaces, source policy, correlation policy, and publication plan: preserved.
- CUE execution: not available to GitHub App actuator.
- CPython regrtest/probes: not executed.
- Astral/CPython and SCIP correlation: not executed.
- OpenTelemetry/OTAP and relational projection: not executed.
- Report/summary are projections of source-qualified evidence.
- Qualification state: `observation_only`.
- Cross-repository writes: none.
- Issue updates: none.
