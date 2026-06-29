package pluginbundletemplate

#NonEmptyString:       string & !=""
#RelativeContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"
#RepoPath:             string & !=""
_issuePathPrefix:      "contracts/issues"
_issue81Segment:       "81"
_staleIssue81Path:     "\(_issuePathPrefix)/\(_issue81Segment)"
#ValidationCommand:    string & !="" & !~"\(_staleIssue81Path)"

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
	srcRootShapeAuthority:             "contracts/plugin-bundle/template/template.cue"
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
	schema:  "factory.plugin-bundle.template.contract.v1"
	package: "pluginbundletemplate"
	exports: [
		"#RelativeContractPath",
		"#PluginBundleSrcRootShape",
		"#PluginBundleTarget",
		"#PluginBundleGate",
		"#PluginBundleTargetFile",
		"#PluginBundleProjectionComponent",
		"#PluginBundleProviderReachabilityEvidence",
		"#PluginBundleAuthorityPolicy",
	]
	requirements: [
		"generated artifacts are evidence only",
		"bundle-local shape overrides are rejected",
		"relative contract paths reject absolute paths and parent traversal",
		"validation commands do not reference issue-81-local checks",
	]
})

_negativeBottomChecks: {
	generatedAuthorityAccepted: *(#PluginBundleAuthorityPolicy & {
		generatedAuthority: true
	}) | _
	externalLookupAccepted: *(#PluginBundleAuthorityPolicy & {
		externalFactoryRootLookup: true
	}) | _
	absolutePathAccepted:    *(#RelativeContractPath & "/absolute/path") | _
	parentTraversalAccepted: *(#RelativeContractPath & "../outside") | _
	missingRequiredPathAccepted: *(#PluginBundleContractsShape & {
		requiredPaths: []
	}) | _
	bundleLocalOverrideAccepted: *(#PluginBundleSrcRootShape & {
		bundleLocalShapeOverride: true
	}) | _
	staleIssue81CheckReferenceAccepted: *(#ValidationCommand & "cue export ./\(_staleIssue81Path)/checks -e _negativeBottomChecks.shapeDrift") | _
}
