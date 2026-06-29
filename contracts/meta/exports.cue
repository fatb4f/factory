package meta

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
			file:        "contracts/meta/primitive.cue"
		},
		{
			name:        "#SurfaceSetSpec"
			constructor: "#MakeSurfaceSet"
			file:        "contracts/meta/surface.cue"
		},
		{
			name:        "#ObservedSurfaceSpec"
			constructor: "#MakeObservedSurface"
			file:        "contracts/meta/surface.cue"
		},
		{
			name:        "#AdmissibleSurfaceSpec"
			constructor: "#MakeAdmissibleSurface"
			file:        "contracts/meta/surface.cue"
		},
		{
			name:        "#PredicateSetSpec"
			constructor: "#MakePredicateSet"
			file:        "contracts/meta/predicate.cue"
		},
		{
			name:        "#PromotionCandidateSpec"
			constructor: "#MakePromotionCandidate"
			file:        "contracts/meta/promotion.cue"
		},
		{
			name:        "#NegativeFixtureSpec"
			constructor: "#MakeNegativeFixture"
			file:        "contracts/meta/fixture.cue"
		},
		{
			name:        "#BottomCheckPlanSpec"
			constructor: "#MakeBottomCheckPlan"
			file:        "contracts/meta/bottom.cue"
		},
		{
			name:        "#BottomCheckProofSpec"
			constructor: "#MakeBottomCheckProof"
			file:        "contracts/meta/bottom.cue"
		},
		{
			name:        "#ValidationPlanSpec"
			constructor: "#MakeValidationPlan"
			file:        "contracts/meta/validation.cue"
		},
		{
			name:        "#CompletionReportSpec"
			constructor: "#MakeCompletionReport"
			file:        "contracts/meta/completion.cue"
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
