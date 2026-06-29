```cue
issue: {
	id:     "factory.meta"
	kind:   "implementation-slice"
	repo:   "fatb4f/factory"
	number: 0
	title:  "factory: meta"

	template: {
		name:     "Factory manifest slice"
		root:     "contracts"
		workflow: "contracts/meta"
		manifest: "contracts/issues/<issue-number>/manifest.cue"
		checks:   "contracts/issues/<issue-number>/checks/bottom.cue"
		import:   "github.com/fatb4f/factory/contracts/meta"
	}

	tracking: {
		parent: _|_
		dependsOn: []
		blocks: [
			"agent-context-resolver constructor-shape migration",
			"code-intel constructor-shape migration",
		]
	}

	goal: {
		implement: [
			"rename the constructor authority from contracts/meta to contracts/meta",
			"split constructor pipeline order from artifact authority strata",
			"make contracts/meta the only allowed artifact-shape catalog for constructor instances",
			"encode the canonical constructor pipeline from primitive through completion",
			"encode authority strata as contract, assertions, fixtures, checks, and evals",
			"require #MakeBottomCheckProof to instantiate only under check surfaces such as checks/_negativeBottomChecks",
			"make generated outputs downstream evidence only",
			"issue-local manifest and negative check surface",
		]

		notImplement: [
			"agent-context-resolver migration into the new shape",
			"code-intel migration into the new shape",
			"template-shaped bundle manifest removal outside compatibility adapters",
			"generated artifacts as authority",
			"completion reports as authority",
			"runtime execution or transport behavior",
		]
	}

	intent: "Refactor the meta constructor catalog into the canonical dual-axis shape so downstream plugin slices instantiate one authority model instead of carrying local bundle or recommendation schemas."

	authorityRoot: {
		root: "contracts/meta"
		surfaces: [
			"contracts/meta/**",
			"contracts/issues/<issue-number>/**",
		]
	}

	authoritySplit: {
		contract: [
			"owns shape, constructors, invariants, and admissible fields",
			"owns the constructor catalog and constructor pipeline metadata",
			"owns the authority strata vocabulary",
		]
		assertions: [
			"bind expected properties over concrete contract instances",
			"prove constructor ordering and stratum separation without becoming constructors",
		]
		fixtures: [
			"provide admissible and inadmissible examples",
			"probe generated-authority, proof-placement, and eval-promotion boundaries",
		]
		checks: [
			"execute proof obligations against fixtures and assertions",
			"host #MakeBottomCheckProof output under checks/_negativeBottomChecks only",
		]
		evals: [
			"summarize evidence only; never become authority",
			"consume validation and check evidence without changing admissibility",
		]
	}

	targetSurfaces: [
		"contracts/meta/**",
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
		legacyImplPath: {
			authority: false
			role: "compatibility alias only during migration; canonical authority is contracts/meta"
		}
		bundleTemplates: {
			authority: false
			role: "adapter/projection compatibility only; not artifact-shape authority"
		}
		generatedArtifacts: {
			authority: false
			role: "projection/evidence only"
		}
		runtimeState: {
			authority: false
			role: "observed evidence only"
		}
		evals: {
			authority: false
			role: "reporting over validated evidence only"
		}
	}

	closure: {
		requires: [
			"contracts/meta constructors generate contract instances",
			"constructor order and artifact authority strata are represented as separate axes",
			"plugin slices instantiate constructors instead of defining parallel manifest schemas",
			"fixtures probe contract boundaries",
			"checks prove success/failure behavior",
			"#MakeBottomCheckPlan remains manifest-safe and #MakeBottomCheckProof remains check-surface-only",
			"evals and reporting consume check evidence only",
			"all declared contract surfaces validate from repo-local CUE",
		]
	}

	validation: {
		commands: [
			"cue export ./contracts/meta",
			"cue vet ./contracts/meta",
			"cue export ./contracts/meta -e constructorPipeline",
			"cue export ./contracts/meta -e authorityStrata",
			"cue export ./contracts/meta -e constructorManifestBaseline",
			"cue export ./contracts/meta -e constructorValidationPlanBaseline",
			"cue export ./contracts/meta -e constructorCompletionReportBaseline",
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
			"cue export ./contracts/issues/<issue-number> -e _completion",
			"! rg '[t]arget:\\s*_|[i]nput:\\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority|manifestExecutableProofObject|eval.*authority' ./contracts/meta ./contracts/issues/<issue-number>",
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
