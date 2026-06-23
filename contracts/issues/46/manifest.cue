package issue46

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue46Manifest: close({
	issue: 46
	sequenceOrder: 4
	previousIssue: 50
	encodedSequence: [48, 49, 50, 46, 47, 51]
	title: "Functionized Codex crate/schema primitive-pattern-constructor kit"
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	manifestPath: "contracts/issues/46/manifest.cue"
	normalizedPath: "contracts/issues/46/normalized.cue"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	inlineConstructorDefinitions: false
	generatedArtifactsAreAuthority: false
	constructorKit: {
		target: "codex-crate-schema"
		functionized: true
		primitives: ["crate", "schema", "primitive-pattern", "constructor"]
		authority: "contracts/meta/impl"
	}
})

validBaseline: #Issue46Manifest

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#CodexPrimitiveConstructorKitManifest"
			role: "closed functionized Codex crate/schema primitive-pattern-constructor kit surface"
			requiredFields: ["issue", "constructorKit"]
			constraints: [
				"constructor definitions remain in contracts/meta/impl",
				"issue surface carries constructor calls only",
			]
		}
	},
]

_observedSurface: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedCodexPrimitiveConstructorKitManifest"
		role: "broad observed Codex crate/schema primitive constructor kit payload"
		factFields: ["issue", "sequenceOrder", "previousIssue", "constructorKit", "inlineConstructorDefinitions"]
		constraints: ["may represent inline constructor definitions and wrong-sequence invalid states"]
	}
}

_admissibleSurface: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#CodexPrimitiveConstructorKitCandidate"
		role: "admissible functionized constructor kit manifest"
		observedSurface: _observedSurface.out.name
		requiredFields: ["issue", "sequenceOrder", "previousIssue", "constructorKit"]
		rejectedFields: ["inlineConstructorDefinitions"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#CodexPrimitiveConstructorKitPredicates"
		role: "derive constructor kit rejection predicates from observed fields"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		derivedPredicates: ["inlineConstructorDefinitions", "wrongSequenceOrder"]
		operatorSupplied: false
	}
}

_promotionCandidate: impl.#MakePromotionCandidate & {
	in: {
		name: "#CodexPrimitiveConstructorKitPromotionCandidate"
		role: "closed promotion candidate for Codex primitive constructor kit manifests"
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
		admissible: [_admissibleSurface.out.name, "#Issue46Manifest"]
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
			name: "inlineConstructorDefinitions"
			violates: "constructor authority boundary"
			refusal: "constructor bodies must stay in contracts/meta/impl"
			input: {
				issue: 46
				sequenceOrder: 4
				previousIssue: 50
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Functionized Codex crate/schema primitive-pattern-constructor kit"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/46/manifest.cue"
				normalizedPath: "contracts/issues/46/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				inlineConstructorDefinitions: true
				generatedArtifactsAreAuthority: false
				constructorKit: validBaseline.constructorKit
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "wrongSequenceOrder"
			violates: "encoded sequence order"
			refusal: "issue 46 must follow issue 50 in this regenerated sequence"
			input: {
				issue: 46
				sequenceOrder: 5
				previousIssue: 50
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Functionized Codex crate/schema primitive-pattern-constructor kit"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/46/manifest.cue"
				normalizedPath: "contracts/issues/46/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				inlineConstructorDefinitions: false
				generatedArtifactsAreAuthority: false
				constructorKit: validBaseline.constructorKit
			}
		}
	},
]

negativeFixtures: {
	inlineConstructorDefinitions: _negativeFixtures[0].out
	wrongSequenceOrder:           _negativeFixtures[1].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/46"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["inlineConstructorDefinitions", "wrongSequenceOrder"]
		checkFile: "./contracts/issues/46/checks"
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
		fixtures: [negativeFixtures.inlineConstructorDefinitions.id, negativeFixtures.wrongSequenceOrder.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["constructor outputs", "bottom check failures", "forbidden-pattern scan"]
	}
}
