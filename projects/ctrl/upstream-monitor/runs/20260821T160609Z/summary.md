# ctrl upstream run summary

## Run identity

- Run ID: `20260821T160609Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `f3ca97ee98a9224dd05c4ed341e47f3fb74b84ee`
- ctrl revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Previous admitted run: `20260818T160440Z`

## Baseline

The selected ctrl monitor authority is unchanged from the prior admitted run; intervening factory changes were monitor outputs/pointers. `fatb4f/ctrl@main` is also unchanged. This run therefore evaluates upstream deltas against the prior sealed source heads.

## Project topology

`ctrl/spec` remains qualification authority. Project topology remains ownership/architecture context only. CPython remains Python runtime/compiler semantic evidence; Astral remains analyzer evidence; SCIP remains cross-file identity; OpenTelemetry remains causal observation; dlt remains external observation acquisition; Arrow/DuckDB/Ibis/Marimo remain projection layers; pydantic-graph remains replaceable execution-graph implementation.

## Decisions

- `blocking-gate`: 1
- `contract-update`: 2
- `note`: 3
- `none`: no additional report items

Material findings:

1. Codex Guardian reviewer sessions now omit selected executor MCP-server projection: blocking policy compatibility gate.
2. Codex app-server protocol/generated schemas advanced across MCP, thread, and configuration surfaces: contract update.
3. OpenTelemetry Python added stable `AlwaysRecordSampler`, preserving processor-visible RECORD_ONLY spans without changing export sampling: contract update.
4. Astral ty/parser/module/IDE semantic movement: note, analyzer evidence only.
5. OpenTelemetry Python GenAI tightened instrumentation dependency bounds/test pins: note.
6. OTel-Arrow added runtime-local retained-work accounting without runtime wiring/exported telemetry changes: note.

CPython current tips do not bind to declared monitored nodes. CUE forecast moved but pinned CUE authority did not; forecast movement does not replace the pinned evaluator.

## Qualification state

`observation_only`. No local CUE execution, CPython probes/regrtest, Astral/SCIP correlation, OpenTelemetry pipeline, OTLP/OTAP roundtrip, or relational projection was executed.

## Operationalization gap

The blocking Codex policy delta requires executable compatibility evidence before local policy adoption. Analyzer, telemetry, and projector conclusions remain non-authoritative until admitted through ctrl CUE qualification semantics.

## Bundle

`contracts/upstream-monitor/ctrl/contract-surface/runs/20260821T160609Z/`

## Validation

All required channels resolved independently; optional channels were also resolved. Source/channel identities were not collapsed. No cross-repository writes or issue updates were performed.
