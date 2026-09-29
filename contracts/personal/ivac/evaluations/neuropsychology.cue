package ivaceval

neuropsychologicalReassessmentContract: #ProfessionalAssessmentContract & {
	id:      "neuropsychological-reassessment"
	version: "1.0.0"
	purpose: "neuropsychological-reassessment"
	root: {
		evaluatorKinds: ["clinical-expert"]
		authorityKinds: ["clinical", "personal", "legal"]
		commissioningModes: ["direct", "mandated"]
		mandateKinds: ["expert"]
		requiredTransitions: ["commission", "disclose", "observe", "opine", "assert"]
	}
	deliverable: {
		evidenceClasses: ["clinical-report", "objective-test"]
		findingKinds: ["diagnosis", "persistent-symptom", "functional-limitation", "prognosis", "other"]
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
			{id: "capacity-impact"},
			{id: "episode-membership"},
			{id: "contradiction-surface"},
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
		{id: "baseline-comparison", domain: "comparison", question: "What is stable versus changed when current findings are compared with prior neuropsychological assessment and the admitted longitudinal record?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "index-transform", id: "assessment-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "executive-control", domain: "executive-function", question: "What do structured measures support regarding inhibition, sustained attention, cognitive flexibility, and working memory?", dependsOn: [{kind: "index-transform", id: "assessment-by-subject"}, {kind: "index-transform", id: "assessment-by-predicate"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "salience-state", domain: "state-regulation", question: "To what extent can validated methods characterize decision-making or self-regulation when emotional load, stress, or reward salience increases?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}, {kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "ecological-gap", domain: "ecological-validity", question: "How should preserved performance in structured testing be reconciled with recurrent real-world functional failure events?", dependsOn: [{kind: "edge-transform", id: "episode-membership"}, {kind: "edge-transform", id: "assessment-input-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "confounds", domain: "differential", question: "Which developmental, psychiatric, substance-related, medication, sleep, or situational factors limit interpretation of the current cognitive profile?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}, {kind: "edge-transform", id: "temporal-window"}], outputs: ["clinical-assessment", "coverage-gap"]},
		{id: "scope-boundary", domain: "scope", question: "Which requested questions cannot be validly answered by neuropsychological assessment and require another professional authority?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}], outputs: ["coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["clinical-expert"]
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"Neuropsychological test performance does not by itself establish medico-legal causation or adjudicative permanence.",
			"Comparison with prior testing must preserve differences in instruments, context, validity, and temporal state.",
		]
	}
	invariants: [
		"structured test performance and ecological functioning remain distinct observation surfaces",
		"confounds remain explicit rather than being silently absorbed into a single causal explanation",
		"questions outside validated neuropsychological scope resolve to coverage gaps rather than inferred findings",
	]
}
