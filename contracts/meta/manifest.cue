package meta

// source: contracts/meta/manifest.cue
#ConstructorOrderEntry: close({
	order:         int & >=1
	id:            #ConstructorID
	instantiateAt: string & !=""
})

#ConstructorAxis: close({
	kind: "constructor-axis"
	pipeline: [...#ConstructorOrderEntry] & [_, ...]
	invariant: string & !=""
})

_constructorAxis: #ConstructorAxis & {
	kind: "constructor-axis"
	pipeline: [
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
	invariant: "Constructor order defines instantiation sequence only; it does not define artifact authority."
}

constructorAxis:     _constructorAxis
constructorPipeline: _constructorAxis.pipeline

#AuthorityStratumID:
	"contract" |
	"assertions" |
	"fixtures" |
	"checks" |
	"evals"

#AuthorityStratumEntry: close({
	order:     int & >=1
	id:        #AuthorityStratumID
	role:      string & !=""
	authority: string & !=""
	accepts: [...string & !=""] | *[]
	rejects: [...string & !=""] | *[]
})

#AuthorityAxis: close({
	kind: "authority-axis"
	order: [...#AuthorityStratumID] & [_, ...]
	strata: [...#AuthorityStratumEntry] & [_, ...]
	invariant: string & !=""
})

_authorityAxis: #AuthorityAxis & {
	kind: "authority-axis"
	order: ["contract", "assertions", "fixtures", "checks", "evals"]
	strata: [
		{
			order:     1
			id:        "contract"
			role:      "Owns constructor signatures, descriptor shapes, invariants, and admissible boundaries."
			authority: "source-of-truth"
			accepts: ["constructor definitions", "descriptor contracts", "admissible surface definitions", "invariants"]
			rejects: ["generated artifacts as authority", "adapter outputs as contract definitions"]
		},
		{
			order:     2
			id:        "assertions"
			role:      "Binds expected properties over concrete contract instances."
			authority: "derived-from-contract"
			accepts: ["expected invariants", "instance-level obligations"]
			rejects: ["new constructor bodies", "schema drift"]
		},
		{
			order:     3
			id:        "fixtures"
			role:      "Provides positive and negative examples that probe contract boundaries."
			authority: "test-input"
			accepts: ["admissible examples", "inadmissible examples", "negative fixtures"]
			rejects: ["proof results", "authority promotion"]
		},
		{
			order:     4
			id:        "checks"
			role:      "Executes proof obligations against fixtures and adapter-bound targets."
			authority: "evidence-generator"
			accepts: ["bottom-check plans", "bottom-check proofs", "validation commands"]
			rejects: ["hand-written bottom sentinels as authority", "fixtures collapsing to top"]
		},
		{
			order:     5
			id:        "evals"
			role:      "Summarizes evidence from checks without becoming a source of truth."
			authority: "evidence-summary"
			accepts: ["completion reports", "review evidence", "publication summaries"]
			rejects: ["contract mutation", "schema authority"]
		},
	]
	invariant: "Authority rank is independent from constructor instantiation order."
}

authorityAxis:   _authorityAxis
authorityStrata: _authorityAxis.strata

#DualAxisShape: close({
	kind:            "meta-dual-axis-shape"
	constructorAxis: #ConstructorAxis
	authorityAxis:   #AuthorityAxis
	invariants: [...string & !=""] & [_, ...]
})

metaDualAxisShape: #DualAxisShape & {
	kind:            "meta-dual-axis-shape"
	constructorAxis: _constructorAxis
	authorityAxis:   _authorityAxis
	invariants: [
		"Constructor order and authority strata are separate axes.",
		"Constructor calls use meta.#MakeX & { in: {...} } according to constructor-specific signatures.",
		"String references bind constructor instances unless a constructor signature explicitly requires an embedded value.",
		"Checks generate proof artifacts from fixtures intersected with adapter-bound admissible targets.",
		"Evaluations and completion reports summarize validated evidence only.",
	]
}

// source: contracts/meta/manifest.cue
#BottomCheckPlanSpec: close({
	name:                 string & !=""
	fixture:              string & !=""
	checkSurface:         string & !=""
	checkFile:            string & !=""
	targetBoundByAdapter: true | *true
})

