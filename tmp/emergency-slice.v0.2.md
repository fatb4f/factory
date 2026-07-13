
# Upstream CUE Alignment Plan

## Objective

Establish that the kernel reflects upstream CUE semantics by validating its dependencies in this order:

```text
upstream CUE specification and API semantics
        ↓
lattice-conformance contracts
        ↓
idiomatic application patterns
        ↓
kernel composition
        ↓
domain projections
        ↓
adapter and runner execution
```

Kernel alignment remains provisional until every lower layer passes its own acceptance gate.

---

## Revised priority order

### P0 — establish the semantic authority

1. Define assertion modes and fixture schemas.
2. Implement the minimal Go probe runner.
3. Add true directional subsumption tests.
4. Add real expected-bottom probes.
5. Add top, bottom, type-ordering, and concreteness cases.
6. Add meet, join, distribution, and normalization laws.
7. Add evaluation-state classification.

### P1 — structural lattice coverage

8. Add field-marker ordering.
9. Add open/closed struct ordering.
10. Add pattern-constraint and ellipsis cases.
11. Add embedding cases.
12. Add open/closed list ordering.
13. Expand cycle and fixed-point cases.
14. Add complete default-ordering cases.

### P2 — repair the application pattern catalog

15. Rename current `subsumption` to compatibility.
16. Create runner-backed `subsumption`.
17. Repair `top-and-bottom`.
18. Repair `negative-fixtures`.
19. Split projection construction from preservation.
20. Complete the hidden-and-let proof.
21. Correct constructor defaults.
22. Separate definition closure from explicit `close`.

### P3 — realign the kernel

23. Remove pure-CUE no-widening claims.
24. Bind kernel proof declarations to explicit assertion modes.
25. Route destructive and directional checks through the runner.
26. Re-run all kernel positive, negative, preservation, and subsumption fixtures.
27. Record the upstream commit used as the conformance baseline.

### P4 — projection and adapter validation

28. Validate generated projections against the corrected kernel.
29. Verify that adapters preserve or narrow authority contracts.
30. Add regression cases for compatibility without subsumption.
31. Add regression cases for invalid fixtures that accidentally evaluate successfully.
32. Publish a coverage report by upstream semantic section.

---

## Completion criteria

The work is complete when:

```text
all lattice primitives have executable coverage
all claimed lattice laws have executable witnesses
subsumption is directional and runner-backed
bottom fixtures are actually evaluated
incompleteness is distinct from bottom
struct, field, and list ordering are represented
application patterns consume rather than redefine theory
kernel proof names match established properties
all kernel checks pass against the pinned upstream CUE version
```

The resulting authority chain is:

```text
upstream CUE
    → executable lattice conformance
    → validated idiomatic patterns
    → validated kernel
    → validated projections and adapters
```

## 1. Separate theory from application patterns

The existing 16 patterns should not collectively serve as the lattice-theory authority.

Split the repository into two conceptual surfaces:

```text
lattice conformance
    primitives
    algebraic laws
    structural ordering
    evaluation states

application patterns
    bounds
    constructors
    projections
    fixtures
    comprehensions
    graph proofs
```

The existing pattern catalog remains useful, but consumes the lattice-conformance layer rather than defining it.

### Proposed structure

```text
patterns/
  lattice/
    top-bottom.cue
    atoms-concreteness.cue
    type-ordering.cue
    unification.cue
    disjunction.cue
    subsumption.cue
    meet-laws.cue
    join-laws.cue
    distribution.cue
    normalization.cue
    defaults.cue
    field-ordering.cue
    struct-ordering.cue
    list-ordering.cue
    pattern-constraints.cue
    embedding.cue
    incompleteness.cue
    cycles-fixed-points.cue

  idioms/
    attributes.cue
    bounds.cue
    closedness.cue
    comprehensions.cue
    constructors.cue
    definitions.cue
    disjunctions.cue
    hidden-and-let.cue
    lists.cue
    negative-fixtures.cue
    projections.cue
    unification.cue

  schema.cue
```

Exact paths may remain flat initially, provided every case declares its family and assertion mode.

---

## 2. Introduce explicit assertion contracts

