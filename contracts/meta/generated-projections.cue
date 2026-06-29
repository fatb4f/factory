package meta

#NonEmptyString: string & !=""
#ContractPath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#GeneratedOutput: close({
	id: #NonEmptyString
	owner: "agent-context-resolver" | "code-intel"
	source: #ContractPath
	target: #ContractPath
	projectionKind: "json" | "script" | "skill"
	generated: true
	authority: false
	metaGate: "contracts/meta"
	schema?: #NonEmptyString
	validation: [...#ContractPath] & [_, ...]
})

generatedOutputRegistry: close({
	schema: "factory.meta.generated-output-registry.v1"
	root: "contracts/meta"
	policy: close({
		generatedOutputsPassThroughMeta: true
		dotCodexPluginsAreGeneratedProjection: true
		directDotCodexPluginPatches: false
	})
	outputs: [...#GeneratedOutput] & [_, ...]
}) & {
	schema: "factory.meta.generated-output-registry.v1"
	root: "contracts/meta"
	policy: {
		generatedOutputsPassThroughMeta: true
		dotCodexPluginsAreGeneratedProjection: true
		directDotCodexPluginPatches: false
	}
	outputs: [
		{
			id: "agent-context-resolver.route-inventory"
			owner: "agent-context-resolver"
			source: "contracts/agent-context-resolver/src/routes.cue"
			target: "contracts/agent-context-resolver/src/generated/route_inventory.json"
			projectionKind: "json"
			generated: true
			authority: false
			metaGate: "contracts/meta"
			schema: "agent-context-resolver.route-inventory.v1"
			validation: ["contracts/agent-context-resolver/src/checks/agent-context-hook"]
		},
		{
			id: "code-intel.lua-first-stage-workflow"
			owner: "code-intel"
			source: "contracts/code-intel/src/contracts/code-intel/lua-first-workflow.cue"
			target: "contracts/code-intel/src/generated/workflows/lua-first/workflow.json"
			projectionKind: "json"
			generated: true
			authority: false
			metaGate: "contracts/meta"
			schema: "factory.plugin-bundle.code-intel.lua-first-workflow.stage-projection.v1"
			validation: ["contracts/meta/checks/plugin-smoke"]
		},
	]
}
