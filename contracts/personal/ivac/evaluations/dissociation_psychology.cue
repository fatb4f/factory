package ivaceval

psychologicalDissociationAssessmentContract: #ProfessionalAssessmentContract & {
	id:      "psychological-dissociation-assessment"
	version: "1.0.0"
	purpose: "psychological-dissociation-assessment"
	root: {
		evaluatorKinds: ["clinical-expert"]
		authorityKinds: ["clinical", "personal", "legal"]
		commissioningModes: ["direct", "mandated"]
		mandateKinds: ["expert"]
		requiredTransitions: ["commission", "disclose", "observe", "opine", "assert"]
	}
	deliverable: {
		evidenceClasses: ["clinical-report", "expert-report", "objective-test"]
		findingKinds: ["diagnosis", "persistent-symptom", "functional-limitation", "permanence", "causal-opinion", "aggravation-opinion", "prognosis", "other"]
		admission: "candidate-until-qualified"
	}
	input: {
		profile: {
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "objective-tests", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["observations", "observationEvidence", "episodes", "episodeObservations", "episodeEvidence", "capacities", "capacityEvidence", "capacitySupport", "interventions", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "assessment-input-surface"},
			{id: "assessment-evidence-links"},
			{id: "episode-membership"},
			{id: "capacity-impact"},
			{id: "contradiction-surface"},
			{id: "causal-attribution-only"},
			{id: "temporal-window"},
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
		{id: "dissociation-phenotype", domain: "dissociation", question: "Which dissociative phenomena are supported by interview, psychometrics, collateral information, and the admitted longitudinal record?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "index-transform", id: "assessment-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "episode-structure", domain: "episodes", question: "How should recurrent episodes involving detachment, altered self-state, amnesia, fugue-like behavior, or impaired reality integration be clinically characterized?", dependsOn: [{kind: "edge-transform", id: "episode-membership"}, {kind: "index-transform", id: "assessment-by-subject"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "affective-integration", domain: "state-integration", question: "What does the assessment support regarding recognition, interpretation, and integration of affective or interoceptive state changes under stress?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}, {kind: "edge-transform", id: "assessment-input-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "functional-regulation", domain: "function", question: "How do supported dissociative or trauma-related mechanisms translate into impaired self-regulation, recurrent risk behavior, or dependence on external support?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "differential", domain: "differential", question: "Which psychiatric, developmental, substance-related, medication, sleep, or situational explanations overlap with or compete with a dissociative formulation?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "longitudinal-causation", domain: "causation", question: "Which persistence, aggravation, or causal relations are clinically supportable, and which remain temporal associations or unresolved?", dependsOn: [{kind: "edge-transform", id: "causal-attribution-only"}, {kind: "edge-transform", id: "temporal-window"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["clinical-expert"]
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"Psychological findings remain distinct from legal review grounds and adjudicative conclusions.",
			"Causal or aggravation opinions require explicit professional attribution and must remain separate from temporal association.",
		]
	}
	invariants: [
		"dissociation, trauma formulation, substance-related effects, and other differential explanations remain separable",
		"high-intensity behavior is not itself proof of a dissociative mechanism",
		"causal upgrades require explicit evaluator attribution",
	]
}
