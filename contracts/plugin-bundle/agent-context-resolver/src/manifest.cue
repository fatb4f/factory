package agentcontextresolverpluginbundle

import (
	canonical "github.com/fatb4f/factory/contracts/agent-context-resolver/src:agentcontextresolver"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

pluginBundleSourceAuthority: canonical.normalizedMaterializedBundleShapeManifest

pluginBundleContract: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	contracts: {
		root: "contracts/plugin-bundle/agent-context-resolver/src"
		cuePackages: [
			{id: "agentcontextresolverpluginbundle", path: "manifest.cue"},
			{id: "graph", path: "internal/graph/manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
			"internal/graph/manifest.cue",
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
	physicalPluginLayout: {
		pluginName: "agent-context-resolver"
	}
	validation: {
		commands: [
			"cue vet ./contracts/plugin-bundle/agent-context-resolver/src",
			"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e pluginBundleContract",
			"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e pluginBundleValidationPlan",
			"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e pluginBundleCompletionReport",
		]
		negativeChecks: []
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "agent-context-resolver"
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
	finalResult:   "agent-context-resolver projected into standardized plugin-bundle path"
})
