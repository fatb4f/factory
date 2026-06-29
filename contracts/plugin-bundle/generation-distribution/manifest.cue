package pluginbundlegenerationdistribution

import impl "github.com/fatb4f/factory/contracts/meta/impl"

_contractSeed: close({
	id:         "plugin-bundle-generation-distribution"
	version:    "v0.1.0"
	owner:      "factory/plugin-bundle"
	idempotent: true
})

_repo: close({
	repository:         "fatb4f/factory"
	module:             "github.com/fatb4f/factory"
	constructorLibrary: "contracts/meta/impl"
	sourceAuthority:    "contracts/plugin-bundle/generation-distribution"
	planExport:         "pluginBundleMaterializationPlan"
})

#PluginBundleGenerationPlan: close({
	templateShape:     string & !=""
	sourceRoots:       [...string & !=""] & [_, ...]
	materializedRoots: [...string & !=""] & [_, ...]
	emittedArtifacts:  [...#PluginBundleDistributionPackage]
	validation:        #PluginBundleGenerationDistributionGate
})

#PluginBundleDistributionPackage: close({
	bundleID:          string & !=""
	sourceRoot:        string & =~"^contracts/plugin-bundle/[^/]+/src$"
	distributionRoot:  string & =~"^\\.codex/plugins/[^/]+$"
	runtimeFiles:      [...string & !=""]
	lockEvidence:      [...string & !=""]
	authorityBoundary: "projection-only"
})

#PluginBundleGenerationDistributionGate: close({
	positiveExports:        [...string & !=""] & [_, ...]
	negativeChecks:         [...string & !=""]
	forbiddenAttractors:    [...string & !=""]
	distributionDiffPolicy: "path-contained-reviewable"
})

#GeneratedPackageAuthorityBoundary: close({
	path:                       string & =~"^\\.codex/plugins/[^/]+/.+"
	role:                       "projection"
	generatedPackageAuthority?: false
})

#DistributionRootContainmentBoundary: close({
	bundleID:         string & !=""
	distributionRoot: string & =~"^\\.codex/plugins/[^/]+$"
	pathContained:    true
})

#DeterministicGenerationBoundary: close({
	generatedAtRuntime?:    false
	nonDeterministicInput?: false
})

#RuntimeExternalSourceLookupBoundary: close({
	runtimeRequiresExternalFactoryLookup?: false
	runtimeRequiresContractCuemodLookup?:  false
})

#PluginBundleMaterializerFunctionRef: close({
	id:                     string & !=""
	role:                   "idempotent projection writer"
	mustBeDeterministic:    true
	mustBeIdempotent:       true
	mustBePathContained:    true
	mustNotOwnPolicy:       true
	mustNotOwnAuthority:    true
	mustEmitReviewableDiff: true
})

#PluginBundleMaterializerFunction: close({
	inputExport:       _repo.planExport
	sourceAuthority:   _repo.sourceAuthority
	writeRoot:         ".codex/plugins"
	modes:             [...("plan" | "check" | "apply")] & ["plan", "check", "apply"]
	idempotent:        true
	deterministic:     true
	pathContained:     true
	projectionOnly:    true
	authorityBoundary: "projection-only"
	lockEvidence: close({
		recordsSourceAuthority: true
		recordsGeneratedFiles:  true
		isAuthority:            false
	})
})

#PluginBundleMaterializationTarget: close({
	sourceBundle:      string & !=""
	sourceAuthority:   _repo.sourceAuthority
	targetRepository:  string & !=""
	targetPath:        string & =~"^\\.codex/plugins/[^/]+$"
	distributionMode:  "repo-local-runtime-projection" | "consumer-runtime-projection"
	authorityBoundary: "projection-only"
	pathContained:     true
	reviewableDiff:    true
})

#PluginBundleMaterializationProgram: close({
	sourceAuthority: _repo.sourceAuthority
	planExport:      _repo.planExport
	materializer:    #PluginBundleMaterializerFunctionRef
	targets:          [...#PluginBundleMaterializationTarget] & [_, ...]
})

#AgentContextResolverMaterializationTarget: #PluginBundleMaterializationTarget & {
	sourceBundle:     "agent-context-resolver"
	targetRepository: "fatb4f/factory" | "fatb4f/dotfiles"
	targetPath:       ".codex/plugins/agent-context-resolver"
	distributionMode: "repo-local-runtime-projection" | "consumer-runtime-projection"
}

