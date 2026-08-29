package gym

#CopenhagenProfile: #ExerciseProfile & {
	id:   "copenhagen"
	name: "Copenhagen plank"
	requiredConstraints: [
		"hips-torso-stack",
		"pelvic-rotation-control",
		"hip-hike-control",
		"rib-flare-control",
	]
	optionalConstraints: [
		"femoral-rotation-control",
	]
	rangeRequired: false
	setupDimensions: [
		"lever-length",
		"bench-height",
		"support-padding",
		"support-contact",
	]
	supportedMetrics: [
		"reps",
		"duration",
		"pelvic-angle",
		"torso-angle",
		"hip-height",
	]
	videoPerspectives: ["front", "rear", "oblique"]
}
