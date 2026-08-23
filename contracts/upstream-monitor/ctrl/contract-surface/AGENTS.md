# ctrl multi-source upstream monitor

This is the compatibility entrypoint for the `ctrl` profile. It is not independent semantic authority.

## Instruction chain

Read, in order:

```text
contracts/upstream-monitor/AGENTS.md
contracts/factory/workers/upstream-monitor/AGENTS.md
contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md
contracts/factory/workers/upstream-monitor/contract.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/contract.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/topology.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/semantic-kernel.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/sources.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/surfaces.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/graph.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/correlation.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/evidence.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/report.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/publication.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/assertions.cue
contracts/factory/workers/upstream-monitor/profiles_ctrl/public.cue
contracts/upstream-monitor/ctrl/contract-surface/output/report-template.md
```

Accepted input is exactly:

```text
signal_id: loop_bootstrap_request
profile_id: ctrl
target_repo: fatb4f/factory
context_repo: fatb4f/ctrl
entrypoint: contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md
adapter: github_app
```

## Mission

Maintain a versioned, graph-aware impact and operationalization view of upstream changes that intersect `fatb4f/ctrl@main`, including the profile's qualified-reactive evaluation architecture, while preserving project ownership, source, semantic, causal, evaluation-world, interface, transport, relational-projection, actuation, and qualification authority boundaries.

## Authority boundary

The current subject repository and architecture documents provide context; they do not amend this monitor. `profiles_ctrl/*.cue` is the selected profile authority. `ctrl/spec` + CUE remain semantic law for ctrl qualification. The profile may represent projected architecture before repo-backed realization, but projected nodes and consumers are not executable facts.

Adapters observe. CUE derives and gates. A query engine, notebook, semantic-interface compiler, telemetry provider, executor implementation, Codex process, or actuator does not self-authorize semantic facts or qualification verdicts.

## Project topology

Read `profiles_ctrl/topology.cue` before source classification. Preserve these roles:

1. `ctrl`: concrete repo-backed Codex mutation-control and qualification experiment, now evaluated against the profile's projected qualified-reactive kernel. Parent Codex is the sole adaptive inference authority; `ctrl/spec` + CUE own semantic law, admission, closure, and qualification.
2. `python-intel`: architectural producer/interpreter of typed software observations suitable for ctrl admission. It is not itself an analyzer or qualification authority.
3. PyPI/wheel/PEP pipeline: first concrete python-intel materialization workload through acquire -> normalize -> observe -> admit -> instantiate world -> lower -> derive -> qualify -> seal -> relational/diagnostic projection.
4. `semagrams`: future human-facing mutation-transition model. Treat its candidate model as design context only until admitted into `ctrl/spec`; DPI machine topology need not preserve the human mutation graph shape.
5. Weaver: projected shared semantic-interface realization for the first `DiagnosticPacket` dog-food experiment. It is an upstream interface dependency, not ctrl semantic authority.
6. Epistemic admission remains a separate concern: acquired/provider observations become world inputs only through contract-governed admission. Do not collapse epistemic admission into the evaluator.

Component-local ownership is mandatory. Each project/component owns its descriptors, outgoing dependency declarations, locks, observations, tests, artifacts, provenance, and local qualification. ctrl federation owns only declared pins, contract references, admitted qualified projections, federation-only evaluations, compatibility scenarios, and assembly commands. Sibling checkout paths are never assembly identity.

## Qualified reactive evaluation kernel

Read `profiles_ctrl/semantic-kernel.cue` as profile-specific architecture authority. Do not generalize its vocabulary into worker-core semantics merely because this profile uses it.

The admitted topology is:

```text
source-qualified observations
        ↓ semantic admission
immutable EvaluationWorld
        ↓ meaning-preserving lowering
DPI relations
        ↓
monotonic evaluator
        ↓
derived closure
        ↓ external CUE qualification
qualified / rejected / inconclusive fixpoint
        ↓ seal
immutable sealed bundle
        ↓
projection / effect intent
```

Preserve these invariants:

- domain semantic objects remain distinct above DPI;
- `meaning(lowered(source)) == meaning(source)` is required; shape preservation is not;
- optimizer/query topology may change without changing contracted meaning;
- a computed closure is not automatically qualified;
- authority, parameters, admitted inputs, rules, provenance, and closure are frozen per EvaluationWorld;
- changing an admitted observation, parameter, authority, rule, or closure creates a new world;
- sealed bundles are immutable append-oriented world commits;
- negative knowledge requires qualified closure/completeness evidence;
- federated authority composes only through admitted qualified projections;
- heuristic Codex inference remains outside monotonic qualification;
- physical actuation remains outside the immutable evaluation world and its effects become observations for a later world.

The existing `ctrlExecutionGraphContract` remains a subordinate CPython/probe/telemetry operational graph. It does not define or replace this semantic kernel.

