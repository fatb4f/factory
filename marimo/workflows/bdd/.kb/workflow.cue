package bdd

import "list"

#WorkflowNode: close({
	id:       #NonEmptyString
	index:    int & >=0
	boundary: "cue" | "marimo-python" | "operator"
	dependsOn: [...#NonEmptyString]
	scenarioIDs: [...#ScenarioID]
	consumes: [...#NonEmptyString]
	produces: [...#NonEmptyString]
	terminal: bool
})

#ValidationWorkflow: close({
	id:      #NonEmptyString
	version: #NonEmptyString
	nodes: [#NonEmptyString]: #WorkflowNode
	terminalNode: #NonEmptyString
})

_scenarioManifestRaw: {
	"BDD-BOOT-POS-001": {class: "positive", criterion: {requirementID: "UV-01", acceptanceID: "UV-01-A1"}, description: "nonempty canonical project with declared Python and direct dependencies", fixture: {root: "positive", path: "project-valid", expectation: "accept"}}
	"BDD-BOOT-NEG-001": {class: "negative", criterion: {requirementID: "UV-01", acceptanceID: "UV-01-A1"}, description: "empty or invalid project placeholder is rejected", fixture: {root: "negative", path: "project-invalid", expectation: "reject"}}
	"BDD-BOOT-POS-002": {class: "positive", criterion: {requirementID: "UV-02", acceptanceID: "UV-02-A1"}, description: "generated lock passes check and digest verification", fixture: {root: "positive", path: "lock-valid", expectation: "accept"}}
	"BDD-BOOT-NEG-002": {class: "negative", criterion: {requirementID: "UV-02", acceptanceID: "UV-02-A1"}, description: "missing stale or modified lock is rejected", fixture: {root: "negative", path: "lock-invalid", expectation: "reject"}}
	"BDD-BOOT-POS-003": {class: "positive", criterion: {requirementID: "UV-03", acceptanceID: "UV-03-A1"}, description: "dedicated BDD workbook is project managed without inline metadata", fixture: {root: "positive", path: "workbook-project-managed", expectation: "accept"}}
	"BDD-BOOT-NEG-003": {class: "negative", criterion: {requirementID: "UV-03", acceptanceID: "UV-03-A1"}, description: "PEP 723 metadata in the BDD workbook is rejected", fixture: {root: "negative", path: "workbook-inline-metadata", expectation: "reject"}}
	"BDD-BOOT-COMP-001": {class: "compatibility", criterion: {requirementID: "UV-03", acceptanceID: "UV-03-A1"}, description: "legacy resolver metadata and UserPromptSubmit path remain intact", fixture: {root: "positive", path: "legacy-resolver-preserved", expectation: "preserve"}}
	"BDD-BOOT-POS-004": {class: "positive", criterion: {requirementID: "UV-04", acceptanceID: "UV-04-A1"}, description: "locked exact execution succeeds with absolute roots", fixture: {root: "positive", path: "locked-exact", expectation: "accept"}}
	"BDD-BOOT-ADV-001": {class: "adversarial", criterion: {requirementID: "UV-04", acceptanceID: "UV-04-A1"}, description: "exact sync removes an extraneous package only in a disposable environment", fixture: {root: "negative", path: "exact-sync-extraneous", expectation: "reject"}}
	"BDD-BOOT-NEG-004": {class: "negative", criterion: {requirementID: "UV-04", acceptanceID: "UV-04-A1"}, description: "unsupported constraints or ambiguous roots are rejected", fixture: {root: "negative", path: "execution-coordinates-invalid", expectation: "reject"}}
	"BDD-BOOT-INV-003": {class: "invariant", criterion: {requirementID: "UV-04", acceptanceID: "UV-04-A1"}, description: "locked exact execution does not imply offline behavior", fixture: {root: "positive", path: "offline-separate", expectation: "preserve"}}
	"BDD-BOOT-POS-005": {class: "positive", criterion: {requirementID: "BD-01", acceptanceID: "BD-01-A1"}, description: "closed versioned schemas and digest subjects export", fixture: {root: "positive", path: "contract-closed", expectation: "accept"}}
	"BDD-BOOT-NEG-005": {class: "negative", criterion: {requirementID: "BD-01", acceptanceID: "BD-01-A1"}, description: "open incomplete or incompatible contract is rejected", fixture: {root: "negative", path: "contract-invalid", expectation: "reject"}}
	"BDD-BOOT-INV-001": {class: "invariant", criterion: {requirementID: "BD-02", acceptanceID: "BD-02-A1"}, description: "selected acceptance IDs are covered inside the dependency closure", fixture: {root: "positive", path: "coverage-closure", expectation: "preserve"}}
	"BDD-BOOT-NEG-006": {class: "negative", criterion: {requirementID: "BD-03", acceptanceID: "BD-03-A1"}, description: "cyclic unresolved or production-after-consumption workflow is rejected", fixture: {root: "negative", path: "workflow-invalid", expectation: "reject"}}
	"BDD-BOOT-INV-002": {class: "invariant", criterion: {requirementID: "BD-04", acceptanceID: "BD-04-A1"}, description: "scenario obligations and omission rationales exist for every criterion", fixture: {root: "positive", path: "scenario-obligations", expectation: "preserve"}}
	"BDD-BOOT-ADV-002": {class: "adversarial", criterion: {requirementID: "BD-05", acceptanceID: "BD-05-A1"}, description: "evidence with a mismatched identity is rejected", fixture: {root: "negative", path: "evidence-identity-mismatch", expectation: "reject"}}
	"BDD-BOOT-ADV-003": {class: "adversarial", criterion: {requirementID: "BD-06", acceptanceID: "BD-06-A1"}, description: "claimant supplied validity and admission booleans are rejected", fixture: {root: "negative", path: "claimant-booleans", expectation: "reject"}}
	"BDD-BOOT-POS-006": {class: "positive", criterion: {requirementID: "BD-07", acceptanceID: "BD-07-A1"}, description: "operator command reaches and verifies literal true", fixture: {root: "positive", path: "operator-command", expectation: "accept"}}
	"BDD-BOOT-NEG-007": {class: "negative", criterion: {requirementID: "BD-07", acceptanceID: "BD-07-A1"}, description: "intermediate failure or non-true admission fails the command", fixture: {root: "negative", path: "operator-command-invalid", expectation: "reject"}}
	"BDD-BOOT-POS-007": {class: "positive", criterion: {requirementID: "BD-08", acceptanceID: "BD-08-A1"}, description: "canonical suite proves self-conformance and retires provisional admission", fixture: {root: "positive", path: "self-conformance", expectation: "accept"}}
	"BDD-BOOT-NEG-008": {class: "negative", criterion: {requirementID: "BD-08", acceptanceID: "BD-08-A1"}, description: "later or repeated provisional admission is rejected", fixture: {root: "negative", path: "provisional-reuse", expectation: "reject"}}
}

scenarioManifest: {
	for id, scenario in _scenarioManifestRaw {
		let scenarioID = id
		(id): #Scenario & {id: scenarioID} & scenario
	}
}

_executorProtocolByScenario: {
	"BDD-BOOT-POS-001":  "project-inspect.v1"
	"BDD-BOOT-NEG-001":  "project-inspect.v1"
	"BDD-BOOT-POS-002":  "project-inspect.v1"
	"BDD-BOOT-NEG-002":  "project-inspect.v1"
	"BDD-BOOT-POS-003":  "project-inspect.v1"
	"BDD-BOOT-NEG-003":  "project-inspect.v1"
	"BDD-BOOT-COMP-001": "artifact-compare.v1"
	"BDD-BOOT-POS-004":  "process-run.v1"
	"BDD-BOOT-ADV-001":  "artifact-compare.v1"
	"BDD-BOOT-NEG-004":  "process-run.v1"
	"BDD-BOOT-INV-003":  "artifact-compare.v1"
	"BDD-BOOT-POS-005":  "cue-projection-observe.v1"
	"BDD-BOOT-NEG-005":  "cue-projection-observe.v1"
	"BDD-BOOT-INV-001":  "artifact-compare.v1"
	"BDD-BOOT-NEG-006":  "cue-projection-observe.v1"
	"BDD-BOOT-INV-002":  "artifact-compare.v1"
	"BDD-BOOT-ADV-002":  "artifact-compare.v1"
	"BDD-BOOT-ADV-003":  "artifact-compare.v1"
	"BDD-BOOT-POS-006":  "process-run.v1"
	"BDD-BOOT-NEG-007":  "process-run.v1"
	"BDD-BOOT-POS-007":  "process-run.v1"
	"BDD-BOOT-NEG-008":  "artifact-compare.v1"
}

_evaluationProtocolByScenario: {
	"BDD-BOOT-POS-001":  "fact-predicate.v1"
	"BDD-BOOT-NEG-001":  "fact-predicate.v1"
	"BDD-BOOT-POS-002":  "fact-predicate.v1"
	"BDD-BOOT-NEG-002":  "fact-predicate.v1"
	"BDD-BOOT-POS-003":  "fact-predicate.v1"
	"BDD-BOOT-NEG-003":  "fact-predicate.v1"
	"BDD-BOOT-COMP-001": "identity-preservation.v1"
	"BDD-BOOT-POS-004":  "subject-exit.v1"
	"BDD-BOOT-ADV-001":  "identity-match.v1"
	"BDD-BOOT-NEG-004":  "subject-exit.v1"
	"BDD-BOOT-INV-003":  "identity-preservation.v1"
	"BDD-BOOT-POS-005":  "projection-conformance.v1"
	"BDD-BOOT-NEG-005":  "projection-conformance.v1"
	"BDD-BOOT-INV-001":  "identity-preservation.v1"
	"BDD-BOOT-NEG-006":  "projection-conformance.v1"
	"BDD-BOOT-INV-002":  "identity-preservation.v1"
	"BDD-BOOT-ADV-002":  "identity-match.v1"
	"BDD-BOOT-ADV-003":  "identity-match.v1"
	"BDD-BOOT-POS-006":  "subject-exit.v1"
	"BDD-BOOT-NEG-007":  "subject-exit.v1"
	"BDD-BOOT-POS-007":  "subject-exit.v1"
	"BDD-BOOT-NEG-008":  "identity-match.v1"
}

scenarioExecutionManifest: {
	for scenarioID, scenario in scenarioManifest {
		let id = scenarioID
		(id): #ScenarioExecutionDeclaration & {
			scenarioID:         id
			executorProtocol:   _executorProtocolByScenario[id]
			evaluationProtocol: _evaluationProtocolByScenario[id]
			executionBoundary:  "python-observe"
			evaluationBoundary: "cue-evaluate"
			fixturePath:        "\(scenario.fixture.root)/\(scenario.fixture.path)/fixture.json"
		}
	}
}

