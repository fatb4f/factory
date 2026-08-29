package gym

#Supersession: close({
	kind:        "supersession"
	id:          #ObservationID
	session:     #SessionID
	supersedes:  string
	replacement: string
	reason?:     string
	provenance:  #Provenance
})

#CaptureRecord:
	#SessionStart |
	#SessionClose |
	#ExposureObservation |
	#RecoveryCheckpoint |
	#Measurement |
	#DualLoadSample |
	#MediaArtifact |
	#Supersession

#CaptureEnvelope: close({
	id:         #CaptureID
	session:    #SessionID
	ingestedAt: #Timestamp
	record:     #CaptureRecord
	rawText?:   string
})
