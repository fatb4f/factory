package codeintelpluginbundle

#NonEmptyString:       string & !=""
#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#PluginBundleSourceRoot: close({
	path:    "contracts/plugin-bundle/code-intel/src"
	package: "pluginbundle_code_intel"
	exports: [...#NonEmptyString] & [_, ...]
	authority: true
})

#PluginBundleInstanceRoot: close({
	targetRepo:       "github.com/fatb4f/dotfiles"
	materializedRoot: ".codex/plugins/code-intel"
	sourceRoot:       "contracts/plugin-bundle/code-intel/src"
	lock: close({
		sourceRoot:       "contracts/plugin-bundle/code-intel/src"
		templateRoot:     "contracts/plugin-bundle/src"
		instanceRoot:     "contracts/plugin-bundle/code-intel/instances/dotfiles"
		materializedRoot: ".codex/plugins/code-intel"
	})
})

#PluginBundleDistributionLock: close({
	sourceRoot:       "contracts/plugin-bundle/code-intel/src"
	templateRoot:     "contracts/plugin-bundle/src"
	instanceRoot:     "contracts/plugin-bundle/code-intel/instances/dotfiles"
	materializedRoot: ".codex/plugins/code-intel"
	fileInventory: [...#RelativeContractPath] & [_, ...]
	checks: [...#NonEmptyString] & [_, ...]
})

#PluginBundleRootShape: close({
	root: "contracts/plugin-bundle/code-intel"
	requiredFiles: [
		"manifest.cue",
		"checks/manifest.cue",
	]
	requiredDirectories: [
		"checks",
		"instances",
		"instances/dotfiles",
		"src",
	]
	generatedPayloadRoot:              "contracts/plugin-bundle/generated/code-intel"
	topLevelGeneratedPayloadUnderRoot: false
})

codeIntelPluginBundleSourceRoot: #PluginBundleSourceRoot & {
	exports: [
		"pluginBundleContract",
		"pluginBundleValidationPlan",
		"pluginBundleCompletionReport",
	]
}

codeIntelPluginBundleInstanceRoot: #PluginBundleInstanceRoot

codeIntelPluginBundleDistributionLock: #PluginBundleDistributionLock & {
	fileInventory: [
		"contracts/plugin-bundle/code-intel/manifest.cue",
		"contracts/plugin-bundle/code-intel/checks/manifest.cue",
		"contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue",
		"contracts/plugin-bundle/code-intel/src/manifest.cue",
		"contracts/plugin-bundle/code-intel/src/checks/manifest.cue",
		"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
		"contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks/manifest.cue",
	]
	checks: [
		"cue-vet",
		"bundle-root-contract-export",
		"bundle-root-lock-export",
		"bundle-root-shape-checks",
	]
}

codeIntelPluginBundleRootShape: #PluginBundleRootShape

codeIntelSiblingRootShape: close({
	bundleID: "code-intel"
	root:     "contracts/plugin-bundle/code-intel"
	requiredRootEntries: [
		"checks",
		"instances",
		"src",
		"manifest.cue",
	]
	requiredSrcEntries: [
		"checks",
		"contracts",
		"generated",
		"manifest.cue",
	]
	requiredGeneratedEntries: [
		".codex-plugin",
		"hooks",
		"reference",
		"SKILL.md",
		"skills",
	]
	forbiddenRootEntries: [
		"generated",
	]
	forbiddenGeneratedEntries: [
		"manifest.json",
		"contracts",
		"generated",
		"scripts",
	]
	sourceAuthorityRoot:     "contracts/plugin-bundle/code-intel/src"
	generatedProjectionRoot: "contracts/plugin-bundle/generated/code-intel"
})
