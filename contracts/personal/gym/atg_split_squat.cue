package gym

#ATGSplitSquatProfile: #ExerciseProfile & {
	id:   "atg-split-squat"
	name: "ATG split squat"
	requiredConstraints: [
		"pelvic-control",
		"femoral-rotation-control",
	]
	optionalConstraints: [
		"hips-torso-stack",
		"rib-flare-control",
		"lumbar-substitution-avoided",
	]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "supported elevated shallow split squat"},
		{id: "R1", order: 1, label: "supported elevated controlled depth"},
		{id: "R2", order: 2, label: "elevated deep controlled split squat"},
		{id: "R3", order: 3, label: "reduced elevation or assistance at controlled depth"},
		{id: "R4", order: 4, label: "prescribed flat-ground full working excursion"},
	]
	setupDimensions: ["side", "front-foot-elevation", "hand-support", "rear-foot-position", "external-load"]
	supportedMetrics: ["reps", "front-foot-elevation", "knee-angle", "hip-angle", "pelvic-angle", "external-load"]
	videoPerspectives: ["front", "left-side", "right-side", "oblique"]
}
