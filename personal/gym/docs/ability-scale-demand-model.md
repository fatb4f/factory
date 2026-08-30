# Ability-scale and demand-transfer model

Status: experimental design layer. This document does not replace the active program, capture, or equilibrium contracts yet.

## Motivation

ATG-style regression is better represented as a multidimensional ability scale than as a single ordered exercise level. A programming variable can change overall difficulty, redistribute demand between joints or support chains, change mobility requirements, or do several of these at once.

The central model is therefore:

```text
movement pattern
      │
      ├── joint motion by phase
      └── capacity-demand channels
                  │
                  ▼
             ExerciseFamily
                  │
             ScaleAxis[]
                  │
        ┌─────────┴──────────┐
        ▼                    ▼
 difficulty effect     demand-transfer effect
        │                    │
        └─────────┬──────────┘
                  ▼
             ScalePosition
                  │
          mechanical admission
                  │
                  ▼
        normalized ability position
                  │
                  ▼
       structural/equilibrium relation
```

## Motion is not demand

Joint motion and the capacity resisting or producing it are separate concepts.

Examples:

- squat descent: hip and knee flex while hip- and knee-extension capacity is loaded eccentrically;
- Nordic lowering: the knee extends while knee-flexion capacity is loaded eccentrically;
- reverse-Nordic lowering: the knee flexes while knee-extension capacity is loaded eccentrically.

This distinction allows functional patterns, agonist/antagonist relationships, and eccentric/concentric capacity to share one schema without reversing semantic meaning between exercises.

## Functional movement patterns

A `MovementPattern` owns:

- joint motion by phase;
- the capacity-demand channels active in each phase;
- optional coupling/transfer relations.

A demand channel is intentionally simple:

```text
joint + capacity action + optional contraction mode
```

Examples:

```text
hip-extension
knee-extension
knee-flexion
ankle-plantarflexion
hip-flexion
trunk-stabilization
```

This provides a common substrate below exercise identity. A Nordic and a hamstring-curl variant can both express knee-flexion capacity even when their kinematics and scaling variables differ.

## Scale axes

The initial recurring vocabulary is:

```text
assistance
external-load
geometry
range
lever
limb-contribution
load-placement
tempo
volume
speed
resistance
stance
rotation
configuration
```

An axis must not be assumed to be monotonically equivalent to difficulty.

Each axis records both:

```text
difficultyEffect
ScaleEffect[]
```

`ScaleEffect` can increase/decrease a demand, redistribute demand, transfer demand between targets, or alter access to a movement requirement.

### Squat example

Trunk and shank geometry changes the relative hip and knee extensor moments even at matched knee-flexion depth. Increased trunk inclination relative to shank shifts the hip:knee moment ratio toward the hip. This makes geometry a demand-transfer variable rather than a mere setup field.

Reference:

- https://pmc.ncbi.nlm.nih.gov/articles/PMC10518215/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC10987311/

ATG's counterbalance and heel-elevation material supplies complementary coaching-scale examples where load placement or geometry changes accessibility and the movement configuration rather than simply adding or subtracting load:

- https://www.atgonlinecoaching.com/articles/article-counterbalance-a-squat-skill-for-life
- https://www.atgonlinecoaching.com/articles/article-how-to-keep-or-rebuild-your-squat-mobility

### Dual-joint configuration example

The gastrocnemius crosses the knee and ankle. Knee position changes its plantarflexion contribution and total plantarflexion torque. A bent-knee and straight-knee calf exposure therefore cannot be treated as identical plantarflexion tests with a cosmetic setup difference.

References:

- https://pmc.ncbi.nlm.nih.gov/articles/PMC4471746/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC11708772/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC4894017/

This generalizes to other bi-articular and coupled-joint cases: joint configuration can alter force capacity, moment arms, muscle length, support requirements, or inter-joint power transfer.

## Demand transfer versus biological attribution

Tier 0 should model demand transfer at the joint-action or chain level before attributing it to a specific tissue.

For example:

```text
trunk/tibia geometry
  → knee-extension demand decreases
  → hip-extension demand increases
```

is supportable without asserting that one specific muscle caused the transfer.

Muscle-level or musculoskeletal-model attribution belongs to a later evidence tier. Bi-articular muscle research can then enrich the same graph with explicit transfer paths rather than forcing the Tier-0 model to depend on EMG, force plates, or OpenSim.

## Standards require a normalization basis

Every `AbilityStandard` and every cross-family `CapacityRelation` must declare a `DemandBasis`:

