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
