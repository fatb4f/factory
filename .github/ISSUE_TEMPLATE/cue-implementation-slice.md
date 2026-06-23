---
name: CUE functional slice
about: Implement a bounded CUE slice with real observed/admissible/bottom-check gates.
title: "cue: "
labels: cue, contract, implementation
---

# CUE functional slice

## Tracking

```text
Parent:
Depends on:
Blocks:
```

## Goal

```text
Implement:
  -

Do not implement:
  -
```

## Constructor manifest

```text
Use repo-local constructor definitions from:
  contracts/meta/impl

Provide compact constructor calls only.
Do not inline constructor definitions.
Do not invent alternate constructor shapes.
Do not encode CUE expressions as strings.

Preferred manifest path:
  contracts/issues/<issue-number>/manifest.cue

Preferred normalized export path:
  contracts/issues/<issue-number>/normalized.cue
```

## Authority boundary

```text
CUE owns:
  - admissibility
  - structural predicates
  - bottom checks

Observed / adapter / generated data:
  - evidence only
  - may be invalid
  - never policy authority
```

## Required shape

```text
#Observed<T>
  -> broad fact substrate
  -> can represent valid and invalid observed states

#Admissible<T>
  -> narrow admissible structure
  -> rejects invalid values structurally

#PatchPredicates
  -> derived from observed structure
  -> no operator-supplied truth flags

#RootPromotionCandidate
  -> closed admissibility surface
  -> wires predicates as control

#NegativeFixture
  -> typed invalid observed object

_negativeBottomChecks
  -> real CUE intersections
  -> expected to bottom
```

## Slice objects

```text
Observed type:
  #Observed<...>:

Admissible type:
  #Admissible<...>:

Predicates:
  #PatchPredicates:

Promotion candidate:
  #RootPromotionCandidate:

Negative fixtures:
  #NegativeFixture:
  negativeFixtures.<name>:

Bottom checks:
  _negativeBottomChecks.<name>:
    negativeFixtures.<name>.input & #RootPromotionCandidate
```

## Negative-check placement

```text
Normal package surface:
  - cue vet clean
  - declares observed/admissible/candidate types
  - declares valid exports and fixtures
  - does not contain realized package-scope bottoms

Test/check surface:
  - contains _negativeBottomChecks
  - contains strict intersections
  - may bottom when a specific negative expression is exported
```

A negative check is valid only if the selected expression exists and fails by conflict/bottom.
It is not valid if it fails by undefined field, missing selector, or absent check surface.

Do not hide negative checks behind defaults or disjunctions such as:

```cue
_negativeBottomChecks: *{} | #NegativeBottomChecks
```

## Files

```text
Add / update:
  - <path>.cue
  - <check-path>.cue or <path>_test.cue

Package:
  package <package>
```

## Public eval surfaces

```text
Required exports:
  - <validObservedBaseline>
  - <admissibleCandidateBaseline>
  - <promotionReport>
```

## Validation

```bash
cue vet ./<contract-path>
cue export ./<contract-path> -e <validObservedBaseline>
cue export ./<contract-path> -e <admissibleCandidateBaseline>
cue export ./<contract-path> -e <promotionReport>

# Negative checks must load the check/test surface and fail by bottom, not undefined field.
! cue export ./<contract-path> ./<check-path>.cue -e '_negativeBottomChecks.<name>'

! rg 'truthFlag|operatorSupplied|bottomCheckSurface|expression:|isInvalid: true' ./<contract-path>
```

## Forbidden attractors

```text
operator-supplied truth flags
predicates stored as review metadata
expectedBottom without real intersection
undefined-field negative checks
missing _negativeBottomChecks selector
stringified CUE expressions
bottomCheckSurface.expression
adapter output as policy authority
generated artifact as authority
shell-only semantic validation
placeholder evidence accepted as admissible
```

## Acceptance

- [ ] `#Observed<T>` admits valid and invalid observations.
- [ ] `#Admissible<T>` rejects invalid values structurally.
- [ ] `#PatchPredicates` are derived, not supplied.
- [ ] `#RootPromotionCandidate` is the closed promotion gate.
- [ ] Constructor manifests use repo-local constructors from `contracts/meta/impl`.
- [ ] Issue bodies carry constructor calls or manifest paths, not constructor bodies.
- [ ] Negative fixtures are typed observed objects.
- [ ] `_negativeBottomChecks` are real intersections in a loaded check/test surface.
- [ ] Negative exports fail by conflict/bottom, not undefined field.
- [ ] Normal package `cue vet` remains clean.
- [ ] Public eval exports validate.
- [ ] Forbidden-attractor search passes.

## Completion report

```text
Summary:
Validation:
Negative bottoms:
  - command:
  - failure mode: conflict/bottom | undefined-field | other
Forbidden attractors:
Exceptions:
```

Stop once the declared slice validates and each loaded negative intersection bottoms.
