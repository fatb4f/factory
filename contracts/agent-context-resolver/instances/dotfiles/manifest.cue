package dotfilespluginbundle

import (
	"list"
)

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
_negativeBottomChecks: {
	codexAsAuthority:
		*(negativeFixtures.codexAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	generatedAsAuthority:
		*(negativeFixtures.generatedAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	externalDependency:
		*(negativeFixtures.externalDependency.input & #AdmissibleDotfilesPluginBundleProjection) | _

	contractCuemodDependency:
		*(negativeFixtures.contractCuemodDependency.input & #AdmissibleDotfilesPluginBundleProjection) | _

	providerOutputAsAuthority:
		*(negativeFixtures.providerOutputAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	topLevelPluginRoot:
		*(negativeFixtures.topLevelPluginRoot.input & #AdmissibleDotfilesPluginBundleProjection) | _

	proseReferenceAuthority:
		*(negativeFixtures.proseReferenceAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	materializationWithoutLock:
		*(negativeFixtures.materializationWithoutLock.input & {provenance: {lockID: dotfilesAgentContextResolverLock.id}}) | _

	controllerLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.controllerLeak.input & #ResolverPromptSurface) | _

	runtimeLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.runtimeLeak.input & #ResolverPromptSurface) | _

	propagationLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.propagationLeak.input & #ResolverPromptSurface) | _

	availableFragmentIDsLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.availableFragmentIDsLeak.input & #ResolverPromptSurface) | _

	availableRouteIDsLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.availableRouteIDsLeak.input & #ResolverPromptSurface) | _

	workerProfileIDLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.workerProfileIDLeak.input & #ResolverPromptSurface) | _

	workerBindingIDLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.workerBindingIDLeak.input & #ResolverPromptSurface) | _

	preferredWorkerAdapterLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.preferredWorkerAdapterLeak.input & #ResolverPromptSurface) | _

	generatedFromLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.generatedFromLeak.input & #ResolverPromptSurface) | _

	rawRegistryLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.rawRegistryLeak.input & #ResolverPromptSurface) | _

	rawTranscriptLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.rawTranscriptLeak.input & #ResolverPromptSurface) | _

	debugPacketAsDefaultOut:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.debugPacketAsDefaultOut.input & #HookEmissionContract) | _
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
// Exportable negative checks live in manifest.cue and checks/manifest.cue because
// cue export excludes *_test.cue files.

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
pluginBundleRoot:         ".codex/plugins/agent-context-resolver"
pluginBundleSourceRoot:   "contracts/plugin-bundle/agent-context-resolver/src"
pluginBundleTemplateRoot: "contracts/plugin-bundle/src"
pluginBundleContractRoot: "contracts/plugin-bundle/agent-context-resolver/instances/dotfiles"
pluginBundlePackage:      "dotfilespluginbundle"

#ContainedBundlePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

pluginBundleContractRequiredPaths: list.Concat([
	baseTemplateRequiredPaths,
	[
		for addition in dotfilesTemplateApplicationAdditions {
			addition.path
		},
	],
])

pluginBundleRuntimePackagePaths: list.Concat([
	runtimeTemplateRequiredPaths,
	[
		for addition in runtimeTemplateApplicationAdditions {
			addition.path
		},
	],
])

// Backwards-compatible aliases. New contract code should use the explicit names above.
pluginBundleRequiredPaths:        pluginBundleContractRequiredPaths
pluginBundleRuntimeRequiredPaths: pluginBundleRuntimePackagePaths

#RuntimePackageSubsetEvidence: close({
	contractRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePathsSubsetOfContractPaths: true
	subsetCheckAuthority:                     true
	runtimePackageAuthority:                  false
})

pluginBundleRuntimeSubsetEvidence: #RuntimePackageSubsetEvidence & {
	contractRequiredPaths: pluginBundleContractRequiredPaths
	runtimePackagePaths:   pluginBundleRuntimePackagePaths
}

_runtimePackagePathSubsetCheck: {
	for path in pluginBundleRuntimePackagePaths {
		if !list.Contains(pluginBundleContractRequiredPaths, path) {
			"\(path)": _|_
		}
	}
}

#BundledCueAuthorityBlock: close({
	root: "contracts"
	resolver: close({
		root: "contracts/agent-context-resolver"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	constructors: close({
		root: "contracts/meta"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	externalFactoryReference?:        false
	externalContractCuemodReference?: false
})

bundledCueAuthorityBlock: #BundledCueAuthorityBlock & {
	resolver: {
		files: [
			"implementation_slice_materializer.cue",
			"implementation_slice_eval_manifest.cue",
			"implementation_slice_runner_result.cue",
			"implementation_slice_constructor_inventory.cue",
			"manifest.cue",
			"manifest.cue",
			"checks/manifest.cue",
		]
	}
	constructors: {
		files: [
			"catalog.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"checks/manifest.cue",
		]
	}
}

#DotfilesAgentContextResolverBundleContract: close({
	schema:           "factory.plugin-bundle.dotfiles-agent-context-resolver.contract.v1"
	contractRoot:     pluginBundleContractRoot
	package:          pluginBundlePackage
	targetRepo:       "github.com/fatb4f/dotfiles"
	sourceRoot:       pluginBundleSourceRoot
	templateRoot:     pluginBundleTemplateRoot
	instanceRoot:     pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	requiredPaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackageSubset: #RuntimePackageSubsetEvidence
	bundledCueAuthority:  #BundledCueAuthorityBlock
	containment: close({
		allowHookIntegrationPath:        ".codex/hooks.json"
		pluginRootOnly:                  true
		topLevelPluginRoot:              false
		externalFactoryReference:        false
		externalContractCuemodReference: false
		proseReferenceAuthority:         false
	})
})

dotfilesAgentContextResolverBundleContract: #DotfilesAgentContextResolverBundleContract & {
	requiredPaths:        pluginBundleContractRequiredPaths
	runtimePackagePaths:  pluginBundleRuntimePackagePaths
	runtimePackageSubset: pluginBundleRuntimeSubsetEvidence
	bundledCueAuthority:  bundledCueAuthorityBlock
	containment: {
		allowHookIntegrationPath:        ".codex/hooks.json"
		pluginRootOnly:                  true
		topLevelPluginRoot:              false
		externalFactoryReference:        false
		externalContractCuemodReference: false
		proseReferenceAuthority:         false
	}
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
negativeFixtures: {
	codexAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {codexAuthority: true}}
	generatedAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {generatedAuthority: true}}
	externalDependency: {input: dotfilesAgentContextResolverBundleInput & {externalFactoryRootLookup: true}}
	contractCuemodDependency: {input: dotfilesAgentContextResolverBundleInput & {externalContractCuemodLookup: true}}
	providerOutputAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {providerOutputIsAuthority: true}}
	topLevelPluginRoot: {input: dotfilesAgentContextResolverBundleInput & {topLevelPluginRoot: true}}
	proseReferenceAuthority: {input: dotfilesAgentContextResolverBundleInput & {proseReferenceAuthority: true}}
	materializationWithoutLock: {input: {
		repo:      dotfilesTarget.repo
		root:      dotfilesTarget.root
		files:     generatedFileInventory
		overwrite: "replace-generated"
		provenance: {
			kind:             "projection"
			contractRoot:     pluginBundleContractRoot
			sourceRoot:       pluginBundleSourceRoot
			templateRoot:     pluginBundleTemplateRoot
			instanceRoot:     pluginBundleContractRoot
			materializedRoot: pluginBundleRoot
			projection:       "dotfiles-agent-context-resolver-plugin-bundle-v1"
			lockID:           "missing-lock-evidence"
			authority:        false
		}
	}}
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
promptSurfaceControllerPacketFixture: {
	schema: "agent.route-controller-packet.v1"
	availableFragmentIDs: ["agent-context-resolver.authority", "agent-skill.projection"]
	selectedFragments: ["agent-context-resolver.authority"]
	controller: {
		schema: "agent.route-plan.v1"
		availableRouteIDs: ["resolver.inspect.current"]
		routes: [{
			id:                     "resolver.inspect.current"
			kind:                   "inspect"
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
		}]
		propagation: {mode: "route-local"}
		runtime: {routeRefs: [{routeID: "resolver.inspect.current"}]}
	}
	generatedFrom: {routeInventory: "generated/route_inventory.json"}
}

promptSurfaceFixtureBase: {
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: ["agent-context-resolver.authority"]
	selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary."}]
	execution: {mode: "prompt-only", routeExecution: false, controllerPacket: false, debugEvidence: "stderr-or-file"}
	hints: [{text: "Emit only the compact prompt surface on UserPromptSubmit stdout."}]
}

dotfilesAgentContextResolverPromptSurfaceNegativeFixtures: {
	controllerLeak: {input: promptSurfaceFixtureBase & {controller: promptSurfaceControllerPacketFixture.controller}}
	runtimeLeak: {input: promptSurfaceFixtureBase & {runtime: promptSurfaceControllerPacketFixture.controller.runtime}}
	propagationLeak: {input: promptSurfaceFixtureBase & {propagation: promptSurfaceControllerPacketFixture.controller.propagation}}
	availableFragmentIDsLeak: {input: promptSurfaceFixtureBase & {availableFragmentIDs: promptSurfaceControllerPacketFixture.availableFragmentIDs}}
	availableRouteIDsLeak: {input: promptSurfaceFixtureBase & {availableRouteIDs: promptSurfaceControllerPacketFixture.controller.availableRouteIDs}}
	workerProfileIDLeak: {input: promptSurfaceFixtureBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", workerProfileID: "agent-context-resolver.a2a-worker"}]}}
	workerBindingIDLeak: {input: promptSurfaceFixtureBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", workerBindingID: "agent-context-resolver.validation-worker"}]}}
	preferredWorkerAdapterLeak: {input: promptSurfaceFixtureBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", preferredWorkerAdapter: "a2a"}]}}
	generatedFromLeak: {input: promptSurfaceFixtureBase & {generatedFrom: promptSurfaceControllerPacketFixture.generatedFrom}}
	rawRegistryLeak: {input: promptSurfaceFixtureBase & {rawRegistry: {fragments: promptSurfaceControllerPacketFixture.availableFragmentIDs}}}
	rawTranscriptLeak: {input: promptSurfaceFixtureBase & {rawTranscript: "UserPromptSubmit full transcript"}}
	debugPacketAsDefaultOut: {input: {
		defaultMode: "compact"
		debugMode:   "debug"
		stdout: {mode: "compact", payload: promptSurfaceControllerPacketFixture}
		stderr: {mode: "debug", optional: true, payload: "route-controller-packet"}
		fullPacketDefaultStdout:     false
		generatedArtifactsAuthority: false
		debug: {allowed: true, sinks: ["stderr", "file"], fullPacketSchema: "agent.route-controller-packet.v1", authority: false}
	}}
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#HookEmissionMode: "compact" | "debug"

#DebugEmissionBoundary: close({
	allowed: true
	sinks: [..."stderr" | "file"]
	fullPacketSchema: "agent.route-controller-packet.v1"
	authority:        false
})

#HookStdoutContract: close({
	mode:    "compact"
	payload: #ResolverPromptSurface
})

#HookStderrContract: close({
	mode:     "debug"
	optional: true
	payload:  "route-controller-packet" | "diagnostics" | "none"
})

