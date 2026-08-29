package gym

#AnkleInversionEversionProfile: #ExerciseProfile & {
	id:   "ankle-inversion-eversion"
	name: "Ankle inversion / eversion"
	requiredConstraints: ["femoral-rotation-control"]
	optionalConstraints: ["pelvic-control"]
	rangeRequired: false
	setupDimensions: ["band-direction", "band-tension", "ankle-position", "support"]
	supportedMetrics: ["reps", "range", "side", "tempo"]
	videoPerspectives: ["front", "rear"]
}
