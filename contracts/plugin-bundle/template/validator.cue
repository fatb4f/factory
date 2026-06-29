package pluginbundletemplate

import impl "github.com/fatb4f/factory/contracts/meta"

pluginBundleScaffoldValidator: impl.#ContractValidator & {
	kind:       "contract-validator"
	id:         "pluginBundleScaffoldValidator"
	name:       "pluginBundleScaffoldValidator"
	target:     "contracts/plugin-bundle/<bundle-id>/src"
	targetPath: "contracts/plugin-bundle/<bundle-id>/src"
	commands: [
		"cue vet ./contracts/plugin-bundle/<bundle-id>/src",
		"cue export ./contracts/plugin-bundle/<bundle-id>/src -e pluginBundleContract",
		"cue vet ./contracts/plugin-bundle/<bundle-id>/src/checks",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.generatedAuthorityAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.externalLookupAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.absolutePathAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.parentTraversalAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.missingRequiredPathAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.bundleLocalOverrideAccepted",
	]
	negativeChecks: [
		"generatedAuthorityAccepted",
		"externalLookupAccepted",
		"absolutePathAccepted",
		"parentTraversalAccepted",
		"missingRequiredPathAccepted",
		"bundleLocalOverrideAccepted",
	]
	forbiddenPattern: "^/|\\.\\./|external lookup authority"
	rejects: [
		"generated files treated as contract authority",
		"stale local checks",
		"external lookup authority",
		"absolute generated paths",
		"parent traversal paths",
		"missing required contract paths",
		"bundle-local shape override escapes",
	]
}
