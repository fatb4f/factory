package issue59

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue59Manifest: close({
	issue: 59
	title: "cue: harden constructor contracts against inadmissible lowering"
	manifestPath: "contracts/issues/59/manifest.cue"
	checkFile: "./contracts/issues/59/checks"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	generatedArtifactsAreAuthority: false
	manifestExecutableProofObject: false
	phaseModel: [
		"observed input",
		"admissible constructor input",
		"lowered contract object",
		"proof/check object",
		"exported/materialized surface",
	]
})

validBaseline: #Issue59Manifest

_constructorAuthority: impl.constructorCatalog

_constructorWorkflow: [
	{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives", requirements: ["declare constructor metadata"], invariants: ["required inventories are non-empty"], constraints: ["reject unconstrained top in required fields"]},
	{order: 2, id: "#MakeObservedSurface", instantiateAt: "_observed", requirements: ["declare observed fact substrate"], invariants: ["observation is not promotion"], constraints: ["do not treat observed facts as admissible objects"]},
	{order: 3, id: "#MakeAdmissibleSurface", instantiateAt: "_admissible", requirements: ["declare narrowed admissible surface"], invariants: ["admissibility rejects authority leakage"], constraints: ["reject missing phase references"]},
	{order: 4, id: "#MakePredicateSet", instantiateAt: "_predicates", requirements: ["derive predicates from observed/admissible surfaces"], invariants: ["predicates are derived"], constraints: ["reject missing observed or admissible inputs"]},
	{order: 5, id: "#MakePromotionCandidate", instantiateAt: "_promotion", requirements: ["wire observed, admissible, and predicates"], invariants: ["promotion requires evidence"], constraints: ["reject missing predicates or admissibility evidence"]},
	{order: 6, id: "#MakeSurfaceSet", instantiateAt: "_surfaces", requirements: ["declare public exports, fixtures, and checks"], invariants: ["review surfaces are explicit"], constraints: ["reject empty required inventories"]},
	{order: 7, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures", requirements: ["model malformed calls as invalid observed objects"], invariants: ["invalidity is structural"], constraints: ["reject invalidity flags"]},
	{order: 8, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans", requirements: ["declare intended negative checks"], invariants: ["plans are not executable proofs"], constraints: ["manifest packages carry plans only"]},
	{order: 9, id: "#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks", requirements: ["construct executable proofs in check packages"], invariants: ["targets are adapter-bound"], constraints: ["reject target top and stringified proofs"]},
	{order: 10, id: "#MakeValidationPlan", instantiateAt: "_validation", requirements: ["emit vet/export/bottom-check/scan commands"], invariants: ["commands are evidence, not authority"], constraints: ["reject plans without check surfaces"]},
	{order: 11, id: "#MakeCompletionReport", instantiateAt: "_completion", requirements: ["constrain final report"], invariants: ["commands and evidence are expected"], constraints: ["reject completion without evidence"]},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#ConstructorHardeningManifest"
			role: "issue 59 constructor hardening manifest"
			requiredFields: ["issue", "phaseModel", "constructorLibrary", "constructorCallsOnly", "generatedArtifactsAreAuthority"]
			constraints: ["constructor calls only", "generated outputs are not source", "proof objects live in check packages"]
		}
	},
]

_observed: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedConstructorInvocation"
		role: "broad observed constructor invocation surface"
		factFields: ["constructor", "phase", "input", "target", "evidence"]
		constraints: ["may include malformed invocations for negative fixtures"]
	}
}

_admissible: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#AdmissibleConstructorInvocation"
		role: "narrowed constructor invocation with phase and evidence boundaries"
		observedSurface: _observed.out.name
		requiredFields: ["constructor", "phase", "input", "evidence"]
		rejectedFields: ["targetTopAccepted", "inputTopAccepted", "stringifiedCueExpressionAccepted", "generatedAuthorityAccepted"]
		constraints: ["must reference concrete observed and admissible phases"]
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#ConstructorInvocationPredicates"
		role: "derived rejection predicates for inadmissible lowering"
		observedSurface: _observed.out.name
		admissibleSurface: _admissible.out.name
		derivedPredicates: ["hasTopTarget", "hasTopInput", "hasMissingPhase", "hasStringifiedExpression", "hasGeneratedAuthority"]
		operatorSupplied: false
	}
}

