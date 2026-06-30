package pluginbundlesrc

import (
	impl "github.com/fatb4f/factory/contracts/meta"
	"strings"
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
		"contracts/plugin-bundle/generated/<plugin-name>/.codex-plugin/plugin.json",
		"contracts/plugin-bundle/generated/<plugin-name>/skills/SKILL.md",
		"contracts/plugin-bundle/generated/<plugin-name>/hooks/hooks.json",
		"contracts/plugin-bundle/generated/<plugin-name>/scripts/README.md",
	]
	invariants: [
		"contracts/plugin-bundle/src remains parent authority for generated plugin-bundle children",
		"generated plugin-bundle artifacts are evidence only",
		"generated plugin files are projection evidence under contracts/plugin-bundle/generated/<plugin-name>",
		"generated plugin files are not emitted under the contract projection root",
		"generated plugin files are not emitted as repo-root installation output",
		"generated child contracts use repo-relative paths only",
		"generated child checks use #MakeBottomCheckProof",
		"generated plugin-bundle children materialize the standard physical plugin layout",
	]
}

// source: contracts/plugin-bundle/src/manifest.cue
#NonEmptyString:             string & !=""
#RelativeContractPath:       string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"
#RepoPath:                   string & !=""
_staleLocalCheckPath:        "contracts/stale/checks"
#ValidationCommand:          string & !="" & !~"\(_staleLocalCheckPath)"
#PluginBundlePluginName:     string & =~"^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$"
#PluginBundleCuePackageName: string & =~"^[A-Za-z_][0-9A-Za-z_]*$"

#PluginBundleAdapterRepoRootBoundary: close({
	repoRoot:              string & !="" & =~"^/"
	scriptPath:            string & !="" & =~"(^|/)contracts/plugin-bundle/src/adapters/scaffold-plugin-bundle$"
	contractRoot:          string & !="" & !~"^Path\\(out_arg\\)$"
	generatedRoot:         string & !="" & !~"^Path\\(generated_root\\)$"
	writesAreRepoAnchored: true
})

#PluginBundlePluginNameRule: close({
	pluginName:               #PluginBundlePluginName
	pattern:                  "^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$"
	maxLength:                64
	folderEqualsManifestName: true
})

#PluginBundleCuePackageNameRule: close({
	bundleID:           #PluginBundlePluginName
	cuePackage:         #PluginBundleCuePackageName & =~"^pluginbundle_"
	packagePrefix:      "pluginbundle_"
	validCueIdentifier: true
})

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

#PluginBundleGeneratedProjectionLayout: close({
	pluginName:    #PluginBundlePluginName
	generatedRoot: "contracts/plugin-bundle/generated/\(pluginName)"
	manifest:      "\(generatedRoot)/.codex-plugin/plugin.json"
	skills:        "\(generatedRoot)/skills"
	hooks:         "\(generatedRoot)/hooks"
	scripts:       "\(generatedRoot)/scripts"
	evidenceOnly:  true
	authority:     false
	requiredPaths: [
		manifest,
		skills,
		hooks,
		scripts,
	]
})

#PluginBundleScaffoldRootDerivation: close({
	bundleID:             #PluginBundlePluginName
	contractRoot:         "contracts/plugin-bundle/\(bundleID)/src"
	generatedRoot:        "contracts/plugin-bundle/generated/\(bundleID)"
	contractRootPattern:  "contracts/plugin-bundle/<bundle-id>/src"
	generatedRootPattern: "contracts/plugin-bundle/generated/<bundle-id>"
	cuePackage:           #PluginBundleCuePackageName & "pluginbundle_\(strings.Replace(bundleID, "-", "_", -1))"
	packagePrefix:        "pluginbundle_"
	validCueIdentifier:   true
})

#PluginBundleContractProjectionLayout: close({
	pluginName:   #PluginBundlePluginName
	contractRoot: "contracts/plugin-bundle/\(pluginName)/src"
	publicExports: [
		"pluginBundleContract",
		"pluginBundleValidationPlan",
		"pluginBundleCompletionReport",
	]
})

