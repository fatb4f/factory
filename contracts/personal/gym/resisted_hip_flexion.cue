package gym

#ResistedHipFlexionProfile: #ExerciseProfile & {
	id:   "resisted-hip-flexion"
	name: "Resisted hip flexion"
	requiredConstraints: [
		"pelvic-control",
		"lumbar-substitution-avoided",
		"rib-flare-control",
	]
	optionalConstraints: [
		"pelvic-rotation-control",
		"dorsiflexion-control",
	]
	rangeRequired: true
	rangeStages: [
		{id: "R0", order: 0, label: "supported short-range knee drive"},
		{id: "R1", order: 1, label: "controlled knee drive below parallel"},
		{id: "R2", order: 2, label: "controlled knee drive to parallel"},
		{id: "R3", order: 3, label: "deep controlled knee drive"},
		{id: "R4", order: 4, label: "prescribed full working hip-flexion excursion"},
	]
	setupDimensions: ["loading-method", "laterality", "ankle-attachment", "stance-side", "cable-height", "external-load"]
	supportedMetrics: ["reps", "hip-angle", "knee-angle", "external-load", "eccentric-duration"]
	videoPerspectives: ["front", "left-side", "right-side", "oblique"]
}
