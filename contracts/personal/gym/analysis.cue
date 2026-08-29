package gym

#MechanicalAdmission: "clean" | "marginal" | "exceeded" | "unknown"
#RecoveryCostLevel: "low" | "moderate" | "high" | "exceeded" | "unknown"
#ProgressEligibility: "eligible" | "hold" | "reduce" | "provisional" | "unknown"
#Direction: "improved" | "unchanged" | "regressed" | "unknown"

#CapacityVector: close({
	assistanceKind?:  string
	assistanceLevel?: string
	externalLoad?:    #ExternalLoad
	rangeStage?:      string
	rangeOrder?:      int & >=0
	reps?:            int & >=0
	eccentricS?:      number & >=0
})

#ExposureAssessment: close({
	exposure:   #ExposureID
	mechanical: #MechanicalAdmission
	capacity:   #CapacityVector
	sources:    [...#ObservationRef]
})

#RecoverySummary: close({
	checkpointCount: int & >=0
	energyDrop?:     #Ordinal0to4
	cognitiveDrop?:  #Ordinal0to4
	maxDoms?:        #Ordinal0to5
	taskInitiationWorst?: "normal" | "impaired" | "severely-impaired" | "unobserved"
	subjectiveWorst?:     "normal" | "taxed" | "crashed" | "unobserved"
	movementAlteredThroughHours?: number & >=0
	recoveredByHours?:             number & >=0
})

#RecoveryAssessment: close({
	level:   #RecoveryCostLevel
	summary: #RecoverySummary
	sources: [...#RecoveryRef]
})

#SessionAssessment: close({
	session:             #SessionID
	exposures:           [...#ExposureAssessment]
	recovery?:           #RecoveryAssessment
	recoveryComplete:    bool
	progressEligibility: #ProgressEligibility
})
