package pluginbundle

import impl "github.com/fatb4f/factory/contracts/meta/impl"

_contractSeed: close({
	id:         "plugin-bundle-root"
	version:    "v0.1.0"
	owner:      "factory/plugin-bundle"
	idempotent: true
})

_repo: close({
	repository:         "fatb4f/factory"
	module:             "github.com/fatb4f/factory"
	factoryRoot:        "contracts/factory"
	constructorLibrary: "contracts/meta/impl"
	contractRoot:       "contracts/plugin-bundle"
	authorityPath:      "contracts/plugin-bundle/manifest.cue"
})

#PluginBundleSourceRoot: close({
	bundleID:               string & !=""
	path:                   string & =~"^contracts/plugin-bundle/[^/]+/src$"
	role:                   "bundle-source-authority"
	templateShapeAuthority: "contracts/plugin-bundle/template/template.cue"
	generatedRoot?:         string & =~"^contracts/plugin-bundle/[^/]+/generated($|/)"
	generatedArtifactsAreAuthority?: false
})

#PluginBundleRuntimeProjectionRoot: close({
	bundleID:                  string & !=""
	path:                      string & =~"^\\.codex/plugins/[^/]+$"
	role:                      "runtime-projection"
	sourceAuthority:           "contracts/plugin-bundle"
	generatedOutputAuthority?: false
	runtimeOutputAuthority?:   false
})

#PluginBundleRuntimeIndependenceBoundary: close({
	runtimeRequiresExternalFactoryLookup?: false
	runtimeRequiresContractCuemodLookup?:  false
	broadRepoScanRequired?:               false
})

#PluginBundleRootAuthority: close({
	root:                    "contracts/plugin-bundle"
	role:                    "plugin-bundle-source-authority"
	factoryRoot:             _repo.factoryRoot
	constructorLibrary:      _repo.constructorLibrary
	authorityPath:           _repo.authorityPath
	authority:               true
	owns:                   [...string & !=""] & [_, ...]
	delegates:              [...string & !=""] & [_, ...]
	projections:            [...#PluginBundleRuntimeProjectionRoot]
	runtime:                #PluginBundleRuntimeIndependenceBoundary
	generatedRoots:         [...string & =~"^contracts/plugin-bundle/[^/]+/generated($|/)"] | *([])
	generatedRootScope:     "bundle-local"
	generatedOutputsAreAuthority?: false
	runtimeOutputsAreAuthority?:   false
	issueLocalContractsAreAuthority?: false
	topLevelGeneratedRoot?: false
})

#PluginBundleRootInventory: close({
	root:                       "contracts/plugin-bundle"
	rootManifest:               "contracts/plugin-bundle/manifest.cue"
	templateRoot:               "contracts/plugin-bundle/template"
	generationDistributionRoot: "contracts/plugin-bundle/generation-distribution"
	bundleSourceRoots: [...#PluginBundleSourceRoot] & [_, ...]
	runtimeProjectionRoots: [...#PluginBundleRuntimeProjectionRoot] & [_, ...]
	subcontractExports: [...string & !=""] & [_, ...]
})

#PluginBundleRootManifest: close({
	seed:       _contractSeed
	repo:       _repo
	authority:  #PluginBundleRootAuthority
	inventory:  #PluginBundleRootInventory
	primitives: [...impl.#PrimitiveDescriptor]
	surfaces:   impl.#SurfaceSetDescriptor
	negativeFixtures: {...}
	bottomCheckPlans: [...impl.#BottomCheckPlan]
	validation: impl.#ValidationPlan
	completion: impl.#CompletionReportContract
})

_pluginBundleRootAuthority: #PluginBundleRootAuthority & {
	owns: [
		"contracts/plugin-bundle/manifest.cue",
		"contracts/plugin-bundle/template",
		"contracts/plugin-bundle/generation-distribution",
		"contracts/plugin-bundle/agent-context-resolver/src",
		"contracts/plugin-bundle/code-intel/src",
	]
	delegates: [
		"template shape authority to contracts/plugin-bundle/template",
		"generation and distribution admission to contracts/plugin-bundle/generation-distribution",
		"bundle-specific source values to contracts/plugin-bundle/<bundle>/src",
		"runtime projection writes to .codex/plugins/<bundle-id>",
	]
	projections: [
		{bundleID: "agent-context-resolver", path: ".codex/plugins/agent-context-resolver", role: "runtime-projection", sourceAuthority: "contracts/plugin-bundle"},
		{bundleID: "code-intel", path: ".codex/plugins/code-intel", role: "runtime-projection", sourceAuthority: "contracts/plugin-bundle"},
	]
	runtime: {
		runtimeRequiresExternalFactoryLookup: false
		runtimeRequiresContractCuemodLookup:  false
		broadRepoScanRequired:               false
	}
	generatedRoots: []
	generatedRootScope: "bundle-local"
}

