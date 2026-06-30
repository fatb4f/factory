package codeintelsrc

import (
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

_materializedBundleShape: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/code-intel/src"
	contracts: {
		root: "contracts/code-intel/src"
		cuePackages: [
			{id: "codeintelsrc", path: "manifest.cue"},
			{id: "codeintel", path: "contracts/code-intel/manifest.cue"},
			{id: "codeintelchecks", path: "contracts/code-intel/checks/manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
			"contracts/code-intel/manifest.cue",
			"contracts/code-intel/checks/manifest.cue",
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
	physicalPluginLayout: {
		pluginName: "code-intel"
	}
	validation: {
		commands: [
			"cue vet ./contracts/code-intel/src",
			"cue vet ./contracts/code-intel/src/contracts/code-intel",
			"cue vet ./contracts/code-intel/src/contracts/code-intel/checks",
			"cue export ./contracts/code-intel/src -e normalizedMaterializedBundleShapeManifest",
			"cue export ./contracts/code-intel/src/contracts/code-intel -e codeIntelBoundaryReport",
			"cue export ./contracts/code-intel/src/contracts/code-intel -e codeIntelImplementationRecommendations",
			"! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.generatedAsAuthority",
			"! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.mcpOutputAsAuthority",
			"! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.lspDiagnosticsAsAuthority",
			"! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.weztermTypesAsAuthority",
			"! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.luaWorkflowGeneratedAsAuthority",
			"! cue export ./contracts/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.resolverContractsLeak",
		]
		negativeChecks: ["codeIntelShapeDrift"]
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

normalizedMaterializedBundleShapeManifest: _materializedBundleShape

materializedBundleShapeValidationPlan: close({
	path:     "contracts/code-intel/src"
	positive: _materializedBundleShape.validation.commands
	negative: [
		"! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted",
	]
})

materializedBundleShapeCompletionReportContract: close({
	bundleID:      _materializedBundleShape.manifest.bundleID
	templateShape: _materializedBundleShape.manifest.srcRootShapeAuthority
	srcRoot:       _materializedBundleShape.srcRoot
	validation:    materializedBundleShapeValidationPlan
	finalResult:   "code-intel bundle conforms to the template-defined src-root shape"
})
