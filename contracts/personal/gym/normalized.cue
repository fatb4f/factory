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

	// Additive semantic interpretation. Historical Tier-0 capture remains valid
	// when these fields are absent; it is simply not mechanically admitted yet.
	scalePosition?:       #ScalePosition
	mechanicalAdmission?: #MechanicalAdmissionRef
	demandBasis?:         [...#MechanicalDemandBasis]

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
