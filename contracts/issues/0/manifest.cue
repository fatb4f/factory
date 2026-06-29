package issue0

import impl "github.com/fatb4f/factory/contracts/meta"

_sliceID:     "factory.meta-generated-contract-compliance-hardening"
_issueNumber: 0
_title:       "factory: harden generated contract compliance validation"
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
			role: "issue-local contract slice for meta compliance hardening"
			requiredFields: [
				"sliceID",
				"issueNumber",
				"parentAuthority",
				"usesMetaConstructors",
				"usesBottomCheckProof",
			]
			constraints: [
				"contracts/meta owns constructor and compliance rules",
				"generator projections remain evidence only",
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
			role: "observed issue-local evidence for compliance hardening"
			factFields: [
				"sliceID",
				"issueNumber",
				"parentAuthority",
				"usesMetaConstructors",
				"usesBottomCheckProof",
				"generatedArtifactsAreAuthority",
			]
			constraints: ["observed facts may include rejected projection claims"]
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:            "AdmissibleGeneratedComplianceSlice"
			role:            "issue-local admissible surface for compliance hardening"
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
			role:              "derived predicates for issue-local compliance hardening"
			observedSurface:   "ObservedGeneratedComplianceSlice"
			admissibleSurface: "AdmissibleGeneratedComplianceSlice"
			derivedPredicates: [
				"meta-constructors-used",
				"bottom-proof-used",
				"generator-projections-evidence-only",
			]
			constraints: ["predicate truth derives from manifest and checks structure"]
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
				"generator-projections-evidence-only",
			]
			admissibilityEvidence: [
				"cue vet ./contracts/meta",
				"cue export ./contracts/meta -e generatedContractCompliance",
				"cue vet ./contracts/plugin-bundle/template",
				"cue export ./contracts/issues/0 -e normalizedIssueManifest",
			]
			constraints: ["all contract rules are repo-local CUE"]
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
			violates: "generator projection promoted past evidence"
			refusal:  "keep projection output outside contract rules"
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
			violates: "validator commands depend on retired issue checks"
			refusal:  "use parent validator checks"
			input: {staleIssueLocalChecks: true}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "externalLookupAccepted"
			violates: "validator commands depend on outside lookup"
			refusal:  "use repo-local CUE"
			input: {externalLookupAuthority: true}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "rootedPathAccepted"
			violates: "scaffold output path starts at filesystem root"
			refusal:  "use a repo-relative output path"
			input: {path: "/contracts/issues/0"}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "parentTraversalAccepted"
			violates: "scaffold output path escapes target root"
			refusal:  "keep output under the target root"
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
		checkFile:    "./contracts/issues/0/checks"
		checkSurface: "_negativeBottomChecks"
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
			"pluginBundleTemplateCompliance",
			"pluginBundleTemplateContractMetaCompliance",
		]
		fixtures: [for item in _negativeFixtures {item.out.id}]
		checks: [for item in _bottomCheckPlans {item.out.name}]
		commands: _validation.out.commands
		evidence: [
			"contracts/meta constructor and validator rules",
			"plugin-bundle template compliance exports",
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
