package gym

gymContract: close({
	id:      "personal.gym"
	version: "0.4.1"

	authority: close({
		capture:     "append-only observations and evidence"
		normalized:  "derived canonical session state"
		mechanics:   "functional movement, objective, demand, contribution, and contextual role semantics"
		admission:   "mechanical and comparison decisions; successful decisions issue transition grants"
		integrity:   "referential and semantic transition qualification over canonical object registries"
		analysis:    "deterministic evidence-bearing derived assertions and projections"
		program:     "target graph, evidence requirements, equilibrium model, and controller policy"
		projections: "generated disposable JSON Schema, Python, relational, and analytical views"
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
		"semantic movement phase context uses PatternPhase identity rather than free-form labels",
		"biomechanical chains are human-facing anatomical projections rather than semantic authority",
		"functional groups are projections over movement, phase, objective, contribution, and role",
		"demand satisfaction and contribution allocation are separate state variables",
		"task success does not imply nominal contribution distribution",
		"compensation is an alternative task solution and dysfunction requires an explicit versioned qualification policy",
		"a compensation observation must resolve to the same movement and phase as its marker",
		"external models and devices are evidence providers and never become Gym semantic authority",
		"normalization, comparison, aggregation, and projection executors compute Gym-defined operations but do not define their meaning",
		"derived values reference first-class evidence records and preserve uncertainty when available",
		"only admitted mechanical decisions may issue MechanicalAdmissionGrant capabilities",
		"normalized capacity is demand-specific and requires a resolved MechanicalAdmissionGrant",
		"multi-demand capacity is represented as a vector; vector-to-scalar aggregation is explicit, evidence-bearing, and versioned",
		"normalization authority resides on NormalizedCapacity and compatible comparison requires matching normalization",
		"only compatible comparison decisions may issue ComparisonAdmissionGrant capabilities",
		"contextual capacity relations require a resolved ComparisonAdmissionGrant",
		"every primary program target requires an observation path and a controllable exposure path",
		"equilibrium is a vector of comparable demand residual, contribution-distribution, bilateral, reciprocal, load-distribution, limiter, compensation, and recovery relations rather than one scalar score",
		"raw unlike exercise outputs are never divided directly to construct cross-group equilibrium ratios",
		"signed asymmetry is preserved so redistribution direction is not erased",
		"local capacity gain alone cannot satisfy restoration while redistribution equilibrium is unsupported or regressing",
		"equilibrium advancement requires mechanically admitted exposures and recovery evidence",
		"ordinary controller progression changes one ScaleAxis coordinate per decision unless coupled change is explicitly authorized",
		"historical Tier-0 capture remains valid when later semantic admission fields are absent",
		"relational row contracts are derived projection qualification targets rather than independent semantic structures",
		"time triggers review and never advances a block by itself",
	]

	projectionTargets: ["json-schema", "pydantic", "ibis", "malloy", "duckdb", "bigquery"]
})
