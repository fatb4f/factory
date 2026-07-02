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
		"contracts/agent-context-resolver/implementation_slice_materializer.cue",
		"contracts/agent-context-resolver/implementation_slice_eval_manifest.cue",
		"contracts/agent-context-resolver/implementation_slice_runner_result.cue",
		"contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue",
		"contracts/plugin-bundle/agent-context-resolver/checks/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
		"contracts/meta/manifest.cue",
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
