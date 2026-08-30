# Ability-scale, mechanical-demand, and semantic object model

Status: additive semantic layer implemented over the existing Tier-0 Gym capture model. Historical session capture remains valid. The active tri-session program can migrate onto the new admission path incrementally rather than being rewritten.

## Canonical semantic axis

Exercise identity is no longer the analytical primitive. The canonical path is:

```text
FunctionalMovement / MovementPattern
        ↓
MovementPhase
        ↓
MechanicalObjective
        ↓
MechanicalDemand
        ↓
MechanicalContribution
        ↓
MechanicalRoleAssignment
        ↓
FunctionalGroup
        ↓
ContributionDistribution
        ↓
EquilibriumProjection
```

`DemandChannel` remains a useful Tier-0 shorthand for joint-targeted capacity such as knee extension, knee flexion, or plantarflexion. New analytical state is expressed in `MechanicalDemand` objects so support, COM braking, propulsion, pelvic stabilization, swing clearance, and similar requirements share one substrate.

`Chain` also remains available as a human-facing anatomical migration view. It is no longer semantic authority.

## Mechanical effect precedes role

A contributor is modeled by what it mechanically produces or resists:

```text
contributor
    produces/resists
        force / moment / acceleration / power / impulse / stability constraint
    on
        COM / segment / joint DOF
    during
        movement phase
```

A `MechanicalRoleAssignment` then interprets that contribution contextually as one or more of:

```text
support
stabilize
brake
propel
rotate
redirect
transfer
steer
clear
recover
```

This prevents role labels from becoming permanent muscle or region categories. One contribution can satisfy several objectives, and the same contributor can have different roles in different phases.

## Demand is not muscular demand

`Contributor` deliberately includes more than muscle:

```text
muscle
muscle-group
passive-structure
skeletal-alignment
external-support
contralateral-limb
functional-aggregate
```

This allows Tier-0 exercise proxies, later OpenSim estimates, force/kinematic evidence, EMG, passive structures, and alignment-mediated support to coexist without asserting that every mechanical requirement is a muscular requirement.

Evidence is classified as:

```text
direct-mechanical
model-derived
physiological
exercise-derived-proxy
qualitative-observation
```

Derived scalars carry source class, evidence, optional uncertainty, and provider/model metadata. A manually captured GHR exposure can therefore support knee-flexion/hip-extension capacity without pretending that it measured a muscle's percentage contribution.

## Ability scale becomes a demand transformer

The existing `ExerciseFamily`, `ScaleAxis`, and `ScalePosition` contracts remain the controlled exposure mechanism.

A progression variable does not mean only "difficulty". It changes the demand field:

```text
ScalePosition
     ↓
DemandTransform
     ↓
MechanicalDemand vector
     ↓
MechanicalContribution allocation
```

`DemandTransform` is explicitly compositional and evidence-bearing. Interactions are first-class because variables such as geometry and load may not act independently.

Conceptually:

```text
D' = Tn(...T2(T1(D)))
```

The controller invariant remains one ordinary coordinate change per progression decision unless the program explicitly authorizes a coupled intervention:

```text
|Δ ScaleAxis| = 1
```

This preserves experimental control: change load while holding ROM, assistance, tempo, geometry, and other axes fixed.

## Admission and normalization path

The migration path is now:

```text
ObservedExposure
      ↓
ScalePosition
      ↓
MechanicalAdmission
      ↓
NormalizedExposure
      ↓
NormalizedCapacity
      ↓
ComparisonAdmission
      ↓
ContextualCapacityRelation
      ↓
EquilibriumProjection
```

Two distinct gates are required.

### Mechanical admission

`MechanicalAdmission` asks whether an observed exercise/scale position actually exposes the claimed `MechanicalDemandBasis`.

The basis names mechanical demands directly and may carry legacy demand channels only as a migration bridge.

### Comparison admission

`ComparisonAdmission` asks whether two normalized capacities can legitimately participate in a relation.

`ComparisonBasis` includes:

```text
normalization class
mechanical demand / legacy channel
movement context
phase
contraction regime
ROM basis
load basis
temporal basis
reference version
```

Two values are not ratio-compatible merely because both are normalized numbers.

## Demand satisfaction and redistribution are separate

Task success is represented separately from how the task was solved.

For a demand in movement `m`, phase `p`:

```text
DemandResidual = required demand - observed contribution toward demand
```

Contribution allocation is tracked independently as `ContributionDistribution`.

Therefore the model can represent:

```text
demand residual ≈ 0
contribution distribution != reference
```

This is the core distinction required for redistribution analysis: the task can succeed while load allocation changes substantially.

`EquilibriumProjection` is derived state. It references demand residuals, optional contribution-distribution residuals, compensation projection, evidence, uncertainty, and a projection version. It is not an authoritative observation and it is not collapsed into one scalar score.

## Compensation is first-class but non-causal

A `CompensationMarker` defines an observable alternative task solution such as excess rotation, translation, bracing, unloading, shortening, or load transfer.

A trial/session produces a `CompensationObservation` with longitudinal quantities such as onset, peak, integral, duration, or deviation from a reference envelope when the evidence tier supports those measurements.

The observation never classifies itself as dysfunctional.

