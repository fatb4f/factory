---
name: Contract issue
about: Submit a factory implementation issue as a single CUE issue block.
title: "factory: "
---

```cue
issue: {
	id:     "factory.<slice-id>"
	kind:   "implementation-slice"
	repo:   "fatb4f/factory"
	number: 0
	title:  "factory: <title>"

	template: {
		name: "Factory manifest slice"
		root: "contracts"
		workflow: "contracts/meta/impl"
		manifest: "contracts/issues/<issue-number>/manifest.cue"
		checks: "contracts/issues/<issue-number>/checks/bottom.cue"
		import: "github.com/fatb4f/factory/contracts/meta/impl"
	}

	tracking: {
		parent: _|_
		dependsOn: []
		blocks: []
	}

	goal: {
		implement: [
			"<primary implementation requirement>",
			"<secondary implementation requirement>",
			"issue-local manifest and negative check surface",
		]

		notImplement: [
			"<explicit non-goal>",
			"generated artifacts as authority",
		]
	}

	intent: "<issue intent>"

	authorityRoot: {
		root: "<authority root>"
		surfaces: [
			"<authority surface glob>",
			"contracts/issues/<issue-number>/**",
		]
	}

	authoritySplit: {
		contract: [
			"owns shape, constructors, invariants, and admissible fields",
		]
		assertions: [
			"bind expected properties over concrete contract instances",
		]
		fixtures: [
			"provide admissible and inadmissible examples",
		]
		checks: [
			"execute proof obligations against fixtures and assertions",
		]
		evals: [
			"summarize evidence only; never become authority",
		]
	}

	targetSurfaces: [
		"<target path>",
		"contracts/issues/<issue-number>/manifest.cue",
		"contracts/issues/<issue-number>/checks/bottom.cue",
	]

	workflow: [
		{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
		{order: 2, id: "#MakeObservedSurface", instantiateAt: "_observed"},
		{order: 3, id: "#MakeAdmissibleSurface", instantiateAt: "_admissible"},
		{order: 4, id: "#MakePredicateSet", instantiateAt: "_predicates"},
		{order: 5, id: "#MakePromotionCandidate", instantiateAt: "_promotion"},
		{order: 6, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
		{order: 7, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
		{order: 8, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
		{order: 9, id: "#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks"},
		{order: 10, id: "#MakeValidationPlan", instantiateAt: "_validation"},
		{order: 11, id: "#MakeCompletionReport", instantiateAt: "_completion"},
	]

	boundaries: {
		generatedArtifacts: {
			authority: false
			role: "projection/evidence only"
		}
		runtimeState: {
			authority: false
			role: "observed evidence only"
		}
	}

	closure: {
		requires: [
			"meta/impl constructors generate contract instances",
			"plugin slices instantiate constructors",
			"fixtures probe contract boundaries",
			"checks prove success/failure behavior",
			"evals and reporting consume check evidence only",
			"all declared contract surfaces validate from repo-local CUE",
		]
	}

	validation: {
		commands: [
			"cue export ./contracts/meta/impl",
			"cue vet ./contracts/issues/<issue-number>",
			"cue export ./contracts/issues/<issue-number> -e _primitives",
			"cue export ./contracts/issues/<issue-number> -e _observed",
			"cue export ./contracts/issues/<issue-number> -e _admissible",
			"cue export ./contracts/issues/<issue-number> -e _predicates",
			"cue export ./contracts/issues/<issue-number> -e _promotion",
			"cue export ./contracts/issues/<issue-number> -e _surfaces",
			"cue export ./contracts/issues/<issue-number> -e _negativeFixtures",
			"cue export ./contracts/issues/<issue-number> -e _bottomCheckPlans",
			"! cue export ./contracts/issues/<issue-number>/checks -e '_negativeBottomChecks.<name>'",
			"cue export ./contracts/issues/<issue-number> -e _validation",
			"cue vet ./contracts/issues/<issue-number>/generated",
			"cue export ./contracts/issues/<issue-number> -e _completion",
			"! rg '[t]arget:\\s*_|[i]nput:\\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority' ./contracts/issues/<issue-number>",
		]
	}

	completionReport: {
		sections: [
			"summary",
			"manifest workflow",
			"target surfaces",
			"requirements",
			"assertions",
			"fixtures",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}
```
