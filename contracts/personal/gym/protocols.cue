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
		produces: [{id: "energy-available"}, {id: "cognitive-available"}, {id: "gait-state"}, {id: "ankle-push-off-state"}]
		phase: "recovery"
		version: "1"
	}
})
