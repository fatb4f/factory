package ivac

ivacContract: close({
	id:      "personal.ivac"
	version: "0.1.0"

	authority: close({
		graph:       "canonical actors, authorities, claim axes, evidence artifacts, findings, mandates, grounds, submissions, decisions, and state snapshots"
		transitions: "typed state-transition primitives, admission decisions, and transition grants"
		integrity:   "referential, actor-capability, authority, trace-continuity, and adjudication-boundary qualification"
		projections: "generated disposable relational and analytical views"
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
		"TAQ is modeled as an escalation boundary rather than an assumed continuation",
		"public fixtures must remain de-identified",
	]

	projectionTargets: ["relational", "json-schema", "pydantic"]
})
