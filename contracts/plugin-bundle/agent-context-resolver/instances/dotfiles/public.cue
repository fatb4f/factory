package dotfilespluginbundle

dotfilesAgentContextResolverReport: {
	schema: "factory.plugin-bundle.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
	templateApplication: {
		template: dotfilesAgentContextResolverTemplateApplication.template.id
		instance: dotfilesAgentContextResolverTemplateApplication.instance.id
		baseRequiredPaths: len(dotfilesAgentContextResolverTemplateApplication.baseRequiredPaths)
		additions: len(dotfilesAgentContextResolverTemplateApplication.additions)
		instanceOwnsTemplate: false
	}
	bundledTooling: {
		mcp: true
		cueLSP: true
		luaLSP: true
		weztermTypes: true
		luaFirstWorkflow: true
		authority: false
	}
}

dotfilesAgentContextResolverPromptSurfaceReport: {
	schema: "factory.plugin-bundle.prompt-surface.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
}

dotfilesTemplateApplicationReport: {
	schema: "factory.plugin-bundle.template-application.report.v1"
	status: "admitted"
	template: dotfilesAgentContextResolverTemplateApplication.template.id
	instance: dotfilesAgentContextResolverTemplateApplication.instance.id
	resultRequiredPaths: len(dotfilesAgentContextResolverTemplateApplication.resultRequiredPaths)
	generatedOutputAuthority: false
	instanceOwnsTemplate: false
}

dotfilesLuaFirstWorkflowReport: {
	schema: "factory.plugin-bundle.dotfiles.lua-first-workflow.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
	workflow: dotfilesLuaFirstWorkflow.id
	gates: [for gate in dotfilesLuaFirstWorkflow.gates {gate.id}]
}
