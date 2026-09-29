package ivaceval

permanentSequelaContract: #ProfessionalAssessmentContract & {
	id:      "permanent-sequela"
	version: "1.1.0"
	purpose: "permanent-sequela"
	root: {
		evaluatorKinds: ["clinical-expert", "medical-expert", "treating-clinician"]
		authorityKinds: ["clinical", "personal", "legal"]
		commissioningModes: ["direct", "mandated"]
		mandateKinds: ["expert"]
		requiredTransitions: ["commission", "disclose", "observe", "opine", "assert"]
	}
	deliverable: {
		evidenceClasses: ["clinical-report", "expert-report", "objective-test"]
		findingKinds: ["diagnosis", "persistent-symptom", "functional-limitation", "permanence", "consolidation", "causal-opinion", "aggravation-opinion", "prognosis", "other"]
		admission: "candidate-until-qualified"
	}
	input: {
		profile: {
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "objective-tests", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["observations", "observationEvidence", "episodes", "episodeObservations", "capacities", "capacityEvidence", "capacitySupport", "interventions", "interventionEvidence", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "assessment-input-surface"},
			{id: "assessment-evidence-links"},
			{id: "capacity-impact"},
			{id: "contradiction-surface"},
			{id: "causal-attribution-only"},
		]
		indices: [
			{id: "assessment-by-subject"},
			{id: "assessment-by-object"},
			{id: "assessment-by-predicate"},
			{id: "assessment-by-evidence"},
		]
		temporalOwner: "evaluation"
	}
	questions: [
		{id: "permanence", domain: "permanence", question: "Does the admitted longitudinal record support a persistent impairment after treatment and stabilization opportunities?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "index-transform", id: "assessment-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "function", domain: "function", question: "Which ordinary capacities are persistently impaired or unreliable, and what concrete failures evidence those limitations?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}, {kind: "index-transform", id: "assessment-by-subject"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "support", domain: "support", question: "Which capacities require recurring external intervention, accommodation, treatment, or human support?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "causation", domain: "causation", question: "Which causal relations are clinically supported, which are associations only, and which remain unresolved?", dependsOn: [{kind: "edge-transform", id: "causal-attribution-only"}, {kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "separate-unit", domain: "functional-unit", question: "Does the evidence support a distinct permanent functional unit rather than a consequence of another impairment?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "edge-transform", id: "capacity-impact"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["clinical-expert", "medical-expert", "treating-clinician"]
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"The evaluator may assess clinical permanence and function but may not manufacture an adjudicative outcome.",
			"A missing causal attribution remains unresolved rather than being inferred from temporal sequence alone.",
		]
	}
	invariants: [
		"cross-sectional stability does not erase longitudinal failure events",
		"permanence is assessed from longitudinal admitted evidence rather than diagnosis count",
		"causal predicates consumed by this evaluation require qualified clinical attribution",
		"root-bound deliverables remain candidates until separately admitted and qualified",
	]
}