#HookEmissionContract: close({
	defaultMode:                 "compact"
	debugMode:                   "debug"
	stdout:                      #HookStdoutContract
	stderr:                      #HookStderrContract
	fullPacketDefaultStdout:     false
	generatedArtifactsAuthority: false
	debug:                       #DebugEmissionBoundary
})

dotfilesAgentContextResolverHookEmissionContract: #HookEmissionContract & {
	defaultMode: "compact"
	debugMode:   "debug"
	stdout: {mode: "compact", payload: dotfilesAgentContextResolverPromptSurface}
	stderr: {mode: "debug", optional: true, payload: "route-controller-packet"}
	fullPacketDefaultStdout:     false
	generatedArtifactsAuthority: false
	debug: {allowed: true, sinks: ["stderr", "file"], fullPacketSchema: "agent.route-controller-packet.v1", authority: false}
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#FileLock: close({
	path:      #NonEmptyString
	generated: true
	authority: false
})

#BundleLockEvidence: close({
	id:               #NonEmptyString
	authority:        false
	contractRoot:     pluginBundleContractRoot
	sourceRoot:       pluginBundleSourceRoot
	templateRoot:     pluginBundleTemplateRoot
	instanceRoot:     pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	projection:       "dotfiles-agent-context-resolver-plugin-bundle-v1"
	target: close({
		repo: "github.com/fatb4f/dotfiles"
		root: "."
	})
	files: [...#FileLock] & [_, ...]
	gates: [#NonEmptyString]: close({
		required: true
		result:   "pass" | "pending"
	})
})