#BottomCheckPlan: close({
	kind:                 "bottom-check-plan"
	name:                 string & !=""
	fixture:              string & !=""
	checkSurface:         string & !=""
	checkFile:            string & !=""
	targetBoundByAdapter: true
})

#ProofInput: close({
	evidence: string & !=""
	value: {...}
})

#ProofTargetRef: close({
	name: string & !=""
	contract: close({
		evidence: string & !=""
		value: {...}
	})
})

#BottomCheckProofSpec: close({
	name:                                      string & !=""
	input:                                     #ProofInput
	target:                                    #ProofTargetRef
	expression?:                               false
	isInvalid?:                                false
	"\(operatorWord)\(truthWord)\(flagWord)"?: false
})

#MakeBottomCheckPlan: {
	in: #BottomCheckPlanSpec

	out: #BottomCheckPlan & {
		kind:                 "bottom-check-plan"
		name:                 in.name
		fixture:              in.fixture
		checkSurface:         in.checkSurface
		checkFile:            in.checkFile
		targetBoundByAdapter: in.targetBoundByAdapter
	}
}

#MakeBottomCheckProof: {
	in: #BottomCheckProofSpec

	out: {
		"\(in.name)": close({
			kind:           "bottom-check-proof"
			name:           in.name
			inputEvidence:  in.input.evidence
			targetName:     in.target.name
			targetEvidence: in.target.contract.evidence
			input:          in.input.value
			target:         in.target.contract.value
			proof:          in.input.value & in.target.contract.value
		})
	}
}

// Deprecated compatibility name for manifests that still need a plan-shaped
// constructor during migration. Executable checks must use #MakeBottomCheckProof.
#MakeBottomCheck: #MakeBottomCheckPlan

// source: contracts/meta/manifest.cue
#CompletionReportSpec: close({
	primitives: [...string & !=""] & [_, ...]
	surfaces: [...string & !=""] & [_, ...]
	fixtures: [...string & !=""] & [_, ...]
	checks: [...string & !=""] & [_, ...]
	commands: [...string & !=""] & [_, ...]
	evidence: [...string & !=""] & [_, ...]
})

#CompletionReportContract: close({
	kind: "completion-report-contract"
	requiredSections: [...string & !=""]
	expected: close({
		primitives: [...string & !=""]
		surfaces: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [...string & !=""]
		commands: [...string & !=""]
		evidence: [...string & !=""]
	})
})

#MakeCompletionReport: {
	in: #CompletionReportSpec

	out: #CompletionReportContract & {
		kind: "completion-report-contract"

		requiredSections: [
			"files changed",
			"primitives implemented",
			"surfaces implemented",
			"fixtures implemented",
			"bottom checks implemented",
			"commands run",
			"evidence",
			"final result",
		]

		expected: {
			primitives: in.primitives
			surfaces:   in.surfaces
			fixtures:   in.fixtures
			checks:     in.checks
			commands:   in.commands
			evidence:   in.evidence
		}
	}
}

// source: contracts/meta/manifest.cue
#ConstructorID:
	"#MakePrimitive" |
	"#MakeObservedSurface" |
	"#MakeAdmissibleSurface" |
	"#MakePredicateSet" |
	"#MakePromotionCandidate" |
	"#MakeSurfaceSet" |
	"#MakeNegativeFixture" |
	"#MakeBottomCheckPlan" |
	"#MakeBottomCheckProof" |
	"#MakeValidationPlan" |
	"#MakeCompletionReport" |
	"#ContractGenerator" |
	"#ContractValidator" |
	"#GeneratedContractCompliance"

#ConstructorCatalogEntry: close({
	id:      #ConstructorID
	file:    string & =~"^contracts/meta/.+\\.cue$"
	purpose: string & !=""
})

#ConstructorCatalog: close({
	kind:    "constructor-catalog"
	package: "meta"
	root:    "contracts/meta"
	axes: close({
		constructorOrder: "constructorAxis"
		authorityStrata:  "authorityAxis"
		shape:            "metaDualAxisShape"
	})
	constructors: [...#ConstructorCatalogEntry] & [_, ...]
	invariants: [...string & !=""] & [_, ...]
})

