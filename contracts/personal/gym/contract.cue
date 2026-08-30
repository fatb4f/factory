package gym

gymContract: close({
	id:      "personal.gym"
	version: "0.4.0"

	authority: close({
		capture:     "append-only observations and evidence"
		normalized:  "derived canonical session state"
		mechanics:   "functional movement, objective, demand, contribution, and contextual role semantics"
		admission:   "mechanical and comparison compatibility decisions"
		analysis:    "deterministic evidence-bearing derived assertions and projections"
		program:     "target graph, evidence requirements, equilibrium model, and controller policy"
		projections: "disposable JSON Schema, Python, relational, and analytical views"
	})

	invariants: [
		"observations do not contain diagnostic or causal assertions",
		"unknown is not equivalent to false, normal, or zero",
		"corrections append supersession records",
		"mechanical quality and recovery cost are co-equal acceptance criteria",
		"raw dual-load values precede asymmetry projections",
		"video artifacts precede video-derived measurements",
		"associations are non-causal unless a separate future authority explicitly admits causality",
		"exercise identity is an observation and stimulation instrument rather than the analytical primitive",
		"mechanical demand is not assumed to be muscular demand",
		"mechanical role is derived from contextual mechanical effect rather than permanently attached to a contributor",
		"biomechanical chains are human-facing anatomical projections rather than semantic authority",
		"functional groups are projections over movement, phase, objective, contribution, and role",
		"demand satisfaction and contribution allocation are separate state variables",
		"task success does not imply nominal contribution distribution",
		"compensation is an alternative task solution and dysfunction requires an explicit versioned qualification policy",
		"external models and devices produce evidence through capability adapters and never become Gym semantic authority",
		"derived values carry source class, evidence, uncertainty when available, and model or method version when applicable",
		"every primary program target requires an observation path and a controllable exposure path",
		"equilibrium is a vector of comparable demand residual, contribution-distribution, bilateral, reciprocal, load-distribution, limiter, compensation, and recovery relations rather than one scalar score",
		"raw unlike exercise outputs are never divided directly to construct cross-group equilibrium ratios",
		"signed asymmetry is preserved so redistribution direction is not erased",
		"local capacity gain alone cannot satisfy restoration while redistribution equilibrium is unsupported or regressing",
		"equilibrium advancement requires mechanically admitted exposures and recovery evidence",
		"comparison admission is required before normalized capacities participate in a relation",
		"ordinary controller progression changes one ScaleAxis coordinate per decision unless coupled change is explicitly authorized",
		"historical Tier-0 capture remains valid when later semantic admission fields are absent",
		"time triggers review and never advances a block by itself",
	]

	projectionTargets: ["json-schema", "pydantic", "ibis", "malloy", "duckdb", "bigquery"]
})
