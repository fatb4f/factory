package pluginbundlechecks

import root "github.com/fatb4f/factory/contracts/plugin-bundle:pluginbundle"

_negativeFixtures: {
	factoryRootAsPluginBundleAuthorityAccepted: {
		input: {
			root:      "contracts/factory"
			authority: true
		}
	}
	generatedRuntimeAuthorityAccepted: {
		input: {
			root:                         "contracts/plugin-bundle"
			generatedOutputsAreAuthority: true
			runtimeOutputsAreAuthority:   true
		}
	}
	projectionOutsideCodexPluginsAccepted: {
		input: {
			bundleID:        "agent-context-resolver"
			path:            "generated/agent-context-resolver"
			role:            "runtime-projection"
			sourceAuthority: "contracts/plugin-bundle"
		}
	}
	externalRuntimeLookupAccepted: {
		input: {
			runtimeRequiresExternalFactoryLookup: true
			runtimeRequiresContractCuemodLookup:  true
			broadRepoScanRequired:               true
		}
	}
	sourceRootOutsidePluginBundleAccepted: {
		input: {
			bundleID:               "agent-context-resolver"
			path:                   "contracts/agent-context-resolver"
			role:                   "bundle-source-authority"
			templateShapeAuthority: "contracts/plugin-bundle/template/template.cue"
		}
	}
	topLevelGeneratedRootAccepted: {
		input: {
			root:               "contracts/plugin-bundle"
			topLevelGeneratedRoot: true
			generatedRootScope: "root"
			generatedRoots: ["contracts/plugin-bundle/generated"]
		}
	}
}

_negativeBottomChecks: {
	factoryRootAsPluginBundleAuthorityAccepted: _negativeFixtures.factoryRootAsPluginBundleAuthorityAccepted.input & root.#PluginBundleRootAuthority
	generatedRuntimeAuthorityAccepted:          _negativeFixtures.generatedRuntimeAuthorityAccepted.input & root.#PluginBundleRootAuthority
	projectionOutsideCodexPluginsAccepted:      _negativeFixtures.projectionOutsideCodexPluginsAccepted.input & root.#PluginBundleRuntimeProjectionRoot
	externalRuntimeLookupAccepted:              _negativeFixtures.externalRuntimeLookupAccepted.input & root.#PluginBundleRuntimeIndependenceBoundary
	sourceRootOutsidePluginBundleAccepted:      _negativeFixtures.sourceRootOutsidePluginBundleAccepted.input & root.#PluginBundleSourceRoot
	topLevelGeneratedRootAccepted:              _negativeFixtures.topLevelGeneratedRootAccepted.input & root.#PluginBundleRootAuthority
}

pluginBundleRootNegativeBottomChecks: _negativeBottomChecks
