package bdd

_workflowDeclarationCheck: workflowDeclarationCheck
_acceptancePolicies:       acceptancePolicies
_commandRefinement:        commandProjectionRefinement
_workbookCommandManifest:  workbookCommandManifest
_workbookScenarioManifest: workbookScenarioManifest
_validationTargets:        validationTargets

contractsOutput: close({
	schema:               "factory.bdd-contracts-output.v1"
	implementationUnitID: _implementationUnitID
	node:                 "contracts.create"
	state:                "declarations-only"
	exports: close({
		contract:                 bddContract
		bootstrap:                bootstrapDeclaration
		scenarios:                scenarioManifest
		acceptancePolicies:       _acceptancePolicies
		workflow:                 bootstrapWorkflow
		workflowDeclarationCheck: _workflowDeclarationCheck
		commandRefinement:        _commandRefinement
		evidenceIngress:          evidenceIngressContract
		runSummaryContract: close({
			schema:     "factory.bdd-run-summary.v1"
			derivation: "cue-derived-from-closed-raw-observation-ingress"
		})
		command:                  commandProjection
		workbookCommandManifest:  _workbookCommandManifest
		workbookScenarioManifest: _workbookScenarioManifest
		validationTargets:        _validationTargets
	})
	deferredClaims: [
		"fixture execution",
		"bounded provisional admission",
		"canonical self-conformance",
		"final implementation-unit admission",
		"provisional-admission retirement",
	]
})

output: contractsOutput
