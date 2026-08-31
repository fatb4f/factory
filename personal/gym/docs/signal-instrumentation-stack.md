# Gym signal instrumentation stack

Status: proposed architecture; not yet implemented.

## Objective

Define the signal-acquisition, sEMG-processing, synchronization, and temporal semantics required to turn low-cost wearable instrumentation into qualified Gym evidence without making any device, DSP package, file format, or biomechanics runtime the semantic authority.

This document specializes the broader `semantic-analytics-stack.md` architecture for high-rate biomechanical signals. The governing authority chain remains:

```text
CUE
 ↓
JSON Schema
 ↓
Pydantic
 ↓
canonical Gym observations
 ↓
replaceable acquisition / processing / projection adapters
```

External OSS should own commodity numerical and interoperability problems. Gym should own contracts, provenance, qualification, time semantics, placement, calibration, mechanical interpretation, comparability, and admission.

## Architectural conclusion

The preferred first instrumentation substrate is currently:

```text
uMyo nodes
   ↓
coordinated USB base
   ↓
Gym acquisition adapter
   ↓
canonical raw observations
   │
   ├── LSL / XDF          synchronization + recording projection
   ├── LibEMG             sEMG filtering + feature extraction
   ├── Pyomeca            biomechanics-oriented signal processing
   ├── Kinetics Toolkit   time series + events + biomechanics operations
   ├── NeuroKit / MNE     reference / differential qualification
   ├── Arrow / Parquet    bounded columnar evidence
   ├── Ibis / Malloy      relational + semantic analytics
   ├── C3D / ezc3d        biomechanics interchange
   ├── OpenSim/OpenSense  model-based IMU/kinematic projection
   └── Rerun              inspection / visualization projection
```

The important rule is:

> OSS libraries are projections, adapters, and numerical executors. Gym contracts remain authoritative.

## Why uMyo changes the engineering economics

The coordinated uMyo USB-base path exposes a full stream containing raw EMG at roughly 1150 Hz together with FFT bins, IMU, fused quaternion, and magnetometer data. The manufacturer describes the USB base as the lowest-latency and best-timing path and documents multi-node operation through a coordinated time-divided radio link.

The device therefore already owns the difficult embedded boundary:

```text
skin
 ↓
analog EMG front end
 ↓
ADC
 ↓
on-device processing
 ↓
IMU / orientation
 ↓
radio
 ↓
coordinated USB receiver
 ↓
existing host parser
```

Gym should not initially build custom ADC drivers, RF firmware, BLE GATT, sensor fusion, charging firmware, custom PCBs, or custom wearable enclosures.

The raw evidence boundary is also strategically important. A raw uMyo stream can be transformed into lower-rate activation measures. A closed processed activation stream cannot be transformed back into raw EMG, spectral information, artifact morphology, high-resolution onset timing, or an alternative processing protocol.

## uMyo versus processed activation sensors

The ANR M40 remains a useful operational comparison, but it occupies a different evidence class.

ANR documents an internal 4800 Hz sample rate followed by proprietary model-based EMG isolation and a BLE measurement update rate of 10 Hz. Its exposed BLE characteristic is therefore a derived activation/flex-level measurement rather than the underlying waveform.

The semantic distinction must be explicit:

```text
SurfaceEMGEvidence
├── RawSurfaceEMG
│   ├── samples
│   ├── sample_rate
│   ├── electrode_configuration
│   ├── preprocessing
│   └── quality
│
└── DerivedMuscleActivation
    ├── value
    ├── unit / scale
    ├── derivation
    ├── source_algorithm
    ├── update_rate
    └── qualification
```

Candidate mapping:

```text
uMyo → RawSurfaceEMG + IMU observations
M40  → DerivedMuscleActivation
```

A processed sensor may eventually win for wear-and-go training ergonomics, but it should not be the initial measurement authority when the cheaper/open path preserves substantially more information and mature OSS already supplies the generic DSP layer.

## Signal instrumentation SDK