_pluginBundleRootInventory: #PluginBundleRootInventory & {
	bundleSourceRoots: [
		{bundleID: "agent-context-resolver", path: "contracts/plugin-bundle/agent-context-resolver/src", role: "bundle-source-authority", templateShapeAuthority: "contracts/plugin-bundle/template/template.cue"},
		{bundleID: "code-intel", path: "contracts/plugin-bundle/code-intel/src", role: "bundle-source-authority", templateShapeAuthority: "contracts/plugin-bundle/template/template.cue"},
	]
	runtimeProjectionRoots: _pluginBundleRootAuthority.projections
	subcontractExports: [
		"normalizedPluginBundleTemplateShapeManifest",
		"pluginBundleTemplateShapeValidationPlan",
		"normalizedPluginBundleGenerationDistributionManifest",
		"pluginBundleGenerationDistributionValidationPlan",
		"normalizedPluginBundleMaterializationManifest",
		"pluginBundleMaterializationPlan",
	]
}

_primitives: [
	impl.#MakePrimitive & {in: {name: "#PluginBundleRootAuthority", role: "root authority and delegation boundary for plugin-bundle contracts", requiredFields: ["root", "role", "factoryRoot", "constructorLibrary", "authorityPath", "authority", "owns", "delegates", "projections", "runtime"], constraints: ["contracts/plugin-bundle is source authority", ".codex/plugins outputs are runtime projections only", "generated roots are bundle-local and non-authority", "contracts/factory is referenced as consumer/factory boundary, not nested ownership"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleRootInventory", role: "normalized inventory of plugin-bundle child authority surfaces and projection roots", requiredFields: ["root", "rootManifest", "templateRoot", "generationDistributionRoot", "bundleSourceRoots", "runtimeProjectionRoots", "subcontractExports"], constraints: ["template and generation-distribution are child authority surfaces", "bundle source roots must be under contracts/plugin-bundle/<bundle>/src", "runtime projection roots must be under .codex/plugins/<bundle-id>"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleSourceRoot", role: "admissible bundle source authority root", requiredFields: ["bundleID", "path", "role", "templateShapeAuthority"], constraints: ["source roots are CUE authority", "generated artifacts under source roots remain evidence/projection only"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleRuntimeProjectionRoot", role: "admissible generated runtime plugin root", requiredFields: ["bundleID", "path", "role", "sourceAuthority"], constraints: ["runtime projection roots are path-contained under .codex/plugins", "runtime projections cannot become authority"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleRuntimeIndependenceBoundary", role: "runtime denial surface for external source lookup and broad scans", requiredFields: ["runtimeRequiresExternalFactoryLookup", "runtimeRequiresContractCuemodLookup", "broadRepoScanRequired"], constraints: ["distributed runtime packages must not require external factory or contract.cuemod lookup"], closed: true}},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#PluginBundleRootAuthority", "#PluginBundleRootInventory", "#PluginBundleSourceRoot", "#PluginBundleRuntimeProjectionRoot", "#PluginBundleRuntimeIndependenceBoundary"]
		observed: ["contracts/plugin-bundle/template", "contracts/plugin-bundle/generation-distribution", "contracts/plugin-bundle/agent-context-resolver/src", "contracts/plugin-bundle/code-intel/src", ".codex/plugins/agent-context-resolver", ".codex/plugins/code-intel"]
		candidates: ["pluginBundleRootAuthority", "pluginBundleRootInventory", "normalizedPluginBundleRootManifest"]
		fixtures: ["negativePluginBundleRootFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["pluginBundleRootAuthority", "pluginBundleRootInventory", "normalizedPluginBundleRootManifest", "pluginBundleRootValidationPlan", "pluginBundleRootCompletionReportContract", "pluginBundleRootAuthorityPath"]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {in: {name: "factoryRootAsPluginBundleAuthorityAccepted", violates: "authority root separation", refusal: "contracts/factory may be referenced but cannot be the plugin-bundle root authority", input: {root: "contracts/factory", authority: true}}},
	impl.#MakeNegativeFixture & {in: {name: "generatedRuntimeAuthorityAccepted", violates: "projection authority boundary", refusal: "generated/runtime package outputs are not source authority", input: {generatedOutputsAreAuthority: true, runtimeOutputsAreAuthority: true}}},
	impl.#MakeNegativeFixture & {in: {name: "projectionOutsideCodexPluginsAccepted", violates: "runtime projection containment", refusal: "runtime plugin projections must stay under .codex/plugins/<bundle-id>", input: {bundleID: "agent-context-resolver", path: "generated/agent-context-resolver", role: "runtime-projection", sourceAuthority: "contracts/plugin-bundle"}}},
	impl.#MakeNegativeFixture & {in: {name: "externalRuntimeLookupAccepted", violates: "runtime independence", refusal: "materialized plugins must not require external factory or contract.cuemod lookup", input: {runtimeRequiresExternalFactoryLookup: true, runtimeRequiresContractCuemodLookup: true}}},
	impl.#MakeNegativeFixture & {in: {name: "sourceRootOutsidePluginBundleAccepted", violates: "source root containment", refusal: "bundle source roots belong under contracts/plugin-bundle/<bundle>/src", input: {bundleID: "agent-context-resolver", path: "contracts/agent-context-resolver", role: "bundle-source-authority", templateShapeAuthority: "contracts/plugin-bundle/template/template.cue"}}},
	impl.#MakeNegativeFixture & {in: {name: "topLevelGeneratedRootAccepted", violates: "generated root locality", refusal: "root-level generated surfaces must be bundle-local or declared under a bundle source root", input: {root: "contracts/plugin-bundle", topLevelGeneratedRoot: true, generatedRootScope: "root"}}},
]

negativePluginBundleRootFixtures: {
	factoryRootAsPluginBundleAuthorityAccepted: _negativeFixtures[0].out
	generatedRuntimeAuthorityAccepted:          _negativeFixtures[1].out
	projectionOutsideCodexPluginsAccepted:      _negativeFixtures[2].out
	externalRuntimeLookupAccepted:              _negativeFixtures[3].out
	sourceRootOutsidePluginBundleAccepted:      _negativeFixtures[4].out
	topLevelGeneratedRootAccepted:              _negativeFixtures[5].out
}

_bottomCheckNames: ["factoryRootAsPluginBundleAuthorityAccepted", "generatedRuntimeAuthorityAccepted", "projectionOutsideCodexPluginsAccepted", "externalRuntimeLookupAccepted", "sourceRootOutsidePluginBundleAccepted", "topLevelGeneratedRootAccepted"]

_bottomCheckPlans: [for fixtureName in _bottomCheckNames {impl.#MakeBottomCheckPlan & {in: {name: fixtureName, fixture: fixtureName, checkSurface: "_negativeBottomChecks", checkFile: "./contracts/plugin-bundle/checks"}}}]

_validation: impl.#MakeValidationPlan & {in: {path: "contracts/plugin-bundle", validBaselineExpr: "normalizedPluginBundleRootManifest", publicExpr: "pluginBundleRootAuthority", bottomChecks: _bottomCheckNames, checkFile: "./contracts/plugin-bundle/checks", checkSurface: "_negativeBottomChecks", forbiddenPattern: "[g]eneratedOutputsAreAuthority: true|[r]untimeOutputsAreAuthority: true|[i]ssueLocalContractsAreAuthority: true|[r]untimeRequiresExternalFactoryLookup: true|[r]untimeRequiresContractCuemodLookup: true|[t]opLevelGeneratedRoot: true"}}

_completion: impl.#MakeCompletionReport & {in: {primitives: [for primitive in _primitives {primitive.out.name}], surfaces: _surfaces.out.publicExports, fixtures: [for fixture in _negativeFixtures {fixture.out.id}], checks: _bottomCheckNames, commands: _validation.out.commands, evidence: ["root contract anchors contracts/plugin-bundle as source authority", "contracts/factory is referenced as factory boundary, not nested plugin-bundle authority", "contracts/meta/impl constructors define root primitive/surface/validation/completion shape", "runtime packages remain path-contained non-authority projections"]}}

pluginBundleRootAuthority:                 _pluginBundleRootAuthority
pluginBundleRootInventory:                 _pluginBundleRootInventory
pluginBundleRootValidationPlan:            _validation.out
pluginBundleRootCompletionReportContract:  _completion.out
pluginBundleRootAuthorityPath:             _repo.authorityPath
normalizedPluginBundleRootManifest: #PluginBundleRootManifest & {
	seed:               _contractSeed
	repo:                _repo
	authority:           _pluginBundleRootAuthority
	inventory:           _pluginBundleRootInventory
	primitives:          [for primitive in _primitives {primitive.out}]
	surfaces:            _surfaces.out
	negativeFixtures:    negativePluginBundleRootFixtures
	bottomCheckPlans:    [for plan in _bottomCheckPlans {plan.out}]
	validation:          _validation.out
	completion:          _completion.out
}
