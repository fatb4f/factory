package ivaceval

legalReviewContract: #EvaluationContract & {
	id:      "legal-review"
	version: "1.0.0"
	purpose: "legal-review"
	input: {
		profile: {
			partitions: ["functional-events", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["evidenceArtifacts", "findings", "findingEvidence", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "evidence-neighborhood"},
			{id: "contradiction-surface"},
			{id: "temporal-window"},
		]
		indices: [
			{id: "edge-by-subject"},
			{id: "edge-by-object"},
			{id: "edge-by-evidence"},
		]
		temporalOwner: "evaluation"
	}
	questions: [
		{id: "grounds", domain: "review-ground", question: "Which admitted clinical findings and evidence support a review ground without changing their medical meaning?", dependsOn: [{kind: "edge-transform", id: "evidence-neighborhood"}, {kind: "index-transform", id: "edge-by-evidence"}], outputs: ["legal-ground-candidate", "coverage-gap"]},
		{id: "gaps", domain: "record-gap", question: "Which missing records, expert opinions, or unresolved contradictions prevent a ground from being safely bound for submission?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}], outputs: ["coverage-gap"]},
		{id: "scope", domain: "scope", question: "Which claim axes are supported for submission and which remain hypotheses or require further qualification?", dependsOn: [{kind: "edge-transform", id: "temporal-window"}, {kind: "index-transform", id: "edge-by-subject"}], outputs: ["legal-ground-candidate", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["legal-representative"]
		mayEmit: ["legal-ground-candidate", "coverage-gap"]
		mustNotEmit: ["clinical-assessment", "finding-candidate"]
		notes: [
			"Legal review consumes admitted medical findings but may not manufacture or upgrade medical findings.",
			"Only adjudication changes the recognized decision state.",
		]
	}
	invariants: [
		"medical meaning and attribution are preserved across legal qualification",
		"record gaps remain gaps rather than negative medical findings",
		"claim-axis state is not upgraded by legal projection alone",
	]
}
