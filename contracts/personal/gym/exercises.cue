package gym

#RangeStage: close({
	id:    string
	order: int & >=0
	label: string
})

#ExerciseProfile: close({
	id:                  #ExerciseID
	name:                string
	requiredConstraints: [...string]
	optionalConstraints?: [...string]
	rangeRequired:       bool
	rangeStages?:        [...#RangeStage]
	setupDimensions?:    [...string]
	supportedMetrics?:   [...string]
	videoPerspectives?:  [...string]
})

#CommonMechanicalConstraints: [
	"hips-torso-stack",
	"pelvic-control",
	"lumbar-substitution-avoided",
	"pelvic-rotation-control",
	"hip-hike-control",
	"rib-flare-control",
	"femoral-rotation-control",
]