constructorCatalog: #ConstructorCatalog & {
	kind:    "constructor-catalog"
	package: "meta"
	root:    "contracts/meta"
	axes: {
		constructorOrder: "constructorAxis"
		authorityStrata:  "authorityAxis"
		shape:            "metaDualAxisShape"
	}
	constructors: [
		{
			id:      "#MakePrimitive"
			file:    "contracts/meta/manifest.cue"
			purpose: "Compress repeated primitive descriptions into a known metadata shape."
		},
		{
			id:      "#MakeObservedSurface"
			file:    "contracts/meta/manifest.cue"
			purpose: "Describe broad observed fact substrates that can carry valid and invalid states."
		},
		{
			id:      "#MakeAdmissibleSurface"
			file:    "contracts/meta/manifest.cue"
			purpose: "Describe narrow admissible surfaces that reject invalid structure."
		},
		{
			id:      "#MakePredicateSet"
			file:    "contracts/meta/manifest.cue"
			purpose: "Describe predicates derived from observed structure."
		},
		{
			id:      "#MakePromotionCandidate"
			file:    "contracts/meta/manifest.cue"
			purpose: "Describe closed promotion candidates wired to predicate control."
		},
		{
			id:      "#MakeSurfaceSet"
			file:    "contracts/meta/manifest.cue"
			purpose: "Declare expected admissible, observed, candidate, fixture, check, and export surfaces."
		},
		{
			id:      "#MakeNegativeFixture"
			file:    "contracts/meta/manifest.cue"
			purpose: "Make rejection cases first-class fixtures."
		},
		{
			id:      "#MakeBottomCheckPlan"
			file:    "contracts/meta/manifest.cue"
			purpose: "Declare intended negative checks in manifests without executable proof targets."
		},
		{
			id:      "#MakeBottomCheckProof"
			file:    "contracts/meta/manifest.cue"
			purpose: "Generate executable CUE intersections from check packages with adapter-bound targets."
		},
		{
			id:      "#MakeValidationPlan"
			file:    "contracts/meta/manifest.cue"
			purpose: "Generate deterministic validation command lists."
		},
		{
			id:      "#MakeCompletionReport"
			file:    "contracts/meta/manifest.cue"
			purpose: "Constrain completion reports into deterministic review evidence."
		},
		{
			id:      "#ContractGenerator"
			file:    "contracts/meta/manifest.cue"
			purpose: "Declare next-layer scaffold generation contracts without making generated files authoritative."
		},
		{
			id:      "#ContractValidator"
			file:    "contracts/meta/manifest.cue"
			purpose: "Declare parent-authority validation contracts for generated scaffold candidates."
		},
		{
			id:      "#GeneratedContractCompliance"
			file:    "contracts/meta/manifest.cue"
			purpose: "Bind one generator and one validator to required exports, constructor use, bottom checks, and evidence-only boundaries."
		},
	]
	invariants: [
		"Constructor definitions live in the repo-local meta package.",
		"Issue manifests carry constructor calls, not constructor bodies.",
		"CUE expressions remain CUE values, not stringified expression metadata.",
		"Negative checks are generated as intersections, not invalidity flags.",
		"Manifest packages carry bottom-check plans; check packages carry executable proof objects.",
		"Constructor order and authority strata are separate axes.",
		"Constructor catalog entries identify available constructors; constructorAxis orders their instantiation.",
		"AuthorityAxis ranks contract, assertions, fixtures, checks, and evals independently of constructor order.",
		"Go wrappers are deferred to transport and materialization.",
		"Generator contracts create candidates; validator contracts prove parent-authority compliance.",
		"Generated artifacts remain evidence only until admitted by repo-local CUE validation.",
	]
}

// source: contracts/meta/manifest.cue
_defaultForbiddenPattern: "\(bottomSurfaceToken)|\(cueExprToken)|\(invalidFlagToken)|\(truthFlagToken)|\(inlineCtorToken)|\(defaultFallbackToken)|\(topDisjunctionToken)|\(rawBottomToken)"

