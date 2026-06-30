package codeintel

// source: contracts/code-intel/src/manifest.cue
#CodeIntelBoundary: close({
	generatedAuthority?:              false
	mcpOutputIsAuthority?:            false
	lspDiagnosticsAreAuthority?:      false
	weztermTypesAreAuthority?:        false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?:           false
})

codeIntelBoundary: #CodeIntelBoundary & {
	generatedAuthority:              false
	mcpOutputIsAuthority:            false
	lspDiagnosticsAreAuthority:      false
	weztermTypesAreAuthority:        false
	luaWorkflowGeneratedAsAuthority: false
	resolverContractsLeak:           false
}

_negativeBottomChecks: {
	generatedAsAuthority: *(#CodeIntelBoundary & {generatedAuthority: true}) | _
	mcpOutputAsAuthority: *(#CodeIntelBoundary & {mcpOutputIsAuthority: true}) | _
	lspDiagnosticsAsAuthority: *(#CodeIntelBoundary & {lspDiagnosticsAreAuthority: true}) | _
	weztermTypesAsAuthority: *(#CodeIntelBoundary & {weztermTypesAreAuthority: true}) | _
	luaWorkflowGeneratedAsAuthority: *(#CodeIntelBoundary & {luaWorkflowGeneratedAsAuthority: true}) | _
	resolverContractsLeak: *(#CodeIntelBoundary & {resolverContractsLeak: true}) | _
}

codeIntelBoundaryReport: {
	schema:    "factory.plugin-bundle.code-intel.boundary-report.v1"
	status:    "admitted"
	authority: codeIntelBoundary
	checks: [
		"generatedAsAuthority",
		"mcpOutputAsAuthority",
		"lspDiagnosticsAsAuthority",
		"weztermTypesAsAuthority",
		"luaWorkflowGeneratedAsAuthority",
		"resolverContractsLeak",
	]
}

// source: contracts/code-intel/src/manifest.cue
#NonEmptyString: string & !=""
#ContainedPath:  string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#Provider: close({
	id:   #NonEmptyString
	kind: "mcp" | "lsp" | "types" | "workflow"
	paths: [...#ContainedPath] & [_, ...]
	authority:    false
	evidenceOnly: true
})

#LuaEntrypoint: close({
	id:       #NonEmptyString
	language: "lua"
	path:     #ContainedPath
	domain:   "nvim" | "wezterm" | "dotfiles"
	provider: "lua-language-server"
	typeOverlays: [...#NonEmptyString]
	authority: "dotfiles-source"
})

#LuaFirstStep: close({
	order:     int & >0
	id:        #NonEmptyString
	goal:      #NonEmptyString
	authority: "dotfiles-source" | "evidence-only"
})

#CodeIntelLuaFirstWorkflow: close({
	schema: "factory.plugin-bundle.code-intel.lua-first-workflow.v1"
	id:     #NonEmptyString
	intent: #NonEmptyString
	entrypoints: [...#LuaEntrypoint] & [_, ...]
	providers: [...#Provider] & [_, ...]
	steps: [...#LuaFirstStep] & [_, ...]
	authority: close({
		owns: [...#NonEmptyString] & [_, ...]
		doesNotOwn: [...#NonEmptyString] & [_, ...]
	})
})

codeIntelLuaFirstWorkflow: #CodeIntelLuaFirstWorkflow & {
	id:     "dotfiles-code-intel-lua-first"
	intent: "Resolve dotfiles Lua surfaces before generic repository context."
	entrypoints: [
		{id: "nvim-init", language: "lua", path: ".config/nvim/init.lua", domain: "nvim", provider: "lua-language-server", typeOverlays: ["nvim-vim-types"], authority: "dotfiles-source"},
		{id: "nvim-lua-modules", language: "lua", path: ".config/nvim/lua", domain: "nvim", provider: "lua-language-server", typeOverlays: ["nvim-vim-types"], authority: "dotfiles-source"},
		{id: "wezterm-config", language: "lua", path: ".config/wezterm/wezterm.lua", domain: "wezterm", provider: "lua-language-server", typeOverlays: ["wezterm-types"], authority: "dotfiles-source"},
	]
	providers: [
		{id: "mcp-tool-registry", kind: "mcp", paths: ["generated/mcp/tool-registry.json"], authority: false, evidenceOnly: true},
		{id: "mcp-context-projection", kind: "mcp", paths: ["generated/mcp/context-projection.json"], authority: false, evidenceOnly: true},
		{id: "cue-lsp", kind: "lsp", paths: ["generated/lsp/cue-lsp.json"], authority: false, evidenceOnly: true},
		{id: "lua-language-server", kind: "lsp", paths: ["generated/lsp/lua-language-server.json", "generated/lsp/provider-routing.json"], authority: false, evidenceOnly: true},
		{id: "wezterm-types", kind: "types", paths: ["generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua"], authority: false, evidenceOnly: true},
		{id: "nvim-vim-types", kind: "types", paths: ["generated/types/nvim/vim.lua"], authority: false, evidenceOnly: true},
	]
	steps: [
		{order: 1, id: "collect-lua-entrypoints", goal: "Resolve Lua entrypoints before generic dotfiles paths.", authority: "dotfiles-source"},
		{order: 2, id: "load-type-overlays", goal: "Attach Neovim and WezTerm type overlays as read-only evidence.", authority: "evidence-only"},
		{order: 3, id: "route-provider", goal: "Select lua-language-server or cue-lsp by path and language.", authority: "evidence-only"},
		{order: 4, id: "project-diagnostics", goal: "Project diagnostics as evidence, not mutation authority.", authority: "evidence-only"},
	]
	authority: {
		owns: ["code-intel bundle workflow shape", "provider ordering for Lua-first dotfiles work"]
		doesNotOwn: ["fatb4f/dotfiles source authority", "runtime execution", "truth of LSP diagnostics", "WezTerm runtime behavior", "Neovim runtime behavior"]
	}
}

// source: contracts/code-intel/src/manifest.cue
#RecommendationTargetPath: #ContainedPath

#CodeIntelRecommendation: close({
	id:       #NonEmptyString
	priority: "high" | "medium" | "low"
	targets: [...#RecommendationTargetPath] & [_, ...]
	observed:       #NonEmptyString
	recommendation: #NonEmptyString
	validation: [...#NonEmptyString] & [_, ...]
})

#CodeIntelRecommendationManifest: close({
	schema:         "factory.plugin-bundle.code-intel.recommendations.v1"
	sourceTemplate: #ContainedPath
	targetRoot:     #ContainedPath
	workflow: [...close({
		order:         int & >0
		id:            #NonEmptyString
		instantiateAt: #NonEmptyString
	})] & [_, ...]
	primitives: [...#NonEmptyString] & [_, ...]
	observedSurfaces: [...close({
		id: #NonEmptyString
		paths: [...#RecommendationTargetPath] & [_, ...]
		evidence: #NonEmptyString
	})] & [_, ...]
	predicates: [...close({
		id:   #NonEmptyString
		rule: #NonEmptyString
	})] & [_, ...]
	recommendations: [...#CodeIntelRecommendation] & [_, ...]
	nonGoals: [...#NonEmptyString] & [_, ...]
})

codeIntelImplementationRecommendations: #CodeIntelRecommendationManifest & {
	schema:         "factory.plugin-bundle.code-intel.recommendations.v1"
	sourceTemplate: "contracts/meta/scripts/scaffold-contract-slice"
	targetRoot:     "contracts/code-intel/src"
	workflow: [
		{order: 1, id: "#MakeDotfilesPrimitive", instantiateAt: "primitives"},
		{order: 2, id: "#MakeObservedSurface", instantiateAt: "observedSurfaces"},
		{order: 3, id: "#MakePredicateSet", instantiateAt: "predicates"},
		{order: 4, id: "#MakePromotionCandidate", instantiateAt: "recommendations"},
		{order: 5, id: "#MakeValidationPlan", instantiateAt: "recommendations.validation"},
	]
	primitives: [
		"generated workflow artifacts remain evidence-only and must match their declared schema",
		"negative boundary checks must bottom for forbidden authority promotion fixtures",
		"Lua type overlays must be complete and reachable from the materialized plugin root",
	]
	observedSurfaces: [
		{
			id: "lua-first-workflow-contract-drift"
			paths: [
				"contracts/code-intel/src/manifest.cue",
				"generated/workflows/lua-first/workflow.json",
				"generated/workflows/lua-first/entrypoints.json",
			]
			evidence: "workflow.json declares lua-first-workflow.v1 but does not satisfy the CUE workflow shape"
		},
		{
			id: "negative-bottom-checks-not-proving"
			paths: [
				"contracts/code-intel/src/manifest.cue",
			]
			evidence: "_negativeBottomChecks evaluates to unconstrained values instead of concrete bottom proofs"
		},
		{
			id: "wezterm-overlay-partial-workflow-load"
			paths: [
				"contracts/code-intel/src/manifest.cue",
				"generated/workflows/lua-first/workflow.json",
				"generated/lsp/lua-language-server.json",
				"generated/types/wezterm/wezterm.lua",
				"generated/types/wezterm/events.lua",
				"generated/types/wezterm/config-builder.lua",
			]
			evidence: "workflow stage input names only the primary WezTerm stub while the provider surface includes three overlay files"
		},
	]
	predicates: [
		{id: "declared-schema-validates", rule: "each generated JSON artifact that declares a CUE-owned schema must vet against that schema"},
		{id: "forbidden-authority-bottoms", rule: "fixtures that promote generated, MCP, LSP, or type overlay output to authority must fail validation"},
		{id: "overlay-provider-complete", rule: "workflow and LSP library surfaces must include every file listed by the provider contract"},
	]
	recommendations: [
		{
			id:       "align-lua-first-workflow-json"
			priority: "high"
			targets: [
				"generated/workflows/lua-first/workflow.json",
				"contracts/code-intel/src/manifest.cue",
				"SKILL.md",
			]
			observed:       "workflow.json uses top-level stages plus boolean authority under the same schema that the CUE contract defines with entrypoints, providers, steps, and structured authority."
			recommendation: "Generate workflow.json from codeIntelLuaFirstWorkflow, or give the stage-only artifact a separate schema and add a second CUE contract for that shape."
			validation: [
				"cue vet ./contracts/code-intel",
				"cue export ./contracts/code-intel -e codeIntelLuaFirstWorkflow",
				"cue vet ./contracts/code-intel/*.cue ./generated/workflows/lua-first/workflow.json -d '#CodeIntelLuaFirstWorkflow'",
			]
		},
		{
			id:       "replace-negative-bottom-placeholders"
			priority: "high"
			targets: [
				"contracts/code-intel/src/manifest.cue",
			]
			observed:       "_negativeBottomChecks uses defaults unioned with _, so forbidden fixture checks can evaluate to _ instead of proving bottom."
			recommendation: "Model each forbidden fixture as an attempted admission into the closed boundary and require the validation plan to run commands that fail for those exports."
			validation: [
				"cue vet ./contracts/code-intel",
				"! cue export ./contracts/code-intel -e '_negativeBottomChecks.generatedAsAuthority'",
				"! cue export ./contracts/code-intel -e '_negativeBottomChecks.mcpOutputAsAuthority'",
				"! cue export ./contracts/code-intel -e '_negativeBottomChecks.lspDiagnosticsAsAuthority'",
				"! cue export ./contracts/code-intel -e '_negativeBottomChecks.weztermTypesAsAuthority'",
				"! cue export ./contracts/code-intel -e '_negativeBottomChecks.luaWorkflowGeneratedAsAuthority'",
				"! cue export ./contracts/code-intel -e '_negativeBottomChecks.resolverContractsLeak'",
			]
		},
		{
			id:       "complete-wezterm-overlay-routing"
			priority: "medium"
			targets: [
				"generated/workflows/lua-first/workflow.json",
				"generated/lsp/lua-language-server.json",
				"contracts/code-intel/src/manifest.cue",
			]
			observed:       "the workflow load-type-overlays stage omits events.lua and config-builder.lua, although the provider contract includes them."
			recommendation: "Keep workflow stage inputs, provider paths, and Lua LSP library paths in lockstep for all WezTerm overlay files."
			validation: [
				"cue export ./contracts/code-intel -e codeIntelLuaFirstWorkflow",
				"jq -e '.stages[] | select(.id == \"load-type-overlays\") | .inputs | index(\"generated/types/wezterm/events.lua\") and index(\"generated/types/wezterm/config-builder.lua\")' generated/workflows/lua-first/workflow.json",
			]
		},
		{
			id:       "add-generated-artifact-schema-gates"
			priority: "medium"
			targets: [
				"SKILL.md",
				"contracts/code-intel/src/manifest.cue",
				"contracts/code-intel/src/manifest.cue",
			]
			observed:       "the documented validation verifies the CUE package exports but does not verify that materialized generated JSON still conforms to the declared contracts."
			recommendation: "Extend validation with targeted generated-artifact gates for workflow JSON, entrypoint JSON, and boundary bottom checks."
			validation: [
				"cue vet ./contracts/code-intel",
				"cue export ./contracts/code-intel -e codeIntelImplementationRecommendations",
			]
		},
	]
	nonGoals: [
		"promote generated code-intel outputs to source authority",
		"merge code-intel with the agent-context-resolver bundle",
		"change dotfiles source behavior from this bundle",
		"treat LSP diagnostics as mutation authority",
	]
}
