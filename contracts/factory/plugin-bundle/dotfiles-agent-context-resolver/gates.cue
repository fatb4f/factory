package dotfilespluginbundle

#PluginCapabilityGate: close({
	hasSkill: bool
	hasMCP:   bool | *false
	hasApp:   bool | *false

	if !hasSkill && !hasMCP && !hasApp {
		_noEffectiveCapability: _|_
	}
})

#PluginBundleInstallGate: close({
	manifestPath: resolverPluginManifestPath
	marketplacePath: resolverMarketplacePath
	pluginRoot: resolverPluginRoot.path
	capability: #PluginCapabilityGate
	archive: #BundleArchiveGate
	rootContainment: [...#NoEscapingPluginRoot]
	hooksRequiredAtRuntime: false
	mcpRequiredAtRuntime: false
	appsRequiredAtRuntime: false
})

resolverPluginCapabilityGate: #PluginCapabilityGate & {
	hasSkill: true
	hasMCP:   false
	hasApp:   false
}

resolverPluginBundleInstallGate: #PluginBundleInstallGate & {
	capability: resolverPluginCapabilityGate
	archive: resolverBundleArchiveGate
	rootContainment: resolverPluginRootContainment
}

upstreamCodexPluginBundleEvidence: {
	source: "openai/codex"
	branchesChecked: ["main", "latest-alpha-cli"]
	state: "aligned-on-checked-plugin-bundle-surfaces"
	evidenceOnly: true
	authority: false
	surfaces: [
		"codex-rs/plugin/src/manifest.rs",
		"codex-rs/core-plugins/src/plugin_bundle_archive.rs",
		"plugin-creator JSON spec",
	]
	mirroredRequirements: [
		"required .codex-plugin/plugin.json",
		"skill-first effective capability",
		"root-contained relative resources",
		"repo-local marketplace entry",
		"archive gate rejects symlinks, hardlinks, unsupported entries, and root escapes",
		"MCP and apps optional",
		"hooks gated until install/runtime behavior is verified",
	]
}
