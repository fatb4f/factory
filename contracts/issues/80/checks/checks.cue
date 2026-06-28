package issue80checks

import tmpl "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/template:pluginbundletemplate"

_validShape: {
	srcRoot: "contracts/plugin-bundle/template"
	contracts: {
		root: "contracts/plugin-bundle/template"
		cuePackages: [
			{id: "pluginbundletemplate", path: "template.cue"},
		]
		requiredPaths: ["template.cue"]
	}
	generated: {
		root:         "contracts/plugin-bundle/template/generated"
		evidenceOnly: true
		artifacts: []
	}
	validation: {
		commands: ["cue vet ./contracts/plugin-bundle/template"]
		negativeChecks: ["bundleLocalShapeOverrideAccepted"]
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "plugin-bundle-template"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/template/template.cue"
		generatedArtifactsAreEvidenceOnly: true
	}
}

_negativeFixtures: {
	bundleLocalShapeOverrideAccepted: {
		input: _validShape & {
			bundleLocalShapeOverride: true
			manifest: bundleLocalShapeOverride: true
		}
	}
}

_negativeBottomChecks: {
	bundleLocalShapeOverrideAccepted: _negativeFixtures.bundleLocalShapeOverrideAccepted.input & tmpl.#PluginBundleSrcRootShape
}
