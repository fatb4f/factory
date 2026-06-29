package codeintelsrc

import (
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/template:pluginbundletemplate"
)

_materializedBundleShape: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/code-intel/src"
	contracts: {
		root: "contracts/code-intel/src/contracts/code-intel"
		cuePackages: [
			{id: "codeintel", path: "contracts/code-intel/src/contracts/code-intel/manifest.cue"},
		]
		requiredPaths: [
			"contracts/code-intel/src/contracts/code-intel/manifest.cue",
		]
	}
	generated: {
		root:         "contracts/code-intel/src/generated"
		evidenceOnly: true
		artifacts: [
			{path: "generated/mcp/server-manifest.json", required: true, evidenceOnly: true},
			{path: "generated/mcp/tool-registry.json", required: true, evidenceOnly: true},
			{path: "generated/lsp/cue-lsp.json", required: true, evidenceOnly: true},
			{path: "generated/lsp/lua-language-server.json", required: true, evidenceOnly: true},
			{path: "generated/workflows/lua-first/workflow.json", required: true, evidenceOnly: true},
		]
	}
	validation: {
		commands: [
			"cue vet ./contracts/code-intel/src",
			"cue export ./contracts/code-intel/src -e normalizedMaterializedBundleShapeManifest",
		]
		negativeChecks: ["codeIntelShapeDrift"]
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "code-intel"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/template/manifest.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride:          false
	}
	bundleLocalShapeOverride: false
}

normalizedMaterializedBundleShapeManifest: _materializedBundleShape

materializedBundleShapeValidationPlan: close({
	path:     "contracts/code-intel/src"
	positive: _materializedBundleShape.validation.commands
	negative: [
		"! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted",
	]
})

materializedBundleShapeCompletionReportContract: close({
	bundleID:      _materializedBundleShape.manifest.bundleID
	templateShape: _materializedBundleShape.manifest.srcRootShapeAuthority
	srcRoot:       _materializedBundleShape.srcRoot
	validation:    materializedBundleShapeValidationPlan
	finalResult:   "code-intel bundle conforms to the template-defined src-root shape"
})