bottomSurfaceToken:   "bottom\(checkWord)Surface"
checkWord:            "Check"
cueExprToken:         "\(cueExprWord):"
cueExprWord:          "expression"
invalidFlagToken:     "\(invalidFlagWord): true"
invalidFlagWord:      "isInvalid"
truthFlagToken:       "operator\(truthFlagWord)"
truthFlagWord:        "TruthFlag"
inlineCtorToken:      "inline \(ctorWord) definition"
ctorWord:             "constructor"
defaultFallbackToken: "\\*\\("
pipeRegexToken:       "\\|"
topDisjunctionToken:  "\(pipeRegexToken) _"
rawBottomToken:       "_\\|_"

constructorLibraryBaseline: close({
	kind:    "constructor-library"
	catalog: constructorCatalog
	specs: [
		{
			name:        "#PrimitiveSpec"
			constructor: "#MakePrimitive"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#SurfaceSetSpec"
			constructor: "#MakeSurfaceSet"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#ObservedSurfaceSpec"
			constructor: "#MakeObservedSurface"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#AdmissibleSurfaceSpec"
			constructor: "#MakeAdmissibleSurface"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#PredicateSetSpec"
			constructor: "#MakePredicateSet"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#PromotionCandidateSpec"
			constructor: "#MakePromotionCandidate"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#NegativeFixtureSpec"
			constructor: "#MakeNegativeFixture"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#BottomCheckPlanSpec"
			constructor: "#MakeBottomCheckPlan"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#BottomCheckProofSpec"
			constructor: "#MakeBottomCheckProof"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#ValidationPlanSpec"
			constructor: "#MakeValidationPlan"
			file:        "contracts/meta/manifest.cue"
		},
		{
			name:        "#CompletionReportSpec"
			constructor: "#MakeCompletionReport"
			file:        "contracts/meta/manifest.cue"
		},
	]
	exports: [
		"constructorCatalog",
		"constructorAxis",
		"authorityAxis",
		"metaDualAxisShape",
		"constructorLibraryBaseline",
		"constructorManifestBaseline",
		"constructorValidationPlanBaseline",
		"constructorCompletionReportBaseline",
		"contractScaffoldGenerator",
		"contractScaffoldValidator",
		"generatedContractCompliance",
	]
})

constructorManifestBaseline: close({
	kind:           "constructor-manifest-baseline"
	authority:      constructorCatalog
	manifestPath:   "<contract-slice-path>/manifest.cue"
	normalizedPath: "<contract-slice-path>/normalized.cue"
	workflow: [
		"#MakePrimitive",
		"#MakeObservedSurface",
		"#MakeAdmissibleSurface",
		"#MakePredicateSet",
		"#MakePromotionCandidate",
		"#MakeSurfaceSet",
		"#MakeNegativeFixture",
		"#MakeBottomCheckPlan",
		"#MakeBottomCheckProof",
		"#MakeValidationPlan",
		"#MakeCompletionReport",
	]
	requirements: [
		"import repo-local constructors from contracts/meta",
		"carry constructor calls only",
		"carry bottom-check plans in manifest packages",
		"construct executable bottom proofs only in check packages",
		"construct executable bottom proofs through #MakeBottomCheckProof, without hand-written defaults, top fallbacks, invalidity flags, or expression strings",
		"keep target expansion, transport, and runtime execution outside constructor authority",
	]
})