dotfilesAgentContextResolverLock: #BundleLockEvidence & {
	id:               "dotfiles-agent-context-resolver-plugin-bundle-v1"
	authority:        false
	contractRoot:     pluginBundleContractRoot
	sourceRoot:       pluginBundleSourceRoot
	templateRoot:     pluginBundleTemplateRoot
	instanceRoot:     pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	projection:       "dotfiles-agent-context-resolver-plugin-bundle-v1"
	target:           dotfilesTarget
	files: [
		for file in generatedFileInventory {
			path:      file.path
			generated: true
			authority: false
		},
	]
	gates: {
		for gate in projectionGates {
			"\(gate.id)": {
				required: true
				result:   "pending"
			}
		}
	}
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#OverwritePolicy: "replace-generated"

#DotfilesPluginMaterialization: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
	files: [...#DotfilesTargetFile] & [_, ...]
	overwrite: #OverwritePolicy
	provenance: close({
		kind:             "projection"
		contractRoot:     pluginBundleContractRoot
		sourceRoot:       pluginBundleSourceRoot
		templateRoot:     pluginBundleTemplateRoot
		instanceRoot:     pluginBundleContractRoot
		materializedRoot: pluginBundleRoot
		projection:       "dotfiles-agent-context-resolver-plugin-bundle-v1"
		lockID:           #NonEmptyString
		authority:        false
	})
})

