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

1. `contracts/personal/gym/`: CUE vocabulary, capture, exercise, analysis, issue, runtime-evidence, and projection authority.
2. `personal/gym/.agents/`: conversational acquisition instructions and templates.
3. `personal/gym/fixtures/`: synthetic examples used to exercise the contracts without publishing personal training data.
4. `personal/gym/projections/`: dormant relational runtime design for DuckDB/Ibis.
5. `personal/gym/docs/`: Gym-local architecture for external semantic conventions, biomechanics runtimes, and analytics substrates.

Observations remain fact-only. Normalization may resolve inherited setup and corrections, but it may not invent facts. Analysis creates derived assertions and never rewrites source observations.

External numerical objects are also non-authoritative. `ktk.TimeSeries`, Pyomeca/xarray arrays, OpenSim models, Pose2Sim outputs, and Malloy measures may participate in execution, but none becomes the Gym domain model.

## Capture model

The primary in-session record is an exposure observation containing sparse dose, ROM, constraint, limiter, measurement, and media references. Setup may be established once and inherited conversationally; normalized state resolves the effective setup before comparison.

Session start and close use small systemic/movement vectors. Recovery remains part of the same run and may be sampled around T+12/T+24/T+48/T+72 without requiring every checkpoint.

## Additional evidence streams

### Dual load

`#DualLoadSample` stores simultaneous left/right readings with a shared unit. `#DualLoadProjection` derives total, right-minus-left difference, shares, and signed asymmetry ratio. Raw samples stay immutable.

Repeated standardized tests are preferred for longitudinal use. Interpretation such as preferred side or correction is not admitted into raw capture.

### Video

`#MediaArtifact` registers the capture. Video-derived angle, ROM, timing, velocity, symmetry, pose, and reconstructed-coordinate values are separate measurements linked by media ID and marked with derivation provenance/certainty.

Future camera nodes should preserve device, stream, clock-domain, frame-rate, calibration, synchronization, orientation/coordinate, and content-digest metadata independently of the pose-estimation implementation.

This permits Pose2Sim, OpenCap, or future computer-vision adapters without changing the session contract.

## Analysis model

Session analysis retains separate vectors for:

- mechanical admission;
- capacity coordinates;
- local/systemic recovery cost;
- progress eligibility;
- adaptation dimensions.

No composite strength or readiness score is authoritative in v1. Adaptation comparisons use dimension directions and a Pareto-style class (`dominates-previous`, `mixed`, `equivalent`, `dominated-by-previous`, `insufficient-evidence`).

Machine-derived biomechanical observations remain inputs to these Gym analyses. A runtime can calculate an angle, force feature, timing feature, EMG envelope, or reconstructed trajectory; Gym determines whether that observation is protocol-comparable and what it means for capacity, compensation, redistribution, recovery, or equilibrium.

## Issues and associations

Persistent anomalies receive stable issue identities. Observations, recovery checkpoints, measurements, machine-derived features, and session assessments can support, contradict, or contextualize an issue.

Association projections are explicitly non-causal. They may describe repeated relationships between exposure dimensions and recovery/mechanical outcomes while retaining source references and runtime derivation lineage.

## Semantic analytics architecture

The Gym domain may reuse external standards, biomechanics runtimes, and analytics substrates without delegating semantic authority to them.

The revised composition is:

```text
BIDS-Motion + ISB conventions + UCUM
              │
              ├── Open mHealth / IEEE 1752.1
              │
              ▼
       Gym CUE authority
              │
              ▼
   capture / signal artifacts
              │
              ▼
 qualified biomechanics runtimes
              │
      ┌───────┼──────────────┐
      ▼       ▼              ▼
 KTK/Pyomeca  Pose2Sim/    OpenSim/
 low-level    OpenCap       biorbd
 processing   video→3D      mechanics
      │       │              │
      └───────┴──────┬───────┘
                     ▼
        canonical derived observations
                     │
                     ▼
          canonical relational model
                     │
              Ibis + Malloy
                     │
             DuckDB / BigQuery
```

This separates four concerns:

1. BIDS-Motion/ISB/UCUM provide external vocabulary and conventions.
2. Gym CUE defines canonical meaning and admission rules.
3. KTK/Pyomeca/Pose2Sim/OpenCap/OpenSim/biorbd are replaceable, qualified numerical executors.
4. Ibis/Malloy/DuckDB/BigQuery operate over canonical projections after derivation.

C3D, OpenSim, Pose2Sim, OpenCap, public biomechanics datasets, wearable schemas, and other source formats enter through normalization/runtime adapters. External reference distributions may contextualize observations but do not automatically become program targets.

The detailed design, authority boundaries, candidate relational dimensions/facts, runtime qualification rules, KTK/Pyomeca differential, markerless-capture path, semantic-query role for Malloy, public-reference plane, and implementation sequence are documented in:

`personal/gym/docs/semantic-analytics-stack.md`

## Biomechanics execution boundary

The first numerical runtime class is generic time-series/geometry processing.

Kinetics Toolkit is the initial candidate because it already provides time/event management, filtering, cycles, C3D handling, coordinate transforms, 3D angle extraction, and kinematic reconstruction. Pyomeca is retained as the closest OSS peer and differential backend, using xarray-backed biomechanical arrays and broad biomechanics file support.

Canonical execution should therefore look like:

```text
Gym operation contract
        │
        ├── KTK adapter
        └── Pyomeca adapter
                │
                ▼
      canonical DerivedObservation
                +
          RuntimeEvidence
```

The same principle applies upstream to Pose2Sim/OpenCap and downstream to OpenSim/biorbd. Runtime identity, version, parameters, inputs, calibration/synchronization references, coordinate convention, quality flags, and output lineage must remain available for reproducibility and comparability checks.

Runtime equivalence is contractual. Same-name/same-unit outputs are not automatically comparable.

## Relational projection

The canonical state remains CUE + captured unit data + admitted derived observations. Relational tables are generated projections for DuckDB/Ibis. Initial row contracts cover exposures, constraints, recovery, DOMS, dual-load samples, video metrics, runtime executions, issue evidence, session assessments, and adaptation dimensions.

High-frequency video, pose, IMU, EMG, GRF, and kinematic series belong in a signal/object/columnar layer. The analytical warehouse receives bounded features, distributions, quality metadata, and lineage rather than one row per raw sample by default.

Malloy is a candidate semantic analytics layer over the generated relational surface, not an additional semantic authority. Important joins, measures, and views should originate from or be checked against Gym CUE metric/relation definitions.

Runtime dependencies should be added only after fixtures establish their operation-level value. The proposed order is KTK first, Pyomeca differential qualification second, relational projection, then Pose2Sim once camera synchronization/calibration contracts are stable. OpenSim/biorbd remain optional until an admitted metric actually requires explicit musculoskeletal modeling.
