package issue72checks

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
	factoryPluginBundleRootAccepted: {input: _validLayout & {factoryPluginBundleRoot: "contracts/factory/plugin-bundle"}}
	materializedSrcRootAccepted: {input: _validLayout & {materializedSrcRoot: ".codex/plugins/agent-context-resolver/src"}}
	topLevelDotfilesPluginRootAccepted: {input: _validLayout & {topLevelDotfilesPluginRoot: "plugins/agent-context-resolver"}}
	externalRuntimeSourceLookupAccepted: {input: _validLayout & {externalRuntimeSourceLookup: true}}
	lockMismatchAccepted: {input: {
		sourceRoot: "contracts/agent-context-resolver"
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
}

_negativeBottomChecks: {
	factoryPluginBundleRootAccepted: *(_negativeFixtures.factoryPluginBundleRootAccepted.input & #Layout) | _
	materializedSrcRootAccepted: *(_negativeFixtures.materializedSrcRootAccepted.input & #Layout) | _
	topLevelDotfilesPluginRootAccepted: *(_negativeFixtures.topLevelDotfilesPluginRootAccepted.input & #Layout) | _
	externalRuntimeSourceLookupAccepted: *(_negativeFixtures.externalRuntimeSourceLookupAccepted.input & #Layout) | _
	lockMismatchAccepted: *(_negativeFixtures.lockMismatchAccepted.input & #Layout) | _
}
