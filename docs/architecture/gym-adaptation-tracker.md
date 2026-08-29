# Gym adaptation tracker

## Contract

The tracker models adaptation under a bounded recovery budget. Exercise performance is an input/output coordinate, not the sole objective.

```text
session intent
    -> planned exposure
    -> append-only capture
    -> normalized session state
    -> recovery checkpoints
    -> deterministic analysis
    -> adaptation / issue / association projections
```

Mechanical quality and systemic recovery cost are co-equal admission criteria.

## Authority layers

1. `contracts/personal/gym/`: CUE vocabulary, capture, exercise, analysis, issue, and projection authority.
2. `personal/gym/.agents/`: conversational acquisition instructions and templates.
3. `personal/gym/fixtures/`: synthetic examples used to exercise the contracts without publishing personal training data.
4. `personal/gym/projections/`: dormant relational runtime design for DuckDB/Ibis.

Observations remain fact-only. Normalization may resolve inherited setup and corrections, but it may not invent facts. Analysis creates derived assertions and never rewrites source observations.

## Capture model

The primary in-session record is an exposure observation containing sparse dose, ROM, constraint, limiter, measurement, and media references. Setup may be established once and inherited conversationally; normalized state resolves the effective setup before comparison.

Session start and close use small systemic/movement vectors. Recovery remains part of the same run and may be sampled around T+12/T+24/T+48/T+72 without requiring every checkpoint.

## Additional evidence streams

### Dual load

`#DualLoadSample` stores simultaneous left/right readings with a shared unit. `#DualLoadProjection` derives total, right-minus-left difference, shares, and signed asymmetry ratio. Raw samples stay immutable.

Repeated standardized tests are preferred for longitudinal use. Interpretation such as preferred side or correction is not admitted into raw capture.

### Video

`#MediaArtifact` registers the capture. Video-derived angle, ROM, timing, velocity, and symmetry values are separate measurements linked by media ID and marked with video provenance/certainty.

This permits later computer-vision adapters without changing the session contract.

## Analysis model

Session analysis retains separate vectors for:

- mechanical admission;
- capacity coordinates;
- local/systemic recovery cost;
- progress eligibility;
- adaptation dimensions.

No composite strength or readiness score is authoritative in v1. Adaptation comparisons use dimension directions and a Pareto-style class (`dominates-previous`, `mixed`, `equivalent`, `dominated-by-previous`, `insufficient-evidence`).

## Issues and associations

Persistent anomalies receive stable issue identities. Observations, recovery checkpoints, measurements, and session assessments can support, contradict, or contextualize an issue.

Association projections are explicitly non-causal. They may describe repeated relationships between exposure dimensions and recovery/mechanical outcomes while retaining source references.

## Relational projection

The canonical state remains CUE + captured unit data. Relational tables are generated projections for DuckDB/Ibis. Initial row contracts cover exposures, constraints, recovery, DOMS, dual-load samples, video metrics, issue evidence, session assessments, and adaptation dimensions.

Runtime dependencies should be added only after the real session corpus stabilizes the vocabulary and repeated queries justify the projection layer.
