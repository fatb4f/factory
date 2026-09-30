package ivac

ivacContract: close({
	id:      "personal.ivac"
	version: "0.4.0"

	authority: close({
		graph:         "canonical actors, authorities, claim axes, evidence artifacts, findings, mandates, grounds, submissions, decisions, and state snapshots"
		transitions:   "typed state-transition primitives, admission decisions, and transition grants"
		integrity:     "referential, actor-capability, authority, trace-continuity, adjudication-boundary, and clinical-evidence qualification"
		evidenceWorld: "normalized admitted observations, episodes, capacities, interventions, provenance, and typed clinical relations"
		profile:       "deterministic non-authoritative subject-profile projection over the admitted evidence world"
		portability:   "artifact envelopes, consumer profiles, disclosure gates, and purpose-bound derivative packages for downstream legal/administrative qualification"
		transforms:    "typed graph-edge and logical-index transform semantics lowered through factory.analytics-ir to Ibis"
		evaluations:   "evaluation-specific profile selectors, relation/index dependencies, questions, authority boundaries, and assessment contracts"
		projections:   "generated disposable relational and analytical views"
	})

	invariants: [
		"source records and external reports are evidence providers and never become IVAC semantic authority",
		"medical experts may emit medical findings but may not manufacture legal review grounds or adjudicative outcomes",
		"legal representatives may commission, qualify, bind, submit, and supplement but may not manufacture medical findings or adjudicative outcomes",
		"only an adjudicative authority may transition the recognized decision state",
		"candidate claim axes remain hypotheses until evidence and qualification gates are satisfied",
		"unknown is not equivalent to false, rejected, absent, or zero",
		"successful transition decisions issue grants; downstream transitions consume grants rather than inferring success from document existence",
		"provider identities are runtime bindings and do not define semantic roles",
		"relational rows are projections of canonical graph state and never independent authority",
		"normalized subject profiles are deterministic read models and never replace their admitted evidence-world inputs",
		"logical indices are derived relations and never backend physical-index authority",
		"edge and index transforms are projections and do not upgrade assertion or admission state",
		"evaluation outputs do not mutate the evidence world; findings require the authority declared by the review plant",
		"causal clinical predicates require explicit qualified clinical attribution rather than temporal sequence alone",
		"evaluation-specific temporal cutoffs and lexical/report rules remain outside the canonical evidence world",
		"IVAC review is one consumer of the normalized legal-medical evidence layer and does not bound its downstream reuse",
		"downstream reuse requires an explicit forum, purpose, consumer profile, and purpose-bound subset; whole-corpus disclosure is never inferred",
		"source records, clinical expert opinions, filed legal material, and legal work product retain distinct portability and protection semantics",
		"potential confidentiality or privilege is never waived or inferred from artifact existence or class; counsel review remains an explicit disclosure gate",
		"reuse never promotes a private expert opinion into a forum-specific statutory assessment, admissibility ruling, or adjudicative outcome",
		"downstream legal qualification may select or requalify existing material but may not change clinical meaning, attribution, provenance, or uncertainty",
		"Ibis and execution backends realize admitted projection intent and never define IVAC semantics",
		"TAQ is modeled as an escalation boundary rather than an assumed continuation",
		"public fixtures must remain de-identified and must not contain real claimant medical or identifying facts",
	]

	projectionTargets: ["relational", "json-schema", "pydantic", "ibis"]
})