#AgentContextResolverMaterializationSlice: close({
	bundleID:        "agent-context-resolver"
	sourceAuthority: _repo.sourceAuthority
	materializer:    #PluginBundleMaterializerFunctionRef
	targets: [
		#AgentContextResolverMaterializationTarget & {
			targetRepository: "fatb4f/factory"
			distributionMode: "repo-local-runtime-projection"
		},
		#AgentContextResolverMaterializationTarget & {
			targetRepository: "fatb4f/dotfiles"
			distributionMode: "consumer-runtime-projection"
		},
	]
	idempotent:     true
	deterministic:  true
	projectionOnly: true
})

CrossRepoPluginBundleDistributionTarget: close({
	sourceBundle:     string & !=""
	sourceAuthority:  string & !=""
	targetRepository: string & !=""
	targetPath:       string & !=""
	distributionMode: "repo-local-runtime-projection" | "consumer-runtime-projection"
})

CrossRepoPluginBundleDistributionTargetMatrix: close({
	targets:         [...CrossRepoPluginBundleDistributionTarget] & [_, ...]
	sourceAuthority: _repo.sourceAuthority
	reviewBoundary:  "path-contained-reviewable"
})

_pluginBundleMaterializerFunctionRef: #PluginBundleMaterializerFunctionRef & {
	id:                     "plugin-bundle-materializer-function"
	role:                   "idempotent projection writer"
	mustBeDeterministic:    true
	mustBeIdempotent:       true
	mustBePathContained:    true
	mustNotOwnPolicy:       true
	mustNotOwnAuthority:    true
	mustEmitReviewableDiff: true
}

_materializerFunction: #PluginBundleMaterializerFunction
_agentContextResolverMaterialization: #AgentContextResolverMaterializationSlice & {
	materializer: _pluginBundleMaterializerFunctionRef
}

