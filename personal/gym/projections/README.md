# Gym relational projections

The CUE authority is `contracts/personal/gym/projections.cue`. Generated Python domain types, session JSONL, DuckDB, Ibis, Marimo, and dedicated UI surfaces are runtime/projection layers, not competing semantic authorities.

See [`../docs/session-execution-architecture.md`](../docs/session-execution-architecture.md) for the executable-session, JSONL, OTel, sealing, analytics, and UI architecture.

## Pipeline

```text
Gym CUE contracts
    -> generated/projected Python program graph
    -> executable Marimo session
    -> append-only session.jsonl + correlated OTel projection
    -> reconciled/sealed session bundle
    -> DuckDB normalized relations/views
    -> Ibis longitudinal/scoped expressions
    -> Marimo analytical views / web-mobile UI / GitHub progression scopes
```

Do not hand-maintain a second semantic schema in Python. The operational model may be Python-native, but adapter/domain types should be generated or projected from CUE contracts when runtime work begins.

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

These are relational projections over durable evidence, not replacements for the event ledger.

## Session artifact and storage adapter

The proposed runtime boundary is one append-only `session.jsonl` ledger per session/episode bundle. It contains normalized observed facts, control receipts, recovery observations, and supersession records with stable identities and revision provenance.

DuckDB should be able to scan the session corpus directly for the first vertical slice:

```text
sessions/*/session.jsonl
    -> normalization views
    -> canonical relational projection
```

Parquet or Arrow remain valid derived interchange/checkpoint formats when corpus size, repeated queries, or high-frequency signal materialization justify them. They should not become a second observation authority.

Ibis remains the query-expression layer so analysis logic is not tied to DuckDB-specific SQL or to one future backend.

## Analytical scope

`Session` is a provenance/execution boundary, not the mandatory query unit. Ibis expressions should support scopes over stable domain identities such as:

- program element and variant;
- movement and movement phase;
- mechanical constraint or demand;
- side;
- complex;
- primary contributor and helper/passive-helper relations;
- program/schema revision;
- recovery horizon and calendar window.

The generated Python program graph may expose ergonomic scope builders, but those should lower to Ibis predicates/joins rather than execute hidden storage logic inside the domain model.

## UI projection

A dedicated workout UI can be built over the same typed query/result boundary used by Marimo. Interaction patterns from projects such as [`WhyAsh5114/MyFit`](https://github.com/WhyAsh5114/MyFit) are useful references for active logging and progression presentation, but the UI must not own a parallel workout schema.

```text
DuckDB + Ibis
    -> typed analytical result adapters
       -> Marimo
       -> web/mobile UI
       -> GitHub progression summaries
```

## Activation gate

Do not add DuckDB/Ibis merely to validate schemas. Activate the runtime with the executable-session vertical slice, after the event envelope and Python projection boundary are explicit enough that at least two real sessions can be compared without reconstructing missing facts.

First queries should target:

1. clean ROM/capacity progression at equal setup and program revision;
2. recovery cost by exercise/dose/range;
3. persistent side/constraint/limiter evidence;
4. one program element together with declared helper/passive-helper exposure;
5. constraint migration across repeated executions;
6. dual-load distribution across repeated standardized stance tests;
7. video-derived mechanical metrics against manually captured constraint states;
8. association between exposure dimensions and recovery outcomes without causal claims.
