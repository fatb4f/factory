package gym

#RecoveryCheckpoint: close({
	kind:         "recovery-checkpoint"
	id:           #RecoveryID
	session:      #SessionID
	at?:          #Timestamp
	elapsedHours?: number & >=0
	doms?:        [string]: #Ordinal0to5
	systemic?:    #SystemicState
	movement?:    #MovementState
	measurements?: [...#MeasurementRef]
	media?:        [...#MediaRef]
	provenance:   #Provenance
})
