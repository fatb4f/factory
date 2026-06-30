package pluginbundle_agent_context_resolver

import (
	canonical "github.com/fatb4f/factory/contracts/agent-context-resolver/src:agentcontextresolver"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

pluginBundleSourceAuthority: canonical.normalizedMaterializedBundleShapeManifest

pluginBundleScaffoldRootDerivation: tmpl.#PluginBundleScaffoldRootDerivation & {
	bundleID: "agent-context-resolver"
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
			{id: "pluginbundle_agent_context_resolver", path: "manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
		]
	}
	generated: {
		root:         pluginBundleScaffoldRootDerivation.generatedRoot
		evidenceOnly: true
		artifacts: [
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/.codex-plugin/plugin.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/skills/SKILL.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/hooks/hooks.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/scripts/README.md", required: true, evidenceOnly: true},
		]
	}
	contractProjection:  pluginBundleContractProjection
	generatedProjection: pluginBundleGeneratedProjection
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
