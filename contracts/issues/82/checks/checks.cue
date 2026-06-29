package issue82checks

#GeneratedPackageAuthorityBoundary: close({
	path: string & =~"^\\.codex/plugins/[^/]+/.+"
	role: "projection"
	generatedPackageAuthority?: false
})

#DistributionRootContainmentBoundary: close({
	bundleID: string & !=""
	distributionRoot: string & =~"^\\.codex/plugins/[^/]+$"
	pathContained: true
})

#DeterministicGenerationBoundary: close({
	generatedAtRuntime?: false
	nonDeterministicInput?: false
})

#RuntimeExternalSourceLookupBoundary: close({
	runtimeRequiresExternalFactoryLookup?: false
	runtimeRequiresContractCuemodLookup?: false
})

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
	generatedPackageAuthorityAccepted:     _negativeFixtures.generatedPackageAuthorityAccepted.input & #GeneratedPackageAuthorityBoundary
	distributionOutsidePluginRootAccepted: _negativeFixtures.distributionOutsidePluginRootAccepted.input & #DistributionRootContainmentBoundary
	nonDeterministicGenerationAccepted:    _negativeFixtures.nonDeterministicGenerationAccepted.input & #DeterministicGenerationBoundary
	runtimeExternalSourceLookupAccepted:   _negativeFixtures.runtimeExternalSourceLookupAccepted.input & #RuntimeExternalSourceLookupBoundary
}
