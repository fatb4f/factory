package agentcontextresolverpluginbundle

import tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"

#NonEmptyString:       string & !=""
#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#PluginBundleSourceRoot: close({
	path:    "contracts/plugin-bundle/agent-context-resolver/src"
	package: "agentcontextresolver"
	exports: [...#NonEmptyString] & [_, ...]
	authority: true
})

#PluginBundleInstanceRoot: close({
	targetRepo:       "github.com/fatb4f/dotfiles"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	sourceRoot:       "contracts/plugin-bundle/agent-context-resolver/src"
	lock: close({
		sourceRoot:       "contracts/plugin-bundle/agent-context-resolver/src"
		templateRoot:     "contracts/plugin-bundle/agent-context-resolver/template"
		instanceRoot:     "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
		materializedRoot: ".codex/plugins/agent-context-resolver"
	})
})

#PluginBundleDistributionLock: close({
	sourceRoot:       "contracts/plugin-bundle/agent-context-resolver/src"
	templateRoot:     "contracts/plugin-bundle/agent-context-resolver/template"
	instanceRoot:     "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	fileInventory: [...#RelativeContractPath] & [_, ...]
	checks: [...#NonEmptyString] & [_, ...]
})

agentContextResolverPluginBundleSourceRoot: #PluginBundleSourceRoot & {
	exports: [
		"implementationSliceIssueBaseline",
		"implementationSliceMaterializationReport",
		"implementationSliceEvalPlan",
		"implementationSliceRunnerPlan",
	]
}

agentContextResolverPluginBundleInstanceRoot: #PluginBundleInstanceRoot

agentContextResolverPluginBundleDistributionLock: #PluginBundleDistributionLock & {
	fileInventory: [
		"contracts/plugin-bundle/agent-context-resolver/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/checks/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/instances/dotfiles/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/instances/dotfiles/checks/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/checks/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/assertions/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/internal/agent-skill/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/internal/graph/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/projections/agent-runtime/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/projections/agent-skill/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/projections/cli/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/projections/mcp/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/adapters/cli/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/adapters/codex-hook/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/adapters/go/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/adapters/mcp-server/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/contract/manifest.cue",
		"contracts/plugin-bundle/agent-context-resolver/src/contracts/agent-context-resolver/seed/fixtures/manifest.cue",
	]
	checks: ["cue-vet", "bundle-contract-export", "materialization-export", "lock-export", "negative-bottom"]
}

agentContextResolverSiblingRootShape: tmpl.#PluginBundleSiblingRootShape & {
	bundleID: "agent-context-resolver"
	forbiddenRootEntries: [
		"generated",
	]
	forbiddenGeneratedEntries: [
		"manifest.json",
		"contracts",
		"generated",
	]
}
