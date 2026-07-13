package bdd

import "list"

#WorkspaceIdentity: close({
	repositoryRevision: #NonEmptyString
	workingTree: close({
		mode:   "clean" | "deterministic-dirty"
		digest: #Digest
	})
	providerRoot: #AbsolutePath
	consumerRoot: #AbsolutePath
})

#ExecutionPlatform: close({
	os:                        #NonEmptyString
	architecture:              #NonEmptyString
	interpreterImplementation: #NonEmptyString
	interpreterVersion:        #NonEmptyString
	uvVersion:                 #NonEmptyString
})

#EvidenceIdentity: close({
	implementationUnitID: _implementationUnitID
	executionID:          #NonEmptyString
	evidenceRoot:         #AbsolutePath
	requirementsSource:   #SourceIdentity
	requirementIDs: [...#RequirementID] & [_, ...]
	acceptanceIDs: [...#AcceptanceID] & [_, ...]
	workspace:      #WorkspaceIdentity
	contractDigest: #Digest
	workflowDigest: #Digest
	projectDigest:  #Digest
	lockDigest:     #Digest
	workbookDigest: #Digest
	fixtureDigest:  #Digest
	runnerProtocol: #NonEmptyString
	scenarioIDs: [...#ScenarioID] & [_, ...]
	platform: #ExecutionPlatform
})

#EvidenceKind: "requirements-source" |
	"bootstrap-contract-validation" |
	"locked-environment-identity" |
	"positive-fixture-results" |
	"negative-fixture-results" |
	"workflow-refinement-result" |
	"scenario-coverage-result" |
	"self-conformance-result" |
	"provisional-retirement-result"

#EvidenceObservation: close({
	name: #NonEmptyString
	value: string | int | bool | [...string]
	source: #NonEmptyString
})

// This ingress deliberately has no claimant-supplied valid or admitted field.
#EvidenceRecord: close({
	schema:    "factory.bdd-evidence.v1"
	generated: true
	transient: true
	kind:      #EvidenceKind
	identity:  #EvidenceIdentity
	executions: [...#FixtureExecution]
	observations: [...#EvidenceObservation] & [_, ...]
})

#EvidenceSet: close({
	records: [...#EvidenceRecord] & [_, ...]
})

evidenceFiles: {
	"requirements-source":           "requirements-source.json"
	"bootstrap-contract-validation": "bootstrap-contract-validation.json"
	"locked-environment-identity":   "locked-environment-identity.json"
	"positive-fixture-results":      "positive-fixture-results.json"
	"negative-fixture-results":      "negative-fixture-results.json"
	"workflow-refinement-result":    "workflow-refinement-result.json"
	"scenario-coverage-result":      "scenario-coverage-result.json"
	"self-conformance-result":       "self-conformance-result.json"
	"provisional-retirement-result": "provisional-retirement-result.json"
}

requiredEvidenceKinds: [for kind, _ in evidenceFiles {kind}]

// Admission is reduced from concrete records by CUE. It is a definition for a
// later evidence ingress, not a claim about the current working tree.
#EvidenceAdmission: {
	Input:    #EvidenceSet
	Expected: #EvidenceIdentity
	Scenarios: [#ScenarioID]: #Scenario

	_kinds: [for record in Input.records {record.kind}]
	_missingKinds: [for kind in requiredEvidenceKinds if !list.Contains(_kinds, kind) {kind}]
	_identityMismatches: [for record in Input.records if record.identity != Expected {record.kind}]
	_executions: [for record in Input.records for execution in record.executions {execution}]
	_scenarioFailures: [for scenarioID, scenario in Scenarios if len([for execution in _executions if execution.scenarioID == scenarioID && execution.outcome == scenario.fixture.expectation {execution.scenarioID}]) == 0 {scenarioID}]
	_selfConformanceFailures: [for record in Input.records if record.kind == "self-conformance-result" && len([for observation in record.observations if observation.name == "admissionExport" && observation.value == "true" {observation.name}]) == 0 {record.kind}]
	_retirementFailures: [for record in Input.records if record.kind == "provisional-retirement-result" && (len([for observation in record.observations if observation.name == "retiredUnit" && observation.value == _implementationUnitID {observation.name}]) == 0 || len([for observation in record.observations if observation.name == "repeatEligible" && observation.value == false {observation.name}]) == 0 || len([for observation in record.observations if observation.name == "laterUnitEligible" && observation.value == false {observation.name}]) == 0) {record.kind}]

	requiredKindsPresent:         len(_missingKinds) == 0
	identitiesMatch:              len(_identityMismatches) == 0
	scenariosMatch:               len(_scenarioFailures) == 0
	selfConformanceIsLiteralTrue: len(_selfConformanceFailures) == 0
	provisionalAdmissionRetired:  len(_retirementFailures) == 0
	computedAdmission:            requiredKindsPresent && identitiesMatch && scenariosMatch &&
		selfConformanceIsLiteralTrue && provisionalAdmissionRetired
}

evidenceIngressContract: close({
	schema:  "factory.bdd-evidence.v1"
	root:    "${XDG_RUNTIME_DIR:-/tmp}/factory-bdd/<execution-id>/"
	records: evidenceFiles
	classification: close({
		generated: true
		transient: true
		authority: false
	})
	claimantFieldsRejected: ["valid", "admitted", "admission"]
})