Replace the ambiguous `canonical`, `positive`, and `negative` convention with typed fixture contracts.

```cue
#AssertionMode:
    "unifies" |
    "bottoms" |
    "subsumes" |
    "preserves" |
    "exports" |
    "requires" |
    "forbids" |
    "isIncomplete" |
    "isConcrete" |
    "isFinal"

#PatternCase: {
    id:          string
    family:      string
    mode:        #AssertionMode
    description: string

    schema?:    _
    value?:     _
    general?:   _
    specific?:  _
    authority?: _
    target?:    _
    selector?:  string
}
```

Each mode has one execution contract:

| Mode           | Execution                                                   |
| -------------- | ----------------------------------------------------------- |
| `unifies`      | Evaluate `schema & value`; expect success                   |
| `bottoms`      | Evaluate the selected destructive expression; expect bottom |
| `subsumes`     | Verify that `general` subsumes `specific`                   |
| `preserves`    | Verify directional relation plus selected-value equality    |
| `exports`      | Export the selected expression; expect concrete data        |
| `requires`     | Select proof expression; expect success                     |
| `forbids`      | Select proof expression; expect bottom                      |
| `isIncomplete` | Validate incomplete but non-fatal evaluation state          |
| `isConcrete`   | Validate concrete data                                      |
| `isFinal`      | Validate final evaluation state                             |

Raw invalid values must be called `negativeFixtures`, not negative assertions.

---

## 3. Build the lattice-conformance baseline

### P0A — primitive ordering

Add executable coverage for:

```text
top
bottom
atoms
basic types
abstract versus concrete values
```

Required cases include:

```text
"foo" ⊑ string
true ⊑ bool
1 ⊑ int
int ⊑ number
every value ⊑ _
_|_ ⊑ every value
```

Also include inverse failures:

```text
string ⋢ "foo"
number ⋢ int
int ⋢ string
_ ⋢ int
```

Directional cases require the Go CUE API.

### P0B — meet and join

Cover unification as meet:

```text
a & b
```

and disjunction as join:

```text
a | b
```

Required laws:

```text
commutativity
associativity
idempotence
top identity for meet
bottom annihilation for meet
bottom identity for join
top annihilation for join
```

### P0C — distribution and normalization

Add cases proving:

```text
(a | b) & c
    ==
(a & c) | (b & c)
```

Add disjunction-normalization cases:

```cue
int | 1
string | "x"
{a: int} | {a: 1}
```

Expected normalized results depend on directional subsumption and must not be inferred from compatibility alone.

### P0D — structural ordering

Add explicit coverage for:

```text
regular fields
required fields
optional fields
open structs
closed structs
definitions
pattern constraints
ellipsis
embedding
open lists
closed lists
```

Required field-ordering cases include:

```text
{a: x} ⊑ {a!: x} ⊑ {a?: x}
```

### P0E — evaluation states

Distinguish:

```text
successful evaluation
bottom
incomplete
concrete
final
exportable
```

Do not collapse incomplete values and evaluation errors into one expected-bottom class.

### Acceptance gate

The lattice layer is complete only when:

1. every directional claim uses an actual subsumption operation;
2. every destructive fixture is selected and expected to fail;
3. algebraic laws have positive and counterexample coverage;
4. structural field, struct, and list ordering are represented;
5. incomplete, concrete, final, and bottom states are independently tested.

---

## 4. Repair the existing application patterns

### `subsumption.cue`

Current behavior:

```cue
compatibility: A & B
```

Action:

1. Rename the current pattern to `compatibility` or `schema-intersection`.
2. Create a true `subsumption` pattern using:

```text
general subsumes specific
```

3. Execute it through the Go runner.

Acceptance:

```text
compatibility and subsumption are separate assertion modes
```

---

### `top-and-bottom.cue`

Current negative fixture stores conflicting values in separate fields.

Change to:

```cue
conflict: {
    left:  meta.#GeneratedOutputResourceRole
    right: "authority"
    proof: left & right
}
```

Acceptance:

```text
selecting conflict.proof evaluates to bottom
```

---

### `negative-fixtures.cue`

Separate metadata from execution:

