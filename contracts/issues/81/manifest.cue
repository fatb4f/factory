package issue81

import acr "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

import codeintel "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/code-intel/src:codeintelsrc"

_issueNumber: 81
_issueTitle:  "cue(plugin-bundle): conform resolver and code-intel bundles to template shape"

_publicExports: [
	"normalizedMaterializedBundleShapeManifest",
	"materializedBundleShapeValidationPlan",
	"materializedBundleShapeCompletionReportContract",
]

normalizedIssueManifest: close({
	issue:         _issueNumber
	title:         _issueTitle
	repository:    "fatb4f/factory"
	parentIssue:   79
	templateShape: "contracts/plugin-bundle/template/template.cue"
	materializedBundles: {
		resolver:  acr.normalizedMaterializedBundleShapeManifest
		codeIntel: codeintel.normalizedMaterializedBundleShapeManifest
	}
	publicExportsPerBundle: _publicExports
	negativeChecks: ["resolverShapeDrift", "codeIntelShapeDrift"]
	acceptance: [
		"resolver src root conforms to template-defined shape",
		"code-intel src root conforms to template-defined shape",
		"bundle differences are represented as values and content",
		"generated outputs remain evidence-only",
	]
})

normalizedMaterializedBundleShapeManifest: normalizedIssueManifest

materializedBundleShapeValidationPlan: close({
	path: "contracts/issues/81"
	positive: [
		"cue vet ./contracts/plugin-bundle/agent-context-resolver/src",
		"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e normalizedMaterializedBundleShapeManifest",
		"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e materializedBundleShapeValidationPlan",
		"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e materializedBundleShapeCompletionReportContract",
		"cue vet ./contracts/plugin-bundle/code-intel/src",
		"cue export ./contracts/plugin-bundle/code-intel/src -e normalizedMaterializedBundleShapeManifest",
		"cue export ./contracts/plugin-bundle/code-intel/src -e materializedBundleShapeValidationPlan",
		"cue export ./contracts/plugin-bundle/code-intel/src -e materializedBundleShapeCompletionReportContract",
	]
	negative: [
		"! cue export ./contracts/issues/81/checks -e _negativeBottomChecks.resolverShapeDrift",
		"! cue export ./contracts/issues/81/checks -e _negativeBottomChecks.codeIntelShapeDrift",
	]
})

materializedBundleShapeCompletionReportContract: close({
	summary: [
		"resolver and code-intel src roots share #PluginBundleSrcRootShape",
		"materialized manifests expose normalized shape, validation, and completion surfaces",
		"issue-local drift checks prove per-bundle srcRoot divergence bottoms",
	]
	filesChanged: [
		"contracts/plugin-bundle/agent-context-resolver/src/bundle_shape.cue",
		"contracts/plugin-bundle/code-intel/src/bundle_shape.cue",
		"contracts/issues/81/manifest.cue",
		"contracts/issues/81/checks/checks.cue",
	]
	exportsAdded: _publicExports
	validation:   materializedBundleShapeValidationPlan
	finalResult:  "issue #81 close-ready once materialized exports and drift checks pass"
})
