package issue47

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue47Manifest: close({
	issue: 47
	sequenceOrder: 5
	previousIssue: 46
	encodedSequence: [48, 49, 50, 46, 47, 51]
	title: "A2A-first worker adapter constructors for Codex crate/schema targets"
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	manifestPath: "contracts/issues/47/manifest.cue"
	normalizedPath: "contracts/issues/47/normalized.cue"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	generatedArtifactsAreAuthority: false
	workerAdapterConstructors: {
		targets: ["codex-crate", "codex-schema"]
		preferredAdapter: "a2a"
		a2aFirst: true
		fallbackMayDefineAuthority: false
		routeLocalContextOnly: true
	}
})

validBaseline: #Issue47Manifest

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#A2AWorkerAdapterConstructorManifest"
			role: "closed A2A-first worker adapter constructor surface for Codex crate/schema targets"
			requiredFields: ["issue", "workerAdapterConstructors"]
			constraints: [
				"A2A is the preferred worker adapter",
				"fallback adapters cannot become semantic authority",
			]
		}
	},
]

_observedSurface: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedA2AWorkerAdapterConstructorManifest"
		role: "broad observed A2A-first worker adapter constructor payload"
		factFields: ["issue", "sequenceOrder", "previousIssue", "workerAdapterConstructors"]
		constraints: ["may represent fallback authority and wrong-sequence invalid states"]
	}
}

_admissibleSurface: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#A2AWorkerAdapterConstructorCandidate"
		role: "admissible A2A-first worker adapter constructor manifest"
		observedSurface: _observedSurface.out.name
		requiredFields: ["issue", "sequenceOrder", "previousIssue", "workerAdapterConstructors"]
		rejectedFields: ["fallbackMayDefineAuthority"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#A2AWorkerAdapterConstructorPredicates"
		role: "derive A2A adapter constructor rejection predicates from observed fields"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		derivedPredicates: ["fallbackAuthority", "wrongSequenceOrder"]
		operatorSupplied: false
	}
}

_promotionCandidate: impl.#MakePromotionCandidate & {
	in: {
		name: "#A2AWorkerAdapterConstructorPromotionCandidate"
		role: "closed promotion candidate for A2A-first adapter constructor manifests"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		predicateSet: _predicates.out.name
		controlPredicates: _predicates.out.derivedPredicates
		admissibilityEvidence: ["observed surface", "admissible surface", "derived predicates"]
		closed: true
	}
}

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: [_admissibleSurface.out.name, "#Issue47Manifest"]
		observed: [_observedSurface.out.name, "validBaseline"]
		candidates: [_promotionCandidate.out.name, "_primitives", "_surfaces", "_negativeFixtures", "_validation", "_completion"]
		fixtures: ["negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["publicContract", "validationPlan", "completionReportContract"]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "fallbackAuthority"
			violates: "A2A-first adapter boundary"
			refusal: "fallback adapters may execute transport only and cannot define authority"
			input: {
				issue: 47
				sequenceOrder: 5
				previousIssue: 46
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "A2A-first worker adapter constructors for Codex crate/schema targets"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/47/manifest.cue"
				normalizedPath: "contracts/issues/47/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				workerAdapterConstructors: {
					targets: ["codex-crate", "codex-schema"]
					preferredAdapter: "a2a"
					a2aFirst: true
					fallbackMayDefineAuthority: true
					routeLocalContextOnly: true
				}
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "wrongSequenceOrder"
			violates: "encoded sequence order"
			refusal: "issue 47 must follow the constructor kit slice"
			input: {
				issue: 47
				sequenceOrder: 6
				previousIssue: 46
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "A2A-first worker adapter constructors for Codex crate/schema targets"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/47/manifest.cue"
				normalizedPath: "contracts/issues/47/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				workerAdapterConstructors: validBaseline.workerAdapterConstructors
			}
		}
	},
]

negativeFixtures: {
	fallbackAuthority: _negativeFixtures[0].out
	wrongSequenceOrder: _negativeFixtures[1].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/47"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["fallbackAuthority", "wrongSequenceOrder"]
		checkFile: "./contracts/issues/47/checks"
		checkSurface: "_negativeBottomChecks"
		forbiddenPattern: _issueForbiddenPattern
	}
}

_issueForbiddenPattern: "\(bottomWord)\(checkWord)\(surfaceWord)|\(expressionWord):|\(invalidWord): true"
bottomWord: "bottom"
checkWord: "Check"
surfaceWord: "Surface"
expressionWord: "expression"
invalidWord: "isInvalid"

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: [
			_observedSurface.out.name,
			_admissibleSurface.out.name,
			_predicates.out.name,
			_promotionCandidate.out.name,
			"publicContract",
			"validationPlan",
			"completionReportContract",
		]
		fixtures: [negativeFixtures.fallbackAuthority.id, negativeFixtures.wrongSequenceOrder.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["constructor outputs", "bottom check failures", "forbidden-pattern scan"]
	}
}
