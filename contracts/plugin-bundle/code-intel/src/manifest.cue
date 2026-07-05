package pluginbundle_code_intel

import (
	canonical "github.com/fatb4f/factory/contracts/plugin-bundle/code-intel/src/contracts/code-intel:codeintel"
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
			{path: "contracts/plugin-bundle/generated/code-intel/SKILL.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/hooks/hooks.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/skills/SKILL.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/lsp/cue-lsp.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/lsp/lua-language-server.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/lsp/provider-routing.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/tools/lua-ls.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/tools/stylua.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/tools/selene.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/tools/luacheck.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/types/nvim/vim.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/types/wezterm/wezterm.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/types/wezterm/events.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/types/wezterm/config-builder.lua", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/workflows/lua-first/workflow.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/workflows/lua-first/entrypoints.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/reference/workflows/lua-first/diagnostic-map.json", required: true, evidenceOnly: true},
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
