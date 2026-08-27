package industrialconstraints

#RecordID: string
#EntityID: string
#SourceID: string
#ChannelID: string
#RevisionID: string
#Timestamp: string

#EntityKind:
	"organization" |
	"facility" |
	"project" |
	"technology" |
	"product-component" |
	"infrastructure-asset" |
	"government-program" |
	"geography" |
	"industry" |
	"dataset-source"

#Predicate:
	"located-in" |
	"operated-by" |
	"owned-by" |
	"produces" |
	"supplies" |
	"consumes" |
	"requires" |
	"depends-on" |
	"substitutable-by" |
	"funded-by" |
	"procured-by" |
	"regulated-by" |
	"announced-by" |
	"participates-in" |
	"projects-to"

#EventKind:
	"capacity-expansion-announced" |
	"plant-construction-started" |
	"grant-awarded" |
	"tender-issued" |
	"interconnection-delayed" |
	"facility-commissioned" |
	"production-curtailed"

#RecordKind:
	"document" |
	"entity" |
	"observation" |
	"event" |
	"measurement" |
	"relation" |
	"claim" |
	"assessment" |
	"constraint-claim"

#RecordRef: close({
	kind: #RecordKind
	id:   #RecordID
})

#EntityRef: close({
	id: #EntityID
})

#Provenance: close({
	source:      #SourceID
	channel:     #ChannelID
	recordID:    string
	revision:    #RevisionID
	observedAt?: #Timestamp
	acquiredAt:  #Timestamp
})

#TypedValue:
	close({kind: "string", value: string}) |
	close({kind: "number", value: number}) |
	close({kind: "boolean", value: bool}) |
	close({kind: "timestamp", value: #Timestamp})
