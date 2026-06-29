package codeintel

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
	targetRoot:     "contracts/plugin-bundle/code-intel/src"
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
				"contracts/code-intel/lua-first-workflow.cue",
				"generated/workflows/lua-first/workflow.json",
				"generated/workflows/lua-first/entrypoints.json",
			]
			evidence: "workflow.json declares lua-first-workflow.v1 but does not satisfy the CUE workflow shape"
		},
		{
			id: "negative-bottom-checks-not-proving"
			paths: [
				"contracts/code-intel/checks.cue",
			]
			evidence: "_negativeBottomChecks evaluates to unconstrained values instead of concrete bottom proofs"
		},
		{
			id: "wezterm-overlay-partial-workflow-load"
			paths: [
				"contracts/code-intel/lua-first-workflow.cue",
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
				"contracts/code-intel/lua-first-workflow.cue",
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
				"contracts/code-intel/checks.cue",
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
				"contracts/code-intel/lua-first-workflow.cue",
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
				"contracts/code-intel/lua-first-workflow.cue",
				"contracts/code-intel/checks.cue",
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
