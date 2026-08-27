# ctrl upstream impact report

## Run identity

- Run ID: `20260827T160600Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `69db2720357f1f6d68771085e3b69022ea641ffe`
- Publication revision: `not-yet-sealed`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Bootstrap baseline: `false`

The evaluated authority is the flattened `contracts/workers/upstream-monitor/` plus `profiles_ctrl/` layout selected by `projects/ctrl/.agents/AGENTS.md`. The subject revision is unchanged from the prior admitted run.

## Subject context

`fatb4f/ctrl@main` remains at `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`. `spec/` remains subject qualification authority. Projected EvaluationWorld, DPI, qualified-fixpoint, sealed-bundle, and Weaver interface concepts remain profile obligations rather than repo-backed subject components unless explicitly materialized.

## Project topology and ownership

The profile retains component-local ownership and treats sibling paths as non-identity. `ctrl` owns mutation-control/qualification federation; python-intel remains an observation/evaluation architecture; the PyPI/wheel/PEP path remains a materialization workload; semagrams remains future design context. No upstream/provider repository became factory or subject authority.

## Qualified reactive evaluation kernel

The evaluated profile topology remains:

```text
source-qualified observations
  -> semantic admission
  -> immutable EvaluationWorld
  -> meaning-preserving DPI lowering
  -> monotonic derivation
  -> derived closure
  -> external CUE qualification
  -> qualified | rejected | inconclusive fixpoint
  -> immutable sealed bundle
  -> deterministic projection / effect intent
```

The GitHub adapter did not execute this kernel. Computed closure is therefore not promoted to qualification, and no projected consumer is treated as materialized merely because its upstream moved.

## Source state

All declared channels resolved independently. Material heads include Codex main `5f49aba876922d6f2f55caa153bbb0ed1b46feba`, CPython 3.14 `f8a703ab3e70c131d44253ba1c3ba005664abb31`, Ruff main `aad0e909ef1390f4b2a3ba8aa0a67fb8ea5cbacd`, SCIP main `a7b9c65a8aa148a79b67cc7f6dafea154dbc63d0`, OTel Python core `953c8db3d83e522d079bd606362f273d0f001e30`, GenAI semantic conventions `67dff024110be5bd9f318006e733f4078e0f4c97`, OTel-Arrow `7a316bb6b38215259ca1a06559da12ce20df990b`, Weaver `c557ef7dde2e1eaac9927e92492beecec34af80d`, and pinned CUE `806821e40fae070318600a264d311517e596353b`. Optional projection sources also resolved and remain non-blocking without a materialized consumer.

## Codex projection graph

Codex main advanced 195 commits from the prior admitted head. The delta directly modifies `codex-rs/app-server-protocol/src/protocol/`, generated JSON/TypeScript schemas, app-server request processors, Guardian/misalignment policy tests, MCP-facing paths, thread history/revert/list/realtime surfaces, and command-execution approval types. The declared protocol -> schema -> runtime projection therefore changed materially.

The existing policy blocking gate remains open: current Codex approval/Guardian/MCP/tool semantics cannot be admitted into `spec/.codex` or controller assumptions without the declared local executable compatibility witness.

## Python semantic and operational graph

CPython 3.14 and main advanced, but the observed tips do not establish an impact on the declared compiler/regrtest/probe nodes. Ruff advanced with analyzer/linter rule-model changes; those remain analyzer observations and do not override CPython semantics. SCIP advanced only through repository-maintenance changes at the observed tip and remains semantic identity rather than runtime truth.

## Observation and acquisition graph

OpenTelemetry Python core changed configuration environment substitution so substitution occurs after parsing and handles YAML aliases/cycles safely. GenAI validation scenarios now observe `gen_ai.system` plus legacy message/choice events from an agent-framework dependency. OTel-Arrow changed transform completion behavior so fully filtered inputs ACK locally without emitting empty PData. These remain execution/transport observations, not qualification verdicts.

## Relational and diagnostic projection

fsspec, Arrow, DuckDB, Ibis, Polars, Marimo, and pydantic-graph all resolved at current heads. Their changes remain optional implementation/projection evidence. No repo-backed ctrl consumer or gate was identified that would promote these changes to a blocking dependency or allow them to define DPI meaning.

## Semantic interface projection

Weaver advanced from `78b64d8da8e0034374e66a560ae22991b2e88a81` to `c557ef7dde2e1eaac9927e92492beecec34af80d` and now disallows stability/deprecated metadata on v2 attribute references. This directly intersects the profile's projected `DiagnosticPacket` semantic-interface validation boundary. It is a contract update, not a qualification verdict, and remains non-blocking until a repo-backed DiagnosticPacket consumer/gate exists.

## Correlation carrier policy

`qualification_run_id`, `evaluation_world_id`, repository revision, and operation identity remain distinct from native trace/span causality. No telemetry observation was used to manufacture semantic identity or qualification. No sealed-bundle identity was projected backward into pre-seal execution.

## Current executable frontier

The declared end-to-end frontier remains projected. The GitHub adapter could not execute the semantic kernel, CPython probes/regrtest, static/dynamic analyzer correlation, OTLP/OTAP round trip, relational projection, or Weaver DiagnosticPacket projection. Qualification is therefore `observation_only` despite successful monitor completion.

## Critical

### Codex policy boundary remains open

**Decision:** `blocking-gate`.

Codex materially changed Guardian, command approval, MCP/tool and related runtime/policy surfaces while `ctrl@main` stayed fixed. No executable local compatibility witness was available. Current upstream policy semantics must not be silently adopted.

## High

### Codex protocol/schema projection advanced

**Decision:** `contract-update`.

App-server protocol and generated schemas changed together across thread listing/revert/realtime, approval, Guardian, error and usage metadata surfaces. Local protocol/config/rollout projections require reconciliation before compatibility can be claimed.

### Weaver v2 attribute-reference validation tightened

**Decision:** `contract-update`.

Weaver now rejects stability/deprecated metadata on v2 attribute references. This changes the projected DiagnosticPacket interface-validation substrate while leaving CUE qualification authority intact.

## Notes

- Ruff continued analyzer/linter semantic evolution; retain as analyzer evidence only.
- GenAI validation scenarios now expose additional system and legacy message/choice events; treat these as observed provider/semantic-convention behavior pending a concrete local consumer.
- OTel-Arrow transform completion now suppresses empty outputs and locally ACKs fully filtered inputs; this is dataflow/transport behavior below ctrl evidence interpretation.

## No local action

SCIP repository maintenance, OTel Python configuration parsing, dlt, fsspec, Arrow, DuckDB, Ibis, Polars, Marimo, pydantic-graph, uv, and Jujutsu changes did not establish a new declared local blocking path in this run. CUE master and the pinned evaluator remain distinct.

## Publication

- Bundle: `projects/ctrl/upstream-monitor/runs/20260827T160600Z/`
- Manifest: `projects/ctrl/upstream-monitor/runs/20260827T160600Z/manifest.json`
- Latest pointer: `projects/ctrl/upstream-monitor/latest.json`
- Export unit: directory

## Validation notes

Authority, subject context, project topology, semantic kernel, source channels, graph/bindings, correlation policy, interface boundary, publication plan, and forbidden attractors were read. Report/summary are projections from `evidence.json`. CUE and executable subject-local ctrl witnesses were unavailable to the GitHub adapter, so their coverage gaps are preserved explicitly rather than asserted as booleans.
