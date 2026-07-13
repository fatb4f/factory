package bdd

_workflowDeclarationCheck: workflowDeclarationCheck
_acceptancePolicies:       acceptancePolicies

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
		evidenceIngress:          evidenceIngressContract
		command:                  commandProjection
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
