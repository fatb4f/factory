package issue80

import tmpl "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/template:pluginbundletemplate"

_issueNumber: 80
_issueTitle:  "cue(plugin-bundle): define template shape authority"

_publicExports: [
	"normalizedPluginBundleTemplateShapeManifest",
	"pluginBundleTemplateShapeValidationPlan",
	"pluginBundleTemplateShapeCompletionReportContract",
]

normalizedIssueManifest: close({
	issue:        _issueNumber
	title:        _issueTitle
	repository:   "fatb4f/factory"
	parentIssue:  79
	templatePath: "contracts/plugin-bundle/template/template.cue"
	requiredTemplateFields: ["srcRoot", "contracts", "generated", "validation", "manifest"]
	templateExports:  _publicExports
	templateManifest: tmpl.normalizedPluginBundleTemplateShapeManifest
	negativeChecks: ["bundleLocalShapeOverrideAccepted"]
	acceptance: [
		"template package exports canonical plugin-bundle src-root shape",
		"template shape defines structure only",
		"bundle-specific semantics remain materialized values",
		"bundle-local shape override bottoms",
	]
})

normalizedPluginBundleTemplateShapeManifest: normalizedIssueManifest

pluginBundleTemplateShapeValidationPlan: close({
	path: "contracts/issues/80"
	positive: [
		"cue vet ./contracts/plugin-bundle/template",
		"cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateShapeBaseline",
		"cue export ./contracts/plugin-bundle/template -e normalizedPluginBundleTemplateShapeManifest",
		"cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateShapeValidationPlan",
		"cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateShapeCompletionReportContract",
	]
	negative: [
		"! cue export ./contracts/issues/80/checks -e _negativeBottomChecks.bundleLocalShapeOverrideAccepted",
	]
})

pluginBundleTemplateShapeCompletionReportContract: close({
	summary: [
		"contracts/plugin-bundle/template/template.cue defines #PluginBundleSrcRootShape",
		"plugin-bundle template shape baseline exports for validation",
		"issue-local check rejects bundle-local shape override",
	]
	filesChanged: [
		"contracts/plugin-bundle/template/template.cue",
		"contracts/issues/80/manifest.cue",
		"contracts/issues/80/checks/checks.cue",
	]
	exportsAdded: _publicExports
	validation:   pluginBundleTemplateShapeValidationPlan
	finalResult:  "issue #80 close-ready once exports and negative check pass"
})
