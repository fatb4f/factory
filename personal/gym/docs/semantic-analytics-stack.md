# Gym semantic analytics stack

Status: proposed architecture; not yet implemented.

## Objective

`personal.gym` should reuse mature biomechanics, motion, unit, wearable, numerical-processing, musculoskeletal-modeling, and analytics ecosystems without allowing any external schema, Python object model, biomechanics package, or query engine to become Gym semantic authority.

The design follows the same Factory rule already documented for software-supply-chain analytics:

```text
domain semantic authority
        ↓
adapters / normalization
        ↓
qualified execution substrate
        ↓
backend-specific representation
        ↓
queries / projections
        ↓
domain admission
```

For software-oriented profiles, GUAC may provide a typed supply-chain graph while the profile determines significance. For Gym, the equivalent is a standards-informed canonical model over acquisition, motion, biomechanics, recovery, program state, capacity, and equilibrium observations, with external biomechanics runtimes used as replaceable numerical executors.

## Authority boundary

Canonical meaning remains under:

```text
contracts/personal/gym/
```

External standards and tools may provide vocabulary, coordinate conventions, acquisition formats, transformation machinery, numerical processing, markerless reconstruction, musculoskeletal modeling, or analytical execution. They do not define program state, causal interpretation, target admission, progression, recovery admission, restoration, capacity, compensation, redistribution, or equilibrium.

In particular:

```text
ktk.TimeSeries          != Gym observation model
xarray / Pyomeca arrays != Gym observation model
OpenSim model           != Gym anatomy authority
Pose2Sim output         != admitted Gym metric
Malloy measure          != Gym metric authority
```

All external outputs cross an explicit adapter/qualification boundary before becoming canonical derived observations.

## Revised layered composition

The architecture has four distinct planes that must not be collapsed into one stack.

```text
INTEROPERABILITY / CONVENTION PLANE

BIDS-Motion + ISB conventions + UCUM
              │
              ├── Open mHealth / IEEE 1752.1 where useful
              │
              ▼
       Gym CUE semantic authority
              │
              ▼
CAPTURE / SIGNAL PLANE

raw observations + media + device/acquisition metadata
              │
              ├── C3D / BIDS-Motion / CSV / Parquet
              ├── video / pose / IMU / EMG / GRF
              └── OpenSim/OpenCap source artifacts
              │
              ▼
QUALIFIED BIOMECHANICS EXECUTION PLANE

      ┌─────────────────────────────────────┐
      │ low-level numerical biomechanics    │
      │ Kinetics Toolkit / Pyomeca          │
      └──────────────────┬──────────────────┘
                         │
        ┌────────────────┼─────────────────┐
        ▼                ▼                 ▼
   Pose2Sim/OpenCap   OpenSim/biorbd    ezc3d/native I/O
 markerless capture  model mechanics      as needed
        │                │
        └────────────────┴─────────────────┐
                                           ▼
                              canonical derived observations
                                           │
                                           ▼
ANALYTICS / PROJECTION PLANE

                              canonical relational model
                                           │
                                  ┌────────┴────────┐
                                  ▼                 ▼
                                Ibis              Malloy
                           transformations    semantic analytics
                                  │                 │
                                  └────────┬────────┘
                                           ▼
                                   DuckDB / BigQuery
```

This preserves the existing BIDS-Motion/ISB/UCUM design while adding the previously missing numerical biomechanics execution layer.

## Runtime classes

The external ecosystem should be modeled by role rather than by package identity.

| Runtime class | Candidate implementations | Gym role |
| --- | --- | --- |
| acquisition/interchange | BIDS-Motion, C3D, CSV, Parquet | source identity, channels, devices, acquisition metadata |
| low-level biomechanics | Kinetics Toolkit, Pyomeca | time-series processing, filtering, events/cycles, geometry, kinematic feature extraction |
| markerless reconstruction | Pose2Sim, OpenCap | camera calibration/synchronization, pose reconstruction, triangulation, OpenSim-oriented outputs |
| C3D I/O | KTK C3D support, ezc3d | interchange implementation detail |
| musculoskeletal mechanics | OpenSim, biorbd | model-based kinematics/kinetics, direct/inverse mechanics, muscle elements |
| optimization/control | bioptim or equivalent | future model-predictive/optimal-control experiments; not required for initial Gym analytics |
| relational transformation | Ibis | deterministic backend-independent relational transforms |
| semantic query | Malloy | reusable joins, dimensions, measures, analytical views |
| execution backend | DuckDB, BigQuery | local and warehouse query execution |

Packages remain candidates until qualified against Gym fixtures and protocols.

## Borrowed semantic substrates

### BIDS-Motion