```cue
#NegativeFixtureSpec: {
    id:          string
    description: string
    authority:   _
    invalid:     _
}

#NegativeFixtureProbe: {
    spec: #NegativeFixtureSpec
    proof: spec.authority & spec.invalid
}
```

Acceptance:

```text
spec exports successfully
probe.proof bottoms
runner inverts the failure into a passing fixture result
```

---

### `projections.cue`

Split into:

```text
projection construction
projection preservation
```

Projection construction remains pure CUE.

Projection preservation must verify:

```text
target ⊑ authority
```

plus any selected equality obligations.

Acceptance:

```text
a compatible-but-wider target fails
a narrowed or equivalent target passes
```

---

### `constructors.cue`

Replace:

```cue
"internal" | *"internal"
```

with either:

```cue
"public" | "internal" | "restricted" | *"internal"
```

or the concrete value:

```cue
"internal"
```

Acceptance:

```text
the example either demonstrates a meaningful default or makes no default claim
```

---

### `hidden-and-let.cue`

Complete the proof:

```cue
let createdID = "generated-file"

proof: {
    created: operation.creates[createdID] & true
    role:    resources[createdID].role & _generatedRole
}
```

Prefer a comprehension over all `creates` entries for kernel use.

Acceptance:

```text
missing creates edge fails
wrong resource role fails
valid edge and role pass
```

---

### `cycles.cue`

Either rename the current pattern to `references` or expand it to cover:

```text
benign reference cycles
fixed-point cycles
recursive definitions
arithmetic cycles
structural cycles
incomplete cycles
```

Acceptance:

```text
each cycle class declares its expected evaluation state
```

---

### `definitions.cue`

Remove explicit `close` from the definition-specific teaching case.

Use the definition itself to demonstrate recursive closure:

```cue
#KernelResourceRef: {
    id:         #KebabIdentifier
    path:       string
    role:       #ResourceRole
    visibility: #VisibilityTier | *"internal"
}
```

Keep explicit `close({...})` isolated in `closedness.cue`.

Acceptance:

```text
definitions and explicit close demonstrate distinct upstream mechanisms
```

---

### `defaults.cue`

Retain the marked disjunction but add cases for:

```text
default selection
explicit override
default elimination after refinement
conflicting defaults
underlying admissible value versus selected default
```

Acceptance:

```text
the pattern covers default semantics, not only default syntax
```

---

### `disjunctions.cue`

Retain the tagged-union example.

Add links to lower-level cases for:

```text
join normalization
distribution
closed-branch rejection
```

The application pattern should not duplicate the complete algebraic suite.

---

### `lists.cue`

Retain list syntax examples and add dependencies on lower-level list-ordering cases:

```text
closed tuple versus open list
element refinement
minimum length
exact length
list subsumption
```

---

### `attributes.cue`

Retain as an application metadata pattern.

Explicitly state:

```text
attributes annotate values but do not participate in lattice evaluation
```

It must not count toward lattice-theory coverage totals.

---

### `bounds.cue`, `comprehensions.cue`, and `unification.cue`

Retain as aligned application examples.

Their acceptance tests should reference the lower-level constraint and meet-law cases rather than acting as substitutes for them.

---

## 5. Reclassify the 16-pattern catalog

After repair, classify each pattern as follows:

| Pattern             | Family                                   |
| ------------------- | ---------------------------------------- |
| `attributes`        | Metadata idiom                           |
| `bounds`            | Constraint idiom                         |
| `closedness`        | Structural idiom                         |
| `comprehensions`    | Construction idiom                       |
| `constructors`      | Construction idiom                       |
| `cycles`            | Evaluation consequence                   |
| `defaults`          | Lattice primitive plus idiom             |
| `definitions`       | Structural idiom                         |
| `disjunctions`      | Lattice composition idiom                |
| `hidden-and-let`    | Proof-construction idiom                 |
| `lists`             | Structural idiom                         |
| `negative-fixtures` | Test-harness idiom                       |
| `projections`       | Transformation idiom                     |
| `subsumption`       | Runner-backed lattice relation           |
| `top-and-bottom`    | Lattice primitive                        |
| `unification`       | Lattice primitive plus composition idiom |

`schema.cue` remains catalog and version metadata, not an executable semantic pattern.

