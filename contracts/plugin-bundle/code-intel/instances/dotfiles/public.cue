package codeintelpluginbundle

codeIntelBundleReport: {
	schema: "factory.plugin-bundle.code-intel.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
	templateRoot: pluginBundleTemplateRoot
	materializedRoot: pluginBundleRoot
	bundledSurfaces: {
		mcp: true
		cueLSP: true
		luaLSP: true
		weztermTypes: true
		nvimTypes: true
		luaFirstWorkflow: true
		authority: false
	}
}

codeIntelLuaFirstWorkflowReport: {
	schema: "factory.plugin-bundle.code-intel.lua-first-workflow.report.v1"
	status: "admitted"
	path: pluginBundleContractRoot
	workflow: codeIntelLuaFirstWorkflow.id
	providers: [for provider in codeIntelLuaFirstWorkflow.providers {provider.id}]
}