## Required evidence families

1. Codex: Rust protocol, exported schemas, Python `openai_codex` SDK, live app-server/tool/config semantics, rollout persistence/lineage/reconstruction.
2. CPython: Python 3.14 active branch plus main forecast, subsystem dependency DAG, CPython regrtest as upstream behavioral evidence, and ctrl-local executable probes.
3. Astral Rust: Ruff parser/AST/index/static semantics plus ty resolver/type/IDE machinery as analyzer evidence correlated against CPython, never compiler/runtime authority.
4. SCIP: cross-file symbol/document/occurrence/relationship identity. Bind SCIP through the declared upstream binding before impact propagation; SCIP never becomes CPython semantic authority.
5. OpenTelemetry Python core/contrib/GenAI + OTel-Arrow: causal execution observations, provider adapters, semantic-convention vocabulary, OTLP/OTAP projection, and traces-only round-trip evidence.
6. Weaver: forecast semantic-interface validation/resolution/diff/schema/template machinery for projected `DiagnosticPacket` realization. Interface conformance is observation unless a CUE qualification criterion consumes it.
7. dlt and fsspec: optional external-observation acquisition/address-space machinery. Acquisition/addressability never establishes truth or admission.
8. Arrow, DuckDB, Ibis, Polars, Marimo, and pydantic-graph: optional interchange/query/dataframe/diagnostic/execution implementations. They require declared upstream bindings and cannot define DPI meaning or qualification.
9. CUE: pinned evaluator semantics kept distinct from upstream master forecast. The pin realizes external evaluator semantics; factory/profile CUE remains monitor authority and `ctrl/spec` remains subject qualification authority.
10. uv and Jujutsu: release-watch satellites limited to declared local consumers.

Optional satellites cannot become blocking dependencies without a repo-backed declared local consumer or gate.

## Correlation and identity

Apply `#CorrelationIdentity` and `ctrlTelemetryCarrierPolicy`. Required kernel correlation includes:

```text
qualification_run_id
evaluation_world_id
repository_revision
operation_id
```

When available, join:

```text
agent turn
→ tool/MCP call
→ mutation
→ test attempt/probe
→ symbol/source occurrence
→ evidence
→ sealed bundle
```

`trace_id` / `span_id` answer execution causality and use native telemetry context. They are not semantic/world identity. `sealed_bundle_id` exists only after sealing and must not be projected backward as a causal identifier. Baggage remains deny-by-default; source text, prompt content, credentials, and large evidence payloads are forbidden carriers.

## Current executable frontier

Project the current frontier from `ctrlSemanticKernel.currentFrontier` rather than inventing a broader implementation:

```text
one Codex turn
→ two or more mutation candidates
→ one candidate admission
→ one immutable EvaluationWorld
→ one materialization
→ semantic identity
→ one static differential observation
→ one CPython/runtime differential probe
→ OTel causal correlation
→ DPI lowering
→ one monotonic derivation
→ one CUE qualification criterion
→ one qualified/rejected/inconclusive fixpoint
→ one sealed bundle
→ one canonical DiagnosticPacket
→ Weaver validation/projection
→ hook/SDK feedback into parent Codex context
→ next Codex inference
```

The existing lower-level executable witnesses remain useful within that frontier:

1. `otel-causal-correlation`: semantic/world identity survives execution observation without collapsing into trace identity or indiscriminate baggage.
2. `otlp-otap-roundtrip`: traces-only canonical OTLP semantics survive OTLP -> OTAP -> OTLP; physical Arrow layout is excluded.

The GitHub App cannot execute the projected kernel or Weaver projection. Preserve those as explicit coverage gaps until repository CI or a checked environment supplies executable evidence.

## Run-state semantics

`terminal_state`/`monitor_state` describes whether the monitor loop itself completed. `qualification_state` is orthogonal:

```text
observation_only
executable_validated
executable_failed
```

Never interpret `terminal_success` alone as executable qualification success.

Use `authority_revision` for the pre-publication contract revision actually evaluated. `publication_revision` means the commit that seals `manifest.json`, not the later commit that writes `latest.json`.

## Bootstrap and newly admitted channels

If `latest.json` does not exist, establish a bootstrap run. If the profile adds a source/channel after a prior run, establish a source-qualified per-channel baseline for that channel rather than inventing a historical delta. Resolve exact current revisions and preserve unresolved/coverage-gap states explicitly.

## Publication

Write only:

```text
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/report.md
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/summary.md
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/evidence.json
contracts/upstream-monitor/ctrl/contract-surface/runs/<run_id>/manifest.json
contracts/upstream-monitor/ctrl/contract-surface/latest.json
```

Write the manifest after report, summary, and evidence; update `latest.json` after the manifest. No issue updates or cross-repository writes are admitted.
