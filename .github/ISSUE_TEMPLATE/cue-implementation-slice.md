---
name: CUE constructor manifest slice
about: Implement a bounded CUE slice from compact repo-local constructor manifests.
title: "cue: "
labels: cue, contract, implementation
---

# CUE Constructor Manifest Slice

## Tracking

```text
Parent:
Depends on:
Blocks:
Manifest path:
```

## Goal

```text
Implement:
  -

Do not implement:
  -
```

## Constructor Authority

Use repo-local constructor definitions from `contracts/meta/impl`.

Issue bodies should carry a compact manifest or a path to `contracts/issues/<issue-number>/manifest.cue`.
Manifests must contain constructor calls only.
Do not embed constructor bodies in issue text.
Do not invent alternate shapes.
Do not encode CUE checks as string metadata.

```cue
import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_constructorWorkflow: [
	{order: 1, id: "#MakePrimitive", constructor: impl.#MakePrimitive, instantiateAt: "_primitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: impl.#MakeObservedSurface, instantiateAt: "_observed"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: impl.#MakeAdmissibleSurface, instantiateAt: "_admissible"},
	{order: 4, id: "#MakePredicateSet", constructor: impl.#MakePredicateSet, instantiateAt: "_predicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: impl.#MakePromotionCandidate, instantiateAt: "_promotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: impl.#MakeSurfaceSet, instantiateAt: "_surfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: impl.#MakeNegativeFixture, instantiateAt: "_negativeFixtures"},
	{order: 8, id: "#MakeBottomCheck", constructor: impl.#MakeBottomCheck, instantiateAt: "_negativeBottomChecks"},
	{order: 9, id: "#MakeValidationPlan", constructor: impl.#MakeValidationPlan, instantiateAt: "_validation"},
	{order: 10, id: "#MakeCompletionReport", constructor: impl.#MakeCompletionReport, instantiateAt: "_completion"},
]
```

## Manifest Shape

```cue
package issue

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#<Primitive>"
			role: "<role>"
			requiredFields: ["<field>"]
			constraints: ["<constraint>"]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#<Admissible>"]
		observed: ["#<Observed>"]
		candidates: ["#<Candidate>"]
		fixtures: ["negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["normalizedIssueManifest", "issueValidationPlan", "issueCompletionReportContract"]
	}
}
```

## Negative Checks

Negative checks must be loaded from an explicit check surface and must fail by structural conflict or bottom.
They must not pass because a selector is absent or because the check file was not loaded.

```cue
_negativeBottomChecks: {
	<name>: negativeFixtures.<name>.input & #<Candidate>
}
```

## Validation

```bash
cue vet ./<contract-path>
cue export ./<contract-path> -e normalizedIssueManifest
cue export ./<contract-path> -e issueValidationPlan
cue export ./<contract-path> -e issueCompletionReportContract
! cue export ./<check-surface-path> -e '_negativeBottomChecks.<name>'
```

## Completion Report

```text
Summary:
  - constructor files:
  - manifest workflow:
  - template changes:
  - public eval surfaces:
  - negative checks:
  - forbidden attractors avoided:

Validation:
  - cue vet:
  - constructor exports:
  - negative bottom checks:
  - forbidden-attractor search:
```

Stop once the declared CUE surfaces export and the loaded negative checks bottom.
