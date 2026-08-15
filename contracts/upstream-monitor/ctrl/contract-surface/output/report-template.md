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

Summarize the current `fatb4f/ctrl@main` authority boundary and components read. `spec/` remains ctrl's qualification semantic authority; the monitor contract remains factory-local authority for this loop. Component identities and roots come from `control/components.cue`.

## Project topology and ownership

Project the architecture contract from `profiles_ctrl/topology.cue` and preserve its ownership boundaries:

- `ctrl`: concrete repository-mutation control and qualification; parent Codex is the sole adaptive inference authority and `ctrl/spec` + CUE gate qualification meaning.
- `python-intel`: architectural observation/evaluation substrate; not itself an analyzer or qualification authority.
- PyPI/wheel/PEP pipeline: first concrete python-intel materialization through acquire -> normalize -> analyze -> correlate -> evaluate -> relational projection.
- `semagrams`: future mutation-graph substrate only until admitted into `ctrl/spec`.

Do not infer assembly identity from sibling checkout paths. Each component/project owns its descriptors, outgoing dependencies, locks, observations, tests, artifacts, provenance, and local qualification. ctrl owns only declared pins/contract references, federation-only evaluations, compatibility scenarios, and assembly commands.

## Source state

List every declared source/channel separately with exact resolved commit or explicit unresolved state. Never collapse same-named channels across sources.

Required families include Codex, CPython, Astral Rust, SCIP, OpenTelemetry Python core, OpenTelemetry Python contrib, GenAI semantic conventions, Python GenAI instrumentation, OTel-Arrow, and CUE. dlt, Arrow, DuckDB, Ibis, Marimo, pydantic-graph, uv, and Jujutsu are optional/release-watch sources unless another contract promotes them.

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

Record projection inconsistencies separately from ordinary upstream changes.

## Python semantic and operational graph

Summarize affected CPython DAG nodes, selected upstream regrtest bindings, selected local probe bindings, and the operationalization state of the typed execution graph. Distinguish source evidence, upstream test evidence, local probe evidence, correlation, and qualification.

Summarize Astral's Rust parser/AST/index/resolver/type observations separately from CPython compiler/runtime semantics. Analyzer evidence may refine correlation and probe selection but may not override contradictory CPython evidence.

Treat SCIP as the cross-file symbol/source-occurrence identity spine. SCIP identity can join definitions/references to CPython source positions, code objects, instructions, executions, tests, and samples, but may not manufacture CPython semantic facts.

## Observation and acquisition graph

Report the acquisition boundary explicitly:

```text
external records / claims                execution observations
          |                                      |
         dlt                               OpenTelemetry
          |                                      |
          |                              trace/span causal context
          |                                      |
          |                                     OTLP
          |                                      |
          |                                     OTAP
          |                                      |
          +----------- Arrow / relational ingress --------+
```

Do not label dlt output as facts before provenance/admission/qualification. Do not treat telemetry as semantic or qualification authority. Record OTel Python core, contrib, GenAI, and OTel-Arrow source identities separately.

## Relational and diagnostic projection

Preserve the intended projection stack:

```text
typed observations
      |
    Arrow
      |
   DuckDB
      |
    Ibis
      |
   Marimo
```

Arrow is typed interchange, DuckDB is the relational substrate, Ibis is the semantic query projection, and Marimo is an interactive diagnostic surface. None of these layers may derive qualification authority. `pydantic-graph`, when used, is a replaceable typed execution-graph implementation; CUE remains the durable operation/qualification contract.

## Correlation carrier policy

Summarize the admitted `#CorrelationIdentity` and `ctrlTelemetryCarrierPolicy` projection. Preserve semantic identity separately from trace/span identity.

At minimum disclose:

- repository/qualification operation identity;
- agent turn, tool call, MCP call, mutation, test-attempt, probe, symbol/source-occurrence, and evidence identities when present;
- which identifiers may enter span attributes;
- which may enter event attributes;
- which may enter baggage;
- which are forbidden from baggage;
- that source text, prompt content, credentials, and large evidence payloads are forbidden telemetry carriers.

Baggage is deny-by-default. Never project the full semantic identity object into baggage.

## P0 executable frontier

Keep P0 constrained to one end-to-end operation and two executable witnesses:

1. `otel-causal-correlation` — semantic identity survives causal execution observation.
2. `otlp-otap-roundtrip` — traces-only semantic preservation across OTLP -> OTAP -> OTLP.

For the round-trip comparator include resource identity, instrumentation scope, `trace_id`, `span_id`, `parent_span_id`, trace state, timestamps, span kind/status, attributes, events and event attributes, links and link attributes, and ctrl correlation attributes.

Explicitly exclude record-batch partitioning, dictionary encoding, batch ordering, column ordering, and physical Arrow representation. Metrics and logs are deferred from P0.

## Critical

Render critical `blocking-gate` items from `evidence.json` only.

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

Disclose authority/context/project-topology reads, source resolution, graph/model reads, correlation-carrier-policy read, report/summary projection status, CUE execution availability, CPython regrtest/probe status, Astral/SCIP correlation status, OpenTelemetry pipeline status, OTLP/OTAP round-trip status, and relational-projection status.

`monitor_state: terminal_success` means the monitor loop completed. It does not imply executable qualification; report `qualification_state` independently as `observation_only`, `executable_validated`, or `executable_failed`.
