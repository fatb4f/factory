package bdd

// Reusable BDD primitives. Factory owns v1 until an explicit compatibility
// implementation unit admits an upstream extraction.
#NonEmptyString:    string & =~"[^[:space:]]"
#Digest:            string & =~"^sha256:[0-9a-f]{64}$"
#AbsolutePath:      string & =~"^/"
#FixtureCoordinate: #AbsolutePath | string & =~"^\\$(provider_root|consumer_root|evidence_root)(/[^[:space:]]+)?$"

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

#ExecutorProtocol: "project-inspect.v1" |
	"process-run.v1" |
	"artifact-compare.v1" |
	"cue-projection-observe.v1"

#EvaluationProtocol: "subject-exit.v1" |
	"identity-match.v1" |
	"identity-preservation.v1" |
	"projection-conformance.v1" |
	"fact-predicate.v1"

#ExecutionBoundary:  "python-observe" | "operator-observe"
#EvaluationBoundary: "cue-evaluate"

#ScenarioExecutionDeclaration: close({
	scenarioID:         #ScenarioID
	executorProtocol:   #ExecutorProtocol
	evaluationProtocol: #EvaluationProtocol
	executionBoundary:  #ExecutionBoundary
	evaluationBoundary: #EvaluationBoundary
	fixturePath:        #NonEmptyString
})

#TypedFailure: close({
	code: "invalid-coordinates" |
		"manifest-digest-mismatch" |
		"unknown-workflow-node" |
		"missing-consumed-artifact" |
		"fixture-protocol-mismatch" |
		"output-already-exists" |
		"claimant-field-present" |
		"process-failed" |
			"internal-protocol-error"
	message:     #NonEmptyString
	scenarioID?: #ScenarioID
	artifactID?: #NonEmptyString
})

#ScenarioFact: close({
	name:  "subjectExitCode" | "projectionParseExitCode" | "missingPathCount" | "digestMismatchCount"
	value: int
}) | close({
	name:  "beforeDigest" | "afterDigest"
	value: #Digest
})

#SubjectProcessObservation: close({
	argv: [...#NonEmptyString] & [_, ...]
	startedAt:    #NonEmptyString
	finishedAt:   #NonEmptyString
	exitCode:     int
	stdoutDigest: #Digest
	stderrDigest: #Digest
})

#ScenarioObservation: close({
	scenarioID:       #ScenarioID
	executorProtocol: #ExecutorProtocol
	runnerExitCode:   int
	protocolExitCode: int
	failure?:         #TypedFailure
	subject:          #SubjectProcessObservation | null
	facts: [...#ScenarioFact]
})

#ObservedOutcome:   "accept" | "reject" | "preserve"
#EvaluationOutcome: #ObservedOutcome | "incomplete"

#ScenarioEvaluationResult: close({
	scenarioID:         #ScenarioID
	evaluationProtocol: #EvaluationProtocol
	runnerCompleted:    bool
	evidenceComplete:   bool
	observedOutcome:    #EvaluationOutcome
	satisfied:          bool
})

#SubjectExitEvaluation: {
	Observation: #ScenarioObservation & {
		subject:  #SubjectProcessObservation
		failure?: _|_
	}
	Scenario: #Scenario
	Declaration: #ScenarioExecutionDeclaration & {
		evaluationProtocol: "subject-exit.v1"
	}

	_observation: Observation
	_scenario:    Scenario
	_declaration: Declaration
	_exitCodes: [for fact in _observation.facts if fact.name == "subjectExitCode" {fact.value}]
	_complete: len(_exitCodes) == 1 &&
		_exitCodes == [_observation.subject.exitCode] &&
		_observation.scenarioID == _scenario.id &&
		_observation.scenarioID == _declaration.scenarioID &&
		_observation.executorProtocol == _declaration.executorProtocol
	_accepts: _observation.subject.exitCode == 0
	_outcome: #EvaluationOutcome
	if !_complete {
		_outcome: "incomplete"
	}
	if _complete && _accepts {
		_outcome: "accept"
	}
	if _complete && !_accepts {
		_outcome: "reject"
	}

	Result: #ScenarioEvaluationResult & {
		scenarioID:         _observation.scenarioID
		evaluationProtocol: _declaration.evaluationProtocol
		runnerCompleted:    _observation.runnerExitCode == 0
		evidenceComplete:   _complete
		observedOutcome:    _outcome
		satisfied:          runnerCompleted && evidenceComplete && _outcome == _scenario.fixture.expectation
	}
}

