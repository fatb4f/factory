package industrialconstraints

#Relation: close({
	kind:       "relation"
	id:         #RecordID
	subject:    #EntityRef
	predicate:  #Predicate
	object:     #EntityRef | #TypedValue
	provenance: #Provenance
	evidence:   [...#RecordRef]
})

#Record:
	#Document |
	#Entity |
	#Observation |
	#Event |
	#Measurement |
	#Relation |
	#EvidenceClaim |
	#Assessment |
	#ConstraintClaim
