package codeintel

#RecommendationTargetPath: #ContainedPath

#CodeIntelRecommendation: close({
	id: #NonEmptyString
	priority: "high" | "medium" | "low"
	targets: [...#RecommendationTargetPath] & [_, ...]
	observed: #NonEmptyString
	recommendation: #NonEmptyString
	validation: [...#NonEmptyString] & [_, ...]
})

#CodeIntelRecommendationManifest: close({
	schema: "factory.plugin-bundle.code-intel.recommendations.v1"
	sourceTemplate: #ContainedPath
	targetRoot: #ContainedPath
	primitives: [...#NonEmptyString] & [_, ...]
	observedSurfaces: [...close({
		id: #NonEmptyString
		paths: [...#RecommendationTargetPath] & [_, ...]
		evidence: #NonEmptyString
	})] & [_, ...]
	recommendations: [...#CodeIntelRecommendation] & [_, ...]
	nonGoals: [...#NonEmptyString] & [_, ...]
})

codeIntelImplementationRecommendations: #CodeIntelRecommendationManifest & {
	schema: "factory.plugin-bundle.code-intel.recommendations.v1"
	sourceTemplate: ".github/dotfiles-manifest-slice/contracts/issues/_template/manifest.cue"
	targetRoot: "contracts/code-intel/src"
	primitives: [
		"generated workflow artifacts remain evidence-only and must match their declared schema",
		"generated outputs are passed through contracts/meta before projection use",
		"factory source changes must not patch .codex/plugins directly",
	]
	observedSurfaces: [
		{
			id: "lua-first-stage-projection"
			paths: [
				"contracts/code-intel/src/contracts/code-intel/lua-first-workflow.cue",
				"contracts/code-intel/src/generated/workflows/lua-first/workflow.json",
			]
			evidence: "workflow.json is a generated stage projection and needs a stage-specific CUE contract."
		},
		{
			id: "meta-generated-output-gate"
			paths: [
				"contracts/meta/generated-projections.cue",
				"contracts/meta/checks/plugin-smoke",
			]
			evidence: "contracts/AGENTS.md requires generated files to pass through contracts/meta."
		},
	]
	recommendations: [
		{
			id: "align-lua-first-workflow-json"
			priority: "high"
			targets: [
				"contracts/code-intel/src/contracts/code-intel/lua-first-workflow.cue",
				"contracts/code-intel/src/generated/workflows/lua-first/workflow.json",
			]
			observed: "workflow.json is stage-only, while codeIntelLuaFirstWorkflow is the full workflow contract."
			recommendation: "Validate workflow.json with CodeIntelLuaFirstWorkflowStageProjection instead of the full workflow contract."
			validation: [
				"cue vet code-intel stage projection",
				"contracts/meta/checks/plugin-smoke",
			]
		},
		{
			id: "avoid-dot-codex-direct-patches"
			priority: "high"
			targets: [
				"contracts/agent-context-resolver",
				"contracts/code-intel",
				"contracts/meta",
			]
			observed: ".codex/plugins files are generated projections in dotfiles."
			recommendation: "Patch factory contract sources and meta-projected generated outputs, not .codex/plugins directly."
			validation: [
				"review changed files for .codex/plugins absence",
				"contracts/meta/checks/plugin-smoke",
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