#IdentityMatchEvaluation: {
	Observation: #ScenarioObservation & {failure?: _|_}
	Scenario: #Scenario
	Declaration: #ScenarioExecutionDeclaration & {
		evaluationProtocol: "identity-match.v1"
	}

	_observation: Observation
	_scenario:    Scenario
	_declaration: Declaration
	_before: [for fact in _observation.facts if fact.name == "beforeDigest" {fact.value}]
	_after: [for fact in _observation.facts if fact.name == "afterDigest" {fact.value}]
	_complete: len(_before) == 1 && len(_after) == 1 &&
		_observation.scenarioID == _scenario.id &&
		_observation.scenarioID == _declaration.scenarioID &&
			_observation.executorProtocol == _declaration.executorProtocol
	_matches: _before == _after
	_outcome: #EvaluationOutcome
	if !_complete {
		_outcome: "incomplete"
	}
	if _complete && _matches {
		_outcome: "accept"
	}
	if _complete && !_matches {
		_outcome: "reject"
	}

	Result: #ScenarioEvaluationResult & {
		scenarioID:         _observation.scenarioID
		evaluationProtocol: _declaration.evaluationProtocol
		runnerCompleted:    _observation.runnerExitCode == 0
		evidenceComplete:   _complete
		observedOutcome:    _outcome
		satisfied:          runnerCompleted && evidenceComplete && _outcome == _scenario.fixture.expectation
	}
}

#IdentityPreservationEvaluation: {
	Observation: #ScenarioObservation & {failure?: _|_}
	Scenario: #Scenario
	Declaration: #ScenarioExecutionDeclaration & {
		evaluationProtocol: "identity-preservation.v1"
	}

	_observation: Observation
	_scenario:    Scenario
	_declaration: Declaration
	_before: [for fact in _observation.facts if fact.name == "beforeDigest" {fact.value}]
	_after: [for fact in _observation.facts if fact.name == "afterDigest" {fact.value}]
	_complete: len(_before) == 1 && len(_after) == 1 &&
		_observation.scenarioID == _scenario.id &&
		_observation.scenarioID == _declaration.scenarioID &&
			_observation.executorProtocol == _declaration.executorProtocol
	_preserved: _before == _after
	_outcome:   #EvaluationOutcome
	if !_complete {
		_outcome: "incomplete"
	}
	if _complete && _preserved {
		_outcome: "preserve"
	}
	if _complete && !_preserved {
		_outcome: "reject"
	}

	Result: #ScenarioEvaluationResult & {
		scenarioID:         _observation.scenarioID
		evaluationProtocol: _declaration.evaluationProtocol
		runnerCompleted:    _observation.runnerExitCode == 0
		evidenceComplete:   _complete
		observedOutcome:    _outcome
		satisfied:          runnerCompleted && evidenceComplete && _outcome == _scenario.fixture.expectation
	}
}

#ProjectionConformanceEvaluation: {
	Observation: #ScenarioObservation & {failure?: _|_}
	Scenario: #Scenario
	Declaration: #ScenarioExecutionDeclaration & {
		evaluationProtocol: "projection-conformance.v1"
	}

	_observation: Observation
	_scenario:    Scenario
	_declaration: Declaration
	_exitCodes: [for fact in _observation.facts if fact.name == "projectionParseExitCode" {fact.value}]
	_complete: len(_exitCodes) == 1 &&
		_observation.scenarioID == _scenario.id &&
		_observation.scenarioID == _declaration.scenarioID &&
		_observation.executorProtocol == _declaration.executorProtocol
	_conforms: _exitCodes == [0]
	_outcome: #EvaluationOutcome
	if !_complete {
		_outcome: "incomplete"
	}
	if _complete && _conforms {
		_outcome: "accept"
	}
	if _complete && !_conforms {
		_outcome: "reject"
	}

	Result: #ScenarioEvaluationResult & {
		scenarioID:         _observation.scenarioID
		evaluationProtocol: _declaration.evaluationProtocol
		runnerCompleted:    _observation.runnerExitCode == 0
		evidenceComplete:   _complete
		observedOutcome:    _outcome
		satisfied:          runnerCompleted && evidenceComplete && _outcome == _scenario.fixture.expectation
	}
}

