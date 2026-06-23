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

## Files

```text
Add / update:
  - <path>.cue

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
! cue export ./<contract-path> -e '_negativeBottomChecks.<name>'
! rg 'truthFlag|operatorSupplied|expectedBottom|bottomCheckSurface|expression:' ./<contract-path>
```

## Forbidden attractors

```text
operator-supplied truth flags
predicates stored as review metadata
expectedBottom without real intersection
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
- [ ] Negative fixtures are typed observed objects.
- [ ] `_negativeBottomChecks` are real intersections and bottom.
- [ ] Public eval exports validate.
- [ ] Forbidden-attractor search passes.

## Completion report

```text
Summary:
Validation:
Negative bottoms:
Forbidden attractors:
Exceptions:
```

Stop once the declared slice validates and the negative intersections bottom.
