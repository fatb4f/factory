package ivaceval

downstreamReuseContract: #EvaluationContract & {
	id:      "downstream-reuse"
	version: "1.0.0"
	purpose: "downstream-reuse"
	input: {
		profile: {
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "objective-tests", "support-dependency", "context"]
			temporal: {mode: "all"}
		}
		relations: ["evidenceArtifacts", "evidenceAxes", "findings", "findingEvidence", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
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
		{id: "purpose-scope", domain: "reuse-scope", question: "Which admitted source records, clinical findings, and existing legal materials are responsive to the declared downstream purpose without expanding their original authority?", dependsOn: [{kind: "edge-transform", id: "evidence-neighborhood"}, {kind: "index-transform", id: "edge-by-evidence"}], outputs: ["reuse-candidate", "coverage-gap"]},
		{id: "clinical-scope", domain: "clinical-scope", question: "Which expert opinions remain within their original clinical mandate and which require a new or supplemental expert mandate for the downstream question?", dependsOn: [{kind: "edge-transform", id: "temporal-window"}, {kind: "edge-transform", id: "contradiction-surface"}], outputs: ["reuse-candidate", "disclosure-risk", "coverage-gap"]},
		{id: "protection", domain: "disclosure-protection", question: "Which candidate materials require explicit counsel review for confidentiality, privilege, waiver, or litigation-strategy exposure before any disclosure selection is approved?", dependsOn: [{kind: "index-transform", id: "edge-by-evidence"}], outputs: ["disclosure-risk", "coverage-gap"]},
		{id: "forum-fit", domain: "forum-requalification", question: "Which candidate materials require forum-specific requalification, a statutory assessment, or a distinct evidentiary foundation before they can be relied upon?", dependsOn: [{kind: "edge-transform", id: "evidence-neighborhood"}, {kind: "edge-transform", id: "contradiction-surface"}], outputs: ["reuse-candidate", "disclosure-risk", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["legal-representative"]
		mayEmit: ["reuse-candidate", "disclosure-risk", "coverage-gap"]
		mustNotEmit: ["clinical-assessment", "finding-candidate", "legal-ground-candidate"]
		notes: [
			"Reuse assessment selects and qualifies existing material; it does not manufacture clinical findings or determine adjudicative outcomes.",
			"Potential confidentiality or privilege is a disclosure gate, not a property inferred solely from artifact class.",
			"A private expert report is never promoted into a forum-specific statutory assessment by reuse projection.",
		]
	}
	invariants: [
		"the downstream forum and purpose are runtime parameters on the evaluation instance",
		"clinical meaning, attribution, provenance, and uncertainty are preserved",
		"whole-corpus disclosure is not a valid default selection",
		"admissibility and waiver remain not determined until the competent legal authority reviews them",
	]
}
