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

#OperatorInvocationObservation: close({
	schema:       "factory.bdd-operator-invocation-observation.v1"
	executionID:  #NonEmptyString
	workflowNode: #NonEmptyString
	argv: [...#NonEmptyString] & [_, ...]
	uvVersion:                 #NonEmptyString
	environmentRoot:           #AbsolutePath
	exitCode:                  int
	startedAt:                 #NonEmptyString
	finishedAt:                #NonEmptyString
	stdout:                    #CapturedStream
	stderr:                    #CapturedStream
	workbookDigest:            #Digest
	commandManifestDigest:     #Digest
	scenarioManifestDigest:    #Digest
	workbookObservationDigest: #Digest
})

#PythonRuntimeIdentity: close({
	executable:     #AbsolutePath
	implementation: #NonEmptyString
	version:        #NonEmptyString
})

#WorkbookNodeObservation: close({
	schema:       "factory.bdd-workbook-node-observation.v1"
	executionID:  #NonEmptyString
	workflowNode: #NonEmptyString
	processArgv: [...#NonEmptyString] & [_, ...]
	runnerExitCode: int
	startedAt:      #NonEmptyString
	finishedAt:     #NonEmptyString
	python:         #PythonRuntimeIdentity
	environment: close({
		providerRoot:         #AbsolutePath
		consumerRoot:         #AbsolutePath
		evidenceRoot:         #AbsolutePath
		uvProjectEnvironment: #AbsolutePath
	})
	stdout: #CapturedStream
	stderr: #CapturedStream
	consumedArtifacts: [...#ObservedArtifactIdentity]
	producedArtifacts: [...#ObservedArtifactIdentity]
	scenarioObservations: [...#ScenarioObservation]
	failure?:               #TypedFailure
	runnerProtocolVersion:  #NonEmptyString
	workbookDigest:         #Digest
	commandManifestDigest:  #Digest
	scenarioManifestDigest: #Digest
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
	schema:       "factory.bdd-evidence.v1"
	generated:    true
	transient:    true
	kind:         #EvidenceKind
	workflowNode: #NonEmptyString
	identity:     #EvidenceIdentity
	scenarioObservations: [...#ScenarioObservation]
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

#EvidenceKindCardinalityCheck: {
	Kinds: [...#EvidenceKind]
	_kinds: Kinds
	_failures: [for kind in requiredEvidenceKinds if len([
		for observedKind in _kinds if observedKind == kind {observedKind}
	]) != 1 {kind}]
	exact: len(_failures) == 0
}

_evidenceNodeByKind: {
	"requirements-source":           "requirements.verify"
	"bootstrap-contract-validation": "contracts.vet"
	"locked-environment-identity":   "project-lock.verify"
	"positive-fixture-results":      "fixtures.execute"
	"negative-fixture-results":      "fixtures.execute"
	"workflow-refinement-result":    "workflow.verify"
	"scenario-coverage-result":      "workflow.verify"
	"self-conformance-result":       "self-conformance.execute"
	"provisional-retirement-result": "provisional.retire"
}

_fixtureEvidenceKindByRoot: {
	positive: "positive-fixture-results"
	negative: "negative-fixture-results"
}

// Evidence acceptance is reduced from concrete records by CUE. It is a
// definition for a later ingress, not a claim about the current working tree
// or final implementation-unit admission.
#EvidenceAdmission: {
	Input:    #EvidenceSet
	Expected: #EvidenceIdentity
	Scenarios: [#ScenarioID]:    #Scenario
	Declarations: [#ScenarioID]: #ScenarioExecutionDeclaration

	_input:        Input
	_expected:     Expected
	_scenarios:    Scenarios
	_declarations: Declarations
	_scenarioIDs: [for scenarioID, _ in _scenarios {scenarioID}]
	_declarationIDs: [for scenarioID, _ in _declarations {scenarioID}]
	_kindCheck: #EvidenceKindCardinalityCheck & {
		Kinds: [for record in _input.records {record.kind}]
	}

	_identityFailures: [for record in _input.records if record.identity != _expected {record.kind}]
	_phaseFailures: [for record in _input.records if record.workflowNode != _evidenceNodeByKind[record.kind] {
		kind: record.kind, workflowNode: record.workflowNode
	}]
	_referenceFailures: [for record in _input.records for observation in record.scenarioObservations
		if !list.Contains(_scenarioIDs, observation.scenarioID) || !list.Contains(_declarationIDs, observation.scenarioID) {
			kind: record.kind, scenarioID: observation.scenarioID
		}]

	_fixtureRecords: [for record in _input.records if record.kind == "positive-fixture-results" || record.kind == "negative-fixture-results" {record}]
	_fixtureCardinalityFailures: [for scenarioID, scenario in _scenarios {
		let expectedKind = _fixtureEvidenceKindByRoot[scenario.fixture.root]
		if len([for record in _fixtureRecords if record.kind == expectedKind
			for observation in record.scenarioObservations if observation.scenarioID == scenarioID {observation.scenarioID}]) != 1 {
			scenarioID
		}
	}]
	_fixturePhaseFailures: [for record in _fixtureRecords for observation in record.scenarioObservations
		if list.Contains(_scenarioIDs, observation.scenarioID) {
			let expectedKind = _fixtureEvidenceKindByRoot[_scenarios[observation.scenarioID].fixture.root]
			if record.kind != expectedKind {scenarioID: observation.scenarioID, kind: record.kind}
		}]

	_selfConformanceRecords: [for record in _input.records if record.kind == "self-conformance-result" {record}]
	_selfConformanceCardinalityFailures: [for scenarioID, _ in _scenarios if len([
		for record in _selfConformanceRecords for observation in record.scenarioObservations
		if observation.scenarioID == scenarioID {observation.scenarioID}
	]) != 1 {scenarioID}]
	_unexpectedObservationPhases: [for record in _input.records
		if record.kind != "positive-fixture-results" && record.kind != "negative-fixture-results" && record.kind != "self-conformance-result" && len(record.scenarioObservations) != 0 {record.kind}]

	_evaluableObservations: [for record in _input.records
		if record.kind == "positive-fixture-results" || record.kind == "negative-fixture-results" || record.kind == "self-conformance-result"
		for observation in record.scenarioObservations
		if list.Contains(_scenarioIDs, observation.scenarioID) && list.Contains(_declarationIDs, observation.scenarioID) {observation}]
	_evaluations: [for observation in _evaluableObservations {
		(#ScenarioEvaluation & {
			Observation: observation
			Scenario:    _scenarios[observation.scenarioID]
			Declaration: _declarations[observation.scenarioID]
		}).Result
	}]
	_evaluationFailures: [for evaluation in _evaluations if !evaluation.satisfied {evaluation.scenarioID}]

	requiredKindsPresentExactlyOnce: _kindCheck.exact
	identitiesMatch:                 len(_identityFailures) == 0
	phasesMatch:                     len(_phaseFailures) == 0
	referencesResolve:               len(_referenceFailures) == 0
	fixtureScenariosMatch:           len(_fixtureCardinalityFailures) == 0 && len(_fixturePhaseFailures) == 0
	selfConformanceScenariosMatch:   len(_selfConformanceCardinalityFailures) == 0
	observationPhasesMatch:          len(_unexpectedObservationPhases) == 0
	evaluationsSatisfyScenarios:     len(_evaluationFailures) == 0
	computedEvidenceAcceptance:      requiredKindsPresentExactlyOnce && identitiesMatch && phasesMatch && referencesResolve &&
		fixtureScenariosMatch && selfConformanceScenariosMatch && observationPhasesMatch && evaluationsSatisfyScenarios
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
	schema:                    "factory.bdd-evidence.v1"
	root:                      "${XDG_RUNTIME_DIR:-/tmp}/factory-bdd/<execution-id>/"
	records:                   evidenceFiles
	operatorObservationSchema: "factory.bdd-operator-invocation-observation.v1"
	workbookObservationSchema: "factory.bdd-workbook-node-observation.v1"
	derivedRunSummarySchema:   "factory.bdd-run-summary.v1"
	classification: close({
		generated: true
		transient: true
		authority: false
	})
	claimantFieldsRejected: ["success", "valid", "complete", "admitted", "admission", "canonicalReady"]
})
