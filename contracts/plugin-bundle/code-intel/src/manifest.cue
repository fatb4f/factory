package codeintelpluginbundle

import (
	canonical "github.com/fatb4f/factory/contracts/code-intel/src:codeintelsrc"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

pluginBundleSourceAuthority: canonical.normalizedMaterializedBundleShapeManifest

pluginBundleContract: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/plugin-bundle/code-intel/src"
	contracts: {
		root: "contracts/plugin-bundle/code-intel/src"
		cuePackages: [
			{id: "codeintelpluginbundle", path: "manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
		]
	}
	generated: {
		root:         "contracts/plugin-bundle/code-intel/src/generated"
		evidenceOnly: true
		artifacts: [
			{path: "generated/mcp/server-manifest.json", required: true, evidenceOnly: true},
			{path: "generated/mcp/tool-registry.json", required: true, evidenceOnly: true},
			{path: "generated/lsp/cue-lsp.json", required: true, evidenceOnly: true},
			{path: "generated/lsp/lua-language-server.json", required: true, evidenceOnly: true},
			{path: "generated/workflows/lua-first/workflow.json", required: true, evidenceOnly: true},
		]
	}
	physicalPluginLayout: {
		pluginName: "code-intel"
	}
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