```text
DemandBasis
├── movement pattern
├── demand channels
└── normalization basis
```

Supported normalization classes begin with:

```text
absolute
body-mass
contralateral-side
self-baseline
anchor-ability
movement-pattern
```

This prevents relations such as:

```text
Nordic reps / reverse-Nordic reps
```

from becoming canonical simply because both numbers exist.

Instead:

```text
raw exercise result
      ↓
mechanically admitted ScalePosition
      ↓
normalize using declared basis
      ↓
capacity on named demand channel(s)
      ↓
structural relation
```

## Structural balance and equilibrium

The new `CapacityRelation` shape can express:

```text
agonist-antagonist
bilateral
support
joint-sharing
proximal-distal
pattern-balance
short-long-range
```

This creates a direct path for public ATG structural-balance references and scientific biomechanics data to coexist with personal longitudinal baselines.

External standards remain reference evidence, not Gym targets.

ATG explicitly describes structural balance as strength relative to other lifts/abilities and presents lower-body examples involving squat, RDL, calf, hamstring, Nordic, tibialis, and hip-flexor capacities:

- https://app.atgonlinecoaching.com/articles/article-structural-balance-1
- https://app.atgonlinecoaching.com/articles/article-my-23-physical-standards

The useful semantic distinction is:

```text
ExternalAbilityStandard != ProgramTarget
```

A program may choose to use an external standard as one reference frame, but admission remains a Gym decision.

## ATG reference fixture

`personal/gym/fixtures/ability_scale_reference.cue` currently exercises the abstraction against representative families:

- deep squat;
- ATG split squat;
- step-down;
- full-stretch RDL;
- Nordic/bodyweight hamstring curl;
- reverse Nordic;
- straight-knee calf raise;
- Garhammer/loaded hip flexion;
- back extension.

The fixture deliberately includes cases where:

- increasing a value makes an exercise harder;
- decreasing a value makes an exercise harder;
- the variable is context-dependent;
- the variable transfers demand between joints;
- joint motion is opposite the loaded capacity action;
- a second-joint configuration changes capacity at the primary joint.

This is the qualification gate for replacing the existing `RangeStage`-centric progression model.

## Python analytical projection

The desired runtime split is:

```text
CUE
  semantic authority
      │
      ▼
Pydantic v2
  nested operational models
      │
      ├── session/controller objects
      └── Arrow-compatible serialization
                │
                ▼
             PyArrow
                │
                ▼
              Ibis
                │
        ┌───────┴────────┐
        ▼                ▼
     DuckDB           BigQuery
        │
        ▼
Pandera/Ibis validation
```

Pydantic is the right object-model layer for nested structures such as:

```text
ExerciseFamily
  axes[]
    effects[]

ScalePosition
  coordinates[]

MovementPattern
  channels[]
  phases[]
```

Ibis already converts PyArrow schemas into Ibis schemas and supports nested data types. DuckDB supports nested list/struct/map values, so operational records do not need to be prematurely flattened.

Pandera's Ibis integration is a good candidate for validating analytical relation contracts after projection.

References:

- https://ibis-project.org/
- https://pandera.readthedocs.io/en/stable/ibis.html
- https://duckdb.org/docs/stable/sql/data_types/overview

`pydantic-to-pyarrow` is worth qualification because it handles nested Pydantic lists/structs/maps, but its published support currently stops at Python 3.13. Factory's Python 3.14 baseline means it should not become a dependency until tested or patched.

- https://github.com/simw/pydantic-to-pyarrow

## Next contract migration

Do not immediately delete `#ExerciseProfile` or `#RangeStage`.

Sequence the migration:

1. validate the reference fixture against additional ATG families and scientific joint-demand cases;
2. define `AdmittedScalePosition` from normalized exposure evidence;
3. define deterministic comparison compatibility for scale positions;
4. redefine `normalized-capacity-index` as a family/basis-specific projection rather than a universal scalar;
5. project existing equilibrium metrics onto `CapacityRelation`;
6. migrate active exercise profiles onto `ExerciseFamily` only after equivalent session capture can be represented;
7. generate/validate Pydantic and Ibis projection models;
8. then resume prescription identity and controller work against the new ability-scale substrate.

The controller should ultimately advance a scale coordinate, not an opaque exercise level:

```text
observed admitted position
        ↓
comparison / recovery gate
        ↓
select one ScaleAxis
        ↓
propose one coordinate change
        ↓
hold remaining coordinates fixed
        ↓
next planned exposure
```
