package pluginbundlegenerationdistributiongeneratedchecks

import gen "github.com/fatb4f/factory/contracts/plugin-bundle/generation-distribution:pluginbundlegenerationdistribution"

_generatedFromContractAssertions: close({
	source: "contracts/plugin-bundle/generation-distribution/manifest.cue"
	contract: "plugin-bundle-generation-distribution"
	fixtureSurface: "negativePluginBundleGenerationDistributionFixtures"
	checkSurface: "_negativeBottomChecks"
	assertions: [
		"generatedPackageAuthorityAccepted",
		"distributionOutsidePluginRootAccepted",
		"nonDeterministicGenerationAccepted",
		"runtimeExternalSourceLookupAccepted",
	]
})

_negativeBottomChecks: {
	generatedPackageAuthorityAccepted:     gen.negativePluginBundleGenerationDistributionFixtures.generatedPackageAuthorityAccepted.input & gen.#GeneratedPackageAuthorityBoundary
	distributionOutsidePluginRootAccepted: gen.negativePluginBundleGenerationDistributionFixtures.distributionOutsidePluginRootAccepted.input & gen.#DistributionRootContainmentBoundary
	nonDeterministicGenerationAccepted:    gen.negativePluginBundleGenerationDistributionFixtures.nonDeterministicGenerationAccepted.input & gen.#DeterministicGenerationBoundary
	runtimeExternalSourceLookupAccepted:   gen.negativePluginBundleGenerationDistributionFixtures.runtimeExternalSourceLookupAccepted.input & gen.#RuntimeExternalSourceLookupBoundary
}

pluginBundleGenerationDistributionNegativeBottomChecks: _negativeBottomChecks
