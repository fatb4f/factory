set shell := ["sh", "-eu", "-c"]

contracts-meta:
	cue vet ./contracts/meta
	cue export ./contracts/meta -e constructorLibraryBaseline >/dev/null
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null
	cue export ./contracts/meta -e generatedContractCompliance >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractGeneratorMissingOutputAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorAbsoluteTargetAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorStaleIssueLocalCheckAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.generatedComplianceAuthorityAccepted >/dev/null

contracts-plugin-bundle-template:
	cue vet ./contracts/plugin-bundle/template
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateContract >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateContractMetaCompliance >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleScaffoldGenerator >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleScaffoldValidator >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateCompliance >/dev/null
	cue vet ./contracts/plugin-bundle/template/checks
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.generatedAuthorityAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.externalLookupAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.absolutePathAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.parentTraversalAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.missingRequiredPathAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.bundleLocalOverrideAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.staleIssue81CheckReferenceAccepted >/dev/null

contracts-issue-0:
	cue vet ./contracts/issues/0
	cue export ./contracts/issues/0 -e normalizedIssueManifest >/dev/null
	cue export ./contracts/issues/0 -e issueValidationPlan >/dev/null
	cue export ./contracts/issues/0 -e issueCompletionReportContract >/dev/null
	cue vet ./contracts/issues/0/checks
	! cue export ./contracts/issues/0/checks -e _negativeBottomChecks.generatedArtifactsAuthorityAccepted >/dev/null
	! cue export ./contracts/issues/0/checks -e _negativeBottomChecks.staleLocalCheckAccepted >/dev/null
	! cue export ./contracts/issues/0/checks -e _negativeBottomChecks.externalLookupAccepted >/dev/null
	! cue export ./contracts/issues/0/checks -e _negativeBottomChecks.rootedPathAccepted >/dev/null
	! cue export ./contracts/issues/0/checks -e _negativeBottomChecks.parentTraversalAccepted >/dev/null
	! rg '[t]arget:\s*_|[i]nput:\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority|O[O] inheritance|external lookup authorit[y]|parent traversa[l]|absolute pat[h]|optional negative bottom-check' ./contracts/issues/0

scaffold-smoke:
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null

validate-all: contracts-meta contracts-plugin-bundle-template contracts-issue-0 scaffold-smoke
