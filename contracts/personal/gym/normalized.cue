package gym

#EffectiveSetup: close({
	variant?:   string
	equipment?: string
	lever?:     string
	support?:   string
	note?:      string
})

#NormalizedExposure: close({
	session:      #SessionID
	exposure:     #ExposureID
	exercise:     #ExerciseRef
	sequence?:    int & >=1
	effectiveSetup?: #EffectiveSetup
	dose?:        #Dose
	range?:       #RangeObservation
	constraints?: [...#ConstraintObservation]
	limiter?:     #Limiter
	measurements?: [...#MeasurementRef]
	media?:        [...#MediaRef]
	sourceObservations: [...#ObservationRef] & [_, ...]
})

#NormalizedSession: close({
	id:            #SessionID
	start:         #SessionStart
	exposures:     [...#NormalizedExposure]
	close?:        #SessionClose
	recovery?:     [...#RecoveryCheckpoint]
	measurements?: [...(#Measurement | #DualLoadSample)]
	media?:        [...#MediaArtifact]
	supersessions?: [...#Supersession]
})
