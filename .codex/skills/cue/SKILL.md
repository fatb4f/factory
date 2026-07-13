---
name: cue
description: Author, refactor, diagnose, and validate nontrivial CUE schemas, evaluators, workflows, evidence ingress, and publication projections. Use when Codex modifies CUE, encounters scope, conjunction, closure, totality, cardinality, or proof-construction failures, or needs concrete positive and negative CUE probes.
---

# CUE Authoring

## Validation model

CUE development requires four complementary layers:

```text
CUE LSP
+ kernel modeling patterns
+ package validation
+ concrete semantic probes
```

No single layer is sufficient. In particular:

```text
Valid CUE is not necessarily a valid proof.
```

### 1. CUE LSP: authoring feedback

Use the CUE language server for syntax and parse diagnostics, name resolution,
navigation and references, module and package awareness, hover information,
formatting feedback, and rapid local feedback while editing.

Treat the LSP as a development sensor, not an admission gate. A clean LSP state
does not imply semantic correctness. It may not fully evaluate every conditional
branch or comprehension under concrete inputs, cardinality assumptions,
evidence completeness, observed-versus-expected equivalence, duplicate evidence,
workflow ordering, reference distinctions, or application-specific proof
obligations.

### 2. Kernel patterns: modeling discipline

Before modifying nontrivial CUE, inspect the designated kernel reference and
apply its forms for:

- Closed ingress.
- Local aliases for conjunct-provided fields.
- Shape/proof separation.
- Hidden proof and failure fields.
- Total evaluator results with explicit incomplete state.
- Exact cardinality proofs.
- Raw facts separated from derived conclusions.
- Wiring-only dispatch.
- Distinct reference-resolution and ordering proofs.

Kernel alignment prevents structurally valid CUE from encoding an invalid
proof. Do not invent a replacement idiom during a validation run.

### 3. Package gates: structural evaluation

Run these gates even when the LSP reports no diagnostics:

```bash
cue fmt --check --files <changed-files>
cue vet <package>
cue vet -c <package>
```

Passing them means the package formats, unifies, and exposes the requested
concrete surface. It does not prove that incorrect evidence is rejected.

### 4. Concrete probes: semantic validation

Require concrete probes for every nontrivial evaluator, dispatcher, admission
rule, and workflow proof. At minimum, test:

- Complete positive and complete negative evidence.
- Missing, duplicated, and wrongly typed required facts.
- Mismatched identities.
- Zero and duplicate matching observations.
- Wrong execution ID, workflow node, evidence phase, or evidence kind.
- Unresolved references.
- Resolved references with invalid ordering.
- Claimant-supplied conclusions.
- Unresolved conditional branches.

Enforce this invariant:

```text
only one complete, correctly scoped, contract-conforming observation
may satisfy an authoritative scenario
```

Interpret results precisely:

```text
LSP clean
    means local authoring diagnostics found no issue.

cue vet passes
    means the package unifies.

cue vet -c passes
    means the requested package surface is concrete.

semantic probes pass
    means the intended proof behavior was exercised.
```

The confidence boundary is:

```text
LSP clean
&& kernel-aligned structure
&& package gates pass
&& semantic probes pass
```

Use this workflow for every nontrivial change:

```text
edit with LSP
→ compare against kernel form
→ run package gates
→ run concrete probes
→ inspect published projections
```

CUE LSP and `cue vet` can accept models where incomplete evidence becomes a
valid rejection, duplicate evidence satisfies existential admission, dispatcher
branches reproduce evaluator semantics, expected outcomes determine observed
outcomes, or unresolved references are conflated with bad ordering. Prevent
these failures with kernel-aligned construction and adversarial probes.

## Required reference

Before modifying nontrivial CUE, read the complete reference at:

- [`~/src/lattice/meta/kernel.cue`](~/src/lattice/meta/kernel.cue)

Use its modeling forms for lexical aliases, hidden proof fields, closed ingress,
total evaluators, derived state, exact identity sets, and concrete probes. Copy
the form, not lattice-specific vocabulary. If the reference is unavailable,
report that limitation before selecting a substitute idiom.

## Workflow

1. Locate the module root and its `cue.mod` before editing.
2. Identify external ingress, internal proof, and published projection boundaries.
3. Inspect the closest kernel analogue.
4. Make one small, localized modeling change.
5. Run formatting, vetting, and concrete probes in the required order.
6. Stop after a second semantic failure instead of inventing another idiom.

Treat language-server feedback as authoring assistance. Keep `cue vet` and
`cue vet -c` as acceptance gates.

## Core rules

### Conjunction is not lexical import

Do not assume fields introduced by another conjunct become lexical identifiers.

Unsafe:

```cue
#Base: {
	Input: #Input
}

#Derived: #Base & {
	result: Input.value
}
```

Redeclare and alias concrete inputs locally:

```cue
#Derived: #Base & {
	Input: #Input
	_input: Input

	result: _input.value
}
```

### Separate shape from proof

Keep the public result shape independent from its concrete proof:

