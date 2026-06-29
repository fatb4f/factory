set shell := ["sh", "-eu", "-c"]

contracts-meta:
	cue vet ./contracts/meta
	cue export ./contracts/meta -e constructorLibraryBaseline >/dev/null
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null
	cue export ./contracts/meta -e generatedContractCompliance >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractGeneratorMissingOutputAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorAbsoluteTargetAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorStaleLocalCheckAccepted >/dev/null
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
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted >/dev/null

contracts-agent-context-resolver-src:
	cue vet ./contracts/agent-context-resolver/src
	cue export ./contracts/agent-context-resolver/src -e normalizedMaterializedBundleShapeManifest >/dev/null
	cue export ./contracts/agent-context-resolver/src -e materializedBundleShapeValidationPlan >/dev/null
	cue export ./contracts/agent-context-resolver/src -e materializedBundleShapeCompletionReportContract >/dev/null

contracts-code-intel-src:
	cue vet ./contracts/code-intel/src
	cue export ./contracts/code-intel/src -e normalizedMaterializedBundleShapeManifest >/dev/null
	cue export ./contracts/code-intel/src -e materializedBundleShapeValidationPlan >/dev/null
	cue export ./contracts/code-intel/src -e materializedBundleShapeCompletionReportContract >/dev/null

contracts-consolidation-guards:
	! rg 'contracts/plugin-bundle/(agent-context-resolver|code-intel)/src' ./contracts/agent-context-resolver/src ./contracts/code-intel/src
	! rg 'contracts/code-intel/manifest\.cue' ./contracts/code-intel/src

scaffold-smoke:
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null

validate-all: contracts-meta contracts-plugin-bundle-template contracts-agent-context-resolver-src contracts-code-intel-src contracts-consolidation-guards scaffold-smoke
