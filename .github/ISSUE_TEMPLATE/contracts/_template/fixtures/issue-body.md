```cue
issue: {
	id:     "factory.<slice-id>"
	kind:   "implementation-slice"
	repo:   "fatb4f/factory"
	number: 0
	title:  "factory: <title>"

	tracking: {
		parent: _|_
		dependsOn: []
		blocks: []
	}

	goal: {
		implement: [
			"<primary implementation goal>",
		]
		notImplement: [
			"<explicit non-goal>",
		]
	}

	intent: "<issue intent>"

	authorityRoot: {
		root: "<authority root>"
		surfaces: [
			"<authority surface glob>",
		]
	}

	authoritySplit: {
		cue: [
			"contract and validation authority under github.com/fatb4f/factory",
		]
		adapters: [
			"external execution only; no authority ownership",
		]
		generatedArtifacts: [
			"projection/evidence only",
		]
	}

	targetSurfaces: [
		"<target path>",
	]

	workflow: [
		{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
		{order: 2, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
		{order: 3, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
		{order: 4, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
		{order: 5, id: "#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks"},
		{order: 6, id: "#MakeValidationPlan", instantiateAt: "_validation"},
		{order: 7, id: "#MakeCompletionReport", instantiateAt: "_completion"},
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
			"<closure requirement>",
		]
	}

	validation: {
		commands: [
			"cue vet <contract-surface>",
			"cue export <contract-surface> -e <normalized-export>",
			"! cue export <contract-surface>/checks -e '_negativeBottomChecks.<name>'",
		]
	}

	completionReport: {
		sections: [
			"summary",
			"manifest workflow",
			"target surfaces",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}
```
