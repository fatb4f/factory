package issue49

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue49Manifest: close({
	issue: 49
	sequenceOrder: 2
	previousIssue: 48
	encodedSequence: [48, 49, 50, 46, 47, 51]
	title: "Alpha channel policy and concrete alpha resolution lock slice"
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	manifestPath: "contracts/issues/49/manifest.cue"
	normalizedPath: "contracts/issues/49/normalized.cue"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	generatedArtifactsAreAuthority: false
	alphaPolicy: {
		channel: "alpha"
		refs: ["main", "alpha-latest"]
		resolutionMode: "concrete-lock"
		requiresConcreteVersion: true
		allowsFloatingRuntimeResolution: false
	}
	alphaResolutionLock: {
		surface: "alpha-resolution-lock"
		lockedBy: "CUE contract"
		materializedBy: "generated projection only"
	}
})

validBaseline: #Issue49Manifest

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#AlphaResolutionLockManifest"
			role: "closed alpha channel policy and concrete resolution lock surface"
			requiredFields: ["issue", "alphaPolicy", "alphaResolutionLock"]
			constraints: [
				"alpha-latest may be observed but concrete lock state must be explicit",
				"runtime floating resolution is rejected",
			]
		}
	},
]

_observedSurface: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedAlphaResolutionLockManifest"
		role: "broad observed alpha channel policy and resolution lock payload"
		factFields: ["issue", "sequenceOrder", "previousIssue", "alphaPolicy", "alphaResolutionLock"]
		constraints: ["may represent floating alpha resolution and wrong-sequence invalid states"]
	}
}

_admissibleSurface: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#AlphaResolutionLockCandidate"
		role: "admissible alpha channel policy with concrete resolution lock"
		observedSurface: _observedSurface.out.name
		requiredFields: ["issue", "sequenceOrder", "previousIssue", "alphaPolicy", "alphaResolutionLock"]
		rejectedFields: ["allowsFloatingRuntimeResolution"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#AlphaResolutionLockPredicates"
		role: "derive alpha lock rejection predicates from observed fields"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		derivedPredicates: ["floatingAlphaResolution", "wrongSequenceOrder"]
		operatorSupplied: false
	}
}

_promotionCandidate: impl.#MakePromotionCandidate & {
	in: {
		name: "#AlphaResolutionLockPromotionCandidate"
		role: "closed promotion candidate for alpha resolution lock manifests"
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
		admissible: [_admissibleSurface.out.name, "#Issue49Manifest"]
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
			name: "floatingAlphaResolution"
			violates: "concrete alpha lock"
			refusal: "alpha resolution must be concrete before runtime use"
			input: {
				issue: 49
				sequenceOrder: 2
				previousIssue: 48
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Alpha channel policy and concrete alpha resolution lock slice"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/49/manifest.cue"
				normalizedPath: "contracts/issues/49/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				alphaPolicy: {
					channel: "alpha"
					refs: ["main", "alpha-latest"]
					resolutionMode: "concrete-lock"
					requiresConcreteVersion: true
					allowsFloatingRuntimeResolution: true
				}
				alphaResolutionLock: validBaseline.alphaResolutionLock
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "wrongSequenceOrder"
			violates: "encoded sequence order"
			refusal: "issue 49 must follow the sprint umbrella"
			input: {
				issue: 49
				sequenceOrder: 3
				previousIssue: 48
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Alpha channel policy and concrete alpha resolution lock slice"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/49/manifest.cue"
				normalizedPath: "contracts/issues/49/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				alphaPolicy: validBaseline.alphaPolicy
				alphaResolutionLock: validBaseline.alphaResolutionLock
			}
		}
	},
]

negativeFixtures: {
	floatingAlphaResolution: _negativeFixtures[0].out
	wrongSequenceOrder:      _negativeFixtures[1].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/49"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["floatingAlphaResolution", "wrongSequenceOrder"]
		checkFile: "./contracts/issues/49/checks"
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
		fixtures: [negativeFixtures.floatingAlphaResolution.id, negativeFixtures.wrongSequenceOrder.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["constructor outputs", "bottom check failures", "forbidden-pattern scan"]
	}
}
