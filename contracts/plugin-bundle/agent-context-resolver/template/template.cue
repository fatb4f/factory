package pluginbundletemplate

#NonEmptyString: string & !=""
#RelativePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#TemplateFile: close({
	path: #RelativePath
	required: true
	generated: bool | *true
	authority: false
})

#PluginBundleTemplate: close({
	schema: "factory.plugin-bundle.template.v1"
	id: #NonEmptyString
	materializedRoot: #RelativePath
	requiredFiles: [...#TemplateFile] & [_, ...]
	requiredSubtrees: [...#RelativePath] & [_, ...]
	containsCueAuthorityBlock: true
	containsResolverContracts: bool | *false
	containsConstructorContracts: bool | *false
	denies: [...#NonEmptyString]
	topLevelPluginRoot?: false
	externalFactoryReference?: false
	externalContractCuemodReference?: false
	proseReferenceAuthority?: false
})

agentContextResolverPluginBundleTemplate: #PluginBundleTemplate & {
	id: "agent-context-resolver"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	containsCueAuthorityBlock: true
	containsResolverContracts: true
	containsConstructorContracts: true
	requiredSubtrees: [
		"scripts",
		"generated",
		"contracts/agent-context-resolver",
		"contracts/meta/impl",
	]
	requiredFiles: [
		{path: "SKILL.md", required: true, authority: false},
		{path: "manifest.json", required: true, authority: false},
		{path: "scripts/agent-context-resolver-hook", required: true, authority: false},
		{path: "scripts/resolve-agent-context", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_materializer.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_eval_projection.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_runner_result.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue", required: true, authority: false},
		{path: "contracts/meta/impl/primitive.cue", required: true, authority: false},
		{path: "contracts/meta/impl/surface.cue", required: true, authority: false},
		{path: "contracts/meta/impl/predicate.cue", required: true, authority: false},
		{path: "contracts/meta/impl/promotion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/fixture.cue", required: true, authority: false},
		{path: "contracts/meta/impl/bottom.cue", required: true, authority: false},
		{path: "contracts/meta/impl/validation.cue", required: true, authority: false},
		{path: "contracts/meta/impl/completion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/exports.cue", required: true, authority: false},
	]
	denies: [
		"external factory lookup from materialized plugin",
		"external contract.cuemod lookup from materialized plugin",
		"top-level plugins runtime root",
		"prose references as authority",
	]
}

dotfilesAgentContextResolverPluginBundleTemplate: #PluginBundleTemplate & {
	id: "dotfiles-agent-context-resolver"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	containsCueAuthorityBlock: true
	containsResolverContracts: true
	containsConstructorContracts: true
	requiredSubtrees: [
		"scripts",
		"generated",
		"generated/mcp",
		"generated/lsp",
		"generated/types/wezterm",
		"generated/types/nvim",
		"generated/workflows/lua-first",
		"contracts/agent-context-resolver",
		"contracts/dotfiles",
		"contracts/meta/impl",
	]
	requiredFiles: [
		{path: "SKILL.md", required: true, authority: false},
		{path: "manifest.json", required: true, authority: false},
		{path: "scripts/agent-context-resolver-hook", required: true, authority: false},
		{path: "scripts/resolve-agent-context", required: true, authority: false},

		{path: "generated/turn_start_fragments.json", required: true, authority: false},
		{path: "generated/prompt_routes.json", required: true, authority: false},
		{path: "generated/route_inventory.json", required: true, authority: false},
		{path: "generated/fragment_inventory.json", required: true, authority: false},
		{path: "generated/provider_inventory.json", required: true, authority: false},
		{path: "generated/dotfiles.schema-map.json", required: true, authority: false},

		{path: "generated/mcp/server-manifest.json", required: true, authority: false},
		{path: "generated/mcp/tool-registry.json", required: true, authority: false},
		{path: "generated/mcp/context-projection.json", required: true, authority: false},

		{path: "generated/lsp/cue-lsp.json", required: true, authority: false},
		{path: "generated/lsp/lua-language-server.json", required: true, authority: false},
		{path: "generated/lsp/provider-routing.json", required: true, authority: false},

		{path: "generated/types/wezterm/wezterm.lua", required: true, authority: false},
		{path: "generated/types/wezterm/events.lua", required: true, authority: false},
		{path: "generated/types/wezterm/config-builder.lua", required: true, authority: false},
		{path: "generated/types/nvim/vim.lua", required: true, authority: false},

		{path: "generated/workflows/lua-first/workflow.json", required: true, authority: false},
		{path: "generated/workflows/lua-first/entrypoints.json", required: true, authority: false},
		{path: "generated/workflows/lua-first/diagnostic-map.json", required: true, authority: false},

		{path: "contracts/dotfiles/lua-first-workflow.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_materializer.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_eval_projection.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_runner_result.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/checks/checks.cue", required: true, authority: false},
		{path: "contracts/meta/impl/primitive.cue", required: true, authority: false},
		{path: "contracts/meta/impl/surface.cue", required: true, authority: false},
		{path: "contracts/meta/impl/predicate.cue", required: true, authority: false},
		{path: "contracts/meta/impl/promotion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/fixture.cue", required: true, authority: false},
		{path: "contracts/meta/impl/bottom.cue", required: true, authority: false},
		{path: "contracts/meta/impl/validation.cue", required: true, authority: false},
		{path: "contracts/meta/impl/completion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/exports.cue", required: true, authority: false},
		{path: "contracts/meta/impl/checks/checks.cue", required: true, authority: false},
	]
	denies: [
		"external factory lookup from materialized plugin",
		"external contract.cuemod lookup from materialized plugin",
		"top-level plugins runtime root",
		"prose references as authority",
		"MCP output treated as authority",
		"LSP diagnostics treated as authority",
		"WezTerm type stubs treated as dotfiles source authority",
		"generated Lua workflow artifacts treated as authority",
	]
}

pluginBundleTemplateComplianceReport: {
	schema: "factory.plugin-bundle.template.compliance.v1"
	status: "admitted"
	template: agentContextResolverPluginBundleTemplate.id
	materializedRoot: agentContextResolverPluginBundleTemplate.materializedRoot
	requiredSubtrees: agentContextResolverPluginBundleTemplate.requiredSubtrees
	checks: ["topLevelPluginRoot", "externalFactoryReference", "externalContractCuemodReference", "proseReferenceAuthority", "missingCueAuthorityBlock"]
}

dotfilesPluginBundleTemplateComplianceReport: {
	schema: "factory.plugin-bundle.template.compliance.v1"
	status: "admitted"
	template: dotfilesAgentContextResolverPluginBundleTemplate.id
	materializedRoot: dotfilesAgentContextResolverPluginBundleTemplate.materializedRoot
	requiredSubtrees: dotfilesAgentContextResolverPluginBundleTemplate.requiredSubtrees
	checks: [
		"topLevelPluginRoot",
		"externalFactoryReference",
		"externalContractCuemodReference",
		"proseReferenceAuthority",
		"missingCueAuthorityBlock",
		"mcpOutputAsAuthority",
		"lspDiagnosticsAsAuthority",
		"weztermTypesAsAuthority",
		"luaWorkflowGeneratedAsAuthority",
	]
}

pluginBundleTemplateComplianceReports: [
	pluginBundleTemplateComplianceReport,
	dotfilesPluginBundleTemplateComplianceReport,
]