workbookScenarioManifest: close({
	schema:    "factory.bdd-workbook-scenario-manifest.v1"
	scenarios: scenarioExecutionManifest
})

acceptanceCoverage: {
	"UV-01-A1": ["BDD-BOOT-POS-001", "BDD-BOOT-NEG-001"]
	"UV-02-A1": ["BDD-BOOT-POS-002", "BDD-BOOT-NEG-002"]
	"UV-03-A1": ["BDD-BOOT-POS-003", "BDD-BOOT-NEG-003", "BDD-BOOT-COMP-001"]
	"UV-04-A1": ["BDD-BOOT-POS-004", "BDD-BOOT-ADV-001", "BDD-BOOT-NEG-004", "BDD-BOOT-INV-003"]
	"BD-01-A1": ["BDD-BOOT-POS-005", "BDD-BOOT-NEG-005"]
	"BD-02-A1": ["BDD-BOOT-INV-001"]
	"BD-03-A1": ["BDD-BOOT-NEG-006"]
	"BD-04-A1": ["BDD-BOOT-INV-002"]
	"BD-05-A1": ["BDD-BOOT-ADV-002"]
	"BD-06-A1": ["BDD-BOOT-ADV-003"]
	"BD-07-A1": ["BDD-BOOT-POS-006", "BDD-BOOT-NEG-007"]
	"BD-08-A1": ["BDD-BOOT-POS-007", "BDD-BOOT-NEG-008"]
}

