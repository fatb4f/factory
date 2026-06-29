package issue82checks

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
	generatedPackageAuthorityAccepted:     _negativeFixtures.generatedPackageAuthorityAccepted.input
	distributionOutsidePluginRootAccepted: _negativeFixtures.distributionOutsidePluginRootAccepted.input
	nonDeterministicGenerationAccepted:    _negativeFixtures.nonDeterministicGenerationAccepted.input
	runtimeExternalSourceLookupAccepted:   _negativeFixtures.runtimeExternalSourceLookupAccepted.input
}
