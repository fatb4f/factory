package gym

#CalfRaiseProfile: #ExerciseProfile & {
	id:   "calf-raise-neutral"
	name: "Neutral calf raise"
	requiredConstraints: ["femoral-rotation-control", "pelvic-control"]
	optionalConstraints: ["hips-torso-stack"]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "flat-foot controlled range"},
		{id: "R1", order: 1, label: "short deficit range"},
		{id: "R2", order: 2, label: "moderate deficit range"},
		{id: "R3", order: 3, label: "full controlled deficit-to-rise range"},
	]
	setupDimensions: ["bilateral-unilateral", "support", "external-load", "deficit-height"]
	supportedMetrics: ["reps", "range", "tempo", "ankle-angle"]
	videoPerspectives: ["front", "rear", "side"]
}
