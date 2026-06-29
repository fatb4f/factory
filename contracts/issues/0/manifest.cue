package issue0

import impl "github.com/fatb4f/factory/contracts/meta"

_sliceID:     "factory.meta-generated-contract-compliance"
_issueNumber: 0
_title:       "factory: add generated contract compliance surface"
_root:        "contracts/issues/0"

#IssueGeneratedComplianceSlice: close({
	sliceID:                         string & !=""
	issueNumber:                     int
	parentAuthority:                 "contracts/meta"
	generatedArtifactsAreAuthority?: false
	usesMetaConstructors:            true
	usesBottomCheckProof:            true
})

_workflow: [
	for step in impl.constructorPipeline {
		order:         step.order
		id:            step.id
		instantiateAt: step.instantiateAt
	},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#IssueGeneratedComplianceSlice"
			role: "issue-local contract slice for meta generated compliance"
			requiredFields: [
				"sliceID",
				"issueNumber",
				"parentAuthority",
				"usesMetaConstructors",
				"usesBottomCheckProof",
			]
			constraints: [
				"contracts/meta owns constructor and compliance authority",
				"generated projections remain evidence only",
				"child scaffold outputs stay repo-relative",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name: "ObservedGeneratedComplianceSlice"
			role: "observed issue-local evidence for generated contract compliance"
			factFields: [
				"sliceID",
				"issueNumber",
				"parentAuthority",
				"usesMetaConstructors",
				"usesBottomCheckProof",
				"generatedArtifactsAreAuthority",
			]
			constraints: ["observed facts may include rejected generated projection claims"]
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:            "AdmissibleGeneratedComplianceSlice"
			role:            "issue-local admissible surface for generated contract compliance"
			observedSurface: "ObservedGeneratedComplianceSlice"
			requiredFields: [
				"sliceID",
				"issueNumber",
				"parentAuthority",
				"usesMetaConstructors",
				"usesBottomCheckProof",
			]
			rejectedFields: ["generatedArtifactsAreAuthority"]
			constraints: [
				"meta constructors are imported from github.com/fatb4f/factory/contracts/meta",
				"checks packages construct executable proofs with #MakeBottomCheckProof",
			]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name:              "#GeneratedCompliancePredicates"
			role:              "derived predicates for issue-local generated compliance"
			observedSurface:   "ObservedGeneratedComplianceSlice"
			admissibleSurface: "AdmissibleGeneratedComplianceSlice"
			derivedPredicates: [
				"meta-constructors-used",
				"bottom-proof-used",
				"generated-projections-evidence-only",
			]
			constraints: ["predicate truth derives from the manifest and checks structure"]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name:              "#GeneratedCompliancePromotionCandidate"
			role:              "promotion candidate for the issue-local compliance slice"
			observedSurface:   "ObservedGeneratedComplianceSlice"
			admissibleSurface: "AdmissibleGeneratedComplianceSlice"
			predicateSet:      "#GeneratedCompliancePredicates"
			controlPredicates: [
				"meta-constructors-used",
				"bottom-proof-used",
				"generated-projections-evidence-only",
			]
			admissibilityEvidence: [
				"cue vet ./contracts/meta",
				"cue export ./contracts/meta -e generatedContractCompliance",
				"cue vet ./contracts/plugin-bundle/template",
				"cue export ./contracts/issues/0 -e normalizedIssueManifest",
			]
			constraints: ["all authority is repo-local CUE"]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["AdmissibleGeneratedComplianceSlice"]
		observed: ["ObservedGeneratedComplianceSlice"]
		candidates: ["#GeneratedCompliancePromotionCandidate"]
		fixtures: [
			"negative.generatedArtifactsAuthorityAccepted",
			"negative.staleLocalCheckAccepted",
			"negative.externalLookupAccepted",
			"negative.rootedPathAccepted",
			"negative.parentTraversalAccepted",
		]
		checks: [
			"_negativeBottomChecks.generatedArtifactsAuthorityAccepted",
			"_negativeBottomChecks.staleLocalCheckAccepted",
			"_negativeBottomChecks.externalLookupAccepted",
			"_negativeBottomChecks.rootedPathAccepted",
			"_negativeBottomChecks.parentTraversalAccepted",
		]
		publicExports: [
			"normalizedIssueManifest",
			"issueValidationPlan",
			"issueCompletionReportContract",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name:     "generatedArtifactsAuthorityAccepted"
			violates: "generated projections are evidence only"
			refusal:  "keep projections from generator output outside authority"
			input: {
				sliceID:                        _sliceID
				issueNumber:                    _issueNumber
				parentAuthority:                "contracts/meta"
				usesMetaConstructors:           true
				usesBottomCheckProof:           true
				generatedArtifactsAreAuthority: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "staleLocalCheckAccepted"
			violates: "validator commands must not depend on old issue-local checks"
			refusal:  "use parent validator checks instead"
			input: {staleIssueLocalChecks: true}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "externalLookupAccepted"
			violates: "validation authority is repo-local CUE"
			refusal:  "remove outside lookup authority"
			input: {externalLookupAuthority: true}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "rootedPathAccepted"
			violates: "scaffold outputs must be repo-relative"
			refusal:  "use a repo-relative output path"
			input: {path: "/contracts/issues/0"}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "parentTraversalAccepted"
			violates: "scaffold outputs must remain below the target root"
			refusal:  "remove dot-dot path segments"
			input: {path: "../outside"}
		}
	},
]

_bottomCheckPlans: [
	for item in [
		{name: "generatedArtifactsAuthorityAccepted", fixture: _negativeFixtures[0].out.id},
		{name: "staleLocalCheckAccepted", fixture: _negativeFixtures[1].out.id},
		{name: "externalLookupAccepted", fixture: _negativeFixtures[2].out.id},
		{name: "rootedPathAccepted", fixture: _negativeFixtures[3].out.id},
		{name: "parentTraversalAccepted", fixture: _negativeFixtures[4].out.id},
	] {
		impl.#MakeBottomCheckPlan & {
			in: {
				name:         item.name
				fixture:      item.fixture
				checkSurface: "_negativeBottomChecks"
				checkFile:    "./contracts/issues/0/checks"
			}
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              _root
		validBaselineExpr: "normalizedIssueManifest"
		publicExpr:        "issueValidationPlan"
		bottomChecks: [for item in _bottomCheckPlans {item.out.name}]
		checkFile:        "./contracts/issues/0/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: "[t]arget:\\s*_|[i]nput:\\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority|O[O] inheritance|external lookup authorit[y]|parent traversa[l]|absolute pat[h]"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for item in _primitives {item.out.name}]
		surfaces: [
			_observed[0].out.name,
			_admissible[0].out.name,
			_promotion[0].out.name,
			"contractScaffoldGenerator",
			"contractScaffoldValidator",
			"generatedContractCompliance",
			"pluginBundleScaffoldGenerator",
			"pluginBundleScaffoldValidator",
		]
		fixtures: [for item in _negativeFixtures {item.out.id}]
		checks: [for item in _bottomCheckPlans {item.out.name}]
		commands: _validation.out.commands
		evidence: [
			"contracts/meta generator and validator constructors",
			"plugin-bundle template generator and validator surfaces",
			"issue-local bottom-check proof package",
		]
	}
}

normalizedIssueManifest: {
	issue: {
		id:     _sliceID
		number: _issueNumber
		title:  _title
	}
	workflow: _workflow
	primitives: [for item in _primitives {item.out}]
	observed: [for item in _observed {item.out}]
	admissible: [for item in _admissible {item.out}]
	predicates: [for item in _predicates {item.out}]
	promotion: [for item in _promotion {item.out}]
	surfaces: _surfaces.out
	negativeFixtures: [for item in _negativeFixtures {item.out}]
	bottomCheckPlans: [for item in _bottomCheckPlans {item.out}]
}

issueValidationPlan:           _validation.out
issueCompletionReportContract: _completion.out
