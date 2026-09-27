package ivaceval

import ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"

#EvaluationID: string & !=""
#QuestionID: string & !=""

#EvaluationPurpose:
	"permanent-sequela" |
	"gp-addendum" |
	"neuroscience-expertise" |
	"legal-review"

#AssessmentDisposition: "supported" | "contradicted" | "insufficient-evidence" | "not-applicable"

#EvaluationOutputKind:
	"clinical-assessment" |
	"finding-candidate" |
	"legal-ground-candidate" |
	"coverage-gap"

#EvaluationQuestion: close({
	id:       #QuestionID
	domain:   string & !=""
	question: string & !=""
	outputs:  [#EvaluationOutputKind, ...#EvaluationOutputKind]
})

#EvaluationContract: close({
	id:      #EvaluationID
	purpose: #EvaluationPurpose
	allowedEvaluatorKinds: [ivac.#ActorKind, ...ivac.#ActorKind]
	selector:              ivac.#ProfileSelector
	transforms:            [ivac.#RelationTransformRef, ...ivac.#RelationTransformRef]
	questions:             [#EvaluationQuestion, ...#EvaluationQuestion]
	boundary: close({
		mayEmit:     [#EvaluationOutputKind, ...#EvaluationOutputKind]
		mustNotEmit: [...#EvaluationOutputKind]
		notes:       [...string]
	})
})

#Assessment: close({
	id:          string & !=""
	questionID:  #QuestionID
	disposition: #AssessmentDisposition
	evidence:    [...ivac.#EvidenceArtifactRef]
	relations:   [...ivac.#ClinicalRelationRef]
	rationale?:  string
})

#AssessmentBundle: close({
	contractID:  #EvaluationID
	evaluator:   ivac.#ActorRef
	profile:     ivac.#SubjectProfileRef
	assessments: [#Assessment, ...#Assessment]
})

permanentSequelaContract: #EvaluationContract & {
	id:      "permanent-sequela"
	purpose: "permanent-sequela"
	allowedEvaluatorKinds: ["medical-expert", "treating-clinician"]
	selector: {
		partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "objective-tests", "support-dependency", "context"]
		temporal: {mode: "all"}
	}
	transforms: [
		{id: "evidence-closure"},
		{id: "capacity-impact"},
		{id: "contradiction-surface"},
		{id: "causal-attribution-only"},
	]
	questions: [
		{id: "permanence", domain: "permanence", question: "Does the admitted longitudinal record support a persistent impairment after treatment and stabilization opportunities?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "function", domain: "function", question: "Which ordinary capacities are persistently impaired or unreliable, and what concrete failures evidence those limitations?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "support", domain: "support", question: "Which capacities require recurring external intervention, accommodation, treatment, or human support?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "causation", domain: "causation", question: "Which causal relations are clinically supported, which are associations only, and which remain unresolved?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "separate-unit", domain: "functional-unit", question: "Does the evidence support a distinct permanent functional unit rather than a consequence of another impairment?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"The evaluator may assess clinical permanence and function but may not manufacture an adjudicative outcome.",
			"A missing causal attribution remains unresolved rather than being inferred from temporal sequence alone.",
		]
	}
}

gpAddendumContract: #EvaluationContract & {
	id:      "gp-addendum"
	purpose: "gp-addendum"
	allowedEvaluatorKinds: ["treating-clinician"]
	selector: {
		partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "support-dependency", "context"]
		temporal: {mode: "all"}
	}
	transforms: [
		{id: "evidence-closure"},
		{id: "capacity-impact"},
		{id: "contradiction-surface"},
		{id: "temporal-window"},
	]
	questions: [
		{id: "ordinary-capacity", domain: "function", question: "What ordinary mental or behavioral capacities cannot be reliably initiated, sequenced, sustained, completed, or resumed?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "failure-events", domain: "function", question: "Which longitudinal failure events demonstrate those capacity losses outside a structured clinical encounter?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "intervention", domain: "support", question: "What recurring intervention is required, by whom, and what occurs when that intervention is absent or insufficient?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "temporal-partition", domain: "time", question: "Which impairments and failure patterns predate the selected administrative cutoff and which represent later deterioration?", outputs: ["clinical-assessment", "coverage-gap"]},
		{id: "reconciliation", domain: "reconciliation", question: "How should preserved cross-sectional capacities be reconciled with recurrent longitudinal decompensation?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"The treating clinician independently confirms, rejects, or qualifies every proposition.",
			"Evaluation-specific wording must not be written back into the normalized evidence world as fact.",
		]
	}
}

neuroscienceExpertiseContract: #EvaluationContract & {
	id:      "neuroscience-expertise"
	purpose: "neuroscience-expertise"
	allowedEvaluatorKinds: ["medical-expert"]
	selector: {
		partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "objective-tests", "support-dependency", "context"]
		temporal: {mode: "all"}
	}
	transforms: [
		{id: "evidence-closure"},
		{id: "episode-membership"},
		{id: "capacity-impact"},
		{id: "contradiction-surface"},
		{id: "causal-attribution-only"},
	]
	questions: [
		{id: "mechanism", domain: "mechanism", question: "Which observed neurocognitive, psychiatric, developmental, and substance-related mechanisms are supported by the admitted record?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "differential", domain: "differential", question: "Which competing or interacting explanations must be separated before causal attribution is made?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "causal-map", domain: "causation", question: "Which graph relations can be upgraded from reported or associated to clinician-attributed causation, and which cannot?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "functional-translation", domain: "function", question: "How do supported mechanisms translate into observed capacity limitations and recurrent real-world failure events?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "prognosis", domain: "prognosis", question: "What does the longitudinal record support regarding persistence, treatment response, recurrence vulnerability, and prognosis?", outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"Temporal association alone is not a causal opinion.",
			"The expert may emit medical findings but not legal review grounds or adjudicative outcomes.",
		]
	}
}

legalReviewContract: #EvaluationContract & {
	id:      "legal-review"
	purpose: "legal-review"
	allowedEvaluatorKinds: ["legal-representative"]
	selector: {
		partitions: ["functional-events", "support-dependency", "context"]
		temporal: {mode: "all"}
	}
	transforms: [
		{id: "evidence-closure"},
		{id: "contradiction-surface"},
		{id: "temporal-window"},
	]
	questions: [
		{id: "grounds", domain: "review-ground", question: "Which admitted clinical findings and evidence support a review ground without changing their medical meaning?", outputs: ["legal-ground-candidate", "coverage-gap"]},
		{id: "gaps", domain: "record-gap", question: "Which missing records, expert opinions, or unresolved contradictions prevent a ground from being safely bound for submission?", outputs: ["coverage-gap"]},
		{id: "scope", domain: "scope", question: "Which claim axes are supported for submission and which remain hypotheses or require further qualification?", outputs: ["legal-ground-candidate", "coverage-gap"]},
	]
	boundary: {
		mayEmit: ["legal-ground-candidate", "coverage-gap"]
		mustNotEmit: ["clinical-assessment", "finding-candidate"]
		notes: [
			"Legal review consumes admitted medical findings but may not manufacture or upgrade medical findings.",
			"Only adjudication changes the recognized decision state.",
		]
	}
}

public: close({
	contracts: close({
		permanentSequela: permanentSequelaContract
		gpAddendum:       gpAddendumContract
		neuroscience:     neuroscienceExpertiseContract
		legalReview:      legalReviewContract
	})
})
