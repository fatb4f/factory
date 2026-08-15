# ctrl upstream impact report

## Run identity

- Run ID: `20260815T140000Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `a00ea5f2e1311bbae5aa47589eebd94c88ad6405`
- Publication revision: recorded in `latest.json` after manifest seal
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Prior sealed run: `20260815T132600Z`
- Bootstrap baseline: `false`

The authority revision is the pre-publication contract state evaluated by this run. The later publication revision denotes the commit that seals `manifest.json`; the `latest.json` commit is intentionally not used as a self-referential publication identity.

## Subject context

`fatb4f/ctrl@main` remains subject context, with `spec/` as its qualification semantic authority. Factory-local CUE plus the compatibility ingress and fixed report template remain monitor authority. The current profile now explicitly includes the OpenTelemetry/OTel-Arrow acquisition fabric and correlation carrier policy at the public actuator boundary.

## Source state

Required source identities used by this run:

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
- `cue/pinned`: `806821e40fae070318600a264d311517e596353b`
- `cue/master`: `f356f8f46cedb8e853ed200fb46ab49a68bfe357`

Optional/release-watch state remains separately identified: `dlt/devel` `a4243c994b9fade227d23e4bb18dab70037507cf`, `uv/main` `f1a42680ff5272232d65748acf338b19778dde24`, and `jj/main` `7fa941edb45b62efdadff6b01f6f8674dbad9063`.

## Codex projection graph

No authority correction changed the Codex projection chain in this run. Protocol, generated schema, Python SDK, live runtime, rollout persistence, and reconstruction remain separate graph nodes and evidence planes.

## Python semantic and operational graph

No authority correction changed CPython or Astral precedence. CPython remains compiler/runtime semantic evidence; regrtest remains upstream behavioral evidence; Astral remains static analyzer evidence; local probes remain targeted executable witnesses. The CPython control graph remains the consumer of all three.

## Observation and acquisition graph

Decision: `contract-update`.

The dlt branch has been corrected from `external-fact-acquisition` / `AcquireExternalFacts` to `external-observation-acquisition` / `AcquireExternalObservations`.

```text
external source
    |
   dlt
    |
acquired records / claims
    |
provenance + normalization
    |
relational ingress
    |
admission / correlation / qualification
    |
possible admitted fact
```

Acquisition adapters no longer imply truth status. dlt acquires externally asserted/observed records; OpenTelemetry acquires execution observations; Astral acquires static-analysis observations; CPython probes acquire language/runtime observations. `ctrl` determines the epistemic interpretation.

## Correlation carrier policy

Decision: `contract-update`.

A new `#CorrelationIdentity` and `ctrlTelemetryCarrierPolicy` now separate semantic identity from telemetry transport policy.

Required semantic identifiers are:

- `qualification_run_id`
- `repository_revision`
- `operation_id`

Optional identifiers are:

- `probe_id`
- `symbol_id`
- `source_occurrence_id`
- `evidence_id`

Baggage is deny-by-default. `qualification_run_id` may propagate in baggage; `repository_revision` is conditional; operation/probe/symbol/source-occurrence/evidence identifiers are span/event attributes but not baggage. Source text, credentials, and large evidence payloads are forbidden from all telemetry correlation carriers. Evidence payloads remain out-of-band and join through `evidence_id`.

The OTel Python baggage API stores arbitrary name/value pairs in context, so bulk projection of the semantic identity object into baggage is explicitly forbidden by the ctrl contract.

## P0 executable frontier

Decision: `contract-update`.

`otlp-otap-roundtrip` is now constrained to traces only. The canonical comparison includes:

- resource identity;
- instrumentation scope;
- `trace_id`, `span_id`, `parent_span_id`;
- trace state;
- timestamps;
- span kind/status;
- span attributes;
- events and event attributes;
- links and link attributes;
- ctrl correlation attributes.

The comparator explicitly ignores record-batch partitioning, dictionary encoding, batch ordering, column ordering, and physical Arrow representation. Metrics and logs are deferred until the trace witness passes.

The second P0 witness remains `otel-causal-correlation`: admitted semantic identity must survive execution observation without collapsing into trace/span identity or indiscriminate baggage.

## Run-state and publication semantics

Decision: `contract-update`.

The evidence/report contract is now v2 and distinguishes:

```text
monitor_state:       terminal_success
qualification_state: observation_only
```

`terminal_success` means the monitor loop completed; it does not claim the proposed realization passed executable qualification.

`factory_revision` has been replaced by `authority_revision` in v2 run evidence/report semantics. `publication_revision` is optional in the immutable bundle and is recorded in `latest.json` after sealing; it means the manifest-seal commit, not the commit that writes the pointer itself.

## Critical

None.

## High

1. Rename dlt acquisition from facts to external observations and require admission before fact status.
2. Add explicit semantic correlation identity and telemetry carrier policy with baggage deny-by-default.
3. Narrow the OTLP/OTAP P0 round-trip to canonical trace semantics.
4. Split monitor completion from executable qualification state.
5. Replace ambiguous `factory_revision` with `authority_revision` and define non-recursive publication revision semantics.

## Notes

- Architecture expansion is intentionally stopped for this slice. The next qualification work is the smallest end-to-end realization, not another provider.
- Marimo remains deferred until the relation containing semantic, static, causal, and qualification identities is executable and joinable.

## No local action

No additional upstream provider family is admitted by this correction run.

## Publication

- Bundle: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T140000Z/`
- Manifest: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T140000Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/ctrl/contract-surface/latest.json`
- Export unit: directory

## Validation notes

- Authority/context reads: completed.
- Required source identities: resolved.
- Graph/model and correlation carrier policy: read.
- CUE execution: not available to GitHub App actuator.
- CPython regrtest/probes: not executed.
- Astral/CPython correlation: not executed.
- OpenTelemetry pipeline: not executed.
- OTLP/OTAP trace round-trip: not executed.
- Report/summary: projections of the v2 evidence model.
- Qualification state: `observation_only`.
- Cross-repository writes: none.
