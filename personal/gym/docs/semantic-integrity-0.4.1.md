# Gym semantic integrity 0.4.1

Status: qualification layer between the 0.4.0 semantic model and live tri-session migration.

## Purpose

0.4.1 does not expand the movement ontology. It makes the existing semantic transitions executable and rejects states that were merely discouraged by documentation in 0.4.0.

The transition law is now:

```text
MechanicalAdmissionDecision(state=admitted)
        ↓ emits
MechanicalAdmissionGrant(demand-specific)
        ↓ authorizes
NormalizedCapacity(demand-specific)
        ↓
ComparisonAdmissionDecision(state=compatible)
        ↓ emits
ComparisonAdmissionGrant
        ↓ authorizes
ContextualCapacityRelation
```

A denied/partial/unknown mechanical decision cannot issue a grant. An incompatible/unknown comparison cannot issue a comparison grant. ID-only references are resolved by `#SemanticIntegrityState` during qualification.

## Capacity cardinality

`NormalizedCapacity` represents exactly one `MechanicalDemand`.

Plural state is explicit:

```text
NormalizedCapacityVector
└── entries[] → NormalizedCapacity
```

Any vector-to-scalar projection requires a separately named `CapacityAggregate` with method, version, evidence and optional weights/executor. There is no implicit demand-vector scalarization.

## Phase identity

Semantic movement phase context now uses:

```text
PatternPhaseID
PatternPhaseRef
```

rather than free-form strings. `#SemanticIntegrityState` verifies that referenced phases exist on the referenced `MovementPattern`. Human labels remain strings.

## Evidence and execution protocols

Evidence is normalized into first-class records:

```text
EvidenceRecord
├── class
├── sourceID
├── provider?
├── method?
├── modelVersion?
└── uncertainty?

EvidenceLink
├── evidence ref
├── role
└── ordinal?
```

External observation/model systems implement `EvidenceProvider` capabilities such as kinematics, kinetics, force, EMG and mechanical contribution.

Gym semantic operations are separate:

```text
OperationExecutor
├── demand-transform
├── normalization
├── comparison
├── projection
└── aggregation
```

The executor computes. Gym contracts determine meaning.

## Relational projection authority

The row definitions in `contracts/personal/gym/projections.cue` are committed qualification targets for generated projections, not independently authored semantic authority.

Intended path:

```text
CUE
 ↓
JSON Schema
 ↓
Pydantic
 ↓
projection policy
 ↓
Ibis / Malloy
 ↓
DuckDB / BigQuery
```

Evidence uses generic `EvidenceRow` and `ObjectEvidenceRow` relations, preserving one-to-many provenance rather than multiplying domain rows by evidence cardinality.

## Qualification

Positive fixtures are validated normally. Negative fixtures in `personal/gym/fixtures/negative/` must fail CUE validation.

The negative suite currently proves rejection of:

- rejected mechanical admission backing a capacity;
- a grant targeting a demand outside the admitted basis;
- incompatible comparison backing a relation;
- compatible comparison across mismatched normalization bases;
- compensation observation contradicting marker phase;
- implicit multi-demand scalar capacity;
- unknown movement phase references;
- unresolved evidence references.

`.github/workflows/gym-cue.yml` pins CUE v0.16.1 and runs the contract, positive-fixture and expected-failure suites on relevant pull requests and pushes to `main`.

## Migration gate

The live tri-session program remains on the current program substrate until this qualification suite passes on the merge commit. 0.4.1 is the semantic-integrity gate; live migration is a subsequent change.