_scenarioClasses: ["positive", "negative", "invariant", "compatibility", "adversarial"]
_obligationLabels: {
	"UV-01-A1": "negative, positive"
	"UV-02-A1": "negative, positive"
	"UV-03-A1": "compatibility, negative, positive"
	"UV-04-A1": "adversarial, invariant, negative, positive"
	"BD-01-A1": "negative, positive"
	"BD-02-A1": "invariant"
	"BD-03-A1": "negative"
	"BD-04-A1": "invariant"
	"BD-05-A1": "adversarial"
	"BD-06-A1": "adversarial"
	"BD-07-A1": "negative, positive"
	"BD-08-A1": "negative, positive"
}

acceptancePolicies: {
	for acceptanceID, scenarioIDs in acceptanceCoverage {
		let criterionID = acceptanceID
		let obligated = [for scenarioID in scenarioIDs {scenarioManifest[scenarioID].class}]
		(acceptanceID): #AcceptanceScenarioPolicy & {
			acceptanceID: criterionID
			obligations: {
				for scenarioClass in obligated {
					(scenarioClass): true
				}
			}
			omissions: [for scenarioClass in _scenarioClasses if !list.Contains(obligated, scenarioClass) {
				class:     scenarioClass
				rationale: "\(scenarioClass) coverage is not applicable to \(criterionID); the declared \(_obligationLabels[criterionID]) obligations cover its acceptance semantics."
			}]
		}
	}
}

