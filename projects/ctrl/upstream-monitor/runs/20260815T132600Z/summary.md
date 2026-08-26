# ctrl upstream monitor summary

## Run identity

- Run: `20260815T132600Z`
- Profile: `ctrl`
- Terminal state: `terminal_success`
- Prior run: `20260812T144000Z`
- Mode: OpenTelemetry acquisition-fabric profile extension

## Decision

- Critical / blocking-gate: **0**
- High / contract-update: **3**
- Notes: **2**

## High

1. **Use OpenTelemetry as the execution-acquisition and causal-context substrate.** Generic contrib instrumentors observe Python plumbing; custom ctrl probes remain responsible for CPython and qualification semantics.
2. **Admit GenAI/MCP semantic conventions and Python instrumentations as the agent-execution observation family.** Agent/model/tool activity can share trace context with repository, analyzer, probe, regrtest, and qualification operations.
3. **Use OTel-Arrow as the OTLP-to-columnar boundary.** Qualify OTLP -> OTAP preservation and consume Arrow RecordBatches / Arrow IPC / Parquet rather than writing a bespoke SpanExporter-to-Arrow semantic bridge first.

## Notes

- `dlt` remains external-data acquisition, separate from OpenTelemetry execution acquisition; they converge only at the facts/Arrow/relational boundary.
- Maturity remains evidence metadata, not authority: contrib and GenAI instrumentations are beta and the OTAP Dataflow Engine is still under active development.

## Authority hierarchy

```text
ctrl/spec + CUE     qualification authority
CPython             compiler/runtime semantics
Astral Rust         static analyzer observations
regrtest/probes     behavioral/domain observations
OpenTelemetry       causal execution observations
OTel-Arrow          columnar telemetry projection/transport
dlt                 external fact acquisition
```

## Execution graph additions

- `AcquireExternalFacts`
- `StartObservationContext`
- `EmitDomainObservations`
- `ExportOTLP`
- `ProjectOTAP`
- `PersistColumnarObservations`

New qualification probes:

- `otel-causal-correlation`
- `otlp-otap-roundtrip`

## Validation

CUE, regrtest, CPython probes, Astral correlation, OpenTelemetry execution, and OTLP/OTAP round-trip validation were not executable through the GitHub App actuator. No such execution is claimed.
