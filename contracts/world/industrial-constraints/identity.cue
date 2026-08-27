package industrialconstraints

#SourceIdentity: close({
	source:     #SourceID
	channel:    #ChannelID
	externalID: string
})

#SourceAlias: close({
	identity: #SourceIdentity
	label?:   string
})

#IdentityCandidate: close({
	id:         string
	entityKind: #EntityKind
	label:      string
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
	id:         #EntityID
	entityKind: #EntityKind
	identity:   #CanonicalEntityIdentity & {entityID: id, entityKind: entityKind}
	provenance?: #Provenance
})
