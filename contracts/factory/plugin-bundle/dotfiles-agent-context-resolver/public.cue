package dotfilespluginbundle

dotfilesAgentContextResolverReport: {
	schema:  "factory.dotfiles-agent-context-resolver-plugin-bundle.report.v0"
	status:  "admitted"
	package: "dotfilespluginbundle"
	path:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
	slice:   "dotfiles-agent-context-resolver-plugin-bundle-v0"

	authority: {
		owns: [
			"dotfiles plugin bundle projection",
			"contract.cuemod input references",
			"dotfiles target materialization",
			"generated file inventory",
			"bundle lock evidence",
		]
		doesNotOwn: [
			"contract.cuemod semantics",
			"dotfiles source authority",
			"runtime behavior",
			"server implementation",
			"manual generated artifact edits",
		]
	}

	rootQuestion: {
		id:   "N0.contract-question"
		text: "What factory authority is required to generate the dotfiles agent context resolver plugin bundle from contract.cuemod while keeping generated artifacts non-authoritative?"
	}

	primitives: [
		"#DotfilesPluginBundleProjection",
		"#ContractCuemodInput",
		"#DotfilesPluginMaterialization",
	]

	files: {
		package: "dotfilespluginbundle"
		root:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
		expected: [
			"root.cue",
			"inputs.cue",
			"projection.cue",
			"materialization.cue",
			"lock.cue",
			"fixtures.cue",
			"checks_test.cue",
			"public.cue",
		]
	}

	targetInventory: [
		for targetPath in dotfilesTargetInventory {targetPath},
	]

	publicExports: [
		"dotfilesAgentContextResolverBundle",
		"dotfilesAgentContextResolverMaterialization",
		"dotfilesAgentContextResolverLock",
		"dotfilesAgentContextResolverReport",
		"_negativeBottomChecks",
	]

	negativeBottomChecks: {
		codexAsAuthority:           "negativeFixtures.codexAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection"
		generatedAsAuthority:       "negativeFixtures.generatedAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection"
		externalDependency:         "negativeFixtures.externalDependency.input & #AdmissibleDotfilesPluginBundleProjection"
		providerOutputAsAuthority:  "negativeFixtures.providerOutputAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection"
		materializationWithoutLock: "negativeFixtures.materializationWithoutLock.input & #AdmissibleDotfilesPluginMaterialization"
	}

	forbiddenAttractors: [
		".codexAuthority",
		"generatedAuthority",
		"providerOutputIsAuthority: true",
		"externalFactoryRootLookup: true",
		"externalContractCuemodLookup: true",
	]

	acceptance: [
		"bounded CUE surface exists",
		"public exports render",
		"negative fixtures bottom out",
		"generated files are materialized non-authority outputs",
		"provider reachability is projected metadata",
	]

	control: {
		action: "admit"
		reason: "The dotfiles plugin bundle projection is bounded to contract.cuemod inputs and materializes generated outputs as non-authority files with lock evidence."
		evidence: [
			"public eval exports",
			"generated file inventory",
			"negative bottom checks",
			"bundle lock evidence",
		]
		nextState: "dotfiles target materialization can be generated from contract.cuemod without treating generated plugin files as source authority"
	}
}

