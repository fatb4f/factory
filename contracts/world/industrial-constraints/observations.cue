package industrialconstraints

#Observation: close({
	kind:            "observation"
	id:              #RecordID
	observationType: string
	subject?:        #EntityRef
	value?:          #TypedValue
	provenance:      #Provenance
	evidence?:       [...#RecordRef]
})

#ObservedParty: close({
	label:      string
	entityKind?: #EntityKind
})

#EventObservation: close({
	kind:      "event-observation"
	id:        #RecordID
	eventKind: #EventKind
	headline:  string
	actors:    [...#ObservedParty]
	subjects:  [...#ObservedParty]
	occurredAt?:  #Timestamp
	announcedAt?: #Timestamp
	relevance: close({
		geographies:       [...#GeographyScope]
		industrialSurfaces: [...#IndustrialSurface] & [_, ...]
		disposition:       #WatchDisposition
	})
	provenance: #Provenance & {
		publisher:       string
		observedSurface: string
	}
	evidence: [...#RecordRef] & [_, ...]
})

#Event: close({
	kind:        "event"
	id:          #RecordID
	eventKind:   #EventKind
	actors:      [...#EntityRef]
	subjects:    [...#EntityRef]
	occurredAt?: #Timestamp
	announcedAt?: #Timestamp
	provenance:  #Provenance
	evidence?:   [...#RecordRef]
})

#Measurement: close({
	kind:       "measurement"
	id:         #RecordID
	subject:    #EntityRef
	metric:     string
	value:      number
	unit:       string
	interval?: close({
		start?: #Timestamp
		end?:   #Timestamp
	})
	provenance: #Provenance
	evidence?:  [...#RecordRef]
})