_allScenarioIDs: [for id, _ in scenarioManifest {id}]

bootstrapWorkflow: #ValidationWorkflow & {
	id:           "kg://repository/factory/workflow/bdd-bootstrap/v1"
	version:      "factory.bdd-bootstrap-workflow.v1"
	terminalNode: "unit.admit"
	nodes: {
		"requirements.verify": {id: "requirements.verify", index: 0, boundary: "cue", dependsOn: [], scenarioIDs: [], consumes: [], produces: ["requirements-source"], terminal: false}
		"workbook-identity.verify": {id: "workbook-identity.verify", index: 1, boundary: "cue", dependsOn: ["requirements.verify"], scenarioIDs: [], consumes: ["requirements-source"], produces: ["workbook-identity"], terminal: false}
		"project-lock.verify": {id: "project-lock.verify", index: 2, boundary: "marimo-python", dependsOn: ["workbook-identity.verify"], scenarioIDs: [], consumes: ["workbook-identity"], produces: ["locked-environment-identity"], terminal: false}
		"contracts.vet": {id: "contracts.vet", index: 3, boundary: "cue", dependsOn: ["requirements.verify", "workbook-identity.verify"], scenarioIDs: [], consumes: ["requirements-source", "workbook-identity"], produces: ["bootstrap-contract-validation"], terminal: false}
		"fixtures.execute": {id: "fixtures.execute", index: 4, boundary: "marimo-python", dependsOn: ["project-lock.verify", "contracts.vet"], scenarioIDs: _allScenarioIDs, consumes: ["locked-environment-identity", "bootstrap-contract-validation"], produces: ["positive-fixture-results", "negative-fixture-results"], terminal: false}
		"workflow.verify": {id: "workflow.verify", index: 5, boundary: "cue", dependsOn: ["fixtures.execute"], scenarioIDs: [], consumes: ["positive-fixture-results", "negative-fixture-results"], produces: ["workflow-refinement-result", "scenario-coverage-result"], terminal: false}
		"provisional.compute": {id: "provisional.compute", index: 6, boundary: "cue", dependsOn: ["workflow.verify"], scenarioIDs: [], consumes: ["workflow-refinement-result", "scenario-coverage-result"], produces: ["bounded-provisional-admission"], terminal: false}
		"self-conformance.execute": {id: "self-conformance.execute", index: 7, boundary: "marimo-python", dependsOn: ["provisional.compute"], scenarioIDs: [], consumes: ["bounded-provisional-admission"], produces: ["self-conformance-result"], terminal: false}
		"self-conformance.admit": {id: "self-conformance.admit", index: 8, boundary: "cue", dependsOn: ["self-conformance.execute"], scenarioIDs: [], consumes: ["self-conformance-result"], produces: ["self-conformance-admission"], terminal: false}
		"provisional.retire": {id: "provisional.retire", index: 9, boundary: "cue", dependsOn: ["self-conformance.admit"], scenarioIDs: [], consumes: ["self-conformance-admission"], produces: ["provisional-retirement-result"], terminal: false}
		"unit.admit": {id: "unit.admit", index: 10, boundary: "cue", dependsOn: ["provisional.retire"], scenarioIDs: [], consumes: ["provisional-retirement-result"], produces: ["implementation-unit-admission"], terminal: true}
	}
}

