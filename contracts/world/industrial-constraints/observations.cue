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
