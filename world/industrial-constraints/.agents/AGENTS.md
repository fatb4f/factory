# industrial-constraints execution procedure

This unit is a domain-owned Factory intelligence profile. Its semantic authority is `contracts/world/industrial-constraints/`; this file defines execution procedure only.

## Phase selection

Read `contract.execution.phase` before executing the task.

The current admitted phase is `event-watch`.

```text
Factory registry
  -> domain CUE authority
  -> event-watch acquisition
  -> source-qualified documents
  -> source-qualified event observations
  -> relevance classification
  -> admitted observation report/run bundle
```

The future `relational-pipeline` phase is already modeled as a target contract, but it is not a prerequisite for current event monitoring:

```text
bounded acquisition adapters
  -> typed relational normalization
  -> canonical identity
  -> Ibis projections
  -> admitted relational state
  -> graph correlation
  -> evidence-backed constraint claims
  -> admitted relational report/run bundle
```

Do not execute the second path unless `contract.execution.phase` is explicitly changed to `relational-pipeline`.

## Event-watch rules

- Track material events across the declared Canada/Quebec industrial surfaces and institutions.
- Prefer official institutional, operator, supplier, program, procurement, regulatory, facility and project publications. Discovery sources may locate candidate records but do not upgrade their authority.
- Represent each acquired publication as a source-qualified `document` and each material tracked event as an `event-observation`.
- Event-observation provenance must retain source family, channel, publisher, source-record identity, revision/publication identity, observed surface, and acquisition time; retain observation/publication time where available.
- Event-observation actors and subjects are observed labels, not canonical entity identities. Do not infer equivalence because labels resemble known entities.
- Classify relevance only against declared geography and industrial surfaces and assign `track`, `investigate`, or `low-relevance`.
- `event-watch` may publish observed events, institutional responses, infrastructure/capacity signals, funding/procurement signals, and explicit coverage gaps.
- `event-watch` must publish no `claim`, `assessment`, `constraint-claim`, canonical graph propagation, or inferred binding-constraint state. The public event-watch report structurally requires `constraintClaims: []`.
- Missing Ibis, DuckDB, BigQuery, bulk adapters, canonical identity resolution, or graph projection is not an event-watch failure. Record a coverage gap only when it materially limits event acquisition within the current watch surface.
- If material source acquisition is incomplete enough that the event set cannot be represented responsibly, return `source_gap` rather than `no_material_events`.
- If acquisition is adequate and no material events are found, return `no_material_events`.
- If one or more material event observations are admitted, return `events_observed`.

## Relational-pipeline rules

These become operative only when `contract.execution.phase == "relational-pipeline"`:

- BigQuery is an observational query space, not canonical state.
- DuckDB/Parquet are bounded analytical-state adapters, not semantic authority.
- Graph representations are projections from admitted relational state.
- A constraint is an evidence-backed admitted claim, never a synonym for an announcement or isolated observation.
- Preserve source, channel/dataset, source-record identity, revision/version, acquisition time, and observation time where available.
- Do not infer graph propagation from names; use admitted relations.
- Record coverage gaps explicitly when required acquisition or validation is unavailable.
- Keep publication fail-closed for claims that fail relational admission.

## Unit surfaces

- `queries/`: target bounded acquisition/query definitions and implementation adapters for the relational pipeline; they are not required to perform the current event watch.
- `projections/`: target Ibis projection implementations and generated adapters for the relational pipeline.
- `runs/`: immutable admitted run bundles for either phase.
- `report-template.md`: current public report structure; phase-specific sections must follow `public.cue`.