A separate `CompensationQualification` applies a versioned policy using explicit qualifiers such as excessive magnitude, persistence, increasing-with-load behavior, capacity limitation, demand displacement, recovery cost, or downstream constraint.

The classification space is:

```text
nominal-variation
adaptive
compensatory
dysfunctional
```

Relations between capacity and compensation begin as evidence-bearing associations and can be promoted only through explicit qualification. This preserves Gym's non-causal stance.

## One semantic object model, multiple projections

The mechanics, allocation, and compensation "graphs" are not separately authoritative graph schemas. They are projections over one semantic object model.

Conceptually, the Python runtime should feel object-native:

```text
movement.phases
movement.objectives
movement.demands

state.mechanics
state.allocation
state.compensation

state.capacity(...)
state.compare(...)
state.equilibrium(...)
state.project(...)
```

The mapping is deliberate:

| Python concept | Gym semantic equivalent |
| --- | --- |
| class | semantic type |
| instance | admitted entity/state |
| field | authoritative fact |
| property | derived projection |
| method | typed transformation/query |
| decorator/metadata | evidence, admission, derivation contract |
| protocol | external provider capability |
| serialization | JSON/Arrow/relational projection |

Generated structural models should remain boring. Behavioral analytics belong in runtime/projector layers rather than being hidden inside generated data classes.

## CUE -> JSON Schema -> Pydantic

The contract pipeline is:

```text
CUE
  semantic constraints, composition, admission contracts
        ↓
JSON Schema
  portable structural contract
        ↓
Pydantic
  Python runtime types, validation, serialization
        ↓
projection/runtime layer
        ├── Ibis
        ├── Malloy
        ├── DuckDB
        └── BigQuery
```

CUE remains the stronger source of truth. JSON Schema is a portable projection and is not assumed to preserve every CUE semantic constraint bidirectionally.

Pydantic is the Python object boundary. Ibis becomes the relational algebra projection; Malloy becomes the analytical semantic projection over admitted relational state. Neither Ibis nor Malloy is domain authority.

A default relational projection policy is:

```text
scalar      -> column
entity ref  -> identity/FK column
list        -> child relation
union       -> tagged relation
nested fact -> struct or child relation by projection policy
derived     -> evidence-bearing view/expression
projection  -> disposable view
```

`projections.cue` now exposes rows for mechanical demand, contribution, role assignment, mechanical admission, normalized capacity, contribution distribution, compensation, and functional equilibrium in addition to the original session/recovery rows.

## External runtime bridge

External systems integrate as capability providers rather than alternate semantic authorities.

Representative capabilities are:

```text
kinematics
kinetics
force
emg
mechanical-contribution
scale-transform
normalization
comparison
projection
```

The intended bridge is:

```text
OpenSim / pymecha / video / force / EMG
        ↓
adapter/provider
        ↓
evidence-bearing Gym objects
        ↓
admission
        ↓
canonical semantic state
```

OpenSim can eventually produce model-derived `MechanicalContribution` evidence. Video can provide kinematic compensation evidence. Manual session capture can provide exposure-derived proxy evidence. All enrich the same graph without replacing Gym's semantics.

## Backward compatibility

The active Tier-0 capture envelope is unchanged.

Existing records remain authoritative observations:

```text
SessionStart
ExposureObservation
SessionClose
RecoveryCheckpoint
Measurement
DualLoadSample
MediaArtifact
Supersession
```

`NormalizedExposure` now permits optional `ScalePosition`, `MechanicalAdmissionRef`, and `MechanicalDemandBasis` fields. Old records lacking these fields remain valid but are mechanically unadmitted or only partially interpretable.

Legacy `DemandChannel`, `CapacityRelation`, `EquilibriumMetric`, `Chain`, `ExerciseProfile`, and `RangeStage` concepts are retained as migration surfaces. They should not be deleted until the current tri-session fixture and live program can be represented without special cases.

## Migration sequence

The next implementation sequence is:

1. instantiate mechanical objectives and demands for the existing tri-session movement patterns;
2. map existing demand channels into `MechanicalDemandBasis` as migration links;
3. admit current `ExerciseFamily + ScalePosition` exposures mechanically;
4. derive normalized capacity only from admitted exposure evidence;
5. enforce `ComparisonAdmission` before contextual capacity relations;
6. add compensation markers only where there is an actual observation path;
7. project demand residual and contribution distribution separately;
8. qualify JSON Schema -> Pydantic generation;
9. derive Ibis schemas and Malloy sources/models from the same structural projection;
10. migrate chain-based equilibrium views onto functional-group and contextual-relation projections;
11. only then replace the old RangeStage-centric controller representation.

The resulting controller state is approximately:

```text
State
├── admitted ScalePosition
├── normalized capacity vector
├── demand residual vector
├── contribution distribution
├── compensation state
├── recovery state
└── uncertainty
        ↓
Controller
        ↓
choose one ScaleAxis
        ↓
propose Δcoordinate
        ↓
predict DemandTransform
        ↓
admit / reject
```

The architecture therefore preserves the existing factory capture substrate while moving Gym's semantic center from exercise/chain identity to movement-phase mechanical demand, contribution, admission, and evidence-bearing projections.