artifactRole: {
	"requirements-source":           "observation"
	"workbook-identity":             "derived"
	"locked-environment-identity":   "observation"
	"bootstrap-contract-validation": "derived"
	"positive-fixture-results":      "observation"
	"negative-fixture-results":      "observation"
	"workflow-refinement-result":    "derived"
	"scenario-coverage-result":      "derived"
	"bounded-provisional-admission": "derived"
	"self-conformance-result":       "observation"
	"self-conformance-admission":    "derived"
	"provisional-retirement-result": "derived"
	"implementation-unit-admission": "derived"
}

#WorkflowRefinementResult: close({
	nodeIdentitiesMatch:              bool
	nodeIndexesUnique:                bool
	dependencyReferencesResolve:      bool
	dependencyOrderPreserved:         bool
	artifactReferencesResolve:        bool
	productionBeforeConsumption:      bool
	everyScenarioAssignedExactlyOnce: bool
	unitAdmissionTerminal:            bool
	pythonProducesObservationsOnly:   bool
})

#WorkflowRefinementEvaluation: {
	Workflow: #ValidationWorkflow
	ArtifactRole: [#NonEmptyString]: "observation" | "derived"
	ScenarioIDs: [...#ScenarioID]

	_workflow:     Workflow
	_artifactRole: ArtifactRole
	_scenarioIDs:  ScenarioIDs
	_workflowNodeIDs: [for nodeID, _ in _workflow.nodes {nodeID}]
	_artifactIDs: [for artifactID, _ in _artifactRole {artifactID}]

	_nodeIdentityFailures: [for nodeID, node in _workflow.nodes if node.id != nodeID {nodeID}]
	_duplicateIndexFailures: [for leftID, left in _workflow.nodes for rightID, right in _workflow.nodes
		if leftID < rightID && left.index == right.index {left: leftID, right: rightID, index: left.index}]
	_dependencyReferenceFailures: [for _, node in _workflow.nodes for dependency in node.dependsOn
		if !list.Contains(_workflowNodeIDs, dependency) {node: node.id, dependency: dependency}]
	_dependencyOrderFailures: [for _, node in _workflow.nodes for dependency in node.dependsOn if len([
		for dependencyID, dependencyNode in _workflow.nodes
		if dependencyID == dependency && dependencyNode.index < node.index {dependencyID}
	]) != 1 {node: node.id, dependency: dependency}]
	_artifactReferenceFailures: [for _, node in _workflow.nodes for artifact in list.Concat([node.consumes, node.produces])
		if !list.Contains(_artifactIDs, artifact) {node: node.id, artifact: artifact}]
	_productionFailures: [for _, node in _workflow.nodes for artifact in node.consumes if len([
		for _, producer in _workflow.nodes if list.Contains(producer.produces, artifact) && producer.index < node.index {producer.id}
	]) != 1 {node: node.id, artifact: artifact}]
	_scenarioAssignmentFailures: [for scenarioID in _scenarioIDs if len([
		for _, node in _workflow.nodes if list.Contains(node.scenarioIDs, scenarioID) {node.id}
	]) != 1 {scenarioID}]
	_unknownScenarioAssignments: [for _, node in _workflow.nodes for scenarioID in node.scenarioIDs
		if !list.Contains(_scenarioIDs, scenarioID) {node: node.id, scenarioID: scenarioID}]
	_terminalNodeFailures: [for nodeID, node in _workflow.nodes
		if (nodeID == _workflow.terminalNode) != node.terminal {nodeID}]
	_terminalDependents: [for _, node in _workflow.nodes if list.Contains(node.dependsOn, _workflow.terminalNode) {node.id}]
	_pythonDerivedArtifacts: [for _, node in _workflow.nodes if node.boundary == "marimo-python"
		for artifact in node.produces if list.Contains(_artifactIDs, artifact) && _artifactRole[artifact] != "observation" {artifact}]

	Result: #WorkflowRefinementResult & {
		nodeIdentitiesMatch:              len(_nodeIdentityFailures) == 0
		nodeIndexesUnique:                len(_duplicateIndexFailures) == 0
		dependencyReferencesResolve:      len(_dependencyReferenceFailures) == 0
		dependencyOrderPreserved:         len(_dependencyOrderFailures) == 0
		artifactReferencesResolve:        len(_artifactReferenceFailures) == 0
		productionBeforeConsumption:      len(_productionFailures) == 0
		everyScenarioAssignedExactlyOnce: len(_scenarioAssignmentFailures) == 0 && len(_unknownScenarioAssignments) == 0
		unitAdmissionTerminal:            len(_terminalNodeFailures) == 0 && len(_terminalDependents) == 0
		pythonProducesObservationsOnly:   len(_pythonDerivedArtifacts) == 0
	}
}