constructorValidationPlanBaseline: (_baselineValidation & {
	in: {
		path:              "contracts/meta"
		validBaselineExpr: "constructorLibraryBaseline"
		publicExpr:        "constructorManifestBaseline"
		bottomChecks: [
			"stringifiedBottomCheckAccepted",
			"\(operatorWord)\(truthWord)\(flagWord)Accepted",
			"inlineConstructorDefinitionAccepted",
			"primitiveEmptyInventoryAccepted",
			"observedEmptyInventoryAccepted",
			"admissibleMissingObservedAccepted",
			"predicateMissingObservedAccepted",
			"promotionWithoutPredicatesAccepted",
			"promotionWithoutEvidenceAccepted",
			"surfaceSetEmptyInventoryAccepted",
			"negativeFixtureInvalidFlagAccepted",
			"bottomPlanMissingCheckSurfaceAccepted",
			"bottomProofTargetTopAccepted",
			"bottomProofInputTopAccepted",
			"validationMissingCheckSurfaceAccepted",
			"completionWithoutEvidenceAccepted",
			"generatedAuthorityAccepted",
			"manifestExecutableProofObjectAccepted",
			"evalAuthorityAccepted",
			"contractGeneratorMissingOutputAccepted",
			"contractValidatorAbsoluteTargetAccepted",
			"contractValidatorStaleLocalCheckAccepted",
			"generatedComplianceAuthorityAccepted",
		]
		checkFile:        "./contracts/meta/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: _defaultForbiddenPattern
	}
}).out

operatorWord: "operator"
truthWord:    "Truth"
flagWord:     "Flag"

_baselineValidation: #MakeValidationPlan

constructorCompletionReportBaseline: (_baselineCompletion & {
	in: {
		primitives: [for spec in constructorLibraryBaseline.specs {spec.name}]
		surfaces: [
			"constructorAxis",
			"authorityAxis",
			"metaDualAxisShape",
			"constructorLibraryBaseline",
			"constructorManifestBaseline",
			"constructorValidationPlanBaseline",
			"constructorCompletionReportBaseline",
			"contractScaffoldGenerator",
			"contractScaffoldValidator",
			"generatedContractCompliance",
		]
		fixtures: [
			"negative.stringifiedBottomCheckAccepted",
			"negative.\(operatorWord)\(truthWord)\(flagWord)Accepted",
			"negative.inlineConstructorDefinitionAccepted",
			"malformed.primitiveEmptyInventoryAccepted",
			"malformed.observedEmptyInventoryAccepted",
			"malformed.admissibleMissingObservedAccepted",
			"malformed.predicateMissingObservedAccepted",
			"malformed.promotionWithoutPredicatesAccepted",
			"malformed.promotionWithoutEvidenceAccepted",
			"malformed.surfaceSetEmptyInventoryAccepted",
			"malformed.negativeFixtureInvalidFlagAccepted",
			"malformed.bottomPlanMissingCheckSurfaceAccepted",
			"malformed.bottomProofTargetTopAccepted",
			"malformed.bottomProofInputTopAccepted",
			"malformed.validationMissingCheckSurfaceAccepted",
			"malformed.completionWithoutEvidenceAccepted",
			"negative.generatedAuthorityAccepted",
			"negative.manifestExecutableProofObjectAccepted",
			"negative.evalAuthorityAccepted",
			"malformed.contractGeneratorMissingOutputAccepted",
			"malformed.contractValidatorAbsoluteTargetAccepted",
			"malformed.contractValidatorStaleLocalCheckAccepted",
			"negative.generatedComplianceAuthorityAccepted",
		]
		checks:   constructorValidationPlanBaseline.commands
		commands: constructorValidationPlanBaseline.commands
		evidence: ["constructor catalog", "negative checks", "forbidden-pattern scan"]
	}
}).out

_baselineCompletion: #MakeCompletionReport

publicContract: constructorLibraryBaseline

// source: contracts/meta/manifest.cue
#NegativeFixtureSpec: close({
	name:     string & !=""
	violates: string & !=""
	refusal:  string & !=""
	input: {...}
	isInvalid?:                                false
	expression?:                               false
	"\(operatorWord)\(truthWord)\(flagWord)"?: false
	inlineConstructorDefinition?:              false
	generatedArtifactsAreAuthority?:           false
})

#NegativeFixtureDescriptor: close({
	kind:            "negative-fixture"
	id:              string & =~"^negative\\..+"
	violates:        string & !=""
	expectedRefusal: string & !=""
	input: {...}
	expectedBottom: true
})

