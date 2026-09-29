package ivaceval

speechLanguageAssessmentContract: #ProfessionalAssessmentContract & {
	id:      "speech-language-assessment"
	version: "1.0.0"
	purpose: "speech-language-assessment"
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
			partitions: ["conditions", "symptoms", "functional-events", "substance-use", "objective-tests", "context"]
			temporal: {mode: "all"}
		}
		relations: ["observations", "observationEvidence", "episodes", "episodeEvidence", "capacities", "capacityEvidence", "clinicalRelations", "relationEvidence", "graphEdges", "graphIndices"]
		edgeTransforms: [
			{id: "assessment-input-surface"},
			{id: "assessment-evidence-links"},
			{id: "capacity-impact"},
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
		{id: "communication-phenotype", domain: "communication", question: "What present speech, language, voice, fluency, motor-speech, or cognitive-communication impairment is supported by examination, as applicable?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}, {kind: "index-transform", id: "assessment-by-subject"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "objective-profile", domain: "measurement", question: "Which standardized or structured measures objectively characterize the present communication deficit and its severity?", dependsOn: [{kind: "index-transform", id: "assessment-by-evidence"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "onset-persistence", domain: "time", question: "What does the admitted record support regarding onset, persistence, variability, and course of the communication difficulty?", dependsOn: [{kind: "edge-transform", id: "temporal-window"}, {kind: "edge-transform", id: "assessment-input-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "functional-impact", domain: "function", question: "How does the communication impairment affect ordinary conversation, task execution, education, work, healthcare interaction, or other daily communication demands?", dependsOn: [{kind: "edge-transform", id: "capacity-impact"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
		{id: "differential", domain: "differential", question: "Which alternative speech-language, neurological, psychiatric, substance-related, structural, or situational explanations remain plausible or unresolved?", dependsOn: [{kind: "edge-transform", id: "contradiction-surface"}], outputs: ["clinical-assessment", "coverage-gap"]},
		{id: "prognosis", domain: "prognosis", question: "What prognosis, treatment recommendations, accommodations, or further referrals are supported within speech-language pathology scope?", dependsOn: [{kind: "edge-transform", id: "assessment-input-surface"}], outputs: ["clinical-assessment", "finding-candidate", "coverage-gap"]},
	]
	boundary: {
		allowedEvaluatorKinds: ["clinical-expert"]
		mayEmit: ["clinical-assessment", "finding-candidate", "coverage-gap"]
		mustNotEmit: ["legal-ground-candidate"]
		notes: [
			"The assessment characterizes communication impairment within speech-language pathology scope.",
			"Temporal consistency with a prior event does not by itself establish medico-legal causation.",
		]
	}
	invariants: [
		"speech-language phenotype, functional impact, etiology, and legal causation remain separate questions",
		"objective testing and patient-reported communication failures retain separate provenance",
		"unsupported etiological questions remain coverage gaps",
	]
}
