# ctrl upstream impact report

## Run identity

- Run ID: `20260815T132600Z`
- Profile: `ctrl`
- Terminal state: `terminal_success`
- Factory authority revision: `91c4d7aed8c3a988e113f7dfed752b0fa7d4c6f8`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Prior sealed run: `20260812T144000Z`
- Run mode: observation/acquisition profile extension and source refresh

## Source state

Required source heads resolved for this run:

- `codex/main`: `a7edf37cb46b5fc4d50bd03df8e5999a86f602eb`
- `codex/latest-alpha-cli`: `334c6ed7fd26cb96d9aa2849cf384ec8fb218f34`
- `cpython/3.14`: `3192cfdff70ef0771f39d2da046186d01951259c`
- `cpython/main`: `948fd7e5c084274c3945d2004a7fffd19c907a15`
- `astral-python/main`: `36cc91ffb72adde11f0c4dfb76330a07481f6153`
- `otel-python-core/main`: `aa8e7dbdfa4bd35c1d780d8c4cd5c7d6e3983ea8`
- `otel-python-contrib/main`: `1192425cdc7be548a1f50e59cef0c13424fdfbad`
- `otel-genai-semconv/main`: `30182acd5ed78ab5f619041eaec5e95a4eb83a48`
- `otel-python-genai/main`: `ae0343175a418e4d661e2508eec17dbd887ad5a3`
- `otel-arrow/main`: `5abeaf8efbd37b6c8519fc8edcd519281e988bbd`
- CUE pin remains `806821e40fae070318600a264d311517e596353b`; CUE `master` remains `f356f8f46cedb8e853ed200fb46ab49a68bfe357`.

Optional release-watch sources were also resolved: `dlt/devel` `a4243c994b9fade227d23e4bb18dab70037507cf`, `uv/main` `f1a42680ff5272232d65748acf338b19778dde24`, and `jj/main` `7fa941edb45b62efdadff6b01f6f8674dbad9063`.

## High — OpenTelemetry becomes the execution acquisition fabric

Decision: `contract-update`.

The profile now treats OpenTelemetry as the standard causal/execution observation substrate instead of planning a bespoke runtime-event transport. `opentelemetry-python-contrib` already provides independently installable provider-style instrumentors and explicitly separates API dependencies from the application-selected SDK. Generic HTTP, asyncio, threading, database, and system plumbing belongs in this instrumentation family; `ctrl`-specific instrumentation remains concentrated on CPython probes, regrtest, qualification, evidence, and semantic correlation identities.

The authority boundary is explicit: a span, event, metric, or log is an execution observation, not a qualification verdict and not an AST/symbol/compiler fact.

## High — GenAI/MCP observations join the same causal trace

Decision: `contract-update`.

The GenAI semantic-conventions repository defines spans, metrics, and events for GenAI clients, MCP, and provider-specific behavior including OpenAI. Its human-readable docs are substantially generated from YAML models and it uses Weaver to manage core-semconv dependencies. The Python GenAI instrumentation repository realizes those conventions on the OpenTelemetry Python SDK/contrib substrate and includes released OpenAI and OpenAI Agents instrumentations.

Local impact: agent/model/tool/MCP activity can share trace context with repository operations, Astral analysis, CPython probes, regrtest execution, and qualification operations. `ctrl` correlation keys remain separate semantic identities carried by telemetry; `trace_id` and `span_id` do not replace revision, symbol, probe, source-occurrence, or evidence identity.

## High — OTel-Arrow replaces a bespoke telemetry-to-Arrow bridge

Decision: `contract-update`.

OTel-Arrow explicitly defines OTAP as the column-oriented equivalent of OTLP and specifies non-lossy bidirectional conversion. Its data model represents telemetry as multiple Arrow record batches, and its embeddable Rust Dataflow Engine already provides OTLP/OTAP receivers/exporters, batching, routing, filtering, sampling, durable Arrow-IPC buffering, DataFusion transforms, and Parquet export.

The admitted projection is now:

```text
OpenTelemetry Python
        |
       OTLP
        v
OTel-Arrow / OTAP
        |
  Arrow RecordBatches
        |
 Arrow IPC / Parquet
        v
ctrl relational ingress
```

`ctrl` should therefore qualify OTLP -> OTAP round-trip preservation rather than authoring a custom `SpanExporter -> Arrow` semantic layer first.

## Note — dlt and OpenTelemetry remain different acquisition families

`dlt` is admitted as optional external-fact acquisition. Its current documentation describes API extraction, normalization, loading, and DuckDB destinations. It does not replace OpenTelemetry execution acquisition.

The separation is:

```text
external data facts       execution observations
       dlt                OpenTelemetry
        |                      |
        +------ Arrow / relational ingress ------+
```

This keeps facts such as release metadata/artifact digests distinct from facts about the execution that acquired or analyzed them.

## Note — maturity stays below authority

The profile does not promote experimental infrastructure into semantic authority. Python contrib labels its instrumentation packages beta; released Python GenAI instrumentations are currently beta versions; OTel-Arrow states that it is still completing its Dataflow Engine phase and does not currently publish prebuilt Dataflow Engine releases.

CUE and `ctrl/spec` remain qualification authority; CPython remains compiler/runtime semantic evidence; Astral remains static analyzer evidence; OpenTelemetry remains causal execution evidence; OTAP remains a transport/projection.

## Execution graph delta

New operations:

```text
AcquireExternalFacts
StartObservationContext
AcquireAstralAnalysis
...
RunRegrtests / RunProbes
EmitDomainObservations
CorrelateStaticDynamic
ExportOTLP
ProjectOTAP
PersistColumnarObservations
NormalizeEvidence
CorrelateEvidence
Qualify
```

New local qualification probes:

- `otel-causal-correlation`
- `otlp-otap-roundtrip`

## Validation

- Factory/profile authority read: yes.
- ctrl context read: yes.
- Required source identities resolved: yes.
- OpenTelemetry execution/semantic authority separation encoded: yes.
- External-fact/runtime-observation separation encoded: yes.
- OTLP/OTAP projection identity encoded: yes.
- CUE execution: not available to GitHub App actuator.
- CPython regrtest/probes: not executed in this profile-extension run.
- Astral/CPython correlation probes: not executed in this profile-extension run.
- OpenTelemetry pipeline and OTLP/OTAP round-trip: not executed in this profile-extension run.
- Cross-repository writes: none.
