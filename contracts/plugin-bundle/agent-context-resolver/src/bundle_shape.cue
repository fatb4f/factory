package agentcontextresolver

import tmpl "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/template:pluginbundletemplate"

_materializedBundleShape: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	contracts: {
		root: "contracts/plugin-bundle/agent-context-resolver/src"
		cuePackages: [
			{id: "agentcontextresolver", path: "resolver.cue"},
			{id: "agentcontextresolver", path: "registry.cue"},
			{id: "agentcontextresolver", path: "routes.cue"},
			{id: "agentcontextresolver", path: "checks.cue"},
		]
		requiredPaths: [
			"resolver.cue",
			"registry.cue",
			"routes.cue",
			"checks.cue",
		]
	}
	generated: {
		root:         "contracts/plugin-bundle/agent-context-resolver/src/generated"
		evidenceOnly: true
		artifacts: [
			{path: "generated/fragment_inventory.json", required: true, evidenceOnly: true},
			{path: "generated/registry.index.json", required: true, evidenceOnly: true},
			{path: "generated/route_inventory.json", required: true, evidenceOnly: true},
			{path: "generated/turn_start_fragments.json", required: true, evidenceOnly: true},
		]
	}
	validation: {
		commands: [
			"cue vet ./contracts/plugin-bundle/agent-context-resolver/src",
			"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e normalizedMaterializedBundleShapeManifest",
		]
		negativeChecks: ["resolverShapeDrift"]
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "agent-context-resolver"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/template/template.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride:          false
	}
	bundleLocalShapeOverride: false
}

normalizedMaterializedBundleShapeManifest: _materializedBundleShape

materializedBundleShapeValidationPlan: close({
	path:     "contracts/plugin-bundle/agent-context-resolver/src"
	positive: _materializedBundleShape.validation.commands
	negative: [
		"! cue export ./contracts/issues/81/checks -e _negativeBottomChecks.resolverShapeDrift",
	]
})

materializedBundleShapeCompletionReportContract: close({
	bundleID:      _materializedBundleShape.manifest.bundleID
	templateShape: _materializedBundleShape.manifest.srcRootShapeAuthority
	srcRoot:       _materializedBundleShape.srcRoot
	validation:    materializedBundleShapeValidationPlan
	finalResult:   "resolver bundle conforms to the template-defined src-root shape"
})