#MakeNegativeFixture: {
	in: #NegativeFixtureSpec

	out: #NegativeFixtureDescriptor & {
		kind:            "negative-fixture"
		id:              "negative.\(in.name)"
		violates:        in.violates
		expectedRefusal: in.refusal
		input:           in.input
		expectedBottom:  true
	}
}

// source: contracts/meta/manifest.cue
#PredicateSetSpec: close({
	name:              string & !=""
	role:              string & !=""
	observedSurface:   string & !=""
	admissibleSurface: string & !=""
	derivedPredicates: [...string & !=""] & [_, ...]
	operatorSupplied: false | *false
	constraints: [...string & !=""] | *[]
	"\(operatorWord)\(truthWord)\(flagWord)"?: false
})

#PredicateSetDescriptor: close({
	kind:              "predicate-set"
	name:              string & !=""
	role:              string & !=""
	observedSurface:   string & !=""
	admissibleSurface: string & !=""
	derivedPredicates: [...string & !=""] & [_, ...]
	operatorSupplied: false
	constraints: [...string & !=""]
})

#MakePredicateSet: {
	in: #PredicateSetSpec

	out: #PredicateSetDescriptor & {
		kind:              "predicate-set"
		name:              in.name
		role:              in.role
		observedSurface:   in.observedSurface
		admissibleSurface: in.admissibleSurface
		derivedPredicates: in.derivedPredicates
		operatorSupplied:  in.operatorSupplied
		constraints:       in.constraints
	}
}

// source: contracts/meta/manifest.cue
#PrimitiveSpec: close({
	name: string & !=""
	role: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	constraints: [...string & !=""] | *[]
	closed:               bool | *true
	observedPhase?:       false
	admissiblePhase?:     false
	loweredObject?:       false
	proofObject?:         false
	materializedSurface?: false
})

#PrimitiveDescriptor: close({
	kind: "primitive-spec"
	name: string & !=""
	role: string & !=""
	requiredFields: [...string & !=""]
	constraints: [...string & !=""]
	closed: bool
})

#MakePrimitive: {
	in: #PrimitiveSpec

	out: #PrimitiveDescriptor & {
		kind:           "primitive-spec"
		name:           in.name
		role:           in.role
		requiredFields: in.requiredFields
		constraints:    in.constraints
		closed:         in.closed
	}
}

// source: contracts/meta/manifest.cue
#PromotionCandidateSpec: close({
	name:              string & !=""
	role:              string & !=""
	observedSurface:   string & !=""
	admissibleSurface: string & !=""
	predicateSet:      string & !=""
	controlPredicates: [...string & !=""] & [_, ...]
	admissibilityEvidence: [...string & !=""] & [_, ...]
	closed: true | *true
	constraints: [...string & !=""] | *[]
})

#PromotionCandidateDescriptor: close({
	kind:              "promotion-candidate"
	name:              string & !=""
	role:              string & !=""
	observedSurface:   string & !=""
	admissibleSurface: string & !=""
	predicateSet:      string & !=""
	controlPredicates: [...string & !=""] & [_, ...]
	admissibilityEvidence: [...string & !=""] & [_, ...]
	closed: true
	constraints: [...string & !=""]
})

#MakePromotionCandidate: {
	in: #PromotionCandidateSpec

	out: #PromotionCandidateDescriptor & {
		kind:                  "promotion-candidate"
		name:                  in.name
		role:                  in.role
		observedSurface:       in.observedSurface
		admissibleSurface:     in.admissibleSurface
		predicateSet:          in.predicateSet
		controlPredicates:     in.controlPredicates
		admissibilityEvidence: in.admissibilityEvidence
		closed:                in.closed
		constraints:           in.constraints
	}
}

// source: contracts/meta/manifest.cue
#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"
#ValidatorCommand:     string & !="" & !~"(^|\\s)/" & !~"(^|\\s|/)\\.\\.(/|\\s|$)" & !~"external lookup authority"

#ContractGenerator: close({
	kind:    "contract-generator"
	id:      string & !=""
	name:    id
	command: string & !=""
	inputs: [...string & !=""] & [_, ...]
	outputs: [...#RelativeContractPath] & [_, ...]
	invariants: [...string & !=""] & [_, ...]
	generatedArtifactsAreAuthority?: false
})

