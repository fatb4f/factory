package dotfilespluginbundle

import "list"

pluginBundleRoot: ".codex/plugins/agent-context-resolver"
pluginBundleSourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
pluginBundleTemplateRoot: "contracts/plugin-bundle/template"
pluginBundleContractRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
pluginBundlePackage: "dotfilespluginbundle"

#ContainedBundlePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

pluginBundleContractRequiredPaths: list.Concat([
	baseTemplateRequiredPaths,
	[
		for addition in dotfilesTemplateApplicationAdditions {
			addition.path
		},
	],
])

pluginBundleRuntimePackagePaths: list.Concat([
	runtimeTemplateRequiredPaths,
	[
		for addition in runtimeTemplateApplicationAdditions {
			addition.path
		},
	],
])

// Backwards-compatible aliases. New contract code should use the explicit names above.
pluginBundleRequiredPaths: pluginBundleContractRequiredPaths
pluginBundleRuntimeRequiredPaths: pluginBundleRuntimePackagePaths

#RuntimePackageSubsetEvidence: close({
	contractRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePathsSubsetOfContractPaths: true
	subsetCheckAuthority: true
	runtimePackageAuthority: false
})

pluginBundleRuntimeSubsetEvidence: #RuntimePackageSubsetEvidence & {
	contractRequiredPaths: pluginBundleContractRequiredPaths
	runtimePackagePaths: pluginBundleRuntimePackagePaths
}

_runtimePackagePathSubsetCheck: {
	for path in pluginBundleRuntimePackagePaths {
		if !list.Contains(pluginBundleContractRequiredPaths, path) {
			"\(path)": _|_
		}
	}
}

#BundledCueAuthorityBlock: close({
	root: "contracts"
	resolver: close({
		root: "contracts/agent-context-resolver"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	constructors: close({
		root: "contracts/meta"
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
			"fixtures.cue",
			"checks.cue",
			"checks/checks.cue",
		]
	}
	constructors: {
		files: [
			"catalog.cue",
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
	sourceRoot: pluginBundleSourceRoot
	templateRoot: pluginBundleTemplateRoot
	instanceRoot: pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	requiredPaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackageSubset: #RuntimePackageSubsetEvidence
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
	requiredPaths: pluginBundleContractRequiredPaths
	runtimePackagePaths: pluginBundleRuntimePackagePaths
	runtimePackageSubset: pluginBundleRuntimeSubsetEvidence
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
