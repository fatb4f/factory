package issue72

issue: {
	number: 72
	title: "cue: move agent-context-resolver into plugin-bundle source"
	contract: {
		path: "contracts/plugin-bundle/agent-context-resolver"
		package: "agentcontextresolverpluginbundle"
		slice: "agent-context-resolver-plugin-bundle-source-layout-v1"
	}
	layout: {
		sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src"
		templateRoot: "contracts/plugin-bundle/agent-context-resolver/template"
		instanceRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
		materializedRoot: ".codex/plugins/agent-context-resolver"
		materializedResolverContracts: ".codex/plugins/agent-context-resolver/contracts/agent-context-resolver"
		materializedConstructorContracts: ".codex/plugins/agent-context-resolver/contracts/meta/impl"
	}
}
