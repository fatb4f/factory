package ivaceval

neuroscienceExpertiseContract: #EvaluationContract & {
	id:      "neuroscience-expertise"
	version: "1.0.0"
	purpose: "neuroscience-expertise"
	input: {
		profile: {
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "objective-tests", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["observations", "observationEvidence", "episodes", "episodeObservations", "capacities", "capacityEvidence", "interventions", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "evidence-neighborhood"},
			{id: "episode-membership"},
			{id: "capacity-impact"},
			{id: "contradiction-surface"},
			{id: "causal-attribution-only"},
		]
		indices: [
			{id: "edge-by-subject"},
			{id: "edge-by-object"},
			{id: "edge-by-predicate"},
			{id: "edge-by-evidence"},
		]
		temporalOwner: "evaluation"
	}
	questions: [
		{id: "mechanism", domain: "mechanism", question: "Which observed neurocognitive, psychiatric, developmental, and substance-related mechanisms are supported by the admitted record?", dependsOn: [{kind: "edge-transform", id: "evidence-neighborhood"}, {kind: "index-transform", id: "edge-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "differential", domain: "differential", question: "Which competing or interacting explanations must be separated before causal attribution is made?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "causal-map", domain: "causation", question: "Which graph relations can be upgraded from reported or associated to clinician-attributed causation, and which cannot?", dependsOn: [{kind: "edge-transform", id: "causal-attribution-only"}, {kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "functional-translation", domain: "function", question: "How do supported mechanisms translate into observed capacity limitations and recurrent real-world failure events?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}, {kind: "edge-transform", id: "episode-membership"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "prognosis", domain: "prognosis", question: "What does the longitudinal record support regarding persistence, treatment response, recurrence vulnerability, and prognosis?", dependsOn: [{kind: "edge-transform", id: "evidence-neighborhood"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
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
	]
}
