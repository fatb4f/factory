package dotfilespluginbundle

dotfilesAgentContextResolverReport: {
	schema: "factory.plugin-bundle.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
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

dotfilesLuaFirstWorkflowReport: {
	schema: "factory.plugin-bundle.dotfiles.lua-first-workflow.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
	workflow: dotfilesLuaFirstWorkflow.id
	gates: [for gate in dotfilesLuaFirstWorkflow.gates {gate.id}]
}