#PluginBundleGeneratorAssertion: close({
	id:     #NonEmptyString
	target: #NonEmptyString
	requires: [...#NonEmptyString] & [_, ...]
})

#PluginBundleValidationShape: close({
	commands: [...#ValidationCommand] & [_, ...]
	negativeChecks: [...#NonEmptyString] | *[]
	forbiddenAttractors: [...string] | *[]
})

#PluginBundleShapeManifest: close({
	bundleID:                          #PluginBundlePluginName
	shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
	srcRootShapeAuthority:             "contracts/plugin-bundle/src/manifest.cue"
	generatedArtifactsAreEvidenceOnly: true
	bundleLocalShapeOverride:          false
})

#PluginBundleSrcRootShape: close({
	srcRoot:                  #RepoPath
	contracts:                #PluginBundleContractsShape
	generated:                #PluginBundleGeneratedShape
	contractProjection:       #PluginBundleContractProjectionLayout
	generatedProjection:      #PluginBundleGeneratedProjectionLayout
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
		"#PluginBundleAdapterRepoRootBoundary",
		"#PluginBundlePluginNameRule",
		"#PluginBundleCuePackageNameRule",
		"#PluginBundleSrcRootShape",
		"#PluginBundleGeneratedProjectionLayout",
		"#PluginBundleContractProjectionLayout",
		"#PluginBundleScaffoldRootDerivation",
		"#PluginBundleGeneratorAssertion",
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
		"generated plugin projection output is separate from contract projection output",
		"repo-root plugin installation output is outside this slice",
		"bundle-local shape overrides are rejected",
		"relative contract paths reject absolute paths and parent traversal",
		"plugin names are lowercase hyphen-case and bounded to the plugin manifest name limit",
		"generated CUE package names are stable valid identifiers with a non-numeric prefix",
		"adapter writes are anchored to the repo root resolved from the adapter script path",
		"validation commands do not reference stale local checks",
	]
})

pluginBundleGeneratorAssertions: {
	generatedProjectionRoot: #PluginBundleGeneratorAssertion & {
		id:     "generated-projection-root"
		target: "#PluginBundleGeneratedProjectionLayout"
		requires: [
			"generatedRoot is contracts/plugin-bundle/generated/<plugin-name>",
			"generated plugin files are projection evidence only",
		]
	}
	contractProjectionRoot: #PluginBundleGeneratorAssertion & {
		id:     "contract-projection-root"
		target: "#PluginBundleContractProjectionLayout"
		requires: [
			"contractRoot is contracts/plugin-bundle/<plugin-name>/src",
			"public exports include pluginBundleContract",
			"public exports include pluginBundleValidationPlan",
			"public exports include pluginBundleCompletionReport",
		]
	}
	outputPlaneSeparation: #PluginBundleGeneratorAssertion & {
		id:     "output-plane-separation"
		target: "pluginBundleScaffoldGenerator"
		requires: [
			"generated plugin files are not emitted under the contract projection root",
			"generated plugin files are not emitted as repo-root installation output",
		]
	}
}

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
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.cwdRelativeWriteAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.uppercaseOrUnderscorePluginNameAccepted",
		"! cue export ./contracts/plugin-bundle/<bundle-id>/src/checks -e _negativeBottomChecks.numericLeadingCuePackageAccepted",
	]
	negativeChecks: [
		"generatedAuthorityAccepted",
		"externalLookupAccepted",
		"absolutePathAccepted",
		"parentTraversalAccepted",
		"missingRequiredPathAccepted",
		"bundleLocalOverrideAccepted",
		"cwdRelativeWriteAccepted",
		"uppercaseOrUnderscorePluginNameAccepted",
		"numericLeadingCuePackageAccepted",
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
		"cwd-relative adapter writes",
		"uppercase or underscore plugin names",
		"numeric-leading generated CUE package declarations",
		"contract projection output and generated plugin projection output are separate planes",
		"repo-root plugin installation output is outside this slice",
	]
}
