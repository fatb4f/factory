package pluginbundlegenerationdistributionchecks

import gen "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/generation-distribution:pluginbundlegenerationdistribution"

_negativeFixtures: {
	generatedPackageAuthorityAccepted: {
		input: {
			path:                      ".codex/plugins/agent-context-resolver/manifest.json"
			role:                      "authority"
			generatedPackageAuthority: true
		}
	}
	distributionOutsidePluginRootAccepted: {
		input: {
			bundleID:         "agent-context-resolver"
			distributionRoot: ".codex/../contracts/plugin-bundle/agent-context-resolver/src"
			pathContained:    false
		}
	}
	nonDeterministicGenerationAccepted: {
		input: {
			generatedAtRuntime:    true
			nonDeterministicInput: true
		}
	}
	runtimeExternalSourceLookupAccepted: {
		input: {
			runtimeRequiresExternalFactoryLookup: true
			runtimeRequiresContractCuemodLookup:  true
		}
	}
}

_negativeBottomChecks: {
	generatedPackageAuthorityAccepted:     _negativeFixtures.generatedPackageAuthorityAccepted.input & gen.#GeneratedPackageAuthorityBoundary
	distributionOutsidePluginRootAccepted: _negativeFixtures.distributionOutsidePluginRootAccepted.input & gen.#DistributionRootContainmentBoundary
	nonDeterministicGenerationAccepted:    _negativeFixtures.nonDeterministicGenerationAccepted.input & gen.#DeterministicGenerationBoundary
	runtimeExternalSourceLookupAccepted:   _negativeFixtures.runtimeExternalSourceLookupAccepted.input & gen.#RuntimeExternalSourceLookupBoundary
}

pluginBundleGenerationDistributionNegativeBottomChecks: _negativeBottomChecks
