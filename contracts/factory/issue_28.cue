package factory

issue: {
	id:    "factory.root.reflective-method-promotion-gate"
	kind:  "parent"
	repo:  "fatb4f/factory"
	title: "feat(factory): tighten root reflective method and promotion-gate model"

	authorityBoundary: {
		cueRootContract: {
			root: "contracts/factory"
			surfaces: ["contracts/factory/**"]

			soleAuthorityFor: [
				"reflective methods",
				"promotion gates",
				"generated artifact graph",
				"derived paths",
				"effects",
				"evidence schemas",
				"closure rules",
			]
		}

		generatedArtifacts: {
			authority: false
			role:      "projection/evidence only"
		}

		resolver: {
			activeScope:        false
			downstreamOnly:     true
			mayDefineAuthority: false
			mayDefinePaths:     false
			mayDefineGates:     false
			mayDefineEffects:   false
		}

		shellJustAdaptersGoGit: {
			activeScope:        false
			downstreamOnly:     true
			role:               "execution substrate only after root-exported operation plans exist"
			mayDefineSemantics: false
			mayDefinePaths:     false
			mayDefineGates:     false
			mayDefineEffects:   false
		}
	}

	scopeLock: {
		activeImplementation: ["contracts/factory/**"]
		inadmissibleForThisParent: [
			"cmd/**",
			"internal/**",
			"contracts/agent-context-resolver/**",
			"adapters outside contracts/factory/**",
			"GitHub Projects mutation/apply code",
			"factoryctl",
			"go-git executor",
			"shell generation scripts",
		]
	}

	promotionGate:    rootPromotionGate
	closureReport:    rootClosureReport
	baselinePatch:    baselineObservedPatch
	negativeFixtures: rootNegativeFixtures
}

rootPromotionGate: #RootPromotionGate & {
	id:        "factory.root.self-operation.promotion-gate"
	candidate: baselineObservedPatch & #RootPromotionCandidate
	checks: [
		{id: "P0_vetRoot", command: "cue vet ./contracts/factory", mutates: false},
		{id: "P1_exportFactory", command: "cue export ./contracts/factory -e factory", mutates: false},
		{id: "P2_exportIssue", command: "cue export ./contracts/factory -e issue", mutates: false},
		{id: "P3_exportPromotionGate", command: "cue export ./contracts/factory -e promotionGate", mutates: false},
		{id: "P4_exportClosureReport", command: "cue export ./contracts/factory -e closureReport", mutates: false},
		{id: "P5_negativeFixtures", command: "cue export ./contracts/factory -e factory.negativeFixtures", mutates: false},
		{id: "P6_pathDerivation", command: "cue export ./contracts/factory -e factory.paths", mutates: false},
		{id: "P7_operationPlans", command: "cue export ./contracts/factory -e factory.operations", mutates: false},
		{id: "P8_evidenceSchemas", command: "cue export ./contracts/factory -e factory.evidence", mutates: false},
	]
	negativeFixtures: [
		rootNegativeFixtures.vocabularyWithoutGateProof,
		rootNegativeFixtures.sidePackageSchemaSprawl,
		rootNegativeFixtures.prematureClosureClaim,
		rootNegativeFixtures.placeholderEvidenceOrProvenance,
		rootNegativeFixtures.nonDerivedPath,
	]
	decision: "blocked"
}

rootClosureReport: #ClosureReport & {
	id:        "factory.root.self-operation.closure"
	gate:      rootPromotionGate
	authority: false
	passed:    false
	candidate: baselineObservedPatch & #RootPromotionCandidate
}

rootNegativeFixtures: negativeFixtures

factory: {
	promotionGate:    rootPromotionGate
	closureReport:    rootClosureReport
	negativeFixtures: rootNegativeFixtures
	paths:            baselineObservedPatch.paths
	operations: {
		rootCandidate: baselineObservedPatch
	}
	evidence: baselineObservedPatch.evidence
}

promotionGate: rootPromotionGate
closureReport: rootClosureReport
