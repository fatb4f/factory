package dotfilespluginbundle

dotfilesTarget: #DotfilesTarget & {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
}

dotfilesTargetInventory: [
	for relativePath in pluginBundleRequiredPaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

generatedFileInventory: [
	for targetPath in dotfilesTargetInventory {
		path: targetPath
		generated: true
		authority: false
		source: "bundle-projection"
	},
]

projectionComponents: [
	{id: "plugin-bundle-contract", path: pluginBundleContractRoot, role: "contract", authority: true},
	{id: "plugin-bundle-source", path: pluginBundleSourceRoot, role: "contract", authority: true},
	{id: "plugin-bundle-template", path: pluginBundleTemplateRoot, role: "contract", authority: true},
	{id: "template-application", path: "\(pluginBundleContractRoot)/template_application.cue", role: "contract", authority: true},
	{id: "dotfiles-materialized-package-root", path: pluginBundleRoot, role: "generated-package", generated: true, authority: false},
	{id: "bundled-resolver-contracts", path: "\(pluginBundleRoot)/contracts/agent-context-resolver", role: "package-content", generated: true, authority: false},
	{id: "bundled-dotfiles-contracts", path: "\(pluginBundleRoot)/contracts/dotfiles", role: "package-content", generated: true, authority: false},
	{id: "bundled-constructor-contracts", path: "\(pluginBundleRoot)/contracts/meta/impl", role: "package-content", generated: true, authority: false},
	{id: "bundled-mcp-surfaces", path: "\(pluginBundleRoot)/generated/mcp", role: "package-content", generated: true, authority: false},
	{id: "bundled-lsp-surfaces", path: "\(pluginBundleRoot)/generated/lsp", role: "package-content", generated: true, authority: false},
	{id: "bundled-wezterm-types", path: "\(pluginBundleRoot)/generated/types/wezterm", role: "package-content", generated: true, authority: false},
	{id: "bundled-nvim-types", path: "\(pluginBundleRoot)/generated/types/nvim", role: "package-content", generated: true, authority: false},
	{id: "lua-first-workflow", path: "\(pluginBundleRoot)/generated/workflows/lua-first", role: "package-content", generated: true, authority: false},
	{id: "package-manifest", path: "\(pluginBundleRoot)/package.json", role: "package-metadata", generated: true, authority: false},
	{id: "package-lock", path: "\(pluginBundleRoot)/package.lock.json", role: "idempotency-lock", generated: true, authority: false},
	{id: "codex-hook-integration", path: ".codex/hooks.json", role: "integration", generated: true, authority: false},
]

projectionGates: [
	{id: "plugin-bundle-cue-vet", kind: "cue-vet", target: "./contracts/plugin-bundle/agent-context-resolver/instances/dotfiles", required: true},
	{id: "plugin-bundle-contract-export", kind: "cue-export", target: "dotfilesAgentContextResolverBundleContract", required: true},
	{id: "plugin-bundle-template-application-export", kind: "cue-export", target: "dotfilesAgentContextResolverTemplateApplication", required: true},
	{id: "plugin-bundle-materialization-export", kind: "cue-export", target: "dotfilesAgentContextResolverMaterialization", required: true},
	{id: "plugin-bundle-lock-export", kind: "cue-export", target: "dotfilesAgentContextResolverLock", required: true},
	{id: "plugin-bundle-package-export", kind: "cue-export", target: "dotfilesAgentContextResolverPackage", required: true},
	{id: "dotfiles-lua-first-workflow-export", kind: "cue-export", target: "dotfilesLuaFirstWorkflow", required: true},
	{id: "dotfiles-lua-first-report-export", kind: "cue-export", target: "dotfilesLuaFirstWorkflowReport", required: true},
	{id: "plugin-bundle-negative-bottom", kind: "negative-bottom", target: "_negativeBottomChecks", required: true},
	{id: "dotfiles-tooling-forbidden-search", kind: "forbidden-search", target: "dotfiles-tooling-authority-attractors", required: true},
]

dotfilesAgentContextResolverBundleInput: {
	contract: dotfilesAgentContextResolverBundleContract
	templateApplication: dotfilesAgentContextResolverTemplateApplication
	target: dotfilesTarget
	components: projectionComponents
	generatedFiles: generatedFileInventory
	materialization: dotfilesAgentContextResolverMaterializationInput
	lock: dotfilesAgentContextResolverLock
	package: dotfilesAgentContextResolverPackage
	gates: projectionGates
	providerReachability: {
		kind: "provider-reachability"
		authority: false
		evidenceOnly: true
		providers: [
			"fragment_inventory",
			"prompt_routes",
			"route_inventory",
			"provider_inventory",
			"mcp-tool-registry",
			"mcp-context-projection",
			"cue-lsp",
			"lua-language-server",
			"wezterm-types",
			"nvim-vim-types",
			"lua-first-workflow",
		]
	}
}

dotfilesAgentContextResolverBundle: #AdmissibleDotfilesPluginBundleProjection & dotfilesAgentContextResolverBundleInput
