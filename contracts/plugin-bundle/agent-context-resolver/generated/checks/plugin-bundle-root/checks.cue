package pluginbundlerootgeneratedchecks

import root "github.com/fatb4f/factory/contracts/plugin-bundle:pluginbundle"

_generatedFromContractAssertions: close({
	source: "contracts/plugin-bundle/manifest.cue"
	contract: "plugin-bundle-root"
	fixtureSurface: "negativePluginBundleRootFixtures"
	checkSurface: "_negativeBottomChecks"
	assertions: [
		"factoryRootAsPluginBundleAuthorityAccepted",
		"generatedRuntimeAuthorityAccepted",
		"projectionOutsideCodexPluginsAccepted",
		"externalRuntimeLookupAccepted",
		"sourceRootOutsidePluginBundleAccepted",
		"topLevelGeneratedRootAccepted",
	]
})

_negativeBottomChecks: {
	factoryRootAsPluginBundleAuthorityAccepted: root.negativePluginBundleRootFixtures.factoryRootAsPluginBundleAuthorityAccepted.input & root.#PluginBundleRootAuthority
	generatedRuntimeAuthorityAccepted:          root.negativePluginBundleRootFixtures.generatedRuntimeAuthorityAccepted.input & root.#PluginBundleRootAuthority
	projectionOutsideCodexPluginsAccepted:      root.negativePluginBundleRootFixtures.projectionOutsideCodexPluginsAccepted.input & root.#PluginBundleRuntimeProjectionRoot
	externalRuntimeLookupAccepted:              root.negativePluginBundleRootFixtures.externalRuntimeLookupAccepted.input & root.#PluginBundleRuntimeIndependenceBoundary
	sourceRootOutsidePluginBundleAccepted:      root.negativePluginBundleRootFixtures.sourceRootOutsidePluginBundleAccepted.input & root.#PluginBundleSourceRoot
	topLevelGeneratedRootAccepted:              root.negativePluginBundleRootFixtures.topLevelGeneratedRootAccepted.input & root.#PluginBundleRootAuthority
}

pluginBundleRootNegativeBottomChecks: _negativeBottomChecks
