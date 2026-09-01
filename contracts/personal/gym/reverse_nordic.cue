package gym

#ReverseNordicProfile: #ExerciseProfile & {
	id:   "reverse-nordic"
	name: "Reverse Nordic"
	requiredConstraints: [
		"hips-torso-stack",
		"pelvic-control",
		"lumbar-substitution-avoided",
		"rib-flare-control",
	]
	optionalConstraints: ["femoral-rotation-control"]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "upright controlled start"},
		{id: "R1", order: 1, label: "short controlled lean"},
		{id: "R2", order: 2, label: "moderate controlled lean"},
		{id: "R3", order: 3, label: "deep controlled lean"},
		{id: "R4", order: 4, label: "prescribed full working excursion"},
	]
	setupDimensions: ["knee-padding", "foot-position", "knee-spacing", "assistance"]
	supportedMetrics: ["reps", "eccentric-duration", "concentric-reversal-duration", "knee-angle", "knee-separation-angle", "hip-angle", "torso-angle"]
	videoPerspectives: ["front", "left-side", "right-side", "oblique"]
}
