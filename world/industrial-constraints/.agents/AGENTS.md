# industrial-constraints execution procedure

This unit is a domain-owned Factory intelligence profile. Its semantic authority is `contracts/world/industrial-constraints/`; this file defines execution procedure only.

## Control path

```text
Factory registry
  -> domain CUE authority
  -> this unit-local procedure
  -> bounded acquisition
  -> typed relational observations
  -> deterministic projections
  -> admitted relational state
  -> evidence-backed constraint assessments
  -> admitted report/run bundle
```

## Rules

- Treat external datasets, documents, API responses, analyzer output, and prior reports as observations until admitted by the domain contract.
- Preserve source, channel/dataset, source-record identity, revision/version, acquisition time, and observation time where available.
- Do not infer entity equivalence from similar labels.
- Do not infer graph propagation from names; use admitted relations.
- BigQuery is an observational query space, not canonical state.
- DuckDB/Parquet are bounded analytical-state adapters, not semantic authority.
- Graph representations are projections from admitted relational state.
- A constraint is an evidence-backed admitted claim, never a synonym for an announcement or isolated observation.
- Record coverage gaps explicitly when required acquisition or validation is unavailable.
- Keep publication fail-closed: do not publish claims that fail contract admission.

## Unit surfaces

- `queries/`: bounded acquisition/query definitions and implementation adapters.
- `projections/`: Ibis projection implementations and generated adapters.
- `runs/`: immutable admitted run bundles only.
- `report-template.md`: fixed public report structure.
