# ctrl upstream impact report

## Run identity

- Run ID: `<run_id>`
- Monitor state: `<monitor_state>`
- Qualification state: `<qualification_state>`
- Authority revision: `<authority_revision>`
- Publication revision: `<publication_revision|not-yet-sealed>`
- ctrl context revision: `<ctrl_revision>`
- Bootstrap baseline: `<true|false>`

`authority_revision` is the pre-publication contract revision evaluated by the run. `publication_revision`, when recorded in the latest pointer, is the commit that seals `manifest.json`; it is not the later commit that writes `latest.json`.

## Subject context

Summarize the current `fatb4f/ctrl@main` boundary and components read. `spec/` remains ctrl's subject qualification semantic authority; the monitor contract remains factory-local authority for this loop. Component identities and roots come from `control/components.cue`.

Projected EvaluationWorld, DPI, fixpoint, sealed-bundle, and Weaver concepts are not concrete subject components unless current repository evidence establishes them. Architecture documents are context observations and do not amend `profiles_ctrl` authority.

## Project topology and ownership

Project `profiles_ctrl/topology.cue` and preserve its ownership boundaries:

- `ctrl`: concrete mutation-control/qualification experiment with a profile-defined projected qualified-reactive evaluation kernel. Parent Codex is the sole adaptive inference authority; `ctrl/spec` + CUE own semantic law, admission, closure, and qualification.
- `python-intel`: architectural producer/interpreter of typed software observations suitable for admission; not itself an analyzer or qualification authority.
- PyPI/wheel/PEP pipeline: first python-intel materialization workload through acquisition, observation, admission, lowering, evaluation, sealing, and relational/diagnostic projection.
- `semagrams`: future human-facing mutation-transition model only until admitted into `ctrl/spec`; its source graph need not equal DPI machine topology.
- Weaver: projected shared semantic-interface realization for `DiagnosticPacket`, never semantic or qualification authority.

Do not infer assembly identity from sibling checkout paths. Each component/project owns its descriptors, outgoing dependencies, locks, observations, tests, artifacts, provenance, and local qualification. ctrl owns only declared pins/contract references, admitted qualified projections, federation-only evaluations, compatibility scenarios, and assembly commands.

## Qualified reactive evaluation kernel

Project `ctrlSemanticKernel`, `ctrlKernelRelations`, and evaluated upstream bindings explicitly.

```text
source-qualified observations
        |
   semantic admission
        v
immutable EvaluationWorld
        |
 meaning-preserving lowering
        v
   DPI relations
        |
 monotonic derivation
        v
  derived closure
        |
 external CUE qualification
        v
qualified / rejected / inconclusive fixpoint
        |
       seal
        v
immutable sealed bundle
        |
 projection / effect intent
```

Disclose which portions are current repo-backed realization versus projected profile obligations. Preserve:

- domain-specific CUE meaning above DPI;
- meaning-preserving lowering without requiring source-shape preservation;
- immutable world authority/parameters/admitted inputs/rules/provenance/closure;
- computed closure distinct from qualification;
- new world creation on admitted-input, parameter, authority, rule, or closure change;
- sealed bundle immutability and append-oriented history;
- qualified closure requirement for negative knowledge;
- inference outside qualification and actuation outside evaluation;
- federation through admitted qualified projections rather than authority collapse.

## Source state

List every declared source/channel separately with exact resolved commit or explicit unresolved state. Never collapse same-named channels across sources.

Required/forecast families include Codex, CPython, Astral Rust, SCIP, OpenTelemetry Python core/contrib/GenAI, OTel-Arrow, Weaver, and CUE. dlt, fsspec, Arrow, DuckDB, Ibis, Polars, Marimo, pydantic-graph, uv, and Jujutsu are optional/release-watch unless another profile contract promotes them.

Newly added source/channels after a prior admitted run establish their own current baseline; do not invent historical deltas.

## Codex projection graph

Project evidence through the declared chain:

```text
Rust protocol -> exported JSON/config schemas -> Python openai_codex SDK
      |                                             |
      +-----------------> live runtime <------------+
                              |
                              v
                    rollout persistence
                              |
                              v
                    rollout reconstruction
```

Record projection inconsistencies separately from ordinary upstream changes. Codex remains adaptive inference/actuation evidence, not qualification authority.

## Python semantic and operational graph

Summarize affected CPython DAG nodes, selected upstream regrtest bindings, selected local probe bindings, and the operationalization state of the typed execution graph. Distinguish source evidence, upstream test evidence, local probe evidence, correlation, semantic admission, derivation, and qualification.

Summarize Astral's Rust parser/AST/index/resolver/type observations separately from CPython compiler/runtime semantics. Analyzer evidence may refine correlation and probe selection but may not override contradictory CPython evidence.

Treat SCIP through its declared `scip-semantic-index -> ctrl-correlation-identity` binding as the cross-file symbol/source-occurrence identity spine. SCIP identity can join definitions/references to CPython source positions, code objects, instructions, executions, tests, samples, and evaluation worlds, but may not manufacture CPython semantic facts.

