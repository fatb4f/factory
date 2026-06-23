package issue

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_issue: {
	tracking: {
		parent: 52
		dependsOn: [53, 54, 55]
		blocks: ["future Go/CUE or MCP materializer"]
	}
	target: {
		contractPath: "contracts/issues/example"
		package: "issue"
		manifestPath: "contracts/issues/example/manifest.cue"
		checkFile: "./contracts/issues/example/checks"
	}
	requiredFiles: [
		"contracts/issues/README.md",
		"contracts/issues/example/manifest.cue",
		"contracts/issues/example/normalized.cue",
		"contracts/issues/example/validation.cue",
		"contracts/issues/example/checks/checks.cue",
		"contracts/issues/example/workflow.cue",
		"docs/codex-manifest-slice-workflow.md",
	]
}

_constructorAuthority: impl.constructorCatalog & {
	package: "impl"
	root: "contracts/meta/impl"
}

_constructorWorkflow: [
	{order: 1, id: "#MakePrimitive", constructor: impl.#MakePrimitive, instantiateAt: "_primitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: impl.#MakeObservedSurface, instantiateAt: "_observed"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: impl.#MakeAdmissibleSurface, instantiateAt: "_admissible"},
	{order: 4, id: "#MakePredicateSet", constructor: impl.#MakePredicateSet, instantiateAt: "_predicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: impl.#MakePromotionCandidate, instantiateAt: "_promotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: impl.#MakeSurfaceSet, instantiateAt: "_surfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: impl.#MakeNegativeFixture, instantiateAt: "_negativeFixtures"},
	{order: 8, id: "#MakeBottomCheck", constructor: impl.#MakeBottomCheck, instantiateAt: "_bottomCheckConstructors"},
	{order: 9, id: "#MakeValidationPlan", constructor: impl.#MakeValidationPlan, instantiateAt: "_validation"},
	{order: 10, id: "#MakeCompletionReport", constructor: impl.#MakeCompletionReport, instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#IssueManifestLayout"
			role: "repo-local issue manifest convention for compact constructor calls"
			requiredFields: ["issue", "target", "constructorAuthority", "constructorWorkflow", "validation", "completion"]
			constraints: [
				"manifest path is contracts/issues/<issue-number>/manifest.cue",
				"manifest imports github.com/fatb4f/contract.cuemod/contracts/meta/impl",
				"manifest contains constructor calls only",
			]
			closed: true
		}
	},
]

_observed: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedIssueManifest"
		role: "broad observed issue manifest payload"
		factFields: ["manifestPath", "implImport", "constructorCalls", "checkFile"]
		constraints: ["can represent valid and invalid observed issue bodies"]
	}
}

_admissible: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#IssueManifestCandidate"
		role: "admissible compact constructor manifest"
		observedSurface: "#ObservedIssueManifest"
		requiredFields: ["manifestPath", "implImport", "constructorCalls"]
		rejectedFields: ["constructorBodies", "stringifiedCueChecks"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#IssueManifestPredicates"
		role: "derive manifest rejection predicates from observed fields"
		inputSurface: "#ObservedIssueManifest"
		derivedPredicates: ["hasConstructorBodies", "hasStringifiedCueChecks"]
		operatorSupplied: false
	}
}

_promotion: impl.#MakePromotionCandidate & {
	in: {
		name: "#IssueManifestPromotionCandidate"
		role: "closed candidate for compact issue manifests"
		observedSurface: "#ObservedIssueManifest"
		admissibleSurface: "#IssueManifestCandidate"
		predicateSet: "#IssueManifestPredicates"
		controlPredicates: ["hasConstructorBodies", "hasStringifiedCueChecks"]
		closed: true
	}
}

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: [_admissible.out.name]
		observed: [_observed.out.name]
		candidates: [_promotion.out.name]
		fixtures: ["validManifestBaseline", "negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["issueManifest", "normalizedIssueManifest", "issueValidationPlan", "issueCompletionReportContract"]
	}
}

negativeFixtureSet: {
	constructorBodies: (impl.#MakeNegativeFixture & {
		in: {
			name: "constructorBodies"
			violates: "manifests must call repo-local constructors without carrying constructor bodies"
			refusal: "move constructor bodies to contracts/meta/impl"
			input: {
				manifestPath: "contracts/issues/example/manifest.cue"
				implImport: "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
				constructorCalls: ["impl.#MakePrimitive"]
				constructorBodies: true
			}
		}
	}).out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: _issue.target.contractPath
		validBaselineExpr: "issueManifest"
		publicExpr: "normalizedIssueManifest"
		bottomChecks: ["constructorBodies"]
		checkFile: _issue.target.checkFile
		forbiddenPattern: _issueForbiddenPattern
	}
}

_issueForbiddenPattern: "\(inlineWord)\(constructorWord)\(definitionsWord)|\(encodedWord)\(cueWord)\(checkWord)\(stringsWord)"
inlineWord: "inline"
constructorWord: "Constructor"
definitionsWord: "Definitions"
encodedWord: "encoded"
cueWord: "Cue"
checkWord: "Check"
stringsWord: "Strings"

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for p in _primitives {p.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [negativeFixtureSet.constructorBodies.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
	}
}

issueManifest: {
	issue: _issue
	authority: _constructorAuthority
	workflow: [for w in _constructorWorkflow {order: w.order, id: w.id, instantiateAt: w.instantiateAt}]
	primitives: [for p in _primitives {p.out}]
	observed: _observed.out
	admissible: _admissible.out
	predicates: _predicates.out
	promotion: _promotion.out
	surfaces: _surfaces.out
	negativeFixtures: negativeFixtureSet
	validationPlan: _validation.out
	completionReportContract: _completion.out
}
