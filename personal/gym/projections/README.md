# Gym relational projections

The CUE authority is `contracts/personal/gym/projections.cue`. DuckDB and Ibis are projection runtimes, not canonical storage.

## Pipeline

```text
append-only capture
    -> normalized session state
    -> CUE projection row contracts
    -> generated Python/Ibis schemas
    -> adapter flattens canonical records
    -> DuckDB relations/views
    -> longitudinal queries
```

Do not hand-maintain a second schema in Python. Generate or project the adapter types from the CUE row contracts when runtime work begins.

## Relations

- `exposures`: normalized dose/capacity/mechanical coordinates;
- `constraints`: one row per observed mechanical constraint;
- `recovery`: systemic recovery checkpoint state;
- `doms`: one row per region/checkpoint;
- `dual_load`: raw values plus deterministic load-distribution projection;
- `video_metrics`: media-linked measurements extracted from video;
- `issue_evidence`: longitudinal evidence attached to stable issue identities;
- `session_assessments`: mechanical/recovery admission output;
- `adaptation_dimensions`: vector-valued comparison dimensions.

## Storage adapter

Initial persistence may remain CUE/YAML/NDJSON. When the session corpus is large enough to justify querying, flatten admitted normalized records to Parquet or Arrow and register them in DuckDB. Ibis should remain the query-expression layer so the analysis logic is not tied to DuckDB-specific SQL.

## Activation gate

Do not add DuckDB/Ibis as runtime dependencies merely to validate the schema. Activate the runtime after repeated real sessions show that the capture vocabulary and exercise profiles are stable enough that longitudinal queries answer recurring questions.

First queries should target:

1. clean ROM/capacity progression at equal setup;
2. recovery cost by exercise/dose/range;
3. persistent side/constraint/limiter evidence;
4. dual-load distribution across repeated standardized stance tests;
5. video-derived mechanical metrics against manually captured constraint states;
6. association between exposure dimensions and recovery outcomes without causal claims.