The useful OpenTelemetry analogy is an instrumentation SDK for biomechanical evidence rather than a monolithic EMG application.

Conceptual mapping:

| Observability concept | Gym signal concept |
| --- | --- |
| instrumentation API | `SignalSource`, `Placement`, `Calibration` |
| SDK | acquisition + processing pipeline |
| resource | sensor, subject/session, placement |
| metric | RMS, activation, MDF, bilateral ratio |
| trace | movement execution/session execution tree |
| span | rep / phase / contraction interval |
| event | onset, offset, clipping, contact loss, manual marker |
| attribute | side, contributor, site, sensor ID, protocol |
| processor | LibEMG / Pyomeca / KTK adapter |
| exporter | LSL, XDF, Arrow, C3D, OpenSim |
| collector | session acquisition runtime |

Do not copy OTel's data model literally. Reuse the separation of instrumentation API, processing, exporters, resources, events, and temporal context.

A likely package boundary is broader than `gym-emg`:

```text
gym-signals
├── contracts
├── acquisition
├── time
├── qualification
├── processing
│   ├── emg
│   ├── imu
│   └── future force / pressure / pose
└── projections
```

`sEMG` is the first signal family rich enough to force this substrate into existence, but the abstraction should admit IMU, force, pressure, pose, and other time-varying evidence without redesign.

## Canonical source protocols

Candidate protocol surface:

```text
SignalSource
ClockSource
ObservationSeries
EventSeries
Placement
Calibration
QualityObservation
TimeMapping
ProcessingProtocol
DerivedSignal
```

Illustrative runtime interface:

```python
source = UmyoSource(...)
stream = signals.acquire(source)
qualified = stream.qualify(protocol="gym.emg.raw.v1")
activation = qualified.process(
    "gym.emg.activation.v1",
    implementation="libemg",
)
activation.export("arrow")
```

The implementation names are replaceable. The Gym protocol names, admitted parameter sets, input/output types, lineage, and quality requirements are stable authority.

## Device identity and anatomical placement

Physical identity and anatomical meaning must never be conflated.

Forbidden shortcut:

```text
sensor 0 = right medial hamstring
```

Required structure:

```text
Sensor
  id: persistent physical identity

Placement
  sensor: sensor identity
  session: session identity
  anatomical_site: ...
  contributor: ...
  side: ...
  position: ...
  orientation: ...
  electrode_type: ...
  applied_at: ...
  removed_at: ...
  confidence: ...
```

Placement is a first-class observation because sensors move between sessions and because placement repeatability is itself part of measurement qualification.

The relation is therefore:

```text
Sensor
  ↓ placement event
AnatomicalSite / contributor region
  ↓ temporal validity
MovementExecution
```

## Canonical session time

The temporal model should distinguish a physical clock from the semantic timeline.

```text
device clocks
   │
   ├── uMyo / receiver domain
   ├── camera clock
   ├── force-device clock
   ├── manual-event clock
   └── host monotonic clock
          │
          ▼
      TimeMapping
          │
          ▼
     SessionClock
          │
          ▼
    SessionTimeline
          │
          ├── MovementExecution
          ├── Rep
          ├── MovementPhase
          ├── SessionEvent
          └── Intervention
```

Definitions:

- `SessionClock`: canonical physical time source/domain selected for the session.
- `SessionTimeline`: canonical ordered coordinate system after source clocks have been mapped into session time.
- `ExecutionSpan`: a semantically typed interval on the session timeline.
- `MovementPhase`: a mechanically meaningful execution span.

The central invariant is:

> All evidence is transformed into one canonical session time domain; semantic state partitions that domain.

The phase/span structure therefore does **not** contain the signal. It provides the semantic coordinate system against which continuously sampled evidence is projected.

```text
EMG       ───────────── continuous samples ─────────────>
IMU       ───────────── continuous samples ─────────────>
Video     ───────────── frames ─────────────────────────>
Force     ───────────── continuous samples ─────────────>

                 [ eccentric ]
                              [ transition ]
                                            [ concentric ]
```