_workflowEvaluation: #WorkflowRefinementEvaluation & {
	Workflow:     bootstrapWorkflow
	ArtifactRole: artifactRole
	ScenarioIDs:  _allScenarioIDs
}

_scenarioPolicyFailures: [for acceptanceID, policy in acceptancePolicies if len(policy.obligations)+len(policy.omissions) != len(_scenarioClasses) {acceptanceID}]

_compatibleEvaluationProtocols: {
	"project-inspect.v1": ["fact-predicate.v1"]
	"process-run.v1": ["subject-exit.v1"]
	"artifact-compare.v1": ["identity-match.v1", "identity-preservation.v1"]
	"cue-projection-observe.v1": ["projection-conformance.v1"]
}
#ScenarioProtocolCompatibilityCheck: {
	Declarations: [#ScenarioID]: #ScenarioExecutionDeclaration
	_declarations: Declarations
	_failures: [for scenarioID, declaration in _declarations if !list.Contains(_compatibleEvaluationProtocols[declaration.executorProtocol], declaration.evaluationProtocol) {scenarioID}]
	compatible: len(_failures) == 0
}

#ScenarioProtocolCompatibilityPositiveProbe: #ScenarioProtocolCompatibilityCheck & {
	Declarations: {
		"BDD-BOOT-COMP-001": {
			scenarioID:         "BDD-BOOT-COMP-001"
			executorProtocol:   "artifact-compare.v1"
			evaluationProtocol: "identity-preservation.v1"
			executionBoundary:  "python-observe"
			evaluationBoundary: "cue-evaluate"
			fixturePath:        "positive/example/fixture.json"
		}
	}
	compatible: true
}

#ScenarioProtocolCompatibilityNegativeProbe: #ScenarioProtocolCompatibilityCheck & {
	Declarations: {
		"BDD-BOOT-COMP-001": {
			scenarioID:         "BDD-BOOT-COMP-001"
			executorProtocol:   "artifact-compare.v1"
			evaluationProtocol: "subject-exit.v1"
			executionBoundary:  "python-observe"
			evaluationBoundary: "cue-evaluate"
			fixturePath:        "positive/example/fixture.json"
		}
	}
	compatible: false
}

_scenarioProtocolCheck: #ScenarioProtocolCompatibilityCheck & {
	Declarations: scenarioExecutionManifest
}

_requirementMilestones: {
	"UV-01": 2, "UV-02": 2, "UV-03": 2, "UV-04": 4
	"BD-01": 3, "BD-02": 5, "BD-03": 5, "BD-04": 5
	"BD-05": 5, "BD-06": 6, "BD-07": 8, "BD-08": 9
}
_requirementEdges: [
	{before: "UV-01", after: "UV-02"}, {before: "UV-02", after: "UV-03"}, {before: "UV-03", after: "UV-04"},
	{before: "BD-01", after: "BD-02"}, {before: "BD-01", after: "BD-03"}, {before: "BD-02", after: "BD-03"},
	{before: "BD-02", after: "BD-04"}, {before: "BD-01", after: "BD-05"}, {before: "BD-03", after: "BD-06"},
	{before: "BD-05", after: "BD-06"}, {before: "BD-06", after: "BD-07"}, {before: "UV-04", after: "BD-07"},
	{before: "BD-01", after: "BD-08"}, {before: "BD-02", after: "BD-08"}, {before: "BD-03", after: "BD-08"},
	{before: "BD-04", after: "BD-08"}, {before: "BD-05", after: "BD-08"}, {before: "BD-06", after: "BD-08"},
	{before: "BD-07", after: "BD-08"}, {before: "UV-04", after: "BD-08"},
]
_requirementOrderFailures: [for edge in _requirementEdges if !(_requirementMilestones[edge.before] <= _requirementMilestones[edge.after]) {edge}]

