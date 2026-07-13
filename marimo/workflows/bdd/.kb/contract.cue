package bdd

// Reusable BDD primitives. Factory owns v1 until an explicit compatibility
// implementation unit admits an upstream extraction.
#NonEmptyString: string & =~"[^[:space:]]"
#Digest:         string & =~"^sha256:[0-9a-f]{64}$"
#AbsolutePath:   string & =~"^/"

#RequirementID: string & =~"^(UV|BD)-[0-9]{2}$"
#AcceptanceID:  string & =~"^(UV|BD)-[0-9]{2}-A[0-9]+$"
#ScenarioID:    string & =~"^BDD-BOOT-(POS|NEG|INV|COMP|ADV)-[0-9]{3}$"
#ScenarioClass: "positive" | "negative" | "invariant" | "compatibility" | "adversarial"

#SourceIdentity: close({
	uri: #NonEmptyString
	transport: close({
		revision:   #NonEmptyString
		bodyDigest: #Digest
	})
	requirementSnapshot: close({
		schema: #NonEmptyString
		digest: #Digest
	})
})

#CriterionReference: close({
	requirementID: #RequirementID
	acceptanceID:  #AcceptanceID
})

#ScenarioOmission: close({
	class:     #ScenarioClass
	rationale: #NonEmptyString
})

#AcceptanceScenarioPolicy: close({
	acceptanceID: #AcceptanceID
	obligations: [#ScenarioClass]: true
	omissions: [...#ScenarioOmission]
})

#Scenario: close({
	id:          #ScenarioID
	class:       #ScenarioClass
	criterion:   #CriterionReference
	description: #NonEmptyString
	fixture: close({
		root:        "positive" | "negative"
		path:        #NonEmptyString
		expectation: "accept" | "reject" | "preserve"
	})
})

#FixtureExecution: close({
	scenarioID: #ScenarioID
	nodeID:     #NonEmptyString
	startedAt:  #NonEmptyString
	finishedAt: #NonEmptyString
	exitCode:   int
	outcome:    "accept" | "reject" | "preserve"
	observations: [...close({
		name:  #NonEmptyString
		value: string | int | bool
	})]
})

#ArtifactDeclaration: close({
	id:        #NonEmptyString
	path:      #NonEmptyString
	authority: "source" | "transient-evidence"
})

#ContractIdentity: close({
	uri:              #NonEmptyString
	version:          #NonEmptyString
	canonicalization: #NonEmptyString
	digestSubject: [...#NonEmptyString] & [_, ...]
	digest?: #Digest
})

#ValidationCommand: close({
	id:                 #NonEmptyString
	operatorEntrypoint: #NonEmptyString
	providerRoot:       "absolute-required"
	consumerRoot:       "absolute-required"
	evidenceRoot:       "absolute-required"
	projectMode:        "locked-exact"
	offlineMode:        "separate-explicit-scenario"
})

#BDDInstantiation: close({
	contract: #ContractIdentity
	scenarioIDs: [...#ScenarioID] & [_, ...]
	workflowID: #NonEmptyString
	coverage: [#AcceptanceID]: [...#ScenarioID] & [_, ...]
	evidenceRequirements: [...#NonEmptyString] & [_, ...]
})

#ImplementationUnit: close({
	id: #NonEmptyString
	satisfies: [#RequirementID]:         true
	dependencyClosure: [#RequirementID]: true
	requirementsSource: #SourceIdentity
	artifacts: [...#ArtifactDeclaration] & [_, ...]
	validation: [...#ValidationCommand] & [_, ...]
	bdd: #BDDInstantiation
})

#ComputedValidation: close({
	computed: bool
})

// Check projections are supplied by CUE definitions, never by an
// implementation-unit declaration or runner payload.
#ImplementationAdmission: {
	RequirementCheck:  #ComputedValidation
	WorkflowCheck:     #ComputedValidation
	ScenarioCheck:     #ComputedValidation
	EvidenceCheck:     #ComputedValidation
	computedAdmission: RequirementCheck.computed &&
		WorkflowCheck.computed &&
		ScenarioCheck.computed &&
		EvidenceCheck.computed
}

bddContract: #ContractIdentity & {
	uri:              "kg://repository/factory/contract/bdd/v1"
	version:          "factory.bdd.v1"
	canonicalization: "CUE value unified from the vetted bdd package and exported as canonical JSON."
	digestSubject: [
		"closed scenario and fixture schemas",
		"closed workflow and execution schemas",
		"closed evidence ingress schemas",
		"bootstrap and admission state schemas",
		"command and output projections",
	]
}