dotfilesAgentContextResolverMaterializationInput: {
	repo:      dotfilesTarget.repo
	root:      dotfilesTarget.root
	files:     generatedFileInventory
	overwrite: "replace-generated"
	provenance: {
		kind:             "projection"
		contractRoot:     pluginBundleContractRoot
		sourceRoot:       dotfilesAgentContextResolverLock.sourceRoot
		templateRoot:     dotfilesAgentContextResolverLock.templateRoot
		instanceRoot:     dotfilesAgentContextResolverLock.instanceRoot
		materializedRoot: dotfilesAgentContextResolverLock.materializedRoot
		projection:       "dotfiles-agent-context-resolver-plugin-bundle-v1"
		lockID:           dotfilesAgentContextResolverLock.id
		authority:        false
	}
}

dotfilesAgentContextResolverMaterialization: #DotfilesPluginMaterialization & dotfilesAgentContextResolverMaterializationInput

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#PluginBundlePackageFile: close({
	path:      #ContainedBundlePath
	generated: true
	authority: false
})

#IdempotentPluginBundlePackage: close({
	schema:           "factory.plugin-bundle.idempotent-package.v1"
	id:               #NonEmptyString
	packageRoot:      #ContainedBundlePath
	materializedRoot: #ContainedBundlePath
	projection:       "dotfiles-agent-context-resolver-plugin-bundle-v1"
	files: [...#PluginBundlePackageFile] & [_, ...]
	lock: #BundleLockEvidence
	install: close({
		mode:       "copy-package-tree"
		overwrite:  "replace-generated"
		idempotent: true
	})
	distribution: close({
		kind:                        "materialized-package"
		publishAfterMaterialization: true
		sourceReferencesInPackage:   false
		externalAuthorityRequired:   false
	})
	invariants: close({
		sameInputsSamePackage:                    true
		packageContentsOnly:                      true
		generatedOutputAuthority:                 false
		runtimeGenerationRequired:                false
		runtimePackagePathsSubsetOfContractPaths: true
		fullContractSurfaceRetained:              true
	})
})

dotfilesAgentContextResolverPackage: #IdempotentPluginBundlePackage & {
	id:               dotfilesAgentContextResolverLock.id
	packageRoot:      pluginBundleRoot
	materializedRoot: pluginBundleRoot
	files: [
		for file in generatedFileInventory {
			path:      file.path
			generated: true
			authority: false
		},
	]
	lock: dotfilesAgentContextResolverLock
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
dotfilesTarget: #DotfilesTarget & {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
}

