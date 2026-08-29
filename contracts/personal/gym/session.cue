package gym

#SystemicState: close({
	energyAvailable?:    #Ordinal0to4
	cognitiveAvailable?: #Ordinal0to4
	taskInitiation?:      "normal" | "impaired" | "severely-impaired" | "unobserved"
	sleepiness?:          "normal" | "elevated" | "unobserved"
	subjectiveRecovery?: "normal" | "taxed" | "crashed" | "unobserved"
})

#MovementState: close({
	gait?:          #GaitState
	hinge?:         #AvailabilityState
	kneeFlexion?:   #AvailabilityState
	anklePushOff?:  #AvailabilityState
})

#SessionStart: close({
	kind:       "session-start"
	id:         #ObservationID
	session:    #SessionID
	startedAt:  #Timestamp
	intent:     string
	planned?:   [...#ExerciseRef]
	baseline?:  #SystemicState
	movement?:  #MovementState
	residualDoms?: [string]: #Ordinal0to5
	provenance: #Provenance
})

#SessionClose: close({
	kind:       "session-close"
	id:         #ObservationID
	session:    #SessionID
	closedAt:   #Timestamp
	systemic?:  #SystemicState
	movement?:  #MovementState
	localResponse?: [string]: "none" | "loaded" | "fatigued" | "discomfort" | "unknown"
	events?: [...string]
	provenance: #Provenance
})
