package issue82

import gen "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/generation-distribution:pluginbundlegenerationdistribution"

_issue: {
	number:        82
	title:         "cue(plugin-bundle): define generation and distribution surface"
	path:          "contracts/issues/82/manifest.cue"
	canonicalPath: "contracts/plugin-bundle/generation-distribution/manifest.cue"
	parent:        79
	dependsOn:     [80, 81]
}

normalizedPluginBundleGenerationDistributionManifest: gen.normalizedPluginBundleGenerationDistributionManifest & {
	issue: _issue
	issueProjection: close({
		role:               "issue-local projection"
		canonicalAuthority: "contracts/plugin-bundle/generation-distribution/manifest.cue"
		checkSurface:       "contracts/issues/82/checks"
	})
}

pluginBundleGenerationDistributionValidationPlan: close({
	path:          "contracts/issues/82"
	canonicalPath: "contracts/plugin-bundle/generation-distribution"
	positive: [
		"cue vet ./contracts/plugin-bundle/generation-distribution",
		"cue export ./contracts/plugin-bundle/generation-distribution -e normalizedPluginBundleGenerationDistributionManifest",
		"cue export ./contracts/plugin-bundle/generation-distribution -e pluginBundleGenerationDistributionValidationPlan",
		"cue export ./contracts/plugin-bundle/generation-distribution -e pluginBundleGenerationDistributionCompletionReportContract",
		"cue vet ./contracts/issues/82",
		"cue export ./contracts/issues/82 -e normalizedPluginBundleGenerationDistributionManifest",
		"cue export ./contracts/issues/82 -e pluginBundleGenerationDistributionValidationPlan",
		"cue export ./contracts/issues/82 -e pluginBundleGenerationDistributionCompletionReportContract",
	]
	negative: [
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.generatedPackageAuthorityAccepted",
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.distributionOutsidePluginRootAccepted",
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.nonDeterministicGenerationAccepted",
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.runtimeExternalSourceLookupAccepted",
		"! cue export ./contracts/issues/82/checks -e _negativeBottomChecks.generatedPackageAuthorityAccepted",
		"! cue export ./contracts/issues/82/checks -e _negativeBottomChecks.distributionOutsidePluginRootAccepted",
		"! cue export ./contracts/issues/82/checks -e _negativeBottomChecks.nonDeterministicGenerationAccepted",
		"! cue export ./contracts/issues/82/checks -e _negativeBottomChecks.runtimeExternalSourceLookupAccepted",
	]
})

pluginBundleGenerationDistributionCompletionReportContract: close({
	summary: [
		"canonical generation/distribution authority lives under contracts/plugin-bundle/generation-distribution",
		"contracts/issues/82 is an issue-local projection only",
		"negative checks bottom through the canonical plugin-bundle check surface and issue wrapper",
	]
	canonicalFiles: [
		"contracts/plugin-bundle/generation-distribution/manifest.cue",
		"contracts/plugin-bundle/generation-distribution/checks/checks.cue",
	]
	issueFiles: [
		"contracts/issues/82/manifest.cue",
		"contracts/issues/82/checks/checks.cue",
	]
	canonicalCompletion: gen.pluginBundleGenerationDistributionCompletionReportContract
	validation:          pluginBundleGenerationDistributionValidationPlan
	finalResult:         "issue #82 tracks the plugin-bundle generation/distribution authority surface"
})

normalizedIssueManifest: normalizedPluginBundleGenerationDistributionManifest
issue82ValidationPlan: pluginBundleGenerationDistributionValidationPlan
issue82CompletionReportContract: pluginBundleGenerationDistributionCompletionReportContract