BIDS-Motion remains the preferred external vocabulary for motion-acquisition identity and metadata. Useful concepts include:

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
runtime/method
```

The coordinate convention is evidence metadata; it does not itself establish mechanical quality.

### UCUM

UCUM-compatible unit identity should be preferred where external interoperability matters. The existing Gym unit vocabulary may remain ergonomic internally, with a deterministic mapping to canonical UCUM expressions where available.

### Open mHealth / IEEE 1752.1

Open mHealth and IEEE 1752.1 are useful reference models for future wearable, sleep, physical-activity, and recovery observations because they distinguish measurement payload from acquisition/context metadata.

Gym must not inherit a closed-world assumption. Missing Gym observations remain unknown/unobserved rather than false or normal.

### OMOP

OMOP is not the Gym canonical model. A future OMOP projection may be useful for interoperability with clinical or population-health data, but Gym-specific concepts such as chain, phase, exercise setup, mechanical constraint, ROM stage, capacity relation, redistribution, and equilibrium should not be flattened into OMOP as the primary representation.

## Numerical biomechanics execution

### Kinetics Toolkit

Kinetics Toolkit is a strong candidate for the initial low-level biomechanics runtime. Its documented surface includes:

- `TimeSeries` data, time, and event management;
- segmentation and missing-data handling;
- filtering and derivatives;
- cycle detection and time normalization;
- C3D/CSV file handling;
- 3D points, vectors, coordinate frames, and homogeneous transforms;
- coordinate-system mapping and 3D angle extraction;
- kinematic chains;
- marker-cluster creation/tracking and kinematic reconstruction.

That is almost exactly the generic numerical middle layer Gym would otherwise have to implement.

KTK must nevertheless remain behind an adapter:

```text
Gym SignalSeries / AcquisitionArtifact
              │
              ▼
          KTK adapter
              │
              ▼
        ktk.TimeSeries
              │
      filters / cycles /
      geometry / kinematics
              │
              ▼
        KTK adapter
              │
              ▼
Gym DerivedObservation + RuntimeEvidence
```

No persisted Gym contract should require callers to construct or understand `ktk.TimeSeries`.

### Pyomeca

Pyomeca is the closest OSS peer to KTK and should be retained as a comparative/alternative runtime rather than ignored.

Its documented surface includes:

- biomechanics-oriented signal processing;
- normalization, onset/outlier detection, derivatives, and filtering;
- markers, analog/EMG channels, angles, and rototransforms;
- C3D, CSV, XLSX, MAT, TRC, STO, and MOT I/O;
- `xarray` as the labelled multidimensional array substrate;
- integration with ezc3d, OpenSim-oriented tooling, and biorbd.

The architectural distinction is useful:

```text
KTK
  custom TimeSeries abstraction
  general time/event/geometry processing

Pyomeca
  xarray-backed biomechanical arrays
  labelled multidimensional processing
```

Gym should not select one based on object-model preference alone. The first runtime qualification should compare both against the same canonical fixtures and expected outputs.

### Runtime neutrality

The canonical operation should be expressed by Gym intent, not package API.

For example:

```text
#BiomechanicsTransform
  operation: joint-angle-series
  inputs: [left-knee-frame, left-tibia-frame]
  coordinate_convention: ...
  protocol: ...
  expected_unit: deg
```

may project to KTK geometry calls, Pyomeca rototransforms, OpenSim coordinates, or another qualified implementation.

The adapter owns that projection.

## Markerless video capture

Video should remain a first-class acquisition stream, not an afterthought attached to session notes.

### Pose2Sim

Pose2Sim is a strong candidate for the initial local markerless pipeline. Its current documented workflow covers:

```text
camera calibration
      ↓
2D pose estimation
      ↓
camera synchronization
      ↓
person association
      ↓
triangulation
      ↓
filtering
      ↓
marker augmentation
      ↓
OpenSim scaling / inverse kinematics
```

It accepts ordinary camera sources such as phones, webcams, and action cameras and is designed to run locally. That maps well to the planned modular Gym capture nodes.

Gym should treat Pose2Sim as an upstream observation producer:

```text
camera artifacts
      ↓
Pose2Sim runtime
      ↓
3D points / markers / OpenSim-oriented files
      ↓
KTK / Pyomeca / OpenSim adapter
      ↓
