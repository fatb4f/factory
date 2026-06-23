package issue48

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue48Manifest: close({
	issue: 48
	sequenceOrder: 1
	encodedSequence: [48, 49, 50, 46, 47, 51]
	title: "Sprint umbrella, child graph, Codex adapter sprint control surface"
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	manifestPath: "contracts/issues/48/manifest.cue"
	normalizedPath: "contracts/issues/48/normalized.cue"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	generatedArtifactsAreAuthority: false
	sprintUmbrella: true
	childGraph: {
		parent: 48
		children: [49, 50, 46, 47, 51]
		edges: [
			{from: 48, to: 49, kind: "contains"},
			{from: 48, to: 50, kind: "contains"},
			{from: 48, to: 46, kind: "contains"},
			{from: 48, to: 47, kind: "contains"},
			{from: 48, to: 51, kind: "contains"},
		]
	}
	codexAdapterSprintControl: {
		surface: "codex-adapter-sprint-control"
		owns: ["sprint issue ordering", "child issue projection", "adapter control checklist"]
		doesNotOwn: ["runtime execution", "GitHub mutation", "generated artifact authority"]
	}
})

validBaseline: #Issue48Manifest

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#SprintUmbrellaManifest"
			role: "closed sprint umbrella and child graph surface for the encoded issue sequence"
			requiredFields: ["issue", "encodedSequence", "childGraph", "codexAdapterSprintControl"]
			constraints: [
				"issue 48 is the umbrella parent for 49, 50, 46, 47, and 51",
				"Codex adapter sprint control is declarative and not runtime authority",
			]
		}
	},
]

_observedSurface: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedSprintUmbrellaManifest"
		role: "broad observed sprint umbrella and Codex adapter sprint-control payload"
		factFields: ["issue", "sequenceOrder", "encodedSequence", "childGraph", "codexAdapterSprintControl"]
		constraints: ["may represent generated-as-authority and wrong-sequence invalid states"]
	}
}

_admissibleSurface: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#SprintUmbrellaCandidate"
		role: "admissible sprint umbrella manifest for the encoded issue sequence"
		observedSurface: _observedSurface.out.name
		requiredFields: ["issue", "sequenceOrder", "encodedSequence", "childGraph", "codexAdapterSprintControl"]
		rejectedFields: ["generatedArtifactsAreAuthority"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#SprintUmbrellaPredicates"
		role: "derive sprint umbrella rejection predicates from observed fields"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		derivedPredicates: ["generatedArtifactsAsAuthority", "wrongSequenceOrder"]
		operatorSupplied: false
	}
}

_promotionCandidate: impl.#MakePromotionCandidate & {
	in: {
		name: "#SprintUmbrellaPromotionCandidate"
		role: "closed promotion candidate for sprint umbrella issue manifests"
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
		admissible: [_admissibleSurface.out.name, "#Issue48Manifest"]
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
			name: "generatedAsAuthority"
			violates: "generated-output boundary"
			refusal: "generated artifacts are sprint projection outputs, not source authority"
			input: {
				issue: 48
				sequenceOrder: 1
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Sprint umbrella, child graph, Codex adapter sprint control surface"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/48/manifest.cue"
				normalizedPath: "contracts/issues/48/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: true
				sprintUmbrella: true
				childGraph: validBaseline.childGraph
				codexAdapterSprintControl: validBaseline.codexAdapterSprintControl
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "wrongSequenceOrder"
			violates: "encoded sequence order"
			refusal: "issue 48 must be the first regenerated sprint surface"
			input: {
				issue: 48
				sequenceOrder: 2
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Sprint umbrella, child graph, Codex adapter sprint control surface"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/48/manifest.cue"
				normalizedPath: "contracts/issues/48/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				sprintUmbrella: true
				childGraph: validBaseline.childGraph
				codexAdapterSprintControl: validBaseline.codexAdapterSprintControl
			}
		}
	},
]

negativeFixtures: {
	generatedAsAuthority: _negativeFixtures[0].out
	wrongSequenceOrder:   _negativeFixtures[1].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/48"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["generatedAsAuthority", "wrongSequenceOrder"]
		checkFile: "./contracts/issues/48/checks"
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
		fixtures: [negativeFixtures.generatedAsAuthority.id, negativeFixtures.wrongSequenceOrder.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["constructor outputs", "bottom check failures", "forbidden-pattern scan"]
	}
}
