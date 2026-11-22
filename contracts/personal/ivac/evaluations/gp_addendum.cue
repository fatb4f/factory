package ivaceval

gpAddendumContract: #ProfessionalAssessmentContract & {
	id:      "gp-addendum"
	version: "1.1.0"
	purpose: "gp-addendum"
	root: {
		evaluatorKinds: ["treating-clinician"]
		authorityKinds: ["clinical", "personal"]
		commissioningModes: ["direct"]
		requiredTransitions: ["observe", "opine", "assert"]
	}
	deliverable: {
		evidenceClasses: ["clinical-report"]
		findingKinds: ["diagnosis", "persistent-symptom", "functional-limitation", "permanence", "consolidation", "causal-opinion", "aggravation-opinion", "prognosis", "other"]
		admission: "candidate-until-qualified"
	}
	input: {
		profile: {
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "sleep", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["observations", "observationEvidence", "episodes", "episodeObservations", "capacities", "capacitySupport", "interventions", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "assessment-input-surface"},
			{id: "assessment-evidence-links"},
			{id: "capacity-impact"},
			{id: "contradiction-surface"},
			{id: "temporal-window"},
			{id: "evidence-neighborhood"},
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
		{id: "ordinary-capacity", domain: "function", question: "What ordinary mental or behavioral capacities cannot be reliably initiated, sequenced, sustained, completed, or resumed?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}, {kind: "index-transform", id: "assessment-by-subject"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "failure-events", domain: "function", question: "Which longitudinal failure events demonstrate those capacity losses outside a structured clinical encounter?", dependsOn: [{kind: "edge-transform", id: "evidence-neighborhood"}, {kind: "index-transform", id: "assessment-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "intervention", domain: "support", question: "What recurring intervention is required, by whom, and what occurs when that intervention is absent or insufficient?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "temporal-partition", domain: "time", question: "Which impairments and failure patterns predate the selected administrative cutoff and which represent later deterioration?", dependsOn: [{kind: "edge-transform", id: "temporal-window"}], outputs: ["clinical-assessment", "coverage-gap"]},
		{id: "reconciliation", domain: "reconciliation", question: "How should preserved cross-sectional capacities be reconciled with recurrent longitudinal decompensation?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}, {kind: "edge-transform", id: "assessment-input-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["treating-clinician"]
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"The treating clinician independently confirms, rejects, or qualifies every proposition.",
			"Evaluation-specific wording must not be written back into the normalized evidence world as fact.",
		]
	}
	invariants: [
		"diagnosis labels are insufficient without concrete incapacity and failure evidence",
		"evaluation-specific administrative cutoffs remain runtime parameters",
		"later deterioration must remain distinguishable from evidence already present at the selected cutoff",
		"root-bound deliverables remain candidates until separately admitted and qualified",
	]
}
