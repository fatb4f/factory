package agentcontextresolver

issue28: {
	id:    "agent-context-resolver.root.reflective-method-promotion-gate"
	kind:  "parent"
	repo:  "fatb4f/factory"
	title: "feat(agent-context-resolver): tighten resolver reflective method and promotion-gate model"

	correction: {
		applied:                true
		priorDraftLocation:     "contracts/factory/**"
		correctedAuthorityRoot: "contracts/agent-context-resolver/**"
		reason: "Issue #28 was drafted with the wrong contract location. The implementation authority root is resolver-local."
	}

	rootQuestion: """
	How can contracts/agent-context-resolver operate on hook/template eval obligations,
	runner plans, generated projection descriptors, fixtures, and negative checks as one
	resolver-local CUE contract before shell, Claude, Codex, git, go-git, factoryctl,
	GitHub Projects, generated artifacts, or adapters can define semantic authority?
	"""

	authorityBoundary: {
		cueRootContract: {
			root:     "contracts/agent-context-resolver"
			surfaces: ["contracts/agent-context-resolver/**"]

			soleAuthorityFor: [
				"hook event shape",
				"issue-template implementation-slice intent shape",
				"eval obligation derivation",
				"eval plan derivation",
				"runner plan derivation",
				"generated hook projection descriptors",
				"resolver-local fixtures",
				"resolver-local negative bottom checks",
				"resolver-local public exports",
			]
		}

		factory: {
			role:      "repository/container context and separate root factory policy"
			authority: false
			mayNotDefineForIssue28: [
				"resolver hook/template/eval authority",
				"resolver runner-plan semantics",
				"resolver-local closure",
			]
		}

		adapters: {
			role:      "observe/project/execute declared behavior only"
			authority: false
			mayNotDefine: ["commands", "expectations", "paths", "gates", "semantic checks", "closure"]
		}

		generatedArtifacts: {
			role:      "projection/evidence only"
			authority: false
		}
	}

	scopeLock: {
		activeImplementation: ["contracts/agent-context-resolver/**"]
		staleDraftLocation:   "contracts/factory/**"
		rule: "Do not evaluate #28 closure against contracts/factory/**; evaluate resolver-local surfaces instead."
	}

	implementedChildren: [
		{
			issue:  40
			commit: "09f75f63b7fdbc90914a7208249fe48cb89b33c9"
			role:   "introduced hook/template eval obligation model"
		},
		{
			issue:  41
			commit: "d458a7ba11ddbacf7a1844b42b4357c8dd078751"
			role:   "relocated hook/template/eval authority into contracts/agent-context-resolver and made runner/projection surfaces resolver-local"
		},
	]

	publicResolverSurfaces: [
		"resolverHookTemplateIssue",
		"resolverHookTemplateEvalPlan",
		"resolverHookEvalRunnerPlan",
		"resolverHookGeneratedProjection",
		"resolverHookTemplateGate",
	]

	closure: {
		state: "reassess"
		reason: "Location correction has been applied. Parent closure now depends on resolver-local gate/evidence evaluation, not factory-local issue text."
		nextRequiredChecks: [
			"cue vet ./contracts/agent-context-resolver",
			"cue export ./contracts/agent-context-resolver -e resolverHookTemplateIssue",
			"cue export ./contracts/agent-context-resolver -e resolverHookTemplateEvalPlan",
			"cue export ./contracts/agent-context-resolver -e resolverHookEvalRunnerPlan",
			"cue export ./contracts/agent-context-resolver -e resolverHookGeneratedProjection",
			"cue export ./contracts/agent-context-resolver -e resolverHookTemplateGate",
			"negative bottom checks under _negativeBottomChecks.hookTemplate",
		]
	}
}

issue28LocationCorrection: issue28.correction
