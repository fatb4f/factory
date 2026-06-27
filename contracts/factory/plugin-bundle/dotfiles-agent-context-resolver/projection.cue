package dotfilespluginbundle

#DotfilesTarget: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
})

#Gate: close({
	id:       #NonEmptyString
	kind:     "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search"
	target:   #NonEmptyString
	required: true
})

dotfilesTargetInventory: [
	".codex/hooks.json",
	".codex/plugins/agent-context-resolver/manifest.json",
	".codex/plugins/agent-context-resolver/SKILL.md",
	".codex/plugins/agent-context-resolver/scripts/agent-context-resolver-hook",
	".codex/plugins/agent-context-resolver/scripts/resolve-agent-context",
	".codex/plugins/agent-context-resolver/generated/turn_start_fragments.json",
	".codex/plugins/agent-context-resolver/generated/prompt_routes.json",
	".codex/plugins/agent-context-resolver/generated/route_inventory.json",
	".codex/plugins/agent-context-resolver/generated/fragment_inventory.json",
	".codex/plugins/agent-context-resolver/generated/provider_inventory.json",
	".codex/plugins/agent-context-resolver/generated/dotfiles.schema-map.json",
]

generatedFileInventory: [
	for targetPath in dotfilesTargetInventory {
		path:      targetPath
		generated: true
		authority: false
		source:    "projection"
	},
]

projectionComponents: [
	{
		id:        "contract-cuemod-agent-context-resolver"
		path:      "contracts/agent-context-resolver"
		role:      "source"
		authority: true
	},
	{
		id:        "dotfiles-plugin-projection"
		path:      "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
		role:      "projection"
		authority: true
	},
	{
		id:        "dotfiles-generated-plugin-files"
		path:      ".codex/plugins/agent-context-resolver/generated"
		role:      "generated-output"
		generated: true
		authority: false
	},
	{
		id:        "provider-reachability"
		path:      "contracts/agent-context-resolver/generated/provider_inventory.json"
		role:      "evidence"
		generated: true
		authority: false
	},
]

projectionGates: [
	{
		id:       "dotfiles-plugin-bundle-cue-vet"
		kind:     "cue-vet"
		target:   "./contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
		required: true
	},
	{
		id:       "dotfiles-plugin-bundle-export"
		kind:     "cue-export"
		target:   "dotfilesAgentContextResolverBundle"
		required: true
	},
	{
		id:       "dotfiles-plugin-materialization-export"
		kind:     "cue-export"
		target:   "dotfilesAgentContextResolverMaterialization"
		required: true
	},
	{
		id:       "dotfiles-plugin-lock-export"
		kind:     "cue-export"
		target:   "dotfilesAgentContextResolverLock"
		required: true
	},
	{
		id:       "dotfiles-plugin-negative-bottom"
		kind:     "negative-bottom"
		target:   "_negativeBottomChecks"
		required: true
	},
]

dotfilesAgentContextResolverBundleInput: {
	source:          contractCuemodInput
	target:          dotfilesTarget
	components:      projectionComponents
	generatedFiles:  generatedFileInventory
	materialization: dotfilesAgentContextResolverMaterializationInput
	lock:            dotfilesAgentContextResolverLock
	gates:           projectionGates
	providerReachability: {
		kind:         "provider-reachability"
		authority:    false
		evidenceOnly: true
		providers: [
			"fragment_inventory",
			"prompt_routes",
			"route_inventory",
			"provider_inventory",
		]
	}
}

dotfilesAgentContextResolverBundle: #AdmissibleDotfilesPluginBundleProjection & dotfilesAgentContextResolverBundleInput
