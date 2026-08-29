package gym

#CurtseyStepdownProfile: #ExerciseProfile & {
	id:   "curtsey-stepdown"
	name: "Curtsey step-down"
	requiredConstraints: [
		"pelvic-control",
		"pelvic-rotation-control",
		"hip-hike-control",
		"femoral-rotation-control",
	]
	optionalConstraints: ["hips-torso-stack", "rib-flare-control"]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "supported shallow step-down"},
		{id: "R1", order: 1, label: "short controlled step-down"},
		{id: "R2", order: 2, label: "moderate controlled step-down"},
		{id: "R3", order: 3, label: "deep controlled step-down"},
		{id: "R4", order: 4, label: "prescribed full working excursion"},
	]
	setupDimensions: ["step-height", "hand-support", "external-load", "stance-width"]
	supportedMetrics: ["reps", "step-height", "knee-angle", "hip-angle", "pelvic-angle"]
	videoPerspectives: ["front", "rear", "oblique"]
}
