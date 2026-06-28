package codeintelpluginbundle

pluginBundleRoot: ".codex/plugins/code-intel"
pluginBundleTemplateRoot: "contracts/plugin-bundle/template"
pluginBundleContractRoot: "contracts/plugin-bundle/code-intel/instances/dotfiles"
pluginBundlePackage: "codeintelpluginbundle"

codeIntelRequiredPaths: [
	"SKILL.md",
	"manifest.json",
	"generated/mcp/server-manifest.json",
	"generated/mcp/tool-registry.json",
	"generated/mcp/context-projection.json",
	"generated/lsp/cue-lsp.json",
	"generated/lsp/lua-language-server.json",
	"generated/lsp/provider-routing.json",
	"generated/types/wezterm/wezterm.lua",
	"generated/types/wezterm/events.lua",
	"generated/types/wezterm/config-builder.lua",
	"generated/types/nvim/vim.lua",
	"generated/workflows/lua-first/workflow.json",
	"generated/workflows/lua-first/entrypoints.json",
	"generated/workflows/lua-first/diagnostic-map.json",
	"contracts/code-intel/lua-first-workflow.cue",
	"contracts/code-intel/checks.cue",
]

#CodeIntelAuthorityBlock: close({
	root: "contracts"
	codeIntel: close({
		root: "contracts/code-intel"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	externalFactoryReference?: false
	externalContractCuemodReference?: false
	resolverContractsLeak?: false
})

codeIntelAuthorityBlock: #CodeIntelAuthorityBlock & {
	codeIntel: {files: ["lua-first-workflow.cue", "checks.cue"]}
}

#CodeIntelBundleContract: close({
	schema: "factory.plugin-bundle.code-intel.contract.v1"
	contractRoot: pluginBundleContractRoot
	package: pluginBundlePackage
	targetRepo: "github.com/fatb4f/dotfiles"
	templateRoot: pluginBundleTemplateRoot
	instanceRoot: pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	requiredPaths: [...#ContainedBundlePath] & [_, ...]
	bundledCueAuthority: #CodeIntelAuthorityBlock
	containment: close({
		pluginRootOnly: true
		topLevelPluginRoot: false
		externalFactoryReference: false
		externalContractCuemodReference: false
		resolverContractsLeak: false
		proseReferenceAuthority: false
	})
})

codeIntelBundleContract: #CodeIntelBundleContract & {
	requiredPaths: codeIntelRequiredPaths
	bundledCueAuthority: codeIntelAuthorityBlock
	containment: {
		pluginRootOnly: true
		topLevelPluginRoot: false
		externalFactoryReference: false
		externalContractCuemodReference: false
		resolverContractsLeak: false
		proseReferenceAuthority: false
	}
}
