package pluginbundlesrc

import (
	impl "github.com/fatb4f/factory/contracts/meta"
)

// source: contracts/plugin-bundle/src/manifest.cue
pluginBundleScaffoldGenerator: impl.#ContractGenerator & {
	kind:    "contract-generator"
	id:      "pluginBundleScaffoldGenerator"
	name:    "pluginBundleScaffoldGenerator"
	command: "contracts/plugin-bundle/src/adapters/scaffold-plugin-bundle"
	inputs: [
		"bundle-id",
		"src-root",
		"out",
		"force",
	]
	outputs: [
		"manifest.cue",
		"checks/manifest.cue",
		"generated/checks/check_manifest.json",
	]
	invariants: [
		"contracts/plugin-bundle/src remains parent authority for generated plugin-bundle children",
		"generated plugin-bundle artifacts are evidence only",
		"generated child contracts use repo-relative paths only",
		"generated child checks use #MakeBottomCheckProof",
	]
}

// source: contracts/plugin-bundle/src/manifest.cue
#NonEmptyString:       string & !=""
#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"
#RepoPath:             string & !=""
_staleLocalCheckPath:  "contracts/stale/checks"
#ValidationCommand:    string & !="" & !~"\(_staleLocalCheckPath)"

#PluginBundleCuePackage: close({
	id:   #NonEmptyString
	path: #RelativeContractPath
})

#PluginBundleContractsShape: close({
	root: #RepoPath
	cuePackages: [...#PluginBundleCuePackage] & [_, ...]
	requiredPaths: [...#RelativeContractPath] & [_, ...]
})

#PluginBundleGeneratedArtifact: close({
	path:         #RelativeContractPath
	required:     bool | *true
	evidenceOnly: true
})

#PluginBundleGeneratedShape: close({
	root:         #RepoPath
	evidenceOnly: true
	artifacts: [...#PluginBundleGeneratedArtifact] & [_, ...]
})

#PluginBundleValidationShape: close({
	commands: [...#ValidationCommand] & [_, ...]
	negativeChecks: [...#NonEmptyString] | *[]
	forbiddenAttractors: [...string] | *[]
})

#PluginBundleShapeManifest: close({
	bundleID:                          #NonEmptyString
	shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
	srcRootShapeAuthority:             "contracts/plugin-bundle/src/manifest.cue"
	generatedArtifactsAreEvidenceOnly: true
	bundleLocalShapeOverride:          false
})

#PluginBundleSrcRootShape: close({
	srcRoot:                  #RepoPath
	contracts:                #PluginBundleContractsShape
	generated:                #PluginBundleGeneratedShape
	validation:               #PluginBundleValidationShape
	manifest:                 #PluginBundleShapeManifest
	bundleLocalShapeOverride: false
})

#PluginBundleTarget: close({
	repo: #NonEmptyString
	root: #RepoPath
})

#PluginBundleGate: close({
	id:       #NonEmptyString
	kind:     "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search" | "plugin-manifest" | "archive"
	target:   #NonEmptyString
	required: true
})

#PluginBundleTargetFile: close({
	path:      #RelativeContractPath
	generated: true
	authority: false
	source:    "bundle-projection"
})

#PluginBundleProjectionComponent: close({
	id:        #NonEmptyString
	path:      #RepoPath
	role:      "contract" | "projection" | "package-source" | "generated-output" | "evidence" | "integration" | "generated-package" | "package-content" | "package-metadata" | "idempotency-lock"
	generated: *false | bool
	authority: bool
})

#PluginBundleProviderReachabilityEvidence: close({
	kind:         "provider-reachability"
	authority:    false
	evidenceOnly: true
	providers: [...#NonEmptyString]
})

#PluginBundleAuthorityPolicy: close({
	generatedAuthority?:             false
	generatedArtifactsAreAuthority?: false
	providerOutputIsAuthority?:      false
	externalFactoryRootLookup?:      false
	externalContractCuemodLookup?:   false
	topLevelPluginRoot?:             false
	proseReferenceAuthority?:        false
	bundleLocalShapeOverride?:       false
})

pluginBundleTemplateContract: close({
	schema:  "factory.plugin-bundle.src.contract.v1"
	package: "pluginbundlesrc"
	exports: [
		"#RelativeContractPath",
		"#PluginBundleSrcRootShape",
		"#PluginBundleTarget",
		"#PluginBundleGate",
		"#PluginBundleTargetFile",
		"#PluginBundleProjectionComponent",
		"#PluginBundleProviderReachabilityEvidence",
		"#PluginBundleAuthorityPolicy",
		"pluginBundleScaffoldGenerator",
		"pluginBundleScaffoldValidator",
		"pluginBundleTemplateCompliance",
		"pluginBundleTemplateContractMetaCompliance",
	]
	requirements: [
		"src validates against contracts/meta generated compliance before its own child surfaces are admitted",
		"generated artifacts are evidence only",
		"bundle-local shape overrides are rejected",
		"relative contract paths reject absolute paths and parent traversal",
		"validation commands do not reference stale local checks",
	]
})

pluginBundleTemplateContractMetaCompliance: impl.#GeneratedContractCompliance & {
	kind:      "generated-contract-compliance"
	generator: impl.contractScaffoldGenerator
	validator: impl.contractScaffoldValidator
	requiredExports: [
		"pluginBundleTemplateContract",
		"pluginBundleScaffoldGenerator",
		"pluginBundleScaffoldValidator",
		"pluginBundleTemplateCompliance",
	]
	requiredConstructors: [
		"#ContractGenerator",
		"#ContractValidator",
		"#GeneratedContractCompliance",
		"#MakeBottomCheckProof",
	]
	mustUseConstructors:            true
	mustUseMakeBottomCheckProof:    true
	requiresBottomCheckProof:       true
	generatedArtifactsAreAuthority: false
	evidenceOnlyGeneratedArtifacts: true
	bindings: {
		generatorName:   impl.contractScaffoldGenerator.name
		validatorName:   impl.contractScaffoldValidator.name
		parentAuthority: "contracts/meta"
	}
}

pluginBundleTemplateCompliance: impl.#GeneratedContractCompliance & {
	kind:      "generated-contract-compliance"
	generator: pluginBundleScaffoldGenerator
	validator: pluginBundleScaffoldValidator
	requiredExports: [
		"pluginBundleContract",
		"pluginBundleValidationPlan",
		"pluginBundleCompletionReport",
	]
	requiredConstructors: [
		"#ContractGenerator",
		"#ContractValidator",
		"#GeneratedContractCompliance",
		"#MakeBottomCheckProof",
		"#MakeValidationPlan",
		"#MakeCompletionReport",
	]
	mustUseConstructors:            true
	mustUseMakeBottomCheckProof:    true
	requiresBottomCheckProof:       true
	generatedArtifactsAreAuthority: false
	evidenceOnlyGeneratedArtifacts: true
	bindings: {
		generatorName:   pluginBundleScaffoldGenerator.name
		validatorName:   pluginBundleScaffoldValidator.name
		parentAuthority: "contracts/meta"
	}
}

// source: contracts/plugin-bundle/src/manifest.cue
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
