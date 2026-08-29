package gym

#GHRProfile: #ExerciseProfile & {
	id:   "ghr"
	name: "Glute-ham raise"
	requiredConstraints: [
		"hips-torso-stack",
		"pelvic-control",
		"lumbar-substitution-avoided",
	]
	optionalConstraints: [
		"femoral-rotation-control",
	]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "supported or isometric region"},
		{id: "R1", order: 1, label: "short controlled excursion"},
		{id: "R2", order: 2, label: "moderate controlled excursion"},
		{id: "R3", order: 3, label: "near-horizontal controlled excursion"},
		{id: "R4", order: 4, label: "prescribed full working excursion"},
	]
	setupDimensions: [
		"assistance",
		"knee-pad-position",
		"ankle-anchor-position",
		"machine",
	]
	supportedMetrics: [
		"reps",
		"eccentric-duration",
		"knee-angle",
		"hip-angle",
		"torso-angle",
	]
	videoPerspectives: ["left-side", "right-side", "oblique"]
}
