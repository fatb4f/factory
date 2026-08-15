# ctrl upstream monitor summary

## Run identity

- Run: `20260815T140000Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `a00ea5f2e1311bbae5aa47589eebd94c88ad6405`
- Prior sealed run: `20260815T132600Z`

## Decisions

- Critical / blocking-gate: **0**
- High / contract-update: **5**
- Notes: **2**

### High

1. Rename dlt acquisition to external observations; acquired records/claims require provenance and admission before fact status.
2. Add `#CorrelationIdentity` plus a deny-by-default `ctrlTelemetryCarrierPolicy`; semantic identity remains distinct from trace/span identity.
3. Narrow `otlp-otap-roundtrip` P0 to canonical trace semantics and exclude physical Arrow layout.
4. Add orthogonal `qualification_state` so monitor success cannot be mistaken for executable qualification success.
5. Replace ambiguous v2 `factory_revision` semantics with `authority_revision`; `publication_revision` means the manifest-seal commit and is recorded by the latest pointer.

## Qualification state

`observation_only`. CUE, regrtest, CPython probes, Astral correlation, OpenTelemetry execution, and OTLP/OTAP round-trip validation were not executable through the GitHub App actuator.

## Operationalization gap

The next slice is intentionally narrow: one `RunProbe` operation, one normalized CPython observation, one OTel trace/event carrying admitted correlation identifiers, OTLP -> OTAP -> Arrow/Parquet, one relational correlation query, and exactly two executable witnesses (`otel-causal-correlation`, `otlp-otap-roundtrip`).

## Bundle

`contracts/upstream-monitor/ctrl/contract-surface/runs/20260815T140000Z/`

## Validation

The public `AGENTS.md` and fixed report template now encode the OpenTelemetry/OTel-Arrow/dlt source families and the same authority/correlation/qualification boundaries as the internal profile contracts.
