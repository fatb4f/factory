package gym

#BridgeMarchProfile: #ExerciseProfile & {
	id:   "cross-supported-bridge-march"
	name: "Cross-supported bridge march"
	requiredConstraints: [
		"pelvic-control",
		"pelvic-rotation-control",
		"rib-flare-control",
		"lumbar-substitution-avoided",
	]
	optionalConstraints: ["hips-torso-stack"]
	rangeRequired: false
	setupDimensions: ["support-side", "contralateral-arm-support", "foot-position"]
	supportedMetrics: ["reps", "duration", "pelvic-angle", "hip-height"]
	videoPerspectives: ["front", "oblique"]
}
