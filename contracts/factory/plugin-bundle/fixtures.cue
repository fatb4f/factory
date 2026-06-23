package pluginbundle

baselineComponents: [
	{
		id:   "agent-context-resolver"
		kind: "contract"
		path: "contracts/agent-context-resolver"
		role: "authority"
	},
	{
		id:   "codex-runtime"
		kind: "adapter"
		path: "contracts/factory/plugin-bundle/codex.cue"
		role: "runtime"
	},
	{
		id:        "turn-start-hook"
		kind:      "hook"
		path:      "contracts/agent-context-resolver/projections/codex/hooks.json"
		role:      "runtime"
		dependsOn: ["agent-context-resolver"]
	},
]

baselineProjections: [
	{
		id:   "codex-runtime-projection"
		from: "contracts/agent-context-resolver"
		to: {
			adapter: "codex"
			path:    ".codex"
		}
		renderer: {
			kind: "cue-export"
		}
	},
]

baselineMaterializations: [
	{
		id:               "codex-hooks-json"
		target:           ".codex/hooks.json"
		sourceProjection: "codex-runtime-projection"
		overwrite:        "replace-generated"
		provenance: {
			kind:          "projection"
			generatedFrom: "codexAgentRuntimeSurface"
		}
	},
]

baselineGates: [
	{
		id:       "plugin-bundle-cue-vet"
		kind:     "cue-vet"
		target:   "./contracts/factory/plugin-bundle"
		required: true
	},
	{
		id:       "plugin-bundle-public-report"
		kind:     "cue-export"
		target:   "pluginBundleFormatReport"
		required: true
	},
	{
		id:       "plugin-bundle-negative-bottom"
		kind:     "negative-bottom"
		target:   "_negativeBottomChecks"
		required: true
	},
]

baselineMetadata: {
	id:        "codex-agent-runtime"
	name:      "Codex Agent Runtime"
	version:   "0.1.0"
	stability: "experimental"
}

baselineAuthority: {
	generatedIsAuthority:    false
	materializedIsAuthority: false
}

baselineExports: {
	bundle: {
		id:     "validBaselineBundle"
		target: "validFixtures.codexAgentRuntime"
	}
	runtime: {
		id:     "codexAgentRuntimeSurface"
		target: "codexAgentRuntimeSurface"
	}
}

baselineBundleInput: {
	apiVersion: "contract.cuemod/plugin-bundle/v0"
	kind:       "PluginBundle"

	metadata:          baselineMetadata
	authority:         baselineAuthority
	components:        baselineComponents
	projections:       baselineProjections
	materializations:  baselineMaterializations
	gates:             baselineGates
	exports:           baselineExports
}

validFixtures: {
	codexAgentRuntime: #AdmissiblePluginBundle & baselineBundleInput
}

codexAgentRuntimeSurface: #AdmissibleCodexRuntime & {
	root: ".codex"
	files: [
		{
			path:   ".codex/hooks.json"
			source: "codex-runtime-projection"
		},
		{
			path:   ".codex/skills/resolve-agent-context/SKILL.md"
			source: "codex-runtime-projection"
		},
	]
	hooks: [
		{
			id:        "turn-start"
			command:   ".codex/skills/resolve-agent-context/scripts/resolve-agent-context"
			inputs:    ["user-prompt", "fragment-inventory", "route-inventory"]
			outputs:   ["bounded-route-controller-packet"]
			boundedBy: ["agent-context-resolver", "codex-runtime-projection"]
		},
	]
	fragments: [
		{
			id:     "agent-context-resolver.authority"
			source: "contracts/agent-context-resolver"
		},
	]
}

validBaselineBundle: validFixtures.codexAgentRuntime

negativeFixtures: {
	codexAsAuthority: {
		input: {
			apiVersion:        baselineBundleInput.apiVersion
			kind:              baselineBundleInput.kind
			metadata:          baselineMetadata
			authority:         baselineAuthority
			components: [
				{
					id:   "codex-hooks-as-source"
					kind: "hook"
					path: ".codex/hooks.json"
					role: "authority"
				},
			]
			projections:       baselineProjections
			materializations:  baselineMaterializations
			gates:             baselineGates
			exports:           baselineExports
		}
	}

	generatedAsAuthority: {
		input: {
			apiVersion:        baselineBundleInput.apiVersion
			kind:              baselineBundleInput.kind
			metadata:          baselineMetadata
			authority:         baselineAuthority
			components: [
				{
					id:        "generated-report-as-source"
					kind:      "evidence"
					path:      "contracts/factory/plugin-bundle/evidence/plugin-bundle-format.report.json"
					role:      "authority"
					generated: !false
				},
			]
			projections:       baselineProjections
			materializations:  baselineMaterializations
			gates:             baselineGates
			exports:           baselineExports
		}
	}

	materializationWithoutProjection: {
		input: {
			apiVersion:        baselineBundleInput.apiVersion
			kind:              baselineBundleInput.kind
			metadata:          baselineMetadata
			authority:         baselineAuthority
			components:        baselineComponents
			projections:       baselineProjections
			materializations: [
				{
					id:               "unknown-source-projection"
					target:           ".codex/missing.json"
					sourceProjection: "missing-projection"
					overwrite:        "if-generated"
					provenance: {
						kind:          "projection"
						generatedFrom: "negative-fixture"
					}
				},
			]
			gates:             baselineGates
			exports:           baselineExports
		}
	}

	unboundedHook: {
		input: {
			root: ".codex"
			files: [
				{
					path:   ".codex/hooks.json"
					source: "codex-runtime-projection"
				},
			]
			hooks: [
				{
					id:      "unbounded"
					command: ".codex/hooks/unbounded"
					inputs:  []
					outputs: []
				},
			]
			fragments: []
		}
	}
}