_workflowIndex: [
	{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
	{order: 2, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
	{order: 3, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
	{order: 4, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
	{order: 5, id: "#MakeValidationPlan", instantiateAt: "_validation"},
	{order: 6, id: "#MakeCompletionReport", instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakePrimitive & {in: {name: "#PluginBundleGenerationPlan", role: "plugin-bundle generation plan", requiredFields: ["templateShape", "sourceRoots", "materializedRoots", "emittedArtifacts", "validation"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleDistributionPackage", role: "path-contained generated runtime package", requiredFields: ["bundleID", "sourceRoot", "distributionRoot", "runtimeFiles", "lockEvidence", "authorityBoundary"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleGenerationDistributionGate", role: "generation/distribution validation gate", requiredFields: ["positiveExports", "negativeChecks", "forbiddenAttractors", "distributionDiffPolicy"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleMaterializationProgram", role: "materialization control surface", requiredFields: ["sourceAuthority", "planExport", "materializer", "targets"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#PluginBundleMaterializerFunction", role: "idempotent projection writer", requiredFields: ["inputExport", "sourceAuthority", "writeRoot", "modes", "idempotent", "deterministic", "pathContained", "projectionOnly", "lockEvidence"], closed: true}},
	impl.#MakePrimitive & {in: {name: "#AgentContextResolverMaterializationSlice", role: "agent-context-resolver materialization target slice", requiredFields: ["bundleID", "sourceAuthority", "materializer", "targets", "idempotent", "deterministic", "projectionOnly"], closed: true}},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#PluginBundleGenerationPlan", "#PluginBundleDistributionPackage", "#PluginBundleGenerationDistributionGate", "#PluginBundleMaterializationProgram", "#PluginBundleMaterializerFunction", "#AgentContextResolverMaterializationSlice"]
		observed: ["contracts/plugin-bundle/template/template.cue", "contracts/plugin-bundle/agent-context-resolver/src", "contracts/plugin-bundle/code-intel/src", ".codex/plugins/agent-context-resolver", ".codex/plugins/code-intel"]
		candidates: ["pluginBundleGenerationDistributionPlan", "pluginBundleMaterializationPlan", "normalizedCrossRepoPluginBundleDistributionManifest"]
		fixtures: ["negativePluginBundleGenerationDistributionFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["normalizedPluginBundleGenerationDistributionManifest", "pluginBundleGenerationDistributionValidationPlan", "pluginBundleGenerationDistributionCompletionReportContract", "pluginBundleMaterializationPlan", "normalizedPluginBundleMaterializationManifest", "pluginBundleMaterializationValidationPlan", "pluginBundleMaterializationCompletionReportContract", "normalizedCrossRepoPluginBundleDistributionManifest"]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {in: {name: "generatedPackageAuthorityAccepted", violates: "generated package authority boundary", refusal: "generated packages are projections only", input: {path: ".codex/plugins/agent-context-resolver/manifest.json", role: "authority", generatedPackageAuthority: true}}},
	impl.#MakeNegativeFixture & {in: {name: "distributionOutsidePluginRootAccepted", violates: "distribution root containment", refusal: "distribution writes stay under .codex/plugins/<bundle-id>", input: {bundleID: "agent-context-resolver", distributionRoot: ".codex/../contracts/plugin-bundle/agent-context-resolver/src", pathContained: false}}},
	impl.#MakeNegativeFixture & {in: {name: "nonDeterministicGenerationAccepted", violates: "deterministic generation boundary", refusal: "generation outputs must be reproducible", input: {generatedAtRuntime: true, nonDeterministicInput: true}}},
	impl.#MakeNegativeFixture & {in: {name: "runtimeExternalSourceLookupAccepted", violates: "runtime distribution independence", refusal: "runtime must not require external source lookup", input: {runtimeRequiresExternalFactoryLookup: true, runtimeRequiresContractCuemodLookup: true}}},
]

negativePluginBundleGenerationDistributionFixtures: {
	generatedPackageAuthorityAccepted:     _negativeFixtures[0].out
	distributionOutsidePluginRootAccepted: _negativeFixtures[1].out
	nonDeterministicGenerationAccepted:    _negativeFixtures[2].out
	runtimeExternalSourceLookupAccepted:   _negativeFixtures[3].out
}

_bottomCheckNames: ["generatedPackageAuthorityAccepted", "distributionOutsidePluginRootAccepted", "nonDeterministicGenerationAccepted", "runtimeExternalSourceLookupAccepted"]

_bottomCheckPlans: [for fixtureName in _bottomCheckNames {impl.#MakeBottomCheckPlan & {in: {name: fixtureName, fixture: fixtureName, checkSurface: "_negativeBottomChecks", checkFile: "./contracts/plugin-bundle/generation-distribution/checks"}}}]

pluginBundleGenerationDistributionPlan: #PluginBundleGenerationPlan & {
	templateShape: "contracts/plugin-bundle/template/template.cue"
	sourceRoots: ["contracts/plugin-bundle/agent-context-resolver/src", "contracts/plugin-bundle/code-intel/src"]
	materializedRoots: sourceRoots
	emittedArtifacts: [
		{bundleID: "agent-context-resolver", sourceRoot: "contracts/plugin-bundle/agent-context-resolver/src", distributionRoot: ".codex/plugins/agent-context-resolver", runtimeFiles: ["manifest.json", "SKILL.md", "scripts/agent-context-resolver-hook", "scripts/resolve-agent-context"], lockEvidence: ["package.lock.json"], authorityBoundary: "projection-only"},
		{bundleID: "code-intel", sourceRoot: "contracts/plugin-bundle/code-intel/src", distributionRoot: ".codex/plugins/code-intel", runtimeFiles: ["manifest.json", "SKILL.md"], lockEvidence: [], authorityBoundary: "projection-only"},
	]
	validation: {positiveExports: ["normalizedPluginBundleGenerationDistributionManifest", "pluginBundleGenerationDistributionValidationPlan", "pluginBundleGenerationDistributionCompletionReportContract"], negativeChecks: _bottomCheckNames, forbiddenAttractors: ["generated packages as authority", "distribution outside .codex/plugins", "non-deterministic generation", "runtime external source checkout"], distributionDiffPolicy: "path-contained-reviewable"}
}

pluginBundleMaterializationPlan: #PluginBundleMaterializationProgram & {
	sourceAuthority: _repo.sourceAuthority
	planExport:      _repo.planExport
	materializer:    _pluginBundleMaterializerFunctionRef
	targets:          _agentContextResolverMaterialization.targets
}

normalizedCrossRepoPluginBundleDistributionManifest: close({
	distributionTargets: [
		{sourceBundle: "agent-context-resolver", sourceAuthority: _repo.sourceAuthority, targetRepository: "fatb4f/factory", targetPath: ".codex/plugins/agent-context-resolver", distributionMode: "repo-local-runtime-projection"},
		{sourceBundle: "agent-context-resolver", sourceAuthority: _repo.sourceAuthority, targetRepository: "fatb4f/dotfiles", targetPath: ".codex/plugins/agent-context-resolver", distributionMode: "consumer-runtime-projection"},
		{sourceBundle: "code-intel", sourceAuthority: _repo.sourceAuthority, targetRepository: "fatb4f/dotfiles", targetPath: ".codex/plugins/code-intel", distributionMode: "consumer-runtime-projection"},
	]
	invariants: ["factory owns canonical plugin-bundle generation/distribution authority", "agent-context-resolver distributes to factory and dotfiles", "code-intel distributes to dotfiles only", "cross-repo promotions require reviewable path-contained diffs"]
})

_validation: impl.#MakeValidationPlan & {in: {path: "contracts/plugin-bundle/generation-distribution", validBaselineExpr: "normalizedPluginBundleGenerationDistributionManifest", publicExpr: "normalizedPluginBundleGenerationDistributionManifest", bottomChecks: _bottomCheckNames, checkFile: "./contracts/plugin-bundle/generation-distribution/checks", checkSurface: "_negativeBottomChecks", forbiddenPattern: "[g]eneratedPackageAuthorityAccepted: true|[p]athContainedAccepted: false|[n]onDeterministicGenerationAccepted: true|[r]untimeExternalSourceLookupAccepted: true"}}
_completion: impl.#MakeCompletionReport & {in: {primitives: [for primitive in _primitives {primitive.out.name}], surfaces: _surfaces.out.publicExports, fixtures: [for fixture in _negativeFixtures {fixture.out.id}], checks: _bottomCheckNames, commands: _validation.out.commands, evidence: ["template-owned src-root shape", "distribution artifacts under .codex/plugins are projections only"]}}

_materializationValidation: impl.#MakeValidationPlan & {in: {path: "contracts/plugin-bundle/generation-distribution", validBaselineExpr: "normalizedPluginBundleMaterializationManifest", publicExpr: "normalizedPluginBundleMaterializationManifest", bottomChecks: _bottomCheckNames, checkFile: "./contracts/plugin-bundle/generation-distribution/checks", checkSurface: "_negativeBottomChecks", forbiddenPattern: "[i]dempotent: false|[d]eterministic: false|[p]athContained: false|[p]rojectionOnly: false|[i]sAuthority: true"}}
_materializationCompletion: impl.#MakeCompletionReport & {in: {primitives: [for primitive in _primitives {primitive.out.name}], surfaces: _surfaces.out.publicExports, fixtures: [for fixture in _negativeFixtures {fixture.out.id}], checks: _bottomCheckNames, commands: _materializationValidation.out.commands, evidence: ["generation-distribution authority exports pluginBundleMaterializationPlan", "agent-context-resolver target matrix includes fatb4f/factory and fatb4f/dotfiles"]}}

normalizedPluginBundleGenerationDistributionManifest: {
	seed:                  _contractSeed
	repo:                  _repo
	workflow:              _workflowIndex
	plan:                  pluginBundleGenerationDistributionPlan
	materializationPlan:   pluginBundleMaterializationPlan
	crossRepoDistribution: normalizedCrossRepoPluginBundleDistributionManifest
	primitives:            [for primitive in _primitives {primitive.out}]
	surfaces:              _surfaces.out
	negativeFixtures:      negativePluginBundleGenerationDistributionFixtures
	bottomCheckPlans:      [for plan in _bottomCheckPlans {plan.out}]
}

normalizedPluginBundleMaterializationManifest: {
	seed:                                _contractSeed
	repo:                                _repo
	workflow:                            _workflowIndex
	parentProgram:                       pluginBundleMaterializationPlan
	materializerFunction:                _materializerFunction
	agentContextResolverMaterialization: _agentContextResolverMaterialization
	primitives:                          [for primitive in _primitives {primitive.out}]
	surfaces:                            _surfaces.out
	negativeFixtures:                    {}
	bottomCheckPlans:                    []
}

pluginBundleGenerationDistributionValidationPlan:           _validation.out
pluginBundleGenerationDistributionCompletionReportContract: _completion.out
normalizedPluginBundleGenerationDistributionAuthority:      normalizedPluginBundleGenerationDistributionManifest
pluginBundleGenerationDistributionAuthorityPath:            "contracts/plugin-bundle/generation-distribution/manifest.cue"
pluginBundleMaterializationValidationPlan:                  _materializationValidation.out
pluginBundleMaterializationCompletionReportContract:        _materializationCompletion.out