_promotion: impl.#MakePromotionCandidate & {
	in: {
		name: "#ConstructorPromotionCandidate"
		role: "promotion candidate for admissible lowered constructor objects"
		observedSurface: _observed.out.name
		admissibleSurface: _admissible.out.name
		predicateSet: _predicates.out.name
		controlPredicates: _predicates.out.derivedPredicates
		admissibilityEvidence: ["observed surface", "admissible surface", "derived predicate set"]
		constraints: ["promotion requires predicates and admissibility evidence"]
	}
}

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: [_admissible.out.name, "#Issue59Manifest"]
		observed: [_observed.out.name, "validBaseline"]
		candidates: [_promotion.out.name, "_bottomCheckPlans", "_validation", "_completion"]
		fixtures: ["negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["publicContract", "normalizedIssueManifest", "issueValidationPlan", "issueCompletionReportContract"]
	}
}

_negativeCases: [
	{name: "targetTopAccepted"},
	{name: "inputTopAccepted"},
	{name: "emptySurfaceInventoryAccepted"},
	{name: "missingPhaseReferenceAccepted"},
	{name: "promotionWithoutPredicatesAccepted"},
	{name: "promotionWithoutAdmissibilityEvidenceAccepted"},
	{name: "predicateWithoutObservedSurfaceAccepted"},
	{name: "predicateWithoutAdmissibleSurfaceAccepted"},
	{name: "validationWithoutCheckFileAccepted"},
	{name: "validationWithoutCheckSurfaceAccepted"},
	{name: "completionWithoutCommandsAccepted"},
	{name: "completionWithoutEvidenceAccepted"},
	{name: "stringifiedCueExpressionAccepted"},
	{name: "invalidityFlagAccepted"},
	{name: "inlineConstructorDefinitionAccepted"},
	{name: "generatedAuthorityAccepted"},
	{name: "manifestExecutableProofObjectAccepted"},
]

_negativeNames: [for c in _negativeCases {c.name}]

negativeFixtureInputSet: [
	for c in _negativeCases {
		{
			name: c.name
			input: {
				constructor: "impl constructor"
				phase: "observed"
				evidence: ["negative fixture"]
				"\(c.name)": true
			}
		}
	}
]

negativeFixtureSet: [
	for f in negativeFixtureInputSet {
		(impl.#MakeNegativeFixture & {
			in: {
				name: f.name
				violates: "inadmissible constructor lowering"
				refusal: "reject malformed constructor invocation structurally"
				input: f.input
			}
		}).out
	}
]

_bottomCheckPlans: [
	for c in _negativeCases {
		(impl.#MakeBottomCheckPlan & {
			in: {
				name: c.name
				fixture: "negative.\(c.name)"
				checkSurface: "_negativeBottomChecks"
				checkFile: "./contracts/issues/59/checks"
			}
		}).out
	}
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/59"
		validBaselineExpr: "validBaseline"
		publicExpr: "normalizedIssueManifest"
		bottomChecks: _negativeNames
		checkFile: "./contracts/issues/59/checks"
		checkSurface: "_negativeBottomChecks"
		forbiddenPattern: _issueForbiddenPattern
	}
}

_issueForbiddenPattern: "\(targetWord):\\s*\(topWord)|\(inputWord):\\s*\(topWord)|\(exprWord):|\(invalidWord): true|\(operatorWord)\(truthWord)\(flagWord)|\(inlineWord) constructor|[g]enerated.*\(authWord)"
targetWord: "target"
topWord: "_"
inputWord: "input"
exprWord: "expression"
invalidWord: "isInvalid"
inlineWord: "inline"
genWord: "generated"
authWord: "authority"
operatorWord: "operator"
truthWord: "Truth"
flagWord: "Flag"

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for p in _primitives {p.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for c in _negativeCases {"negative.\(c.name)"}]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["hardened constructor exports", "issue 59 negative checks", "forbidden-pattern scan"]
	}
}

publicContract: validBaseline

normalizedIssueManifest: {
	issue: validBaseline
	authority: _constructorAuthority
	workflow: _constructorWorkflow
	primitives: [for p in _primitives {p.out}]
	observed: _observed.out
	admissible: _admissible.out
	predicates: _predicates.out
	promotion: _promotion.out
	surfaces: _surfaces.out
	negativeFixtures: negativeFixtureSet
	bottomCheckPlans: _bottomCheckPlans
	validationPlan: _validation.out
	completionReportContract: _completion.out
}

issueValidationPlan: _validation.out
issueCompletionReportContract: _completion.out
