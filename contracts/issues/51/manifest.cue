package issue51

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue51Manifest: close({
	issue: 51
	sequenceOrder: 6
	previousIssue: 47
	encodedSequence: [48, 49, 50, 46, 47, 51]
	title: "GitHub Projects v2 sprint-tracking projection"
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	manifestPath: "contracts/issues/51/manifest.cue"
	normalizedPath: "contracts/issues/51/normalized.cue"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	generatedArtifactsAreAuthority: false
	projectsV2Projection: {
		surface: "github-projects-v2-sprint-tracking"
		projectionOnly: true
		mutationAuthority: false
		tracks: [48, 49, 50, 46, 47, 51]
		fields: ["sprint", "issue", "sequenceOrder", "status", "surface"]
	}
})

validBaseline: #Issue51Manifest

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#ProjectsV2SprintTrackingManifest"
			role: "closed GitHub Projects v2 sprint-tracking projection surface"
			requiredFields: ["issue", "projectsV2Projection"]
			constraints: [
				"Projects v2 data is a projection of source issue surfaces",
				"project mutation authority stays outside this contract",
			]
		}
	},
]

_observedSurface: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedProjectsV2SprintTrackingManifest"
		role: "broad observed GitHub Projects v2 sprint-tracking projection payload"
		factFields: ["issue", "sequenceOrder", "previousIssue", "projectsV2Projection"]
		constraints: ["may represent project mutation authority and wrong-sequence invalid states"]
	}
}

_admissibleSurface: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#ProjectsV2SprintTrackingCandidate"
		role: "admissible projection-only Projects v2 sprint tracking manifest"
		observedSurface: _observedSurface.out.name
		requiredFields: ["issue", "sequenceOrder", "previousIssue", "projectsV2Projection"]
		rejectedFields: ["mutationAuthority"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#ProjectsV2SprintTrackingPredicates"
		role: "derive Projects v2 projection rejection predicates from observed fields"
		inputSurface: _observedSurface.out.name
		derivedPredicates: ["projectMutationAuthority", "wrongSequenceOrder"]
		operatorSupplied: false
	}
}

_promotionCandidate: impl.#MakePromotionCandidate & {
	in: {
		name: "#ProjectsV2SprintTrackingPromotionCandidate"
		role: "closed promotion candidate for Projects v2 sprint tracking manifests"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		predicateSet: _predicates.out.name
		controlPredicates: _predicates.out.derivedPredicates
		closed: true
	}
}

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: [_admissibleSurface.out.name, "#Issue51Manifest"]
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
			name: "projectMutationAuthority"
			violates: "projection-only boundary"
			refusal: "GitHub Projects v2 mutation authority is not owned by this projection"
			input: {
				issue: 51
				sequenceOrder: 6
				previousIssue: 47
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "GitHub Projects v2 sprint-tracking projection"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/51/manifest.cue"
				normalizedPath: "contracts/issues/51/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				projectsV2Projection: {
					surface: "github-projects-v2-sprint-tracking"
					projectionOnly: true
					mutationAuthority: true
					tracks: [48, 49, 50, 46, 47, 51]
					fields: ["sprint", "issue", "sequenceOrder", "status", "surface"]
				}
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "wrongSequenceOrder"
			violates: "encoded sequence order"
			refusal: "issue 51 must close the regenerated sequence"
			input: {
				issue: 51
				sequenceOrder: 5
				previousIssue: 47
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "GitHub Projects v2 sprint-tracking projection"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/51/manifest.cue"
				normalizedPath: "contracts/issues/51/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				projectsV2Projection: validBaseline.projectsV2Projection
			}
		}
	},
]

negativeFixtures: {
	projectMutationAuthority: _negativeFixtures[0].out
	wrongSequenceOrder:       _negativeFixtures[1].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/51"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["projectMutationAuthority", "wrongSequenceOrder"]
		checkFile: "./contracts/issues/51/checks"
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
		fixtures: [negativeFixtures.projectMutationAuthority.id, negativeFixtures.wrongSequenceOrder.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
	}
}
