package industrialsignals

#SourceIdentity: close({
	source:     string
	channel:    string
	externalID: string
})

#SourceAlias: close({
	identity: #SourceIdentity
	label?:   string
})

#IdentityCandidate: close({
	id:          string
	entityKind:  #EntityKind
	label:       string
	sourceAlias: #SourceAlias
})

#EquivalenceEvidence: close({
	left:     #SourceIdentity
	right:    #SourceIdentity
	evidence: [...#RecordRef] & [_, ...]
})

#CanonicalEntityIdentity: close({
	entityID:            #EntityID
	entityKind:          #EntityKind
	canonicalName:       string
	sourceAliases:       [...#SourceAlias] & [_, ...]
	equivalenceEvidence: [...#EquivalenceEvidence]
	state:               "admitted"
})

#Entity: close({
	kind:       "entity"
	identity:   #CanonicalEntityIdentity
	id:         identity.entityID
	entityKind: identity.entityKind
	provenance?: #Provenance
})

#ActorRoleAssignment: close({
	kind:    "actor-role-assignment"
	id:      #RecordID
	actor:   #EntityRef
	role:    #ActorRole
	surface: #IndustrialSurface
	facility?: #EntityRef
	validDuring?: close({
		start?: #Timestamp
		end?:   #Timestamp
	})
	provenance: #Provenance
	evidence:   [...#RecordRef] & [_, ...]
})