This permits object-native access such as:

```python
rep.phase("eccentric").emg
rep.phase("eccentric").orientation
rep.phase("eccentric").force
```

without copying the underlying signals into the phase object. These are temporal projections/joins over canonical evidence.

## Time-mapping contract

For a source clock mapped into session time:

```text
t_session = a * t_source + b + ε
```

where:

- `a` is clock-rate correction / drift;
- `b` is clock offset;
- `ε` is residual synchronization uncertainty.

Candidate contract:

```text
TimeMapping
├── source_clock
├── session_clock
├── offset
├── drift
├── residual_error
├── method
├── observed_offsets
├── valid_from
├── valid_until
└── qualification
```

Every time-addressable observation should be able to retain:

```text
Observation
├── source_time
├── session_time
├── time_uncertainty
├── sequence
├── source
└── value
```

This makes offset, drift, jitter, packet loss, and mapping uncertainty measured variables rather than hidden implementation details.

## LSL / XDF role

Lab Streaming Layer should be the initial multi-stream synchronization and recording projection.

LSL supplies sample timestamps and clock-offset measurements between stream origins and consumers. Its XDF recording ecosystem stores synchronization information, and the reference import path can use offset histories and linear clock-drift assumptions to remap streams into a common time domain.

Gym should consume this capability without surrendering its own time model:

```text
uMyo parser
   ↓
Gym canonical observation
   ├──────────────→ LSL outlet
   │                  ↓
   │              LabRecorder
   │                  ↓
   │                 XDF
   │                  ↓
   │                pyxdf
   │                  ↓
   └────────────── Gym TimeMapping qualification
```

LSL/XDF is therefore an implementation of clock observation, synchronized recording, and replay—not the semantic definition of `SessionClock` or `SessionTimeline`.

For uMyo specifically, host arrival time alone is insufficient as measurement authority. Where the vendor stream exposes sample framing/sequence information, reconstruct acquisition timing from the strongest available combination of:

```text
device/frame sequence
sample position within frame
nominal sample rate
host monotonic receipt time
known transport behavior
known acquisition gaps
external synchronization events
```

## sEMG processing substrate

Gym should not become another generic signal-processing package.

Commodity DSP belongs behind processing adapters. Candidate primary implementations are LibEMG and Pyomeca, with KTK, NeuroKit, and MNE useful for biomechanics execution and differential qualification.

### LibEMG

LibEMG is the strongest current candidate for the EMG-specific feature engine. It provides reusable filtering and a broad feature vocabulary including common amplitude, waveform, autoregressive, and spectral measures such as MAV, RMS, IAV/IEMG, waveform length, median frequency, and mean frequency.

Role:

```text
RawSurfaceEMG
   ↓
LibEMG adapter
   ├── filtering
   ├── windowing
   ├── RMS / MAV / IEMG
   ├── waveform features
   ├── spectral features
   └── feature sets
        ↓
Gym DerivedEMGObservation
```

### Pyomeca

Pyomeca should remain a peer biomechanics-oriented processor rather than a replacement semantic model. It supplies biomechanics signal processing such as filtering, normalization, onset detection, and labelled multidimensional arrays through an xarray-backed representation.

Role:

```text
RawSurfaceEMG / derived arrays
   ↓
Pyomeca adapter
   ↓
biomechanics-oriented transforms
   ↓
Gym derived observations
```

### Kinetics Toolkit

Kinetics Toolkit is best treated as a broader time-series/biomechanics execution projection. Its `TimeSeries` abstraction supports data, time, events, metadata, segmentation, missing data, resampling, merging, synchronization helpers, and filtering. Its documented EMG example follows a conventional band-pass → rectify → low-pass envelope pipeline.

Do not persist `ktk.TimeSeries` as canonical Gym state.

```text
Gym ObservationSeries
   ↓
KTK adapter
   ↓
ktk.TimeSeries
   ↓
biomechanics operations
   ↓
Gym DerivedObservation
```