canonical derived observations
```

Pose2Sim output is evidence, not automatically an admitted metric. Calibration quality, synchronization, model choice, filtering, confidence, occlusion, and reconstruction errors must remain available to qualification logic.

### OpenCap

OpenCap remains useful as both an alternative markerless runtime and a validation/reference ecosystem. OpenCap Core takes two or more videos, estimates 3D marker positions, and produces OpenSim-formatted movement kinematics; its related processing stack can extend into kinetics.

OpenCap should therefore be modeled as a peer source/runtime adapter rather than embedded in the Gym semantic model.

### Capture-node contract

Future capture hardware should target a package-neutral envelope such as:

```text
AcquisitionArtifact
  media_id
  device_id
  stream_id
  clock_domain
  start_time
  sample/frame rate
  calibration_ref
  synchronization_ref
  lens/camera metadata
  orientation / coordinate metadata
  content_digest
```

That lets the same capture node feed Pose2Sim, OpenCap, a future estimator, or direct video review.

## Musculoskeletal-model layer

### OpenSim

OpenSim remains the strongest interoperability target for model-based outputs because OpenCap and Pose2Sim already project into its ecosystem and public biomechanical datasets commonly expose TRC/MOT/STO artifacts.

OpenSim output should be imported as derived evidence with explicit model identity and processing protocol.

### biorbd

`biorbd` is a complementary OSS model runtime rather than a KTK replacement. It provides rigid-body and muscle-element analyses with direct/inverse biomechanics workflows through C++ plus Python/MATLAB interfaces.

The useful separation is:

```text
KTK / Pyomeca
    low-level observations and geometry
             ↓
OpenSim / biorbd
    explicit body/model mechanics
```

Gym should preserve that distinction. A kinematic observation should not require a musculoskeletal model unless the metric actually depends on one.

### bioptim

`bioptim` sits one layer further downstream, combining biorbd with optimal-control tooling. It is relevant to future control-theoretic experiments around movement strategies, load redistribution, or trajectory constraints, but it is not a dependency of the initial tracker.

## Canonical execution evidence

Every machine-derived observation should be able to preserve enough information to reproduce or challenge the calculation.

Candidate execution evidence:

```text
runtime_class
runtime_implementation
runtime_version
operation
parameter_set / digest
input_artifact_refs
input_digests
output_artifact_refs
coordinate_convention
unit convention
calibration_ref
synchronization_ref
quality flags
software/environment digest
```

This enables differential qualification:

```text
same Gym operation
      │
      ├── KTK adapter
      └── Pyomeca adapter
             │
             ▼
compare outputs within declared tolerance
```

Correlation/comparability is contractual. Two values that happen to have the same label and unit are not equivalent unless their protocol, coordinate semantics, derivation, and quality constraints are compatible.

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
dim_runtime
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
fact_runtime_execution
```

### Bridges / declared relations

```text
bridge_exercise_chain
bridge_region_chain
bridge_metric_subject
bridge_chain_relation
bridge_metric_lineage
bridge_runtime_qualification
```

These relations are generated or validated against CUE authority. The relational schema is an analytical projection, not an independent source of meaning.

## Semantic analytics with Malloy

Malloy remains a candidate semantic-query layer above DuckDB and BigQuery. Its role is distinct from Ibis and from the numerical biomechanics runtimes:

```text
CUE
  defines metric and relation meaning

KTK / Pyomeca / Pose2Sim / OpenSim / biorbd
  produce qualified biomechanical observations

Ibis
  performs deterministic relational transformations

Malloy
  exposes reusable joins, dimensions, measures, and analytical views

DuckDB / BigQuery
  execute queries
```

A Malloy measure must not become authoritative merely because it exists in a model. Important Gym measures should originate from or be checked against CUE metric definitions and lineage.

Example analytical surface:

```text
session
  -> exposures
     -> exercise
        -> primary chain
        -> constraint interfaces
  -> machine-derived observations
     -> runtime execution evidence
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
Pose2Sim outputs
OpenCap outputs
AddBiomechanics outputs
PhysioNet datasets
CSV / Parquet
        │
        ▼
normalization / runtime adapter
        │
        ▼
Gym canonical observations and relations
```

C3D/OpenSim/BIDS identity should be retained as provenance where relevant, while source-specific structural details are normalized away unless they affect interpretation or reproducibility.

## Signal store versus analytical warehouse

High-frequency samples should not dominate the ordinary analytical model.

Use a two-tier representation:

```text
object/columnar signal store
  raw + processed frame-level video/pose/IMU/EMG/GRF/kinematic series
        │
        ├── qualified runtime processing
        │      KTK / Pyomeca / Pose2Sim / OpenSim / biorbd
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
  runtime evidence
  quality/provenance
```