#ContractValidator: close({
	kind:       "contract-validator"
	id:         string & !=""
	name:       id
	target:     #RelativeContractPath
	targetPath: target
	commands: [...#ValidatorCommand] & [_, ...]
	negativeChecks: [...string & !=""] & [_, ...]
	forbiddenPattern: string & !=""
	rejects: [...string & !=""] & [_, ...]
	staleLocalChecks?:        false
	externalLookupAuthority?: false
	localOverrideEscapes?:    false
})

#GeneratedContractCompliance: close({
	kind:      "generated-contract-compliance"
	generator: #ContractGenerator
	validator: #ContractValidator
	requiredExports: [...string & !=""] & [_, ...]
	requiredConstructors: [...#ConstructorID] & [_, ...]
	mustUseConstructors:            true
	mustUseMakeBottomCheckProof:    true
	requiresBottomCheckProof:       true
	generatedArtifactsAreAuthority: false
	evidenceOnlyGeneratedArtifacts: true
	bindings: close({
		generatorName:   string & !=""
		validatorName:   string & !=""
		parentAuthority: "contracts/meta"
	})
})

contractScaffoldGenerator: #ContractGenerator & {
	kind:    "contract-generator"
	id:      "contractScaffoldGenerator"
	name:    "contractScaffoldGenerator"
	command: "contracts/meta/scripts/scaffold-contract-slice"
	inputs: [
		"slice-id",
		"title",
		"out",
		"force",
	]
	outputs: [
		"manifest.cue",
		"checks/manifest.cue",
	]
	invariants: [
		"contracts/meta remains constructor authority",
		"generated skeletons are scaffolds only",
		"manifest packages carry bottom-check plans only",
		"check packages carry executable bottom-check proofs only",
		"generated checks do not use default fallbacks, top fallbacks, invalidity flags, or expression strings",
		"generated outputs use repo-relative paths without parent traversal",
	]
}

contractScaffoldValidator: #ContractValidator & {
	kind:       "contract-validator"
	id:         "contractScaffoldValidator"
	name:       "contractScaffoldValidator"
	target:     "<contract-slice-path>"
	targetPath: "<contract-slice-path>"
	commands: [
		"cue vet ./<contract-slice-path>",
		"cue export ./<contract-slice-path> -e contractSliceManifest",
		"cue export ./<contract-slice-path> -e contractSliceValidationPlan",
		"cue export ./<contract-slice-path> -e contractSliceCompletionReport",
		"! cue export ./<contract-slice-path>/checks -e '_negativeBottomChecks.<name>'",
	]
	negativeChecks: [
		"generatedAuthorityAccepted",
		"externalLookupAccepted",
		"absolutePathAccepted",
		"parentTraversalAccepted",
	]
	forbiddenPattern: _defaultForbiddenPattern
	rejects: [
		"generated files treated as contract authority",
		"external lookup authority",
		"absolute generated scaffold paths",
		"parent traversal in generated scaffold paths",
		"local override escapes",
	]
}

generatedContractCompliance: #GeneratedContractCompliance & {
	kind:      "generated-contract-compliance"
	generator: contractScaffoldGenerator
	validator: contractScaffoldValidator
	requiredExports: [
		"contractSliceManifest",
		"contractSliceValidationPlan",
		"contractSliceCompletionReport",
	]
	requiredConstructors: [
		"#MakePrimitive",
		"#MakeObservedSurface",
		"#MakeAdmissibleSurface",
		"#MakePredicateSet",
		"#MakePromotionCandidate",
		"#MakeSurfaceSet",
		"#MakeNegativeFixture",
		"#MakeBottomCheckPlan",
		"#MakeBottomCheckProof",
		"#MakeValidationPlan",
		"#MakeCompletionReport",
	]
	mustUseConstructors:            true
	mustUseMakeBottomCheckProof:    true
	requiresBottomCheckProof:       true
	generatedArtifactsAreAuthority: false
	evidenceOnlyGeneratedArtifacts: true
	bindings: {
		generatorName:   contractScaffoldGenerator.name
		validatorName:   contractScaffoldValidator.name
		parentAuthority: "contracts/meta"
	}
}