dotfilesContractTargetInventory: [
	for relativePath in pluginBundleContractRequiredPaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

dotfilesRuntimePackageTargetInventory: [
	for relativePath in pluginBundleRuntimePackagePaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

// Backwards-compatible aliases. The materialized package uses the runtime inventory.
dotfilesTargetInventory:        dotfilesContractTargetInventory
dotfilesRuntimeTargetInventory: dotfilesRuntimePackageTargetInventory

generatedFileInventory: [
	for targetPath in dotfilesRuntimePackageTargetInventory {
		path:      targetPath
		generated: true
		authority: false
		source:    "bundle-projection"
	},
]

fullGeneratedFileInventory: [
	for targetPath in dotfilesContractTargetInventory {
		path:      targetPath
		generated: true
		authority: false
		source:    "bundle-projection"
	},
]

projectionComponents: [
	{id: "plugin-bundle-contract", path: pluginBundleContractRoot, role: "contract", authority: true},
	{id: "plugin-bundle-source", path: pluginBundleSourceRoot, role: "contract", authority: true},
	{id: "plugin-bundle-template", path: pluginBundleTemplateRoot, role: "contract", authority: true},
	{id: "template-application", path: "\(pluginBundleContractRoot)/manifest.cue", role: "contract", authority: true},
	{id: "dotfiles-runtime-package-root", path: pluginBundleRoot, role: "generated-package", generated: true, authority: false},
	{id: "runtime-generated-surfaces", path: "\(pluginBundleRoot)/generated", role: "package-content", generated: true, authority: false},
	{id: "runtime-manifest", path: "\(pluginBundleRoot)/manifest.json", role: "package-metadata", generated: true, authority: false},
	{id: "runtime-package-lock", path: "\(pluginBundleRoot)/package.lock.json", role: "idempotency-lock", generated: true, authority: false},
	{id: "codex-hook-integration", path: ".codex/hooks.json", role: "integration", generated: true, authority: false},
]

projectionGates: [
	{id: "plugin-bundle-cue-vet", kind: "cue-vet", target: "./contracts/plugin-bundle/agent-context-resolver/instances/dotfiles", required: true},
	{id: "plugin-bundle-contract-export", kind: "cue-export", target: "dotfilesAgentContextResolverBundleContract", required: true},
	{id: "plugin-bundle-template-application-export", kind: "cue-export", target: "dotfilesAgentContextResolverTemplateApplication", required: true},
	{id: "plugin-bundle-materialization-export", kind: "cue-export", target: "dotfilesAgentContextResolverMaterialization", required: true},
	{id: "plugin-bundle-lock-export", kind: "cue-export", target: "dotfilesAgentContextResolverLock", required: true},
	{id: "plugin-bundle-package-export", kind: "cue-export", target: "dotfilesAgentContextResolverPackage", required: true},
	{id: "plugin-bundle-negative-bottom", kind: "negative-bottom", target: "_negativeBottomChecks", required: true},
]

dotfilesAgentContextResolverBundleInput: {
	contract:            dotfilesAgentContextResolverBundleContract
	templateApplication: dotfilesAgentContextResolverTemplateApplication
	target:              dotfilesTarget
	components:          projectionComponents
	generatedFiles:      generatedFileInventory
	materialization:     dotfilesAgentContextResolverMaterializationInput
	lock:                dotfilesAgentContextResolverLock
	package:             dotfilesAgentContextResolverPackage
	gates:               projectionGates
	providerReachability: {
		kind:         "provider-reachability"
		authority:    false
		evidenceOnly: true
		providers: [
			"fragment_inventory",
			"prompt_routes",
			"route_inventory",
		]
	}
}

dotfilesAgentContextResolverBundle: #AdmissibleDotfilesPluginBundleProjection & dotfilesAgentContextResolverBundleInput

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#PromptSurfaceIntent: "resolver" | "context-resolution" | "dotfiles-agent-context-resolver"

#PromptSurfaceRoute: close({
	id:        #NonEmptyString
	kind:      "inspect" | "validate" | "generate" | "diff" | "test" | "summarize" | "risk_scan"
	objective: #NonEmptyString
})

#PromptSurfaceExecution: close({
	mode:             "prompt-only" | "compact-summary"
	routeExecution:   false
	controllerPacket: false
	debugEvidence:    "stderr-or-file"
})

#PromptSurfaceHint: close({text: #NonEmptyString})