Parquet/Arrow is the preferred bounded/local interchange surface where practical. Native source files may be retained when conversion would discard relevant metadata. BigQuery is appropriate for larger public reference corpora and cross-dataset aggregation. DuckDB remains the local execution backend. Ibis should express relational transformations independently of backend when practical.

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
muscle    -> acts-across       -> joint
joint     -> part-of           -> region
region    -> participates-in   -> chain
metric    -> measures          -> region/joint/chain
metric    -> derived-from      -> signal
trial     -> uses-protocol     -> protocol
trial     -> performs          -> task
signal    -> captured-by       -> device
feature   -> produced-by       -> runtime execution
feature   -> comparable-with   -> Gym metric
runtime   -> qualified-for     -> operation/protocol
```

`comparable-with` requires explicit qualification. Shared anatomy, source package, or a similar metric name is not sufficient evidence of comparability.

## Equilibrium integration

The equilibrium model remains a Gym semantic construct. External biomechanics runtimes can supply observations and reference distributions for:

- bilateral asymmetry;
- reciprocal/agonist-antagonist capacity;
- distal-proximal relations;
- anterior-posterior relations;
- frontal-sagittal relations;
- load-transfer timing;
- controlled-ROM fractions;
- limiter distributions;
- muscle-synergy/coordination features where measured;
- recovery-normalized capacity.

A useful separation is:

```text
runtime fact
  knee flexion angle / pelvis rotation / GRF / EMG envelope / timing
             │
             ▼
Gym relation
  capacity / coordination / compensation / redistribution / equilibrium
```

External norms do not override the current requirement that equilibrium use mechanically admitted, protocol-comparable observations and preserve signed asymmetry.

## Runtime selection and qualification policy

No biomechanics package should become an architectural dependency merely because it is convenient.

Candidate admission criteria:

```text
licensing compatible
reproducible local execution
supported file/interface surface
coordinate semantics understood
version identifiable
parameters capturable
quality/error outputs available
fixtures reproducible
output tolerances declared
privacy/network behavior acceptable
```

The first useful differential is KTK versus Pyomeca for low-level processing. Pose2Sim versus OpenCap provides a later markerless-capture differential. OpenSim versus biorbd applies only once model-dependent metrics are required.

## Revised implementation sequence

1. Keep this architecture documentation-only until the personal capture vocabulary and first baseline runs stabilize.
2. Add external semantic/source references under the Gym contracts without changing personal observation authority.
3. Add canonical contracts for signal-series descriptors, coordinate frames, runtime execution evidence, derived observations, and derivation lineage.
4. Define the canonical relational dimensions, facts, bridges, and grain in CUE, including runtime/provenance dimensions.
5. Build synthetic and public-reference fixtures covering at least time-series, C3D, geometry, events/cycles, and bilateral observations.
6. Implement a bounded Kinetics Toolkit adapter first for generic time-series/geometry processing; validate that no KTK-specific object leaks into canonical contracts.
7. Implement a small Pyomeca differential adapter against the same fixtures and declare operation-level equivalence/tolerances where justified.
8. Generate or validate Ibis schemas/transforms from the canonical relational contracts and run the same bounded queries on DuckDB and BigQuery.
9. Add a small Malloy model generated from or checked against authoritative metric/relation definitions.
10. Add Pose2Sim as the first local video-to-3D candidate once capture-node synchronization/calibration contracts exist; retain OpenCap as a peer/validation adapter.
11. Add OpenSim or biorbd only for metrics that require explicit musculoskeletal mechanics rather than ordinary kinematic observations.
12. Add public reference datasets only when they answer a concrete program/equilibrium or runtime-qualification question.
13. Keep bioptim/control experiments, OMOP, and broader clinical interoperability as optional projections rather than baseline dependencies.

## References

### Standards and analytics

- BIDS specification and machine-readable schema: https://bids-specification.readthedocs.io/
- BIDS-Motion: https://bids-specification.readthedocs.io/en/stable/modality-specific-files/motion.html
- Malloy database support: https://docs.malloydata.dev/documentation/setup/database_support
- Open mHealth schema design principles: https://www.openmhealth.org/documentation/schema-docs/schema-design-principles/
- IEEE 1752.1-2021: https://standards.ieee.org/ieee/1752.1/6982/

### Biomechanics OSS

- Kinetics Toolkit documentation: https://kineticstoolkit.uqam.ca/doc/
- Pyomeca documentation: https://pyomeca.github.io/
- Pose2Sim: https://github.com/perfanalytics/pose2sim
- OpenCap Core: https://github.com/opencap-org/opencap-core
- biorbd: https://github.com/pyomeca/biorbd
- bioptim: https://github.com/pyomeca/bioptim
- ezc3d: https://github.com/pyomeca/ezc3d
- OpenSim: https://opensim.stanford.edu/

### Factory

- Factory tracker/runtime architecture: `docs/architecture/factory-tracker-runtime.md`
- Gym adaptation tracker: `docs/architecture/gym-adaptation-tracker.md`
