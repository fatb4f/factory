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
		produces: [{id: "left-scale-load"}, {id: "right-scale-load"}, {id: "stance-asymmetry-ratio"}]
		phase: "baseline"
		requirements: ["same scales", "same unit", "repeatable stance width", "repeatable foot orientation", "no external hand support", "stable reading window"]
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
	"recovery-check-v1": #Protocol & {
		id: "recovery-check-v1"
		label: "Recovery checkpoint"
		produces: [{id: "energy-available"}, {id: "cognitive-available"}, {id: "gait-state"}, {id: "ankle-push-off-state"}, {id: "energy-drop"}, {id: "cognitive-drop"}, {id: "recovered-by-hours"}, {id: "recovery-cost"}]
		phase: "recovery"
		requirements: ["same session identity", "elapsed time or timestamp", "sparse honest checkpoints allowed"]
		version: "1"
	}
})
