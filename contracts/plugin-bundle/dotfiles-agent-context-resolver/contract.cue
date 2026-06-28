package dotfilespluginbundle

pluginBundleRoot: ".codex/plugins/agent-context-resolver"
pluginBundleContractRoot: "contracts/plugin-bundle/dotfiles-agent-context-resolver"
pluginBundlePackage: "dotfilespluginbundle"

#ContainedBundlePath: string & !="" & !~"^/" & !~"(^|/)\.\.(/|$)"

pluginBundleRequiredPaths: [
	"SKILL.md",
	"manifest.json",
	"scripts/agent-context-resolver-hook",
	"scripts/resolve-agent-context",
	"generated/turn_start_fragments.json",
	"generated/prompt_routes.json",
	"generated/route_inventory.json",
	"generated/fragment_inventory.json",
	"generated/provider_inventory.json",
	"generated/dotfiles.schema-map.json",
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
	"contracts/meta/impl/checks/checks.cue",
]

#BundledCueAuthorityBlock: close({
	root: "contracts"
	resolver: close({
		root: "contracts/agent-context-resolver"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	constructors: close({
		root: "contracts/meta/impl"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	externalFactoryReference?: false
	externalContractCuemodReference?: false
})

bundledCueAuthorityBlock: #BundledCueAuthorityBlock & {
	resolver: {
		files: [
			"implementation_slice_materializer.cue",
			"implementation_slice_eval_projection.cue",
			"implementation_slice_runner_result.cue",
			"implementation_slice_constructor_inventory.cue",
			"checks/checks.cue",
		]
	}
	constructors: {
		files: [
			"primitive.cue",
			"surface.cue",
			"predicate.cue",
			"promotion.cue",
			"fixture.cue",
			"bottom.cue",
			"validation.cue",
			"completion.cue",
			"exports.cue",
			"checks/checks.cue",
		]
	}
}

#DotfilesAgentContextResolverBundleContract: close({
	schema: "factory.plugin-bundle.dotfiles-agent-context-resolver.contract.v1"
	contractRoot: pluginBundleContractRoot
	package: pluginBundlePackage
	targetRepo: "github.com/fatb4f/dotfiles"
	materializedRoot: pluginBundleRoot
	requiredPaths: [...#ContainedBundlePath] & [_, ...]
	bundledCueAuthority: #BundledCueAuthorityBlock
	containment: close({
		allowHookIntegrationPath: ".codex/hooks.json"
		pluginRootOnly: true
		topLevelPluginRoot: false
		externalFactoryReference: false
		externalContractCuemodReference: false
		proseReferenceAuthority: false
	})
})

dotfilesAgentContextResolverBundleContract: #DotfilesAgentContextResolverBundleContract & {
	requiredPaths: pluginBundleRequiredPaths
	bundledCueAuthority: bundledCueAuthorityBlock
	containment: {
		allowHookIntegrationPath: ".codex/hooks.json"
		pluginRootOnly: true
		topLevelPluginRoot: false
		externalFactoryReference: false
		externalContractCuemodReference: false
		proseReferenceAuthority: false
	}
}
