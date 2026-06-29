package issue83

_issueNumber: 83
_issueTitle:  "cue(plugin-bundle): define cross-repo generation and distribution targets"

_publicExports: [
	"normalizedCrossRepoPluginBundleDistributionManifest",
	"crossRepoPluginBundleDistributionValidationPlan",
	"crossRepoPluginBundleDistributionCompletionReportContract",
]

normalizedIssueManifest: close({
	issue:       _issueNumber
	title:       _issueTitle
	repository:  "fatb4f/factory"
	parentIssue: 79
	dependsOn:   [80, 81, 82]
	distributionTargets: [
		{
			sourceBundle:      "agent-context-resolver"
			sourceAuthority:   "contracts/plugin-bundle/generation-distribution"
			targetRepository:  "fatb4f/factory"
			targetPath:        ".codex/plugins/agent-context-resolver"
			distributionMode:   "repo-local-runtime-projection"
		},
		{
			sourceBundle:      "agent-context-resolver"
			sourceAuthority:   "contracts/plugin-bundle/generation-distribution"
			targetRepository:  "fatb4f/dotfiles"
			targetPath:        ".codex/plugins/agent-context-resolver"
			distributionMode:   "consumer-runtime-projection"
		},
		{
			sourceBundle:      "code-intel"
			sourceAuthority:   "contracts/plugin-bundle/generation-distribution"
			targetRepository:  "fatb4f/dotfiles"
			targetPath:        ".codex/plugins/code-intel"
			distributionMode:   "consumer-runtime-projection"
		},
	]
	negativeChecks: [
		"codeIntelDistributedToFactoryAccepted",
		"dotfilesSourceAuthorityAccepted",
		"outsidePluginRootAccepted",
		"unreviewedCrossRepoWriteAccepted",
	]
	acceptance: [
		"factory retains canonical generation/distribution authority",
		"agent-context-resolver distributes to factory and dotfiles",
		"code-intel distributes to dotfiles only",
		"cross-repo promotion requires reviewable, path-contained diffs",
	]
})

normalizedCrossRepoPluginBundleDistributionManifest: normalizedIssueManifest

crossRepoPluginBundleDistributionValidationPlan: close({
	path: "contracts/issues/83"
	positive: [
		"cue vet ./contracts/plugin-bundle/generation-distribution",
		"cue export ./contracts/plugin-bundle/generation-distribution -e normalizedCrossRepoPluginBundleDistributionManifest",
		"cue export ./contracts/plugin-bundle/generation-distribution -e crossRepoPluginBundleDistributionValidationPlan",
		"cue export ./contracts/plugin-bundle/generation-distribution -e crossRepoPluginBundleDistributionCompletionReportContract",
		"cue vet ./contracts/issues/83",
		"cue export ./contracts/issues/83 -e normalizedCrossRepoPluginBundleDistributionManifest",
		"cue export ./contracts/issues/83 -e crossRepoPluginBundleDistributionValidationPlan",
		"cue export ./contracts/issues/83 -e crossRepoPluginBundleDistributionCompletionReportContract",
	]
	negative: [
		"! cue export ./contracts/issues/83/checks -e _negativeBottomChecks.codeIntelDistributedToFactoryAccepted",
		"! cue export ./contracts/issues/83/checks -e _negativeBottomChecks.dotfilesSourceAuthorityAccepted",
		"! cue export ./contracts/issues/83/checks -e _negativeBottomChecks.outsidePluginRootAccepted",
		"! cue export ./contracts/issues/83/checks -e _negativeBottomChecks.unreviewedCrossRepoWriteAccepted",
	]
})

crossRepoPluginBundleDistributionCompletionReportContract: close({
	summary: [
		"factory owns canonical plugin-bundle generation/distribution authority",
		"issue 83 records cross-repo runtime projections for factory and dotfiles",
		"issue-local checks prove authority, containment, and review boundaries bottom",
	]
	filesChanged: [
		"contracts/plugin-bundle/generation-distribution/manifest.cue",
		"contracts/plugin-bundle/generation-distribution/checks/checks.cue",
		"contracts/issues/83/manifest.cue",
		"contracts/issues/83/checks/checks.cue",
	]
	exportsAdded: _publicExports
	validation:   crossRepoPluginBundleDistributionValidationPlan
	finalResult:  "issue #83 close-ready once cross-repo targets and negative checks pass"
})
