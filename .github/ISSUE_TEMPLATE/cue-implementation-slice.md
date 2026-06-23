---
name: CUE functional slice
about: Implement a bounded eval-first CUE contract slice.
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
  -

Not CUE authority:
  -

Adapter / generated / runtime boundary:
  -
```

## Functional contract

```text
Observed type:
  #Observed<T>
  role:
  must allow invalid observed states:

Admissible / candidate type:
  #Admissible<T> / #<Candidate>
  role:
  must reject:

Predicates:
  #<Predicates>
  derived from structure, not operator flags:

Fixtures:
  valid:
    -
  negative:
    -

Required bottom intersections:
  _negativeBottomChecks.<fixture>:
    negativeFixtures.<fixture>.input & #<Candidate>
```

## Files

```text
Add / update:
  - <contract-path>/<file>.cue
      purpose:

Package:
  package <package>
```

## Public eval surfaces

```text
Required exports:
  - <validBaselineExpr>
  - <publicSliceExpr>
  - <gateOrReportExpr>
```

## Validation commands

```bash
cue vet ./<contract-path>
cue export ./<contract-path> -e <validBaselineExpr>
cue export ./<contract-path> -e <publicSliceExpr>

# If negative fixtures exist:
! cue export ./<contract-path> -e '_negativeBottomChecks.<fixtureName>'

# Forbidden-attractor search:
! rg '<forbiddenNameA>|<forbiddenNameB>|bottomCheckSurface|expression:' ./<contract-path>
```

## Forbidden attractors

Do not introduce:

```text
diagnostic boolean fields used as authority
expectedBottom without real intersections
stringified CUE expressions
bottomCheckSurface.expression
review-only metadata as proof
fake/default provenance
placeholder evidence accepted as admissible evidence
adapter output as policy authority
generated artifact as authority
shell-only semantic validation
side-package schema sprawl
```

Repo-specific forbidden names:

```text
-
-
-
```

## Acceptance criteria

- [ ] Scope is bounded.
- [ ] Authority boundary is explicit.
- [ ] Observed type can represent invalid observations.
- [ ] Candidate/admissible type rejects invalid observations structurally.
- [ ] Predicates are derived from structure, not supplied as truth flags.
- [ ] Valid baseline exports.
- [ ] Public slice/gate/report exports.
- [ ] Negative fixtures bottom through real CUE intersections, if present.
- [ ] Forbidden-attractor search passes.
- [ ] Completion report includes validation results.

## Completion report

```text
Summary:
  - primitives:
  - admissible/candidate surfaces:
  - fixtures:
  - predicates/checks:
  - public eval surfaces:
  - generated/projection updates:
  - forbidden attractors avoided:

Validation:
  - cue vet:
  - valid baseline export:
  - public slice export:
  - negative bottom checks:
  - forbidden attractor search:
  - generated/projection checks:

Compatibility exceptions:
  -
```

Stop once the declared CUE contract slice exports and validates.
