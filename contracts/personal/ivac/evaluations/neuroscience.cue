package ivaceval

neuroscienceExpertiseContract: #ProfessionalAssessmentContract & {
	id:      "neuroscience-expertise"
	version: "1.1.0"
	purpose: "neuroscience-expertise"
	root: {
		evaluatorKinds: ["medical-expert"]
		authorityKinds: ["clinical", "legal"]
		commissioningModes: ["mandated"]
		mandateKinds: ["expert"]
		requiredTransitions: ["commission", "disclose", "observe", "opine", "assert"]
	}
	deliverable: {
		evidenceClasses: ["expert-report", "clinical-report", "objective-test"]
		findingKinds: ["diagnosis", "persistent-symptom", "functional-limitation", "permanence", "consolidation", "causal-opinion", "aggravation-opinion", "prognosis", "other"]
		admission: "candidate-until-qualified"
	}
	input: {
		profile: {
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "objective-tests", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["observations", "observationEvidence", "episodes", "episodeObservations", "capacities", "capacityEvidence", "interventions", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "assessment-input-surface"},
			{id: "assessment-evidence-links"},
			{id: "episode-membership"},
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
		{id: "mechanism", domain: "mechanism", question: "Which observed neurocognitive, psychiatric, developmental, and substance-related mechanisms are supported by the admitted record?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "index-transform", id: "assessment-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "differential", domain: "differential", question: "Which competing or interacting explanations must be separated before causal attribution is made?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "causal-map", domain: "causation", question: "Which graph relations can be upgraded from reported or associated to clinician-attributed causation, and which cannot?", dependsOn: [{kind: "edge-transform", id: "causal-attribution-only"}, {kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "functional-translation", domain: "function", question: "How do supported mechanisms translate into observed capacity limitations and recurrent real-world failure events?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}, {kind: "edge-transform", id: "episode-membership"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "prognosis", domain: "prognosis", question: "What does the longitudinal record support regarding persistence, treatment response, recurrence vulnerability, and prognosis?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "index-transform", id: "assessment-by-subject"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["medical-expert"]
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"Temporal association alone is not a causal opinion.",
			"The expert may emit medical findings but not legal review grounds or adjudicative outcomes.",
		]
	}
	invariants: [
		"mechanism, differential diagnosis, causation, functional translation, and prognosis remain separate questions",
		"patient-reported and derived relations remain visible without being silently upgraded to causal findings",
		"clinical causal upgrades require explicit expert attribution",
		"root-bound deliverables remain candidates until separately admitted and qualified",
	]
}
