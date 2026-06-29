package meta

#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#ContractGenerator: close({
	kind:    "contract-generator"
	name:    string & !=""
	command: string & !=""
	inputs: [...string & !=""] & [_, ...]
	outputs: [...#RelativeContractPath] & [_, ...]
	invariants: [...string & !=""] & [_, ...]
	generatedArtifactsAreAuthority?: false
})

#ContractValidator: close({
	kind:       "contract-validator"
	name:       string & !=""
	targetPath: #RelativeContractPath
	commands: [...string & !=""] & [_, ...]
	negativeChecks: [...string & !=""] & [_, ...]
	forbiddenPattern: string & !=""
	rejects: [...string & !=""] & [_, ...]
	staleIssueLocalChecks?:   false
	externalLookupAuthority?: false
	localOverrideEscapes?:    false
})

#GeneratedContractCompliance: close({
	kind:      "generated-contract-compliance"
	generator: #ContractGenerator
	validator: #ContractValidator
	requiredExports: [...string & !=""] & [_, ...]
	requiredConstructors: [...#ConstructorID] & [_, ...]
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
	name:    "contractScaffoldGenerator"
	command: "contracts/meta/scripts/scaffold-contract-slice"
	inputs: [
		"issue",
		"slice-id",
		"title",
		"out",
		"force",
	]
	outputs: [
		"manifest.cue",
		"checks/checks.cue",
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
	name:       "contractScaffoldValidator"
	targetPath: "contracts/issues/<issue-number>"
	commands: [
		"cue vet ./contracts/issues/<issue-number>",
		"cue export ./contracts/issues/<issue-number> -e normalizedIssueManifest",
		"cue export ./contracts/issues/<issue-number> -e issueValidationPlan",
		"cue export ./contracts/issues/<issue-number> -e issueCompletionReportContract",
		"! cue export ./contracts/issues/<issue-number>/checks -e '_negativeBottomChecks.<name>'",
	]
	negativeChecks: [
		"generatedAuthorityAccepted",
		"staleIssueLocalCheckAccepted",
		"externalLookupAccepted",
		"absolutePathAccepted",
		"parentTraversalAccepted",
	]
	forbiddenPattern: _defaultForbiddenPattern
	rejects: [
		"generated files treated as contract authority",
		"stale issue-local check references",
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
		"normalizedIssueManifest",
		"issueValidationPlan",
		"issueCompletionReportContract",
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
	requiresBottomCheckProof:       true
	generatedArtifactsAreAuthority: false
	evidenceOnlyGeneratedArtifacts: true
	bindings: {
		generatorName:   contractScaffoldGenerator.name
		validatorName:   contractScaffoldValidator.name
		parentAuthority: "contracts/meta"
	}
}
