package agentcontextresolverpluginbundle

#NonEmptyString: string & !=""
#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#PluginBundleSourceRoot: close({
	path: "contracts/plugin-bundle/agent-context-resolver/src"
	package: "agentcontextresolver"
	exports: [...#NonEmptyString] & [_, ...]
	authority: true
})

#PluginBundleInstanceRoot: close({
	targetRepo: "github.com/fatb4f/dotfiles"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	lock: close({
		sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
		templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
		instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
		materializedRoot: ".codex/plugins/agent-context-resolver"
	})
})

#PluginBundleDistributionLock: close({
	sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
	instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
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

agentContextResolverPluginBundleDistributionLock: #PluginBundleDistributionLock & {
	fileInventory: [
		"contracts/agent-context-resolver/implementation_slice_materializer.cue",
		"contracts/agent-context-resolver/implementation_slice_eval_projection.cue",
		"contracts/agent-context-resolver/implementation_slice_runner_result.cue",
		"contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue",
		"contracts/agent-context-resolver/checks/checks.cue",
		"contracts/meta/impl/primitive.cue",
		"contracts/meta/impl/surface.cue",
		"contracts/meta/impl/predicate.cue",
		"contracts/meta/impl/promotion.cue",
		"contracts/meta/impl/fixture.cue",
		"contracts/meta/impl/bottom.cue",
		"contracts/meta/impl/validation.cue",
		"contracts/meta/impl/completion.cue",
		"contracts/meta/impl/exports.cue",
	]
	checks: ["cue-vet", "bundle-contract-export", "materialization-export", "lock-export", "negative-bottom"]
}
