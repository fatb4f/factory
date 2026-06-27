package dotfilespluginbundle

dotfilesAgentContextResolverReport: {
	schema:  "factory.dotfiles-agent-context-resolver-plugin-bundle.report.v0"
	status:  "admitted"
	package: "dotfilespluginbundle"
	path:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
	slice:   "dotfiles-agent-context-resolver-plugin-bundle-v0"

	authority: {
		owns: [
			"dotfiles plugin bundle projection",
			"contract.cuemod input references",
			"dotfiles target materialization",
			"generated file inventory",
			"bundle lock evidence",
		]
		doesNotOwn: [
			"contract.cuemod semantics",
			"dotfiles source authority",
			"runtime behavior",
			"server implementation",
			"manual generated artifact edits",
		]
	}

	rootQuestion: {
		id:   "N0.contract-question"
		text: "What factory authority is required to generate the dotfiles agent context resolver plugin bundle from contract.cuemod while keeping generated artifacts non-authoritative?"
	}

	primitives: [
		"#DotfilesPluginBundleProjection",
		"#ContractCuemodInput",
		"#DotfilesPluginMaterialization",
	]

	files: {
		package: "dotfilespluginbundle"
		root:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
		expected: [
			"root.cue",
			"inputs.cue",
			"projection.cue",
			"materialization.cue",
			"lock.cue",
			"fixtures.cue",
			"checks_test.cue",
			"public.cue",
		]
	}

	targetInventory: [
		for targetPath in dotfilesTargetInventory {targetPath},
	]

	publicExports: [
		"dotfilesAgentContextResolverBundle",
		"dotfilesAgentContextResolverMaterialization",
		"dotfilesAgentContextResolverLock",
		"dotfilesAgentContextResolverReport",
		"_negativeBottomChecks",
	]

	negativeBottomChecks: {
		codexAsAuthority:           "negativeFixtures.codexAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection"
		generatedAsAuthority:       "negativeFixtures.generatedAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection"
		externalDependency:         "negativeFixtures.externalDependency.input & #AdmissibleDotfilesPluginBundleProjection"
		providerOutputAsAuthority:  "negativeFixtures.providerOutputAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection"
		materializationWithoutLock: "negativeFixtures.materializationWithoutLock.input & #AdmissibleDotfilesPluginMaterialization"
	}

	forbiddenAttractors: [
		".codexAuthority",
		"generatedAuthority",
		"providerOutputIsAuthority: true",
		"externalFactoryRootLookup: true",
		"externalContractCuemodLookup: true",
	]

	acceptance: [
		"bounded CUE surface exists",
		"public exports render",
		"negative fixtures bottom out",
		"generated files are materialized non-authority outputs",
		"provider reachability is projected metadata",
	]

	control: {
		action: "admit"
		reason: "The dotfiles plugin bundle projection is bounded to contract.cuemod inputs and materializes generated outputs as non-authority files with lock evidence."
		evidence: [
			"public eval exports",
			"generated file inventory",
			"negative bottom checks",
			"bundle lock evidence",
		]
		nextState: "dotfiles target materialization can be generated from contract.cuemod without treating generated plugin files as source authority"
	}
}