#ResolverPromptSurface: close({
	schema: "agent.resolver-prompt-surface.v1"
	intent: #PromptSurfaceIntent
	selectedFragments: [...#NonEmptyString]
	selectedRoutes: [...#PromptSurfaceRoute]
	execution: #PromptSurfaceExecution
	hints: [...#PromptSurfaceHint]
})

dotfilesAgentContextResolverPromptSurface: #ResolverPromptSurface & {
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: [
		"agent-context-resolver.authority",
		"agent-skill.projection",
		"repo.lifecycle",
		"resolver.context-packet",
	]
	selectedRoutes: [
		{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary."},
		{id: "resolver.plan.compile", kind: "validate", objective: "Validate bounded prompt projection without runtime execution."},
		{id: "agent-skill.projection.validate", kind: "validate", objective: "Validate hook and skill projections as generated artifacts."},
	]
	execution: {
		mode:             "prompt-only"
		routeExecution:   false
		controllerPacket: false
		debugEvidence:    "stderr-or-file"
	}
	hints: [
		{text: "Emit only the compact prompt surface on UserPromptSubmit stdout."},
		{text: "Keep the route-controller packet as debug evidence on stderr or in a file."},
		{text: "Treat generated hook artifacts as non-authoritative projections."},
		{text: "Reject controller, runtime, registry, worker binding, and transcript leakage."},
	]
}

#ProjectionDropField: "controller" | "propagation" | "runtime" | "availableFragmentIDs" | "availableRouteIDs" | "workerProfileID" | "workerBindingID" | "preferredWorkerAdapter" | "generatedFrom" | "rawRegistry" | "rawTranscript"

#ResolverPromptProjection: close({
	sourceSchema: "agent.route-controller-packet.v1"
	targetSchema: "agent.resolver-prompt-surface.v1"
	drop: [...#ProjectionDropField]
	stdout: close({payload: "prompt-surface", compact: true})
	debug: close({explicit: true, fullPacketSinks: [..."stderr" | "file"]})
})

dotfilesAgentContextResolverPromptSurfaceProjection: #ResolverPromptProjection & {
	sourceSchema: "agent.route-controller-packet.v1"
	targetSchema: "agent.resolver-prompt-surface.v1"
	drop: ["controller", "propagation", "runtime", "availableFragmentIDs", "availableRouteIDs", "workerProfileID", "workerBindingID", "preferredWorkerAdapter", "generatedFrom", "rawRegistry", "rawTranscript"]
	stdout: {payload: "prompt-surface", compact: true}
	debug: {explicit: true, fullPacketSinks: ["stderr", "file"]}
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
dotfilesAgentContextResolverReport: {
	schema: "factory.plugin-bundle.report.v1"
	status: "admitted"
	path:   pluginBundleContractRoot
	templateApplication: {
		template:             dotfilesAgentContextResolverTemplateApplication.template.id
		instance:             dotfilesAgentContextResolverTemplateApplication.instance.id
		baseRequiredPaths:    len(dotfilesAgentContextResolverTemplateApplication.baseRequiredPaths)
		additions:            len(dotfilesAgentContextResolverTemplateApplication.additions)
		instanceOwnsTemplate: false
	}
}

dotfilesAgentContextResolverPromptSurfaceReport: {
	schema: "factory.plugin-bundle.prompt-surface.report.v1"
	status: "admitted"
	path:   pluginBundleContractRoot
}

dotfilesTemplateApplicationReport: {
	schema:                   "factory.plugin-bundle.template-application.report.v1"
	status:                   "admitted"
	template:                 dotfilesAgentContextResolverTemplateApplication.template.id
	instance:                 dotfilesAgentContextResolverTemplateApplication.instance.id
	resultRequiredPaths:      len(dotfilesAgentContextResolverTemplateApplication.resultRequiredPaths)
	generatedOutputAuthority: false
	instanceOwnsTemplate:     false
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#NonEmptyString: string & !=""

#DotfilesTarget: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
})

#Gate: close({
	id:       #NonEmptyString
	kind:     "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search" | "plugin-manifest" | "archive"
	target:   #NonEmptyString
	required: true
})

#DotfilesTargetFile: close({
	path:      #NonEmptyString
	generated: true
	authority: false
	source:    "bundle-projection"
})

#ProjectionComponent: close({
	id:        #NonEmptyString
	path:      #NonEmptyString
	role:      "contract" | "projection" | "generated-output" | "evidence" | "integration" | "generated-package" | "package-content" | "package-metadata" | "idempotency-lock"
	generated: *false | bool
	authority: bool
})

#ProviderReachabilityEvidence: close({
	kind:         "provider-reachability"
	authority:    false
	evidenceOnly: true
	providers: [...#NonEmptyString]
})

