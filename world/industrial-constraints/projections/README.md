# Projections

Ibis is the canonical relational projection IR for this unit. CUE defines projection identity, purpose, inputs, outputs, state boundary, and allowed backends; implementation adapters remain thin.

```text
CUE projection contract
  -> Ibis expression
  -> backend adapter
```

Backend roles:

- BigQuery: bounded external observational queries only.
- adapter: HTTP/API/bulk acquisition projected into an Ibis-compatible relation.
- memory: transient candidate/normalized relations.
- DuckDB: bounded admitted analytical state.
- Parquet: portable admitted-state interchange/checkpoint format.

Graph nodes and edges are derived from admitted `entities` and `relations`; NetworkX, Graphviz, Marimo, graph databases, and web views are render/adaptor targets rather than authority.

Implement source-specific expressions only when the corresponding source channel and projection are already represented in CUE. Prefer generated schemas and adapters over hand-maintained column contracts.
