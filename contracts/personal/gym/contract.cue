package gym

gymContract: close({
	id:      "personal.gym"
	version: "0.3.0"

	authority: close({
		capture:     "append-only observations and evidence"
		normalized:  "derived canonical session state"
		analysis:    "deterministic derived assertions"
		program:     "target graph, evidence requirements, equilibrium model, and controller policy"
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
		"biomechanical chains are operational reasoning models rather than diagnostic anatomical truth",
		"every primary program target requires an observation path and a controllable exposure path",
		"equilibrium is a vector of comparable bilateral, reciprocal, cross-chain, range-control, load-distribution, limiter, and recovery relations rather than one scalar score",
		"raw unlike exercise outputs are never divided directly to construct cross-chain equilibrium ratios",
		"signed asymmetry is preserved so redistribution direction is not erased",
		"local capacity gain alone cannot satisfy restoration while redistribution equilibrium is unsupported or regressing",
		"equilibrium advancement requires mechanically admitted exposures and recovery evidence",
		"time triggers review and never advances a block by itself",
	]

	projectionTargets: ["duckdb", "ibis"]
})