// source: contracts/meta/manifest.cue
#ObservedSurfaceSpec: close({
	name: string & !=""
	role: string & !=""
	factFields: [...string & !=""] & [_, ...]
	mayRepresentInvalid: true | *true
	constraints: [...string & !=""] | *[]
	generatedArtifactsAreAuthority?: false
})

#ObservedSurfaceDescriptor: close({
	kind: "observed-surface"
	name: string & !=""
	role: string & !=""
	factFields: [...string & !=""] & [_, ...]
	mayRepresentInvalid: true
	constraints: [...string & !=""]
})

#MakeObservedSurface: {
	in: #ObservedSurfaceSpec

	out: #ObservedSurfaceDescriptor & {
		kind:                "observed-surface"
		name:                in.name
		role:                in.role
		factFields:          in.factFields
		mayRepresentInvalid: in.mayRepresentInvalid
		constraints:         in.constraints
	}
}

#AdmissibleSurfaceSpec: close({
	name:            string & !=""
	role:            string & !=""
	observedSurface: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	rejectedFields: [...string & !=""] | *[]
	closed: true | *true
	constraints: [...string & !=""] | *[]
	generatedArtifactsAreAuthority?: false
	stringifiedCueExpression?:       false
})

#AdmissibleSurfaceDescriptor: close({
	kind:            "admissible-surface"
	name:            string & !=""
	role:            string & !=""
	observedSurface: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	rejectedFields: [...string & !=""]
	closed: true
	constraints: [...string & !=""]
})

#MakeAdmissibleSurface: {
	in: #AdmissibleSurfaceSpec

	out: #AdmissibleSurfaceDescriptor & {
		kind:            "admissible-surface"
		name:            in.name
		role:            in.role
		observedSurface: in.observedSurface
		requiredFields:  in.requiredFields
		rejectedFields:  in.rejectedFields
		closed:          in.closed
		constraints:     in.constraints
	}
}

#SurfaceSetSpec: close({
	admissible: [...string & !=""] & [_, ...]
	observed: [...string & !=""] & [_, ...]
	candidates: [...string & !=""] & [_, ...]
	fixtures: [...string & !=""] & [_, ...]
	checks: [...string & !=""] & [_, ...]
	publicExports: [...string & !=""] & [_, ...]
	manifestExecutableProofObject?: false
})

#SurfaceSetDescriptor: close({
	kind: "surface-set"
	admissible: [...string & !=""]
	observed: [...string & !=""]
	candidates: [...string & !=""]
	fixtures: [...string & !=""]
	checks: [...string & !=""]
	publicExports: [...string & !=""]
})

#MakeSurfaceSet: {
	in: #SurfaceSetSpec

	out: #SurfaceSetDescriptor & {
		kind:          "surface-set"
		admissible:    in.admissible
		observed:      in.observed
		candidates:    in.candidates
		fixtures:      in.fixtures
		checks:        in.checks
		publicExports: in.publicExports
	}
}

// source: contracts/meta/manifest.cue
#ValidationPlanSpec: close({
	path:              string & !=""
	validBaselineExpr: string & !=""
	publicExpr:        string & !=""
	bottomChecks: [...string & !=""] & [_, ...]
	checkFile:        string & !=""
	checkSurface:     string & !=""
	forbiddenPattern: string | *_defaultForbiddenPattern
})

#ValidationPlan: close({
	kind: "validation-plan"
	commands: [...string & !=""]
})

#MakeValidationPlan: {
	in: #ValidationPlanSpec

	out: #ValidationPlan & {
		kind: "validation-plan"
		commands: [
			"cue vet ./\(in.path)",
			"cue export ./\(in.path) -e \(in.validBaselineExpr)",
			"cue export ./\(in.path) -e \(in.publicExpr)",
			for c in in.bottomChecks {
				"! cue export \(in.checkFile) -e '\(in.checkSurface).\(c)'"
			},
			"! rg '\(in.forbiddenPattern)' ./\(in.path)",
		]
	}
}
