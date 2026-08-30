package gym

#ProtocolID: string
#ProtocolRef: close({id: #ProtocolID})
#SessionPhase: "baseline" | "pre-session" | "in-session" | "post-session" | "recovery"

#Protocol: close({
	id:       #ProtocolID
	label:    string
	produces: [...#MetricRef]
	phase?:   #SessionPhase
	exercise?: #ExerciseRef
	requirements?: [...string]
	version:  string
})

protocols: close({
	"session-mechanical-capture-v1": #Protocol & {
		id: "session-mechanical-capture-v1"
		label: "Session mechanical capture"
		produces: [{id: "rep-count"}, {id: "constraint-state"}, {id: "limiter-onset"}, {id: "clean-rom-stage"}, {id: "mechanical-admission"}]
		phase: "in-session"
		requirements: ["establish effective setup once", "capture dose deltas", "record constraint failures or marginal states", "record limiter when observed", "unknown remains unobserved"]
		version: "1"
	}
	"dual-scale-neutral-stance-v1": #Protocol & {
		id: "dual-scale-neutral-stance-v1"
		label: "Dual-scale neutral stance"
		produces: [{id: "left-scale-load"}, {id: "right-scale-load"}, {id: "stance-asymmetry-ratio"}, {id: "stance-asymmetry-variability"}]
		phase: "baseline"
		requirements: ["same scales", "same unit", "repeatable stance width", "repeatable foot orientation", "no external hand support", "stable reading window", "repeat repeated samples before estimating variability"]
		version: "1"
	}
	"ghr-side-video-v1": #Protocol & {
		id: "ghr-side-video-v1"
		label: "GHR side video"
		produces: [{id: "clean-rom-stage"}, {id: "eccentric-duration"}, {id: "constraint-state"}]
		phase: "in-session"
		exercise: {id: "ghr"}
		requirements: ["side perspective", "machine reference visible", "full working excursion visible", "entire repetition visible"]
		version: "1"
	}
	"rom-control-baseline-v1": #Protocol & {
		id: "rom-control-baseline-v1"
		label: "Controlled versus available range baseline"
		produces: [{id: "available-rom-stage"}, {id: "clean-rom-stage"}, {id: "controlled-rom-fraction"}]
		phase: "baseline"
		requirements: ["match movement and range-stage definitions", "record available reference range separately from loaded clean range", "do not infer passive tissue limits from the ratio"]
		version: "1"
	}
	"capacity-equilibrium-review-v1": #Protocol & {
		id: "capacity-equilibrium-review-v1"
		label: "Cross-region capacity equilibrium review"
		produces: [
			{id: "normalized-capacity-index"},
			{id: "bilateral-capacity-asymmetry"},
			{id: "reciprocal-capacity-ratio"},
			{id: "anterior-posterior-capacity-ratio"},
			{id: "distal-proximal-capacity-ratio"},
			{id: "frontal-sagittal-capacity-ratio"},
			{id: "limiter-concentration"},
			{id: "recovery-normalized-capacity-state"},
		]
		phase: "recovery"
		requirements: [
			"use finalized sessions only",
			"use mechanically admitted exposures for capacity comparison",
			"compare like protocols or baseline-normalized indices rather than raw unlike exercise outputs",
			"preserve side and chain identity",
			"require recovery evidence before declaring redistribution progress",
			"treat agonist-antagonist and cross-chain ratios as operational equilibrium metrics, not universal diagnostic thresholds",
		]
		version: "1"
	}
	"recovery-check-v1": #Protocol & {
		id: "recovery-check-v1"
		label: "Recovery checkpoint"
		produces: [{id: "energy-available"}, {id: "cognitive-available"}, {id: "gait-state"}, {id: "ankle-push-off-state"}, {id: "energy-drop"}, {id: "cognitive-drop"}, {id: "recovered-by-hours"}, {id: "recovery-cost"}]
		phase: "recovery"
		requirements: ["same session identity", "elapsed time or timestamp", "sparse honest checkpoints allowed"]
		version: "1"
	}
})