dotfilesAgentContextResolverPromptSurfaceReport: {
	schema:  "factory.dotfiles-agent-context-resolver-prompt-surface.report.v0"
	status:  "admitted"
	package: "dotfilespluginbundle"
	path:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
	slice:   "dotfiles-agent-context-resolver-prompt-surface-v0"

	authority: {
		owns: [
			"resolver prompt-surface projection",
			"UserPromptSubmit emission boundary",
			"debug-only controller packet classification",
			"negative leakage checks",
		]
		doesNotOwn: [
			"dotfiles source authority",
			"contract.cuemod semantics",
			"runtime execution",
			"manual generated artifact edits",
		]
	}

	rootQuestion: {
		id:   "N0.prompt-surface"
		text: "What bounded factory contract keeps the dotfiles resolver useful while preventing UserPromptSubmit from emitting full route-controller packets?"
	}

	context: {
		parentIssue:            70
		factoryEvidenceCommit: "768f60094a9511dee3d3d58483f4a225191d2a68"
		refImplementation: {
			repo: "fatb4f/dotfiles"
			ref:  "main"
			root: ".github"
			paths: [
				".github/dotfiles-manifest-slice/README.md",
				".github/dotfiles-manifest-slice/contracts/issues/_template/manifest.cue",
			]
		}
		observed: {
			badSurface: "UserPromptSubmit emits agent.route-controller-packet.v1"
			constraint: "issue body and hook output must stay compact"
		}
	}

	primitives: [
		{
			name: "#ResolverPromptSurface"
			role: "prompt-visible digest for resolver output"
			requiredFields: ["schema", "intent", "selectedFragments", "selectedRoutes", "execution", "hints"]
			constraints: ["no controller packet", "no registry dump", "no runtime routeRefs", "max five hints"]
		},
		{
			name: "#ResolverPromptProjection"
			role: "lossy projection from route-controller packet to prompt surface"
			requiredFields: ["sourceSchema", "targetSchema", "drop", "map"]
			constraints: ["drops internals by default", "debug output is explicit", "stdout is compact"]
		},
		{
			name: "#HookEmissionContract"
			role: "adapter contract for dotfiles UserPromptSubmit hook"
			requiredFields: ["defaultMode", "debugMode", "stdout", "stderr"]
			constraints: ["compact is default", "full packet is stderr or file only", "generated artifacts remain non-authority"]
		},
	]

	files: {
		package: "dotfilespluginbundle"
		root:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
		expected: [
			"prompt_surface.cue",
			"hook_emission.cue",
			"fixtures_prompt_surface.cue",
			"checks_prompt_surface_test.cue",
			"public.cue",
		]
	}

	targetInventory: [
		".codex/hooks.json",
		".codex/plugins/agent-context-resolver/scripts/agent-context-resolver-hook",
		".codex/plugins/agent-context-resolver/scripts/resolve-agent-context",
	]

	publicExports: [
		"dotfilesAgentContextResolverPromptSurface",
		"dotfilesAgentContextResolverPromptSurfaceProjection",
		"dotfilesAgentContextResolverHookEmissionContract",
		"dotfilesAgentContextResolverPromptSurfaceReport",
		"_negativeBottomChecks",
	]

	negativeBottomChecks: {
		controllerLeak:          "negativeFixtures.controllerLeak.input & #ResolverPromptSurface"
		runtimeLeak:             "negativeFixtures.runtimeLeak.input & #ResolverPromptSurface"
		registryLeak:            "negativeFixtures.registryLeak.input & #ResolverPromptSurface"
		workerBindingLeak:       "negativeFixtures.workerBindingLeak.input & #ResolverPromptSurface"
		debugPacketAsDefaultOut: "negativeFixtures.debugPacketAsDefaultOut.input & #HookEmissionContract"
	}

	forbiddenAttractors: [
		"controller:",
		"propagation:",
		"runtime:",
		"availableFragmentIDs",
		"availableRouteIDs",
		"workerProfileID",
		"workerBindingID",
		"preferredWorkerAdapter",
		"generatedFrom:",
		"rawRegistry",
		"rawTranscript",
	]

	acceptance: [
		"issue body remains a compact CUE implementation slice",
		"UserPromptSubmit emits prompt surface only",
		"full route-controller packet is debug/evidence only",
		"negative leakage fixtures bottom out",
		"dotfiles .github implementation pattern is used as workflow reference",
	]

	control: {
		action: "admit"
		reason: "The UserPromptSubmit boundary defaults to a compact resolver prompt surface while retaining full route-controller packets only as debug evidence."
		evidence: [
			"prompt surface export",
			"projection export",
			"hook emission export",
			"negative leakage checks",
		]
		nextState: "dotfiles hook output can emit a compact prompt surface without leaking controller internals"
	}
}
