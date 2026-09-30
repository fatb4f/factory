package ivaceval

import ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"

#EvaluationID: string & !=""
#QuestionID: string & !=""

#EvaluationPurpose:
	"permanent-sequela" |
	"gp-addendum" |
	"neuroscience-expertise" |
	"legal-review" |
	"downstream-reuse"

#AssessmentDisposition: "supported" | "contradicted" | "insufficient-evidence" | "not-applicable"

#EvaluationOutputKind:
	"clinical-assessment" |
	"finding-candidate" |
	"legal-ground-candidate" |
	"reuse-candidate" |
	"disclosure-risk" |
	"coverage-gap"

#DependencyKind: "edge-transform" | "index-transform"

#EvaluationDependencyRef: close({
	kind: #DependencyKind
	id:   string & !=""
})

#EvaluationQuestion: close({
	id:         #QuestionID
	domain:     string & !=""
	question:   string & !=""
	dependsOn:  [...#EvaluationDependencyRef]
	outputs:    [#EvaluationOutputKind, ...#EvaluationOutputKind]
})

#EvaluationInputContract: close({
	profile:        ivac.#ProfileSelector
	relations:      [ivac.#ProjectionRelationID, ...ivac.#ProjectionRelationID]
	edgeTransforms: [ivac.#EdgeTransformRef, ...ivac.#EdgeTransformRef]
	indices:        [ivac.#IndexTransformRef, ...ivac.#IndexTransformRef]
	temporalOwner:  "evaluation"
})

#EvaluationBoundary: close({
	allowedEvaluatorKinds: [ivac.#ActorKind, ...ivac.#ActorKind]
	mayEmit:               [#EvaluationOutputKind, ...#EvaluationOutputKind]
	mustNotEmit:           [...#EvaluationOutputKind]
	notes:                 [...string]
})

#EvaluationContract: close({
	id:         #EvaluationID
	version:    string & !=""
	purpose:    #EvaluationPurpose
	input:      #EvaluationInputContract
	questions:  [#EvaluationQuestion, ...#EvaluationQuestion]
	boundary:   #EvaluationBoundary
	invariants: [string & !="", ...(string & !="")]
})

#EvaluationContractRef: close({
	id:      #EvaluationID
	version: string & !=""
})

#EvaluationInstance: close({
	id:         string & !=""
	contract:   #EvaluationContractRef
	evaluator:  ivac.#ActorRef
	profile:    ivac.#SubjectProfileRef
	parameters: [string]: string
})

#Assessment: close({
	id:          string & !=""
	questionID:  #QuestionID
	disposition: #AssessmentDisposition
	evidence:    [...ivac.#EvidenceArtifactRef]
	relations:   [...ivac.#ClinicalRelationRef]
	dependencies: [...#EvaluationDependencyRef]
	rationale?:  string
})

#AssessmentBundle: close({
	instanceID:             string & !=""
	contract:               #EvaluationContractRef
	evaluator:              ivac.#ActorRef
	profile:                ivac.#SubjectProfileRef
	executedEdgeTransforms: [...ivac.#EdgeTransformRef]
	materializedIndices:    [...ivac.#IndexSnapshotRef]
	assessments:            [#Assessment, ...#Assessment]
})
