package pluginbundletemplate

import impl "github.com/fatb4f/factory/contracts/meta"

pluginBundleTemplateCompliance: impl.#GeneratedContractCompliance & {
	kind:      "generated-contract-compliance"
	generator: pluginBundleScaffoldGenerator
	validator: pluginBundleScaffoldValidator
	requiredExports: [
		"pluginBundleContract",
		"pluginBundleValidationPlan",
		"pluginBundleCompletionReport",
	]
	requiredConstructors: [
		"#ContractGenerator",
		"#ContractValidator",
		"#GeneratedContractCompliance",
		"#MakeBottomCheckProof",
		"#MakeValidationPlan",
		"#MakeCompletionReport",
	]
	requiresBottomCheckProof: true
	generatedArtifactsAreAuthority: false
	evidenceOnlyGeneratedArtifacts: true
	bindings: {
		generatorName:   pluginBundleScaffoldGenerator.name
		validatorName:   pluginBundleScaffoldValidator.name
		parentAuthority: "contracts/meta"
	}
}
