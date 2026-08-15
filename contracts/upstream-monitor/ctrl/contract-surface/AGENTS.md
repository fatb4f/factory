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

Maintain a versioned, graph-aware impact and operationalization view of upstream changes that intersect `fatb4f/ctrl@main`, while preserving source, semantic, causal, transport, and qualification authority boundaries.

Required evidence families:

1. Codex: Rust protocol, exported schemas, Python `openai_codex` SDK, live app-server/tool/config semantics, rollout persistence/lineage/reconstruction.
2. CPython: Python 3.14 active branch plus main forecast, subsystem dependency DAG, CPython regrtest as upstream behavioral evidence, and ctrl-local executable probes.
3. Astral Rust: Ruff parser/AST/index/static semantics plus ty resolver/type/IDE machinery as analyzer evidence correlated against CPython, never compiler/runtime authority.
4. OpenTelemetry Python core: API/SDK, context, traces and OTLP as execution-observation and causal transport substrate.
5. OpenTelemetry Python contrib: generic integration instrumentors as provider adapters for runtime plumbing; they do not replace ctrl domain probes.
6. GenAI semantic conventions and Python realization: agent/model/tool/MCP observation vocabulary and instrumentors, including OpenAI-facing behavior, without promotion to ctrl qualification authority.
7. OTel-Arrow: OTLP/OTAP projection, Arrow record batches, dataflow, IPC/Parquet persistence, and the P0 traces-only round-trip preservation boundary.
8. dlt: optional external-observation acquisition. Acquired records/claims require provenance and admission before any ctrl fact status; they remain distinct from OpenTelemetry execution observations.
9. CUE: ctrl's pinned evaluator revision kept distinct from upstream master forecast.
10. uv and Jujutsu: release-watch satellites limited to declared local consumers.

## Authority and identity boundaries

`ctrl/spec` and CUE determine qualification meaning. CPython supplies compiler/runtime semantic evidence. Astral supplies static analyzer observations. OpenTelemetry supplies causal execution observations. OTel-Arrow supplies a physical/columnar telemetry projection. dlt supplies externally acquired observations. None of those acquisition or observation adapters may manufacture qualification verdicts.

Trace identity and semantic identity are distinct. Read `correlation.cue` and apply `ctrlTelemetryCarrierPolicy` before projecting ctrl identities into span attributes, event attributes, baggage, or resource attributes. Baggage is deny-by-default; source text, credentials, and large evidence payloads are forbidden carriers.

## CPython operationalization

Treat operational CPython as a qualification target. The durable operation graph is declared in CUE and may project to Pydantic transports. `pydantic-graph` is an initial executor candidate, not authority. Marimo is an interactive projection/diagnosis surface, not workflow, evidence, or qualification authority.

The CPython process adapter must invoke the checked-out interpreter through `./python -m test` for regrtest slices. Do not import `test.libregrtest` as a stable dependency. Local probes emit normalized observations; they do not emit claimant-authored qualification verdicts.

## P0 executable frontier

Keep the initial realization narrow:

```text
CUE correlation + carrier policy
        -> Python observation adapter
        -> one RunProbe operation
        -> normalized CPython observation + OTel trace/event
        -> OTLP
        -> OTAP
        -> Arrow/Parquet
        -> relational ingress
        -> one correlation query
```

The two required executable witnesses are:

1. `otel-causal-correlation`: admitted semantic identities survive execution observation without collapsing into trace identity or indiscriminate baggage.
2. `otlp-otap-roundtrip`: traces-only canonical OTLP semantics survive OTLP -> OTAP -> OTLP. Compare resource/scope identity, trace/span/parent IDs, trace state, timestamps, kind/status, attributes, events, links, and ctrl correlation attributes. Ignore record-batch partitioning, dictionary encoding, batch/column ordering, and physical Arrow representation. Metrics and logs are deferred.

## Run-state semantics

`terminal_state`/`monitor_state` describes whether the monitor loop itself completed. `qualification_state` is orthogonal:

```text
observation_only
executable_validated
executable_failed
```

Never interpret `terminal_success` alone as executable qualification success.

Use `authority_revision` for the pre-publication contract revision actually evaluated. When publication identity is recorded, `publication_revision` means the commit that seals `manifest.json`, not the later self-referential commit that writes `latest.json`.

## Bootstrap run

If `latest.json` does not exist, establish a bootstrap baseline rather than inventing a historical delta. Resolve exact current source/channel revisions, verify required upstream surfaces exist, bind observations to declared graph nodes/edges, disclose unavailable executable validation, set the corresponding qualification state, and publish a normal sealed bundle.

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
