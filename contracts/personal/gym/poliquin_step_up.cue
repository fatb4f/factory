package gym

#PoliquinStepUpProfile: #ExerciseProfile & {
	id:   "poliquin-step-up"
	name: "Poliquin step-up"
	requiredConstraints: [
		"pelvic-control",
		"femoral-rotation-control",
	]
	optionalConstraints: [
		"hip-hike-control",
		"rib-flare-control",
	]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "hand-assisted low step"},
		{id: "R1", order: 1, label: "low controlled step-down and return"},
		{id: "R2", order: 2, label: "moderate controlled step height"},
		{id: "R3", order: 3, label: "deep controlled step height"},
		{id: "R4", order: 4, label: "prescribed full working step height"},
	]
	setupDimensions: ["side", "step-height", "wedge-angle", "hand-support", "external-load"]
	supportedMetrics: ["reps", "step-height", "knee-angle", "hip-angle", "pelvic-angle", "external-load"]
	videoPerspectives: ["front", "rear", "left-side", "right-side", "oblique"]
}