#FactPredicateEvaluation: {
	Observation: #ScenarioObservation & {failure?: _|_}
	Scenario: #Scenario
	Declaration: #ScenarioExecutionDeclaration & {
		evaluationProtocol: "fact-predicate.v1"
	}

	_observation: Observation
	_scenario:    Scenario
	_declaration: Declaration
	_missing: [for fact in _observation.facts if fact.name == "missingPathCount" {fact.value}]
	_mismatches: [for fact in _observation.facts if fact.name == "digestMismatchCount" {fact.value}]
	_complete: len(_missing) == 1 && len(_mismatches) == 1 &&
		_observation.scenarioID == _scenario.id &&
		_observation.scenarioID == _declaration.scenarioID &&
		_observation.executorProtocol == _declaration.executorProtocol
	_conforms: _missing == [0] && _mismatches == [0]
	_outcome: #EvaluationOutcome
	if !_complete {
		_outcome: "incomplete"
	}
	if _complete && _conforms {
		_outcome: "accept"
	}
	if _complete && !_conforms {
		_outcome: "reject"
	}

	Result: #ScenarioEvaluationResult & {
		scenarioID:         _observation.scenarioID
		evaluationProtocol: _declaration.evaluationProtocol
		runnerCompleted:    _observation.runnerExitCode == 0
		evidenceComplete:   _complete
		observedOutcome:    _outcome
		satisfied:          runnerCompleted && evidenceComplete && _outcome == _scenario.fixture.expectation
	}
}

// The dispatcher selects one evaluator. It does not duplicate evaluator proof.
#ScenarioEvaluation: {
	Observation: #ScenarioObservation
	Scenario:    #Scenario
	Declaration: #ScenarioExecutionDeclaration

	_observation: Observation
	_scenario:    Scenario
	_declaration: Declaration

	Result: #ScenarioEvaluationResult
	if _declaration.evaluationProtocol == "subject-exit.v1" {
		Result: (#SubjectExitEvaluation & {Observation: _observation, Scenario: _scenario, Declaration: _declaration}).Result
	}
	if _declaration.evaluationProtocol == "identity-match.v1" {
		Result: (#IdentityMatchEvaluation & {Observation: _observation, Scenario: _scenario, Declaration: _declaration}).Result
	}
	if _declaration.evaluationProtocol == "identity-preservation.v1" {
		Result: (#IdentityPreservationEvaluation & {Observation: _observation, Scenario: _scenario, Declaration: _declaration}).Result
	}
	if _declaration.evaluationProtocol == "projection-conformance.v1" {
		Result: (#ProjectionConformanceEvaluation & {Observation: _observation, Scenario: _scenario, Declaration: _declaration}).Result
	}
	if _declaration.evaluationProtocol == "fact-predicate.v1" {
		Result: (#FactPredicateEvaluation & {Observation: _observation, Scenario: _scenario, Declaration: _declaration}).Result
	}
}

#ScenarioFixtureInput: close({
	schema:           "factory.bdd-scenario-fixture.v1"
	scenarioID:       #ScenarioID
	executorProtocol: #ExecutorProtocol
	paths?: [...close({
		path:            #NonEmptyString
		expectedDigest?: #Digest
	})]
	process?: close({
		argv: [...#NonEmptyString] & [_, ...]
		cwd: #FixtureCoordinate
		environment: [#NonEmptyString]: string
	})
	projectionPath?: #FixtureCoordinate
	sourcePath?:     #FixtureCoordinate
	candidatePath?:  #FixtureCoordinate
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
