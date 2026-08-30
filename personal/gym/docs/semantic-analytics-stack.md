# Gym semantic analytics stack

Status: proposed architecture; not yet implemented.

## Objective

`personal.gym` should reuse mature biomechanics, motion, unit, wearable, and analytics conventions without allowing any external schema or query engine to become Gym semantic authority.

The design follows the same Factory rule already documented for software-supply-chain analytics:

```text
domain semantic authority
        ↓
adapters / normalization
        ↓
backend-specific representation
        ↓
queries / projections
        ↓
domain admission
```

For software-oriented profiles, GUAC may provide a typed supply-chain graph while the profile determines significance. For Gym, the equivalent is a standards-informed relational model over motion, biomechanical, recovery, and program observations.

## Authority boundary

Canonical meaning remains under:

```text
contracts/personal/gym/
```

External standards and tools may provide vocabulary, coordinate conventions, acquisition formats, transformation machinery, or analytical execution. They do not define program state, causal interpretation, target admission, progression, recovery admission, or restoration.

The intended stack is:

```text
BIDS-Motion + ISB conventions + UCUM
              │
              ├── Open mHealth / IEEE 1752.1 where useful
              │
              ▼
       Gym CUE semantic profile
              │
              ▼
    canonical relational model
              │
       ┌──────┴──────┐
       ▼             ▼
     Ibis          Malloy
 transforms    semantic analytics
       │             │
       └──────┬──────┘
              ▼
      DuckDB / BigQuery
```

C3D, OpenSim, OpenCap, AddBiomechanics, PhysioNet, CSV, Parquet, and similar formats or sources enter through adapters below the Gym authority boundary.

## Borrowed semantic substrates

### BIDS-Motion

BIDS-Motion is the preferred external vocabulary for motion-acquisition identity and metadata. Useful concepts include:

- subject;
- session;
- task;
- tracking system;
- acquisition/run identity;
- channel;
- tracked point/component;
- sampling frequency;
- device metadata;
- coordinate/reference metadata.

BIDS also maintains a machine-readable schema in YAML/JSON. Gym should consume selected concepts through an adapter rather than serialize personal training data as a literal BIDS dataset unless a future export use case requires it.

Proposed mapping:

```text
BIDS subject         -> Gym subject
BIDS session         -> Gym session
BIDS task            -> Gym task/exercise context
BIDS tracking system -> acquisition device/system
BIDS channel         -> signal channel
BIDS component       -> signal component
BIDS sidecar metadata-> acquisition/protocol metadata
```

### ISB biomechanical conventions

Where joint or segment geometry becomes machine-derived, Gym should reference established International Society of Biomechanics joint/segment coordinate conventions rather than inventing local coordinate semantics.

A future angle measurement should therefore be able to retain at least:

```text
joint / segment
side
quantity
coordinate convention
value
unit
source/protocol
```

The coordinate convention is evidence metadata; it does not itself establish mechanical quality.

### UCUM

UCUM-compatible unit identity should be preferred where external interoperability matters. The existing Gym unit vocabulary may remain ergonomic internally, with a deterministic mapping to canonical UCUM expressions where available.

### Open mHealth / IEEE 1752.1

Open mHealth and IEEE 1752.1 are useful reference models for future wearable, sleep, physical-activity, and recovery observations because they distinguish measurement payload from acquisition/context metadata.

Gym must not inherit Open mHealth's closed-world assumption. Missing Gym observations remain unknown/unobserved rather than false or normal.

### OMOP

OMOP is not the Gym canonical model. A future OMOP projection may be useful for interoperability with clinical or population-health data, but Gym-specific concepts such as chain, phase, exercise setup, mechanical constraint, ROM stage, and equilibrium relation should not be flattened into OMOP as the primary representation.

## Canonical relational model

The Gym warehouse should remain a conventional relational analytical model rather than a universal graph.

### Dimensions

Candidate dimensions:

```text
dim_subject
dim_session
dim_task
dim_exercise
dim_protocol
dim_region
dim_joint
dim_chain
dim_metric
dim_channel
dim_device
dim_coordinate_frame
dim_dataset
```

### Facts

Candidate facts:

```text
fact_exposure
fact_measurement
fact_signal_feature
fact_constraint
fact_recovery
fact_capacity
fact_equilibrium
fact_relation_evidence
```

### Bridges / declared relations

```text
bridge_exercise_chain
bridge_region_chain
bridge_metric_subject
bridge_chain_relation
bridge_metric_lineage
```

These relations are generated or validated against CUE authority. The relational schema is an analytical projection, not an independent source of meaning.

## Semantic analytics with Malloy

Malloy is a candidate semantic-query layer above DuckDB and BigQuery. Its role is distinct from Ibis:

```text
CUE
  defines metric and relation meaning

Ibis
  performs deterministic relational transformations

Malloy
  exposes reusable joins, dimensions, measures, and analytical views

DuckDB / BigQuery
  execute queries
```

Malloy supports both DuckDB and BigQuery, which matches Factory's existing local-versus-warehouse execution model.

A Malloy measure must not become authoritative merely because it exists in a model. Important Gym measures should originate from or be checked against CUE metric definitions and lineage.

Example analytical surface:

```text
session
  -> exposures
     -> exercise
        -> primary chain
        -> constraint interfaces
  -> recovery
  -> equilibrium
```

Reusable measures may include:

```text
clean_exposure_count
highest_clean_rom
limiter_rate
bilateral_asymmetry
posterior_capacity_index
anterior_capacity_index
recovery_cost
```

## Source-format adapters

Source formats remain below the semantic boundary.

```text
C3D
OpenSim TRC/MOT/STO
BIDS-Motion TSV/JSON
OpenCap outputs
AddBiomechanics outputs
PhysioNet datasets
CSV / Parquet
        │
        ▼
normalization adapter
        │
        ▼
Gym canonical relations
```

C3D/OpenSim/BIDS identity should be retained as provenance where relevant, while source-specific structural details are normalized away unless they affect interpretation.

## Signal store versus analytical warehouse

High-frequency samples should not dominate the ordinary analytical model.

Use a two-tier representation:

```text
object/columnar signal store
  frame-level video/pose/IMU/EMG/GRF/kinematic series
        │
        ▼
feature extraction
        │
        ▼
DuckDB / BigQuery analytical relations
  trial metadata
  derived features
  distributions
  semantic relations
  quality/provenance
```

Parquet/Arrow is the preferred bounded/local interchange surface. BigQuery is appropriate for larger public reference corpora and cross-dataset aggregation. DuckDB remains the local execution backend. Ibis should express transformations independently of backend when practical.

## Public reference data

Public datasets belong to a reference plane distinct from personal Gym state.

Candidate initial sources include:

- AddBiomechanics for standardized kinematic/kinetic features;
- PhysioNet multimodal gait data for force, IMU, and muscle-activation relationships;
- GaitRec and Gutenberg gait datasets for bilateral GRF and redistribution/reference analyses;
- OpenCap validation data for future video-to-kinematics qualification.

External distributions may contextualize Gym observations but must not automatically become target criteria.

```text
reference distribution != program target
```

A target requires separate Gym program admission.

## Semantic relations

The relational model should permit declared relations such as:

```text
muscle   -> acts-across       -> joint
joint    -> part-of           -> region
region   -> participates-in   -> chain
metric   -> measures          -> region/joint/chain
metric   -> derived-from      -> signal
trial    -> uses-protocol     -> protocol
trial    -> performs          -> task
signal   -> captured-by       -> device
feature  -> comparable-with   -> Gym metric
```

`comparable-with` requires explicit qualification. Shared anatomy or a similar metric name is not sufficient evidence of comparability.

## Equilibrium integration

The equilibrium model remains a Gym semantic construct. External biomechanics data can supply observations and reference distributions for:

- bilateral asymmetry;
- reciprocal/agonist-antagonist capacity;
- distal-proximal relations;
- anterior-posterior relations;
- frontal-sagittal relations;
- load-transfer timing;
- controlled-ROM fractions;
- limiter distributions;
- recovery-normalized capacity.

External norms do not override the current requirement that equilibrium use mechanically admitted, protocol-comparable observations and preserve signed asymmetry.

## Implementation sequence

1. Keep this architecture documentation-only until the personal capture vocabulary and first baseline runs stabilize.
2. Add external semantic/source references under the Gym contracts without changing personal observation authority.
3. Define the canonical relational dimensions, facts, bridges, and grain in CUE.
4. Generate or validate Ibis schemas/adapters from those contracts.
5. Add a small Malloy model generated from or checked against authoritative metric/relation definitions.
6. Implement one bounded adapter first, preferably BIDS-Motion or AddBiomechanics-derived features.
7. Validate equivalent Ibis queries against DuckDB and BigQuery.
8. Add public reference datasets only when they answer a concrete program/equilibrium question.
9. Keep OMOP and clinical interoperability as optional projections rather than dependencies.

## References

- BIDS specification and machine-readable schema: https://bids-specification.readthedocs.io/
- BIDS-Motion: https://bids-specification.readthedocs.io/en/stable/modality-specific-files/motion.html
- Malloy database support: https://docs.malloydata.dev/documentation/setup/database_support
- Open mHealth schema design principles: https://www.openmhealth.org/documentation/schema-docs/schema-design-principles/
- IEEE 1752.1-2021: https://standards.ieee.org/ieee/1752.1/6982/
- Factory tracker/runtime architecture: `docs/architecture/factory-tracker-runtime.md`