### NeuroKit / MNE

Use NeuroKit and MNE principally as independent reference implementations and qualification oracles. They are valuable because independently derived filtering, envelope, activation/onset, epoching, and event results can be compared against the preferred Gym processor implementation.

```text
raw fixture
   │
   ├── LibEMG implementation
   ├── Pyomeca implementation
   ├── NeuroKit reference
   └── MNE reference
          ↓
   differential qualification
```

Gym should define the processing protocol and parameter set rather than blindly adopting a package default.

## Processing protocol as authority

Example canonical intent:

```text
EMGProcessingProtocol
├── id: gym.semga.activation.v1
├── input_type: RawSurfaceEMG
├── bandpass
├── notch
├── rectification
├── envelope
├── normalization
├── window
├── missing_sample_policy
├── quality_policy
└── output_type: MuscleActivation
```

A runtime may declare:

```text
LibEMGProcessor implements gym.semga.activation.v1
```

but the runtime does not define the protocol.

This gives reproducible lineage:

```text
raw evidence
  + processing protocol identity
  + parameter digest
  + runtime/version
  + quality result
  ↓
derived observation
```

## Raw-signal quality

uMyo documents a short recurring acquisition gap when the ADC pauses for battery measurement. Such artifacts must be represented rather than silently smoothed away.

Candidate signal-quality contract:

```text
EMGSampleQuality
├── complete
├── gap_before
├── clipping
├── contact_quality
├── mains_interference
├── motion_artifact
├── packet_loss
├── interpolation_applied
└── confidence
```

Qualification should characterize rather than prematurely solve:

- baseline/noise floor;
- known periodic gaps;
- packet loss;
- clipping;
- mains interference;
- movement artifact;
- electrode contact behavior;
- placement repeatability;
- MVC/reference-contraction repeatability;
- dry-versus-gel differences where relevant;
- cross-talk sensitivity;
- inter-device timing error.

## Mechanical semantic projection

Raw or processed EMG is evidence about activation, not a direct mechanical-role assertion.

The domain hierarchy remains approximately:

```text
FunctionalMovement
    ↓
MovementPhase
    ↓
MechanicalDemand
    ↓
MechanicalContribution
    ↓
MechanicalRole
    ↓
FunctionalGroup
```

Signal observations join that semantic model through session time, placement, and contributor identity:

```text
RawSurfaceEMG
   ↓ processing
MuscleActivation
   ↓ placement + SessionTimeline
PhaseConditionedActivation
   ↓ mechanical interpretation
MechanicalContribution evidence
   ↓ qualified aggregation
capacity / allocation / redistribution / equilibrium analytics
```

This prevents an activation metric from being mistaken for mechanical contribution without phase and biomechanical context.

## IMU and OpenSense path

uMyo's orientation stream provides a direct future path into OpenSim/OpenSense.

OpenSense consumes orientations from multiple IMUs, associates sensors with model body segments, uses calibration poses to register sensors to the model, and performs IMU-based inverse kinematics.

The Gym placement/calibration model should therefore preserve enough information for a deterministic projection:

```text
SensorPlacement
├── sensor
├── body_segment
├── anatomical_site
├── orientation / axes
├── session
└── calibration_ref
```

Then:

```text
uMyo quaternion
   ↓
Gym OrientationObservation
   ↓
OpenSense adapter
   ↓
OpenSim IMU frames
   ↓
inverse kinematics
   ↓
Gym derived kinematic evidence
```

OpenSense remains an external numerical/model executor. Model identity, calibration, coordinate mapping, runtime version, and output qualification remain explicit evidence.

## Storage and analytics

Use separate representations for high-rate evidence and ordinary analytical relations.

```text
raw / processed signal store
  XDF + Parquet/Arrow + source artifacts
           │
           ▼
qualified processing
           │
           ▼
feature / interval observations
           │
           ▼
Ibis relational projection
           │
      ┌────┴────┐
      ▼         ▼
   DuckDB     BigQuery
      │         │
      └────┬────┘
           ▼
         Malloy
```