workflowDeclarationCheck: close({
	nodeIdentitiesMatch:              _workflowEvaluation.Result.nodeIdentitiesMatch
	nodeIndexesUnique:                _workflowEvaluation.Result.nodeIndexesUnique
	dependencyReferencesResolve:      _workflowEvaluation.Result.dependencyReferencesResolve
	dependencyOrderPreserved:         _workflowEvaluation.Result.dependencyOrderPreserved && len(_requirementOrderFailures) == 0
	artifactReferencesResolve:        _workflowEvaluation.Result.artifactReferencesResolve
	productionBeforeConsumption:      _workflowEvaluation.Result.productionBeforeConsumption
	everyScenarioAssignedExactlyOnce: _workflowEvaluation.Result.everyScenarioAssignedExactlyOnce
	allScenarioPoliciesComplete:      len(_scenarioPolicyFailures) == 0
	scenarioProtocolsCompatible:      _scenarioProtocolCheck.compatible
	evidenceFollowsExecution:         bootstrapWorkflow.nodes["workflow.verify"].index > bootstrapWorkflow.nodes["fixtures.execute"].index
	unitAdmissionTerminal:            _workflowEvaluation.Result.unitAdmissionTerminal
	pythonProducesObservationsOnly:   _workflowEvaluation.Result.pythonProducesObservationsOnly
})

_unresolvedCommandNodes: [for step in commandProjection.steps if len([
	for nodeID, _ in bootstrapWorkflow.nodes if nodeID == step.workflowNode {nodeID}
]) != 1 {step.workflowNode}]

_commandCoverageFailures: [for nodeID, _ in bootstrapWorkflow.nodes if len([
	for step in commandProjection.steps if step.workflowNode == nodeID {step.id}
]) != 1 {nodeID}]

_commandBoundaryFailures: [for step in commandProjection.steps if len([
	for nodeID, node in bootstrapWorkflow.nodes if nodeID == step.workflowNode && node.boundary == step.boundary {nodeID}
]) != 1 {step.workflowNode}]

_commandConsumptionFailures: [for step in commandProjection.steps if len([
	for nodeID, node in bootstrapWorkflow.nodes if nodeID == step.workflowNode && node.consumes == step.consumes {nodeID}
]) != 1 {step.workflowNode}]

_commandProductionFailures: [for step in commandProjection.steps if len([
	for nodeID, node in bootstrapWorkflow.nodes if nodeID == step.workflowNode && node.produces == step.produces {nodeID}
]) != 1 {step.workflowNode}]

_commandOrderingFailures: [for commandIndex, step in commandProjection.steps
	for nodeID, node in bootstrapWorkflow.nodes if nodeID == step.workflowNode
	for dependency in node.dependsOn if len([
		for dependencyIndex, dependencyStep in commandProjection.steps
		if dependencyStep.workflowNode == dependency && dependencyIndex < commandIndex {dependencyStep.id}
	]) != 1 {node: nodeID, dependency: dependency}]

_finalCommandStep:     commandProjection.steps[len(commandProjection.steps)-1]
_terminalWorkflowNode: bootstrapWorkflow.nodes[bootstrapWorkflow.terminalNode]

commandProjectionRefinement: close({
	everyCommandReferencesWorkflowNode: true & len(_unresolvedCommandNodes) == 0
	everyWorkflowNodeProjectedOnce:     true & len(_commandCoverageFailures) == 0
	commandBoundariesMatch:             true & len(_commandBoundaryFailures) == 0
	commandConsumptionMatches:          true & len(_commandConsumptionFailures) == 0
	commandProductionMatches:           true & len(_commandProductionFailures) == 0
	commandOrderingPreservesWorkflow:   true & len(_commandOrderingFailures) == 0
	finalCommandTargetsTerminalNode:    true & _finalCommandStep.workflowNode == bootstrapWorkflow.terminalNode
	terminalProductIsUnitAdmission: true & _terminalWorkflowNode.produces == ["implementation-unit-admission"]
	literalGateTargetsUnitAdmission: true & commandProjection.literalTrueGate.expression == "implementationUnitAdmission"
})
