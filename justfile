set shell := ["sh", "-eu", "-c"]

contracts-meta:
	cue vet ./contracts/meta
	cue export ./contracts/meta -e constructorLibraryBaseline >/dev/null
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null
	cue export ./contracts/meta -e generatedContractCompliance >/dev/null

contracts-plugin-bundle-template:
	cue vet ./contracts/plugin-bundle/template
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateContract >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleScaffoldGenerator >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleScaffoldValidator >/dev/null
	cue vet ./contracts/plugin-bundle/template/checks

contracts-issue-0:
	cue vet ./contracts/issues/0
	cue export ./contracts/issues/0 -e normalizedIssueManifest >/dev/null
	cue export ./contracts/issues/0 -e issueValidationPlan >/dev/null
	cue export ./contracts/issues/0 -e issueCompletionReportContract >/dev/null
