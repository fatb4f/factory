package issue72checks

_oldResolverRoot: "contracts/" + "agent-context-resolver"
_oldFactoryPluginBundleRoot: "contracts/factory/" + "plugin-bundle"
_materializedSrcRoot: ".codex/plugins/agent-context-resolver/" + "src"
_topLevelDotfilesPluginRoot: "plugins/" + "agent-context-resolver"
_runtimeLookupEnabled: true

#Layout: close({
	sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
	instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	materializedResolverContracts: ".codex/plugins/agent-context-resolver/contracts/agent-context-resolver"
	materializedConstructorContracts: ".codex/plugins/agent-context-resolver/contracts/meta/impl"
	factoryPluginBundleRoot?: _|_
	materializedSrcRoot?: _|_
	topLevelDotfilesPluginRoot?: _|_
	externalRuntimeSourceLookup?: false
	lock: close({
		sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
		templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
		instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
		materializedRoot: ".codex/plugins/agent-context-resolver"
	})
})

#ClosureState: close({
	normalizedIssueManifest: _
	pluginBundleLayoutValidationPlan: _
	pluginBundleLayoutCompletionReportContract: _
	sourceRoot?: "contracts/plugin-bundle/agent-context-resolver/src"
	factoryPluginBundleRoot?: _|_
})

_validClosureState: {
	normalizedIssueManifest: {}
	pluginBundleLayoutValidationPlan: {}
	pluginBundleLayoutCompletionReportContract: {}
	sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
}

_validLayout: {
	sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
	instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	materializedResolverContracts: ".codex/plugins/agent-context-resolver/contracts/agent-context-resolver"
	materializedConstructorContracts: ".codex/plugins/agent-context-resolver/contracts/meta/impl"
	lock: {
		sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
		templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
		instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
		materializedRoot: ".codex/plugins/agent-context-resolver"
	}
}

_negativeFixtures: {
	factoryPluginBundleRootAccepted: {input: _validLayout & {factoryPluginBundleRoot: _oldFactoryPluginBundleRoot}}
	materializedSrcRootAccepted: {input: _validLayout & {materializedSrcRoot: _materializedSrcRoot}}
	topLevelDotfilesPluginRootAccepted: {input: _validLayout & {topLevelDotfilesPluginRoot: _topLevelDotfilesPluginRoot}}
	externalRuntimeSourceLookupAccepted: {input: _validLayout & {externalRuntimeSourceLookup: _runtimeLookupEnabled}}
	lockMismatchAccepted: {input: {
		sourceRoot: _oldResolverRoot
		templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
		instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
		materializedRoot: ".codex/plugins/agent-context-resolver"
		materializedResolverContracts: ".codex/plugins/agent-context-resolver/contracts/agent-context-resolver"
		materializedConstructorContracts: ".codex/plugins/agent-context-resolver/contracts/meta/impl"
		lock: {
			sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
			templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
			instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
			materializedRoot: ".codex/plugins/agent-context-resolver"
		}
	}}
	missingNormalizedIssueManifestAccepted: {input: {
		pluginBundleLayoutValidationPlan: {}
		pluginBundleLayoutCompletionReportContract: {}
	}}
	missingValidationPlanAccepted: {input: {
		normalizedIssueManifest: {}
		pluginBundleLayoutCompletionReportContract: {}
	}}
	missingCompletionReportAccepted: {input: {
		normalizedIssueManifest: {}
		pluginBundleLayoutValidationPlan: {}
	}}
	oldResolverRootAccepted: {input: {
		normalizedIssueManifest: {}
		pluginBundleLayoutValidationPlan: {}
		pluginBundleLayoutCompletionReportContract: {}
		sourceRoot: _oldResolverRoot
	}}
	oldFactoryPluginBundleRootAccepted: {input: _validClosureState & {factoryPluginBundleRoot: _oldFactoryPluginBundleRoot}}
}

_negativeBottomChecks: {
	factoryPluginBundleRootAccepted: *(_negativeFixtures.factoryPluginBundleRootAccepted.input & #Layout) | _
	materializedSrcRootAccepted: *(_negativeFixtures.materializedSrcRootAccepted.input & #Layout) | _
	topLevelDotfilesPluginRootAccepted: *(_negativeFixtures.topLevelDotfilesPluginRootAccepted.input & #Layout) | _
	externalRuntimeSourceLookupAccepted: *(_negativeFixtures.externalRuntimeSourceLookupAccepted.input & #Layout) | _
	lockMismatchAccepted: *(_negativeFixtures.lockMismatchAccepted.input & #Layout) | _
	missingNormalizedIssueManifestAccepted: *(_negativeFixtures.missingNormalizedIssueManifestAccepted.input & #ClosureState) | _
	missingValidationPlanAccepted: *(_negativeFixtures.missingValidationPlanAccepted.input & #ClosureState) | _
	missingCompletionReportAccepted: *(_negativeFixtures.missingCompletionReportAccepted.input & #ClosureState) | _
	oldResolverRootAccepted: *(_negativeFixtures.oldResolverRootAccepted.input & #ClosureState) | _
	oldFactoryPluginBundleRootAccepted: *(_negativeFixtures.oldFactoryPluginBundleRootAccepted.input & #ClosureState) | _
}
