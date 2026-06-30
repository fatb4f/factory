set shell := ["sh", "-eu", "-c"]

scaffold-contract-slice slice_id title out force="false":
	sh contracts/meta/scripts/scaffold-contract-slice --slice-id '{{slice_id}}' --title '{{title}}' --out '{{out}}' {{if force == "true" { "--force" } else { "" } }}

contracts-meta:
	cue vet ./contracts/meta
	cue export ./contracts/meta -e constructorLibraryBaseline >/dev/null
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null
	cue export ./contracts/meta -e generatedContractCompliance >/dev/null
	cue export ./contracts/meta/checks -e assertionGeneratedCheckManifest >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractGeneratorMissingOutputAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorAbsoluteTargetAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorStaleLocalCheckAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.generatedComplianceAuthorityAccepted >/dev/null

contracts-plugin-bundle-src:
	cue vet ./contracts/plugin-bundle/src
	cue export ./contracts/plugin-bundle/src -e pluginBundleTemplateContract >/dev/null
	cue export ./contracts/plugin-bundle/src -e pluginBundleTemplateContractMetaCompliance >/dev/null
	cue export ./contracts/plugin-bundle/src -e pluginBundleScaffoldGenerator >/dev/null
	cue export ./contracts/plugin-bundle/src -e pluginBundleScaffoldValidator >/dev/null
	cue export ./contracts/plugin-bundle/src -e pluginBundleTemplateCompliance >/dev/null
	cue vet ./contracts/plugin-bundle/src/checks
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.generatedAuthorityAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.externalLookupAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.absolutePathAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.parentTraversalAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.missingRequiredPathAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.bundleLocalOverrideAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted >/dev/null

contracts-plugin-bundle-template: contracts-plugin-bundle-src

contracts-agent-context-resolver-src:
	cue vet ./contracts/agent-context-resolver/src
	cue export ./contracts/agent-context-resolver/src -e normalizedMaterializedBundleShapeManifest >/dev/null
	cue export ./contracts/agent-context-resolver/src -e materializedBundleShapeValidationPlan >/dev/null
	cue export ./contracts/agent-context-resolver/src -e materializedBundleShapeCompletionReportContract >/dev/null

contracts-code-intel-src:
	cue vet ./contracts/code-intel/src
	cue vet ./contracts/code-intel/src/contracts/code-intel
	cue vet ./contracts/code-intel/src/contracts/code-intel/checks
	cue export ./contracts/code-intel/src -e normalizedMaterializedBundleShapeManifest >/dev/null
	cue export ./contracts/code-intel/src -e materializedBundleShapeValidationPlan >/dev/null
	cue export ./contracts/code-intel/src -e materializedBundleShapeCompletionReportContract >/dev/null
	cue export ./contracts/code-intel/src/contracts/code-intel -e codeIntelBoundaryReport >/dev/null
	cue export ./contracts/code-intel/src/contracts/code-intel -e codeIntelImplementationRecommendations >/dev/null
	! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.generatedAsAuthority >/dev/null
	! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.mcpOutputAsAuthority >/dev/null
	! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.lspDiagnosticsAsAuthority >/dev/null
	! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.weztermTypesAsAuthority >/dev/null
	! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.luaWorkflowGeneratedAsAuthority >/dev/null
	! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.resolverContractsLeak >/dev/null

contracts-consolidation-guards:
	! rg 'contracts/plugin-bundle/code-intel/src' ./contracts/code-intel/src
	! rg 'contracts/code-intel/manifest\.cue' ./contracts/code-intel/src

scaffold-smoke:
	mkdir -p .tmp && tmpdir=$(mktemp -d .tmp/plugin-bundle-smoke.XXXXXX) && contracts/plugin-bundle/src/adapters/scaffold-plugin-bundle --bundle-id smoke --src-root contracts/plugin-bundle/src --out "$tmpdir" --force && cue vet "$tmpdir/manifest.cue" && ! cue export "$tmpdir/checks/manifest.cue" -e _negativeBottomChecks.generatedAuthorityAccepted >/dev/null && cue export "$tmpdir/manifest.cue" -e contractSliceManifest >/dev/null && python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$tmpdir/generated/checks/check_manifest.json" && test -f "$tmpdir/generated/checks/check_manifest.json" && rm -rf "$tmpdir"

validate-all: contracts-meta contracts-plugin-bundle-src contracts-agent-context-resolver-src contracts-code-intel-src contracts-consolidation-guards scaffold-smoke