#DotfilesPluginBundleProjection: close({
	contract:            #DotfilesAgentContextResolverBundleContract
	templateApplication: #PluginBundleTemplateApplication
	target:              #DotfilesTarget
	components: [...#ProjectionComponent] & [_, ...]
	generatedFiles: [...#DotfilesTargetFile] & [_, ...]
	materialization: #DotfilesPluginMaterialization
	lock:            #BundleLockEvidence
	package:         #IdempotentPluginBundlePackage
	gates: [...#Gate] & [_, ...]
	providerReachability?: #ProviderReachabilityEvidence

	codexAuthority?:               false
	generatedAuthority?:           false
	providerOutputIsAuthority?:    false
	externalFactoryRootLookup?:    false
	externalContractCuemodLookup?: false
	topLevelPluginRoot?:           false
	proseReferenceAuthority?:      false
})

#AdmissibleDotfilesPluginBundleProjection: #DotfilesPluginBundleProjection & {
	codexAuthority?:               false
	generatedAuthority?:           false
	providerOutputIsAuthority?:    false
	externalFactoryRootLookup?:    false
	externalContractCuemodLookup?: false
	topLevelPluginRoot?:           false
	proseReferenceAuthority?:      false
}

// source: contracts/agent-context-resolver/instances/dotfiles/manifest.cue
#TemplateApplicationAddition: close({
	path:      #ContainedBundlePath
	kind:      "resolver-output"
	generated: true
	authority: false
	reason:    #NonEmptyString
})

#PluginBundleTemplateApplication: close({
	schema: "factory.plugin-bundle.template-application.v1"
	template: close({
		id:               "agent-context-resolver"
		root:             "contracts/plugin-bundle/src"
		materializedRoot: ".codex/plugins/agent-context-resolver"
	})
	instance: close({
		id:               "dotfiles"
		root:             pluginBundleContractRoot
		targetRepo:       "github.com/fatb4f/dotfiles"
		materializedRoot: pluginBundleRoot
	})
	baseRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	additions: [...#TemplateApplicationAddition]
	contractRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	runtimePackagePaths: [...#ContainedBundlePath] & [_, ...]
	resultRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	generatedOutputAuthority: false
	instanceOwnsTemplate:     false
})

baseTemplateRequiredPaths: [
	"SKILL.md",
	"manifest.json",
	"package.json",
	"package.lock.json",
	"cue.mod/module.cue",
	"scripts/agent-context-resolver-hook",
	"scripts/resolve-agent-context",
	"contracts/agent-context-resolver/implementation_slice_materializer.cue",
	"contracts/agent-context-resolver/implementation_slice_eval_manifest.cue",
	"contracts/agent-context-resolver/implementation_slice_runner_result.cue",
	"contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue",
	"contracts/agent-context-resolver/manifest.cue",
	"contracts/agent-context-resolver/manifest.cue",
	"contracts/agent-context-resolver/checks/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/manifest.cue",
	"contracts/meta/checks/manifest.cue",
]

runtimeTemplateRequiredPaths: [
	"SKILL.md",
	"manifest.json",
	"package.lock.json",
	"scripts/agent-context-resolver-hook",
	"scripts/resolve-agent-context",
]

dotfilesTemplateApplicationAdditions: [
	{path: "generated/turn_start_fragments.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver turn-start fragment projection"},
	{path: "generated/prompt_routes.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver prompt route projection"},
	{path: "generated/route_inventory.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver route inventory projection"},
	{path: "generated/fragment_inventory.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver fragment inventory projection"},
	{path: "generated/provider_inventory.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver provider inventory projection"},
	{path: "generated/dotfiles.schema-map.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle dotfiles schema-map projection"},
]

runtimeTemplateApplicationAdditions: [
	dotfilesTemplateApplicationAdditions[0],
	dotfilesTemplateApplicationAdditions[1],
	dotfilesTemplateApplicationAdditions[2],
	dotfilesTemplateApplicationAdditions[3],
]

dotfilesAgentContextResolverTemplateApplication: #PluginBundleTemplateApplication & {
	template: {
		id:               "agent-context-resolver"
		root:             pluginBundleTemplateRoot
		materializedRoot: pluginBundleRoot
	}
	instance: {
		id:               "dotfiles"
		root:             pluginBundleContractRoot
		targetRepo:       dotfilesTarget.repo
		materializedRoot: pluginBundleRoot
	}
	baseRequiredPaths:        baseTemplateRequiredPaths
	additions:                dotfilesTemplateApplicationAdditions
	contractRequiredPaths:    pluginBundleContractRequiredPaths
	runtimePackagePaths:      pluginBundleRuntimePackagePaths
	resultRequiredPaths:      pluginBundleContractRequiredPaths
	generatedOutputAuthority: false
	instanceOwnsTemplate:     false
}