The legacy `ctrlExecutionGraphContract` is a subordinate CPython/probe/telemetry operation graph. It is not the authoritative qualified-reactive semantic kernel.

## Observation and acquisition graph

Report the acquisition boundary explicitly:

```text
external records / claims                execution observations
          |                                      |
      dlt / fsspec                          OpenTelemetry
          |                                      |
          |                              trace/span causal context
          |                                      |
          |                                     OTLP
          |                                      |
          |                                     OTAP
          |                                      |
          +----------- Arrow / relational ingress --------+
                                  |
                          semantic admission
                                  |
                         EvaluationWorld
```

Do not label dlt output as facts before provenance/admission/qualification. fsspec supplies addressability only. Do not treat telemetry as semantic or qualification authority. Record OTel Python core, contrib, GenAI, and OTel-Arrow source identities separately.

## Relational and diagnostic projection

Preserve the intended implementation/projection stack without moving semantic authority into it:

```text
address / observations
      |
    fsspec
      |
    Arrow
      |
 DuckDB / Ibis / Polars
      |
 DPI-compatible execution/projection
      |
   Marimo
```

Arrow is typed interchange; DuckDB is an optional relational persistence/execution substrate; Ibis is an optional composable relational expression layer; Polars is an optional dataframe/lazy execution substrate; Marimo is an interactive diagnostic surface. These may realize or inspect relations, but DPI meaning remains contract-governed and qualification remains external CUE authority. `pydantic-graph`, when used, is a replaceable typed operation-graph implementation.

## Semantic interface projection

Project the first interface experiment separately from qualification:

```text
sealed qualified world
        |
canonical diagnostic relation
        |
DiagnosticPacket
        |
Weaver check / resolve / compatibility / projection
        |
Codex-native hook / SDK / app-server context
        |
parent Codex inference
```

Weaver is an upstream semantic-interface implementation source. Its validation/diff/generation results are observations unless consumed by an explicit CUE criterion. Do not promote Weaver to semantic law, evaluation authority, or qualification authority. Until a repo-backed `DiagnosticPacket` consumer exists, preserve Weaver as projected/forecast coverage rather than a blocking dependency.

## Correlation carrier policy

Summarize the admitted `#CorrelationIdentity` and `ctrlTelemetryCarrierPolicy`. Required kernel identity includes:

- `qualification_run_id`;
- `evaluation_world_id`;
- `repository_revision`;
- `operation_id`.

When present, also correlate agent turn, tool call, MCP call, mutation, test attempt, probe, symbol/source occurrence, evidence, sealed-bundle, trace, and span identities.

`trace_id` and `span_id` use native telemetry context and answer causality; they are not semantic/world identities. `sealed_bundle_id` is post-seal identity and must not be projected backward as if it caused evaluation execution. Baggage is deny-by-default. Never project the full semantic identity object into baggage; source text, prompt content, credentials, and large evidence payloads are forbidden carriers.

## Current executable frontier

Project `ctrlSemanticKernel.currentFrontier` exactly unless the authority contract changes:

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

Within that frontier retain the lower-level executable witnesses:

1. `otel-causal-correlation` — semantic/world identity survives causal execution observation without collapsing into trace identity.
2. `otlp-otap-roundtrip` — traces-only semantic preservation across OTLP -> OTAP -> OTLP.

For the round-trip comparator include resource identity, instrumentation scope, `trace_id`, `span_id`, `parent_span_id`, trace state, timestamps, span kind/status, attributes, events and event attributes, links and link attributes, and ctrl correlation attributes. Exclude record-batch partitioning, dictionary encoding, batch ordering, column ordering, and physical Arrow representation. Metrics and logs remain deferred unless the contract changes.

Explicitly record the GitHub App coverage gaps for semantic-kernel execution and Weaver projection rather than asserting them as validated.

## Critical

Render critical `blocking-gate` items from `evidence.json` only. A projected or optional upstream cannot become blocking without a materialized declared local consumer/gate.

## High

Render high `contract-update` items from `evidence.json` only.

## Notes

Render note items from `evidence.json` only.

## No local action

Render `none` items from `evidence.json` only.

## Publication

- Bundle: `<bundle_path>`
- Manifest: `<manifest_path>`
- Latest pointer: `<latest_pointer_path>`
- Export unit: directory

The run artifacts bind the authority revision they evaluated. The latest pointer may additionally record the manifest-seal commit as `publication_revision`.

## Validation notes

Disclose authority/context/project-topology/semantic-kernel reads, source resolution, graph/model and upstream-binding reads, correlation-carrier-policy and semantic-interface-boundary reads, report/summary projection status, CUE execution availability, CPython regrtest/probe status, Astral/SCIP correlation status, OpenTelemetry pipeline status, OTLP/OTAP round-trip status, relational-projection status, semantic-kernel execution status, and Weaver projection status.

`monitor_state: terminal_success` means the monitor loop completed. It does not imply executable qualification; report `qualification_state` independently as `observation_only`, `executable_validated`, or `executable_failed`.