---

## 6. Amend the kernel only after pattern gates pass

The kernel may consume a pattern only when that pattern has:

```text
an upstream semantic source
a precise assertion mode
a positive witness
a counterexample or negative witness
a defined execution surface
a passing conformance result
```

Specific kernel changes:

1. Replace pure-CUE `#NoWideningProof` with a runner-facing directional fixture.
2. Retain pure-CUE key equality only as a separate structural invariant.
3. Separate negative-fixture specifications from destructive probes.
4. Rename proof types according to the property actually established.
5. Keep normalization and referential-integrity comprehensions in pure CUE.
6. Route subsumption, evaluation-state inspection, and inverted-bottom expectations through the runner.

---

## 7. Runner contract

The Go runner becomes a narrow semantic adapter, not a second authority.

### Inputs

```cue
#ProbeRequest: {
    id:       string
    mode:     #AssertionMode
    selector?: string

    schema?:    _
    value?:     _
    general?:   _
    specific?:  _
    authority?: _
    target?:    _
}
```

### Results

```cue
#ProbeResult: {
    id:     string
    mode:   #AssertionMode
    passed: bool

    evaluation?: {
        bottom:     bool
        incomplete: bool
        concrete:   bool
        final:      bool
    }

    diagnostic?: string
}
```

### Required adapter operations

```text
unify
validate
select
export
subsume
classify evaluation state
compare selected values
```

The runner must not redefine CUE semantics. It reports results from the upstream CUE API.

---

## 8. Evidence and traceability

Every conformance case should record:

```cue
source: {
    repository: "cue-lang/cue"
    document:   "doc/ref/spec.md"
    section:    string
    commit:     string
}
```

API-dependent assertions should also identify the upstream Go symbol, such as the subsumption or validation API being exercised.

This allows the suite to detect:

```text
upstream documentation drift
API behavior drift
experimental-feature changes
pattern assumptions that are no longer valid
```

---

## 9. Revised priority order

### P0 — establish the semantic authority

1. Define assertion modes and fixture schemas.
2. Implement the minimal Go probe runner.
3. Add true directional subsumption tests.
4. Add real expected-bottom probes.
5. Add top, bottom, type-ordering, and concreteness cases.
6. Add meet, join, distribution, and normalization laws.
7. Add evaluation-state classification.

### P1 — structural lattice coverage

8. Add field-marker ordering.
9. Add open/closed struct ordering.
10. Add pattern-constraint and ellipsis cases.
11. Add embedding cases.
12. Add open/closed list ordering.
13. Expand cycle and fixed-point cases.
14. Add complete default-ordering cases.

### P2 — repair the application pattern catalog

15. Rename current `subsumption` to compatibility.
16. Create runner-backed `subsumption`.
17. Repair `top-and-bottom`.
18. Repair `negative-fixtures`.
19. Split projection construction from preservation.
20. Complete the hidden-and-let proof.
21. Correct constructor defaults.
22. Separate definition closure from explicit `close`.

### P3 — realign the kernel

23. Remove pure-CUE no-widening claims.
24. Bind kernel proof declarations to explicit assertion modes.
25. Route destructive and directional checks through the runner.
26. Re-run all kernel positive, negative, preservation, and subsumption fixtures.
27. Record the upstream commit used as the conformance baseline.

### P4 — projection and adapter validation

28. Validate generated projections against the corrected kernel.
29. Verify that adapters preserve or narrow authority contracts.
30. Add regression cases for compatibility without subsumption.
31. Add regression cases for invalid fixtures that accidentally evaluate successfully.
32. Publish a coverage report by upstream semantic section.

---

## 10. Completion criteria

The work is complete when:

```text
all lattice primitives have executable coverage
all claimed lattice laws have executable witnesses
subsumption is directional and runner-backed
bottom fixtures are actually evaluated
incompleteness is distinct from bottom
struct, field, and list ordering are represented
application patterns consume rather than redefine theory
kernel proof names match established properties
all kernel checks pass against the pinned upstream CUE version
```

The resulting authority chain is:

```text
upstream CUE
    → executable lattice conformance
    → validated idiomatic patterns
    → validated kernel
    → validated projections and adapters
```
