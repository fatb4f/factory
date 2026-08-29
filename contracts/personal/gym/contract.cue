package gym

gymContract: close({
	id:      "personal.gym"
	version: "0.1.0"

	authority: close({
		capture:     "append-only observations and evidence"
		normalized:  "derived canonical session state"
		analysis:    "deterministic derived assertions"
		projections: "disposable relational views"
	})

	invariants: [
		"observations do not contain diagnostic or causal assertions",
		"unknown is not equivalent to false, normal, or zero",
		"corrections append supersession records",
		"mechanical quality and recovery cost are co-equal acceptance criteria",
		"raw dual-load values precede asymmetry projections",
		"video artifacts precede video-derived measurements",
		"associations are non-causal unless a separate future authority explicitly admits causality",
	]

	projectionTargets: ["duckdb", "ibis"]
})