```cue
#ResultShape: {
	admitted: bool
}

#Result: #ResultShape & {
	Input: #Input
	_input: Input

	_complete: ...
	_matches:  ...

	admitted: _complete && _matches
}
```

### Keep conclusions out of raw facts

Allow ingress facts such as argv, timestamps, exit codes, paths, digests,
identities, and observed values. Reject claimant conclusions such as `valid`,
`success`, `complete`, `admitted`, and `satisfied`.

### Derive outcomes from observations

Never derive an observed outcome from an expected outcome.

Bad:

```cue
if Scenario.expected == "preserve" {
	observed: "preserve"
}
```

Good:

```cue
_preserved: Before.digest == After.digest

if _preserved {
	observed: "preserve"
}
```

### Prove completeness independently

Incomplete evidence does not satisfy a negative case. Establish required
cardinality before comparing evidence:

```cue
_complete: len(_before) == 1 && len(_after) == 1
_match:    _complete && _before == _after

satisfied: _complete && observed == Scenario.expected
```

### Avoid unsafe indexing

Prefer whole-list comparison after cardinality checks:

```cue
_complete: len(_left) == 1 && len(_right) == 1
_equal:    _complete && _left == _right
```

Do not rely on Boolean short-circuiting to protect `_left[0]`.

### Close ingress and publication boundaries

Use `close({...})` for external observations, manifests, published projections,
and compact results. Keep internal proof structures open only where extension is
intentional.

### Make evaluators total

For every admitted input, derive required evidence, evidence completeness,
observed result, and satisfaction. No conditional branch may leave a referenced
public field unresolved.

Use one evaluator form consistently:

```cue
#SomeEvaluation: #ScenarioEvaluationShape & {
	Observation: #ScenarioObservation
	Scenario:    #Scenario

	_observation: Observation
	_scenario:    Scenario

	_requiredFacts: [...]
	_complete:      ...
	_proof:         ...

	if _complete && _proof {
		observedOutcome: "accept"
	}
	if _complete && !_proof {
		observedOutcome: "reject"
	}

	evidenceComplete: _complete
	satisfied: runnerCompleted && evidenceComplete &&
		observedOutcome == _scenario.fixture.expectation
}
```

For preservation, derive `"preserve"` only from a raw identity proof.

## Kernel pattern catalogue

| Pattern | Kernel example | Failure prevented | Typical Factory application |
| --- | --- | --- | --- |
| Concrete aliases | `let closedAuthority = ...`; local `authorityKeys` | Conjunct fields mistaken for lexical scope | Evaluators using `Observation` and `Scenario` |
| Hidden proof fields | `_operationRefProof`, `_invalidField` | Proof machinery leaking into publication | `_complete`, `_matches`, `_failures` |
| Shape/proof separation | `#NegativeFixtureSpec` and probe binding | Claimant facts confused with derived conclusions | Observation schemas versus admissions |
| Closed external records | `#Resource`, `#Operation`, `#NegativeFixtureSpec` | Undeclared ingress or publication fields | Manifests and transient evidence ingress |
| Total derived values | `#StateKeySet`, `#OperationRefKeySet` | Referenced values remaining unresolved | `observedOutcome`, `satisfied`, node state |
| Raw facts to proof to result | fixture, conflict probe, check binding | Expectation-derived outcomes | Scenario evaluation |
| Exact identity sets | sorted key lists in `#NoWideningProof` | Partial or existential identity matches | Artifacts and workflow projections |
| Concrete probes | `#NegativeFixtureConflictProbe` | Schemas appearing valid without rejection proof | Every evaluator and dispatcher |
| Bottom as rejection | `proof: authority & invalid` | Invalid structures accepted by Boolean claims | Incomplete or claimant-supplied structures |
| Bounded vocabulary | constrained primitive definitions and enums | Uncontrolled protocol vocabulary | Protocol IDs, boundaries, failure codes |

## Anti-patterns

Reject these patterns during review:

- Assuming conjunction creates lexical scope.
- Referencing conditional fields as guaranteed values.
- Deriving an observation from its expected outcome.
- Treating absent evidence as a valid rejection.
- Using list indexing behind Boolean guards.
- Using generic raw facts without cardinality proofs.
- Mixing runner exit status with subject exit status.
- Accepting existential success across unrelated evidence phases.
- Duplicating command or workflow semantics in Python.
- Parsing CUE source instead of exporting and consuming JSON.

## Validation order

Run exactly:

```bash
cue fmt --check --files <changed-files>
cue vet ./path/to/module
cue vet -c ./path/to/module
```

Then run concrete positive and negative probes. Keep structural CUE validation
independent from producer or workbook runtime validation.

For each evaluator, probe:

- Valid positive evidence.
- Valid negative evidence.
- Missing required fact.
- Duplicate required fact.
- Wrong fact type.
- Unexpected claimant conclusion.
- Mismatched identity.
- Unresolved conditional branch.

Validate dispatchers separately to prove they select an evaluator without
duplicating evaluator semantics.

## Stop rule

On the first semantic failure, inspect the failing definition and its kernel
analogue, then apply one targeted correction. On the second semantic failure,
stop and report the failure; do not improvise a new modeling pattern.