Do not expand every ~kHz EMG sample into the ordinary analytical fact model. Keep raw evidence addressable and derive bounded feature tables keyed by session time, interval, placement, protocol, and provenance.

Candidate derived facts include:

```text
fact_signal_feature
fact_phase_activation
fact_rep_activation
fact_bilateral_relation
fact_agonist_antagonist_relation
fact_activation_onset
fact_fatigue_feature
fact_signal_quality
fact_time_mapping
```

## Session workflow integration

A signal-enabled Gym session should follow the same session lifecycle as manually captured training, with additional acquisition gates.

```text
start session
   │
   ├── discover physical sensors
   ├── bind expected placement events
   ├── establish SessionClock
   ├── baseline / contact qualification
   ├── reference or MVC contractions where required
   └── begin acquisition
           │
           ▼
     MovementExecution
           │
        sets / reps
           │
      phase intervals
           │
           ▼
    finalize acquisition
           │
   ├── close placements
   ├── reconstruct TimeMappings
   ├── qualify streams
   ├── derive admitted features
   └── seal session evidence
```

A session manifest may declare intended capture without binding to a particular runtime:

```yaml
movement: ghr
sensors:
  - site: right_medial_hamstring
  - site: left_medial_hamstring
  - site: right_gluteal_region
  - site: left_gluteal_region
capture:
  emg: true
  imu: true
  video: true
```

## Initial qualification sequence

### P0 — contracts

Define and validate:

```text
RawSurfaceEMG
DerivedMuscleActivation
OrientationObservation
SensorPlacement
Calibration
SignalQuality
ClockObservation
TimeMapping
SessionClock
SessionTimeline
ExecutionSpan
ProcessingProtocol
RuntimeEvidence
```

### P1 — uMyo vertical slice

Use 2–3 uMyo nodes plus the USB base:

```text
uMyo USB
   ↓
vendor parser
   ↓
Gym adapter
   ↓
canonical raw observations
   ↓
LSL
   ↓
XDF
   ↓
pyxdf / TimeMapping
   ↓
Gym canonical replay
   ├── LibEMG
   ├── KTK
   └── Arrow
```

Required outcomes:

- persistent physical identity;
- simultaneous multi-node acquisition;
- measured transport behavior;
- raw EMG preservation;
- IMU/orientation preservation;
- known-gap representation;
- deterministic replay;
- first admitted processing protocol;
- first phase-conditioned activation query.

### P2 — processing differential qualification

Run identical raw fixtures through multiple implementations and compare within declared tolerances:

```text
LibEMG
Pyomeca
NeuroKit
KTK / SciPy reference where useful
```

No package is accepted merely because it is widely used.

### P3 — semantic time projection

Bind manually marked and/or automatically detected movement spans to `SessionTimeline` and prove that the same canonical interval projects consistently over EMG, IMU, and video timestamps.

### P4 — processed-sensor comparison

Only after the raw path is working, compare a low-friction processed activation sensor such as M40 against uMyo-derived activation on comparable contractions.

Qualify **metrics**, not devices globally:

| Metric | Processed 10 Hz sensor | Raw uMyo path |
| --- | --- | --- |
| rep-integrated bilateral allocation | candidate | candidate/reference |
| agonist/antagonist ratio | candidate | candidate/reference |
| coarse activation persistence | candidate | candidate/reference |
| co-contraction timing | likely limited | candidate |
| fine activation onset | limited | candidate |
| spectral fatigue | unsupported | candidate |
| waveform artifact discrimination | opaque | candidate |
| segment orientation | unsupported | candidate |
| OpenSense projection | unsupported | candidate |

A processed device can be admitted for a metric whose information loss is empirically shown to be acceptable without becoming the authority for metrics it cannot support.

## Explicit non-goals for v1

Do not initially build:

- custom PCB;
- custom uMyo firmware;
- custom radio receiver;
- direct BLE-first acquisition;
- custom Android application;
- generic DSP primitives already supplied by SciPy/LibEMG/Pyomeca/KTK;
- real-time ML;
- custom biomechanics visualization;
- live OpenSim integration;
- automatic causal interpretation of EMG amplitude;
- motor-unit decomposition;
- clinical diagnostic inference.

## Open-source dependency policy

Packages remain candidates until qualified against Gym fixtures and contracts.

Preferred roles:

| Runtime | Role |
| --- | --- |
| uMyo vendor parser | device transport decoder only |
| LSL / pylsl | live stream interoperability and clock observations |
| XDF / pyxdf | synchronized recording, import, replay |
| LibEMG | primary EMG feature-processing candidate |
| Pyomeca | biomechanics-oriented signal-processing candidate |
| Kinetics Toolkit | time/event/biomechanics runtime projection |
| NeuroKit | independent signal-processing reference |
| MNE | independent time-series/epoching reference |
| Arrow / Parquet | canonical bounded columnar interchange/storage |
| Ibis | relational transforms |
| Malloy | semantic analytics projection |
| DuckDB / BigQuery | local/warehouse execution |
| ezc3d / C3D | biomechanics interchange |
| OpenSim / OpenSense | model-based IMU/kinematic projection |
| Rerun | diagnostic visualization projection |

## Reference architecture

```text
                            CUE
                             │
                        JSON Schema
                             │
                          Pydantic
                             │
                  canonical Gym contracts
                             │
         ┌───────────────────┼────────────────────┐
         │                   │                    │
         ▼                   ▼                    ▼
    acquisition            time              semantics
         │                   │                    │
      uMyo USB            LSL/XDF          SessionTimeline
         │                   │             execution spans
         └──────────────┬────┘                    │
                        ▼                         │
                 raw observations                │
                        │                         │
             ┌──────────┼───────────┐             │
             ▼          ▼           ▼             │
          LibEMG     Pyomeca       KTK            │
             │          │           │             │
             └──────────┼───────────┘             │
                        ▼                         │
                 derived signals                 │
                        └─────────────┬───────────┘
                                      ▼
                           phase-conditioned evidence
                                      │
                         ┌────────────┼────────────┐
                         ▼            ▼            ▼
                       Ibis         OpenSim       Rerun
                         │          OpenSense       │
                         ▼            │             │
                  DuckDB/BigQuery     │             │
                         │            │             │
                         ▼            ▼             │
                       Malloy   derived mechanics   │
                         └────────────┬──────────────┘
                                      ▼
                     capacity / allocation / redistribution
                              / equilibrium analytics
```

## Sources

Primary technical references used for the current candidate architecture:

- uMyo connectivity: <https://make.udevices.io/umyo/connectivity/>
- uMyo hardware/signal notes: <https://make.udevices.io/umyo/hardware/>
- Lab Streaming Layer time synchronization: <https://github.com/sccn/labstreaminglayer/blob/master/docs/info/time_synchronization.rst>
- LibEMG filtering: <https://libemg.github.io/libemg/documentation/filtering/filtering.html>
- LibEMG feature extraction: <https://libemg.github.io/libemg/documentation/features/features.html>
- Kinetics Toolkit `TimeSeries`: <https://kineticstoolkit.uqam.ca/doc/api/ktk.TimeSeries.html>
- Kinetics Toolkit EMG filtering exercise: <https://kineticstoolkit.uqam.ca/doc/filters_butter_exercise.html>
- Pyomeca: <https://github.com/pyomeca/pyomeca>
- OpenSim OpenSense workflow: <https://opensimconfluence.atlassian.net/wiki/spaces/OpenSim/pages/53084203>
- ANR M40 product sheet: <https://www.anrcorp.com/documents/M40_ProductSheet.pdf>
- ANR M40 BLE design guide: <https://www.anrcorp.com/documents/BLE_DesignGuide.pdf>
