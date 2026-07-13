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

#ObservedArtifactIdentity: close({
	id:     #NonEmptyString
	digest: #Digest
})

#CapturedStream: close({
	path:   #AbsolutePath
	digest: #Digest
})

#RelevantEnvironmentIdentity: close({
	providerRoot:         #AbsolutePath
	consumerRoot:         #AbsolutePath
	evidenceRoot:         #AbsolutePath
	uvProjectEnvironment: #AbsolutePath
	platform:             #ExecutionPlatform
})

#RawCommandObservation: close({
	schema:       "factory.bdd-raw-command-observation.v1"
	executionID:  #NonEmptyString
	workflowNode: #NonEmptyString
	argv: [...#NonEmptyString] & [_, ...]
	exitCode:    int
	startedAt:   #NonEmptyString
	finishedAt:  #NonEmptyString
	environment: #RelevantEnvironmentIdentity
	stdout:      #CapturedStream
	stderr:      #CapturedStream
	consumedArtifacts: [...#ObservedArtifactIdentity]
	producedArtifacts: [...#ObservedArtifactIdentity]
	runnerProtocolVersion:   #NonEmptyString
	workbookDigest:          #Digest
	commandProjectionDigest: #Digest
})

#EvidenceIdentity: close({
	implementationUnitID: _implementationUnitID
	executionID:          #NonEmptyString
	evidenceRoot:         #AbsolutePath
	requirementsSource:   #SourceIdentity
	requirementIDs: [...#RequirementID] & [_, ...]
	acceptanceIDs: [...#AcceptanceID] & [_, ...]
	workspace:               #WorkspaceIdentity
	contractDigest:          #Digest
	workflowDigest:          #Digest
	projectDigest:           #Digest
	lockDigest:              #Digest
	workbookDigest:          #Digest
	commandProjectionDigest: #Digest
	fixtureDigest:           #Digest
	runnerProtocol:          #NonEmptyString
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

#ObservationName: #NonEmptyString & !~"^(success|valid|complete|admitted|admission|canonicalReady)$"

#EvidenceObservation: close({
	name: #ObservationName
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

// Evidence acceptance is reduced from concrete records by CUE. It is a
// definition for a later ingress, not a claim about the current working tree
// or final implementation-unit admission.
#EvidenceAdmission: {
	Input:    #EvidenceSet
	Expected: #EvidenceIdentity
	Scenarios: [#ScenarioID]: #Scenario

	_kinds: [for record in Input.records {record.kind}]
	_missingKinds: [for kind in requiredEvidenceKinds if !list.Contains(_kinds, kind) {kind}]
	_identityMismatches: [for record in Input.records if record.identity != Expected {record.kind}]
	_executions: [for record in Input.records for execution in record.executions {execution}]
	_scenarioFailures: [for scenarioID, scenario in Scenarios if len([for execution in _executions if execution.scenarioID == scenarioID && execution.outcome == scenario.fixture.expectation {execution.scenarioID}]) == 0 {scenarioID}]

	requiredKindsPresent:       len(_missingKinds) == 0
	identitiesMatch:            len(_identityMismatches) == 0
	scenariosMatch:             len(_scenarioFailures) == 0
	computedEvidenceAcceptance: requiredKindsPresent && identitiesMatch && scenariosMatch
}

#DerivedNodeState: "admitted" | "blocked" | "failed"

#DerivedRunSummary: close({
	schema:              "factory.bdd-run-summary.v1"
	executionID:         #NonEmptyString
	requestedNode:       #NonEmptyString
	derivedState:        #DerivedNodeState
	exitCode:            int
	evidenceRoot:        #AbsolutePath
	changedPathsAllowed: bool
	literalGate:         bool
	nextNode?:           #NonEmptyString
	progressProjection:  #AbsolutePath
})

evidenceIngressContract: close({
	schema:                  "factory.bdd-evidence.v1"
	root:                    "${XDG_RUNTIME_DIR:-/tmp}/factory-bdd/<execution-id>/"
	records:                 evidenceFiles
	rawObservationSchema:    "factory.bdd-raw-command-observation.v1"
	derivedRunSummarySchema: "factory.bdd-run-summary.v1"
	classification: close({
		generated: true
		transient: true
		authority: false
	})
	claimantFieldsRejected: ["success", "valid", "complete", "admitted", "admission", "canonicalReady"]
})
