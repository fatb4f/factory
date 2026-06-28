package codeintelpluginbundle

codeIntelTarget: #CodeIntelTarget & {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
}

codeIntelTargetInventory: [
	for relativePath in codeIntelRequiredPaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

generatedFileInventory: [
	for targetPath in codeIntelTargetInventory {
		path: targetPath
		generated: true
		authority: false
		source: "bundle-projection"
	},
]

projectionComponents: [
	{id: "code-intel-contract", path: pluginBundleContractRoot, role: "contract", authority: true},
	{id: "code-intel-source-tree", path: pluginBundleSourceRoot, role: "package-source", authority: true},
	{id: "plugin-bundle-template", path: pluginBundleTemplateRoot, role: "contract", authority: true},
	{id: "code-intel-materialized-root", path: pluginBundleRoot, role: "generated-package", generated: true, authority: false},
	{id: "bundled-mcp-surfaces", path: "\(pluginBundleRoot)/generated/mcp", role: "package-content", generated: true, authority: false},
	{id: "bundled-lsp-surfaces", path: "\(pluginBundleRoot)/generated/lsp", role: "package-content", generated: true, authority: false},
	{id: "bundled-wezterm-types", path: "\(pluginBundleRoot)/generated/types/wezterm", role: "package-content", generated: true, authority: false},
	{id: "bundled-nvim-types", path: "\(pluginBundleRoot)/generated/types/nvim", role: "package-content", generated: true, authority: false},
	{id: "lua-first-workflow", path: "\(pluginBundleRoot)/generated/workflows/lua-first", role: "package-content", generated: true, authority: false},
]

projectionGates: [
	{id: "code-intel-cue-vet", kind: "cue-vet", target: "./contracts/plugin-bundle/code-intel/instances/dotfiles", required: true},
	{id: "code-intel-contract-export", kind: "cue-export", target: "codeIntelBundleContract", required: true},
	{id: "code-intel-output-export", kind: "cue-export", target: "codeIntelOutputPlan", required: true},
	{id: "code-intel-workflow-export", kind: "cue-export", target: "codeIntelLuaFirstWorkflow", required: true},
	{id: "code-intel-negative-bottom", kind: "negative-bottom", target: "_negativeBottomChecks", required: true},
]

codeIntelBundleInput: {
	contract: codeIntelBundleContract
	target: codeIntelTarget
	components: projectionComponents
	generatedFiles: generatedFileInventory
	outputPlan: codeIntelOutputPlan
	gates: projectionGates
	providerReachability: {
		kind: "provider-reachability"
		authority: false
		evidenceOnly: true
		providers: ["mcp-tool-registry", "mcp-context-projection", "cue-lsp", "lua-language-server", "wezterm-types", "nvim-vim-types", "lua-first-workflow"]
	}
}

codeIntelBundle: #AdmissibleCodeIntelPluginBundleProjection & codeIntelBundleInput
