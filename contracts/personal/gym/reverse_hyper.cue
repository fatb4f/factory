package gym

#ReverseHyperProfile: #ExerciseProfile & {
	id:   "reverse-hyper"
	name: "Reverse hyperextension"
	requiredConstraints: [
		"pelvic-control",
		"lumbar-substitution-avoided",
	]
	optionalConstraints: [
		"hips-torso-stack",
		"femoral-rotation-control",
	]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "minimal decompression swing"},
		{id: "R1", order: 1, label: "short controlled swing"},
		{id: "R2", order: 2, label: "moderate controlled swing"},
		{id: "R3", order: 3, label: "full controlled working swing"},
	]
	setupDimensions: [
		"external-load",
		"pelvis-pad-position",
		"ankle-attachment",
		"grip-position",
		"machine",
	]
	supportedMetrics: [
		"reps",
		"eccentric-duration",
		"hip-angle",
		"pelvic-angle",
		"swing-amplitude",
	]
	videoPerspectives: ["left-side", "right-side", "rear", "oblique"]
}
