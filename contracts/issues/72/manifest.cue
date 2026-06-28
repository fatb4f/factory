package issue72

import "list"

_oldResolverRoot: "contracts/" + "agent-context-resolver"
_oldFactoryPluginBundleRoot: "contracts/factory/" + "plugin-bundle"
_materializedSrcRoot: ".codex/plugins/agent-context-resolver/" + "src"
_issueNumber: 72
_issueTitle: "cue: move agent-context-resolver into plugin-bundle source"
_layout: {
	sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
	instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	materializedResolverContracts: ".codex/plugins/agent-context-resolver/contracts/agent-context-resolver"
	materializedConstructorContracts: ".codex/plugins/agent-context-resolver/contracts/meta/impl"
}

issue: {
	number: _issueNumber
	title: _issueTitle
	contract: {
		path: "contracts/plugin-bundle/agent-context-resolver"
		package: "agentcontextresolverpluginbundle"
		slice: "agent-context-resolver-plugin-bundle-source-layout-v1"
	}
	layout: _layout
}

issue72Evidence: {
	commit: "fd2c650d84ad6fc75f0c83be4430b4ebac6827b6"
	message: "Move resolver contracts into plugin bundle"
	layout: _layout
	existingProofSurface: "contracts/issues/72/checks/checks.cue"
	existingNegativeChecks: [
		"factoryPluginBundleRootAccepted",
		"materializedSrcRootAccepted",
		"topLevelDotfilesPluginRootAccepted",
		"externalRuntimeSourceLookupAccepted",
		"lockMismatchAccepted",
	]
}

_publicExports: [
	"normalizedIssueManifest",
	"pluginBundleLayoutValidationPlan",
	"pluginBundleLayoutCompletionReportContract",
]

_closureNegativeChecks: [
	"missingNormalizedIssueManifestAccepted",
	"missingValidationPlanAccepted",
	"missingCompletionReportAccepted",
	"oldResolverRootAccepted",
	"oldFactoryPluginBundleRootAccepted",
]

normalizedIssueManifest: close({
	issue: _issueNumber
	title: _issueTitle
	contract: {
		path: "contracts/plugin-bundle/agent-context-resolver"
		package: "agentcontextresolverpluginbundle"
		slice: "agent-context-resolver-plugin-bundle-source-layout-v1"
	}
	evidence: issue72Evidence
	layout: _layout
	publicExports: _publicExports
	negativeChecks: list.Concat([issue72Evidence.existingNegativeChecks, _closureNegativeChecks])
	acceptance: [
		"normalizedIssueManifest exports",
		"pluginBundleLayoutValidationPlan exports",
		"pluginBundleLayoutCompletionReportContract exports",
		"issue-local negative checks bottom structurally",
		"fd2c650 path migration remains the implementation evidence",
		"no old top-level resolver root is referenced as source authority",
		"no factory plugin-bundle root remains under contracts/factory",
	]
})

pluginBundleLayoutValidationPlan: close({
	path: "contracts/issues/72"
	positive: [
		"cue vet ./contracts/issues/72",
		"cue export ./contracts/issues/72 -e normalizedIssueManifest",
		"cue export ./contracts/issues/72 -e pluginBundleLayoutValidationPlan",
		"cue export ./contracts/issues/72 -e pluginBundleLayoutCompletionReportContract",
	]
	negative: [
		for name in _closureNegativeChecks {
			"! cue export ./contracts/issues/72/checks -e \"_negativeBottomChecks.\(name)\""
		},
	]
	forbiddenAttractors: [
		{pattern: _oldResolverRoot, scope: "source authority"},
		{pattern: _oldFactoryPluginBundleRoot, scope: "factory plugin-bundle root"},
		{pattern: _materializedSrcRoot, scope: "materialized src path"},
		{pattern: "externalRuntimeSourceLookup: true", scope: "runtime source lookup"},
		{pattern: "generated.*authority", scope: "generated authority"},
	]
})

pluginBundleLayoutCompletionReportContract: close({
	summary: [
		"fd2c650 moved resolver source into contracts/plugin-bundle/agent-context-resolver/src",
		"dotfiles instance lives under contracts/plugin-bundle/agent-context-resolver/instances/dotfiles",
		"distribution lock binds source/template/instance/materialized roots",
		"issue-local normalized, validation, and completion exports were added",
		"negative checks prove missing public surfaces and old roots bottom",
	]
	filesChanged: [
		"contracts/issues/72/manifest.cue",
		"contracts/issues/72/checks/checks.cue",
	]
	exportsAdded: _publicExports
	negativeChecks: _closureNegativeChecks
	validation: pluginBundleLayoutValidationPlan
	finalResult: "issue #72 close-ready once exported surfaces and negative checks pass"
})
