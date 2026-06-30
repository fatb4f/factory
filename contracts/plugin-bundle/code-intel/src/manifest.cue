package pluginbundle_code_intel

import (
	canonical "github.com/fatb4f/factory/contracts/code-intel/src:codeintelsrc"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

pluginBundleSourceAuthority: canonical.normalizedMaterializedBundleShapeManifest

pluginBundleScaffoldRootDerivation: tmpl.#PluginBundleScaffoldRootDerivation & {
	bundleID: "code-intel"
}

pluginBundleContractProjection: tmpl.#PluginBundleContractProjectionLayout & {
	pluginName: pluginBundleScaffoldRootDerivation.bundleID
}

pluginBundleGeneratedProjection: tmpl.#PluginBundleGeneratedProjectionLayout & {
	pluginName: pluginBundleScaffoldRootDerivation.bundleID
}

pluginBundleContract: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: pluginBundleScaffoldRootDerivation.contractRoot
	contracts: {
		root: pluginBundleScaffoldRootDerivation.contractRoot
		cuePackages: [
			{id: "pluginbundle_code_intel", path: "manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
		]
	}
	generated: {
		root:         pluginBundleScaffoldRootDerivation.generatedRoot
		evidenceOnly: true
		artifacts: [
			{path: "contracts/plugin-bundle/generated/code-intel/.codex-plugin/plugin.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/manifest.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/skills/SKILL.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/hooks/hooks.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/scripts/README.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/mcp/server-manifest.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/mcp/tool-registry.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/mcp/context-projection.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/lsp/cue-lsp.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/lsp/lua-language-server.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/lsp/provider-routing.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/types/wezterm/wezterm.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/types/wezterm/events.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/types/wezterm/config-builder.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/types/nvim/vim.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/workflows/lua-first/workflow.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/workflows/lua-first/entrypoints.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/generated/workflows/lua-first/diagnostic-map.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/contracts/code-intel/manifest.cue", required: true, evidenceOnly: true},
		]
	}
	contractProjection:  pluginBundleContractProjection
	generatedProjection: pluginBundleGeneratedProjection
	validation: {
		commands: [
			"cue vet ./contracts/plugin-bundle/code-intel/src",
			"cue export ./contracts/plugin-bundle/code-intel/src -e pluginBundleContract",
			"cue export ./contracts/plugin-bundle/code-intel/src -e pluginBundleValidationPlan",
			"cue export ./contracts/plugin-bundle/code-intel/src -e pluginBundleCompletionReport",
			"test -f contracts/plugin-bundle/generated/code-intel/manifest.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/mcp/server-manifest.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/mcp/tool-registry.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/mcp/context-projection.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/lsp/cue-lsp.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/lsp/lua-language-server.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/lsp/provider-routing.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/types/wezterm/wezterm.lua",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/types/wezterm/events.lua",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/types/wezterm/config-builder.lua",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/types/nvim/vim.lua",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/workflows/lua-first/workflow.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/workflows/lua-first/entrypoints.json",
			"test -f contracts/plugin-bundle/generated/code-intel/generated/workflows/lua-first/diagnostic-map.json",
			"test -f contracts/plugin-bundle/generated/code-intel/contracts/code-intel/manifest.cue",
			"! rg -n 'import\\s*\\(|github.com/fatb4f/factory|github.com/fatb4f/contract.cuemod|#MakeBottomCheckProof|impl\\.' contracts/plugin-bundle/generated/code-intel/contracts/code-intel",
			"jq -e '.contracts | index(\"contracts/code-intel/manifest.cue\")' contracts/plugin-bundle/generated/code-intel/manifest.json",
			"! jq -e '.contracts[] | select(. == \"contracts/code-intel/lua-first-workflow.cue\" or . == \"contracts/code-intel/checks.cue\" or . == \"contracts/code-intel/recommendations.cue\")' contracts/plugin-bundle/generated/code-intel/manifest.json",
		]
		negativeChecks: []
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "code-intel"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/src/manifest.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride:          false
	}
	bundleLocalShapeOverride: false
}

pluginBundleValidationPlan: close({
	path:     pluginBundleContract.srcRoot
	positive: pluginBundleContract.validation.commands
	negative: []
	sourceAuthority: pluginBundleSourceAuthority.srcRoot
})

pluginBundleCompletionReport: close({
	bundleID:      pluginBundleContract.manifest.bundleID
	templateShape: pluginBundleContract.manifest.srcRootShapeAuthority
	srcRoot:       pluginBundleContract.srcRoot
	sourceRoot:    pluginBundleSourceAuthority.srcRoot
	validation:    pluginBundleValidationPlan
	finalResult:   "code-intel projected into standardized plugin-bundle path"
})
