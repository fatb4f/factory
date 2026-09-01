package uqamcatalog

import state "github.com/fatb4f/factory/contracts/state"

#NonEmptyString: string & != ""
#URL:            string & =~"^https?://"

#EntityID:   string & =~"^uqam:[a-z0-9][a-z0-9._:-]*$"
#RelationID: string & =~"^rel:[a-z0-9][a-z0-9._:-]*$"

#SourceObservation: close({
	source:           #NonEmptyString
	channel:          #NonEmptyString
	ref:              #NonEmptyString
	observed_surface: #NonEmptyString
	acquired_at:      #NonEmptyString
	revision?:        #NonEmptyString
	content_digest?:  state.#SHA256
})

#EntityKind:
	"institution" |
	"academic-unit" |
	"academic-program" |
	"course" |
	"academic-calendar" |
	"academic-policy" |
	"administrative-unit" |
	"student-association" |
	"student-group" |
	"group-category" |
	"student-media" |
	"cafe" |
	"community-space" |
	"service" |
	"platform" |
	"facility" |
	"resource"

#EntityStatus: "active" | "inactive" | "historical" | "unknown"

#Audience:
	"student" |
	"staff" |
	"researcher" |
	"alumni" |
	"public"

#Location: close({
	pavilion?: #NonEmptyString
	room?:     #NonEmptyString
	address?:  #NonEmptyString
})

#Entity: close({
	id:     #EntityID
	kind:   #EntityKind
	name:   #NonEmptyString
	status: #EntityStatus

	category?:    #NonEmptyString
	description?: #NonEmptyString
	primary_url?: #URL
	location?:    #Location
	audiences?:   [...#Audience]

	evidence: [...#SourceObservation] & [_, ...]
})

#RelationType:
	"part-of" |
	"operated-by" |
	"supported-by" |
	"represents" |
	"offers" |
	"offered-by" |
	"serves" |
	"located-at" |
	"publishes" |
	"organizes" |
	"categorized-as" |
	"accessed-via" |
	"discoverable-at"

#Relation: close({
	id:   #RelationID
	type: #RelationType
	from: #EntityID
	to:   #EntityID

	description?: #NonEmptyString
	evidence:     [...#SourceObservation] & [_, ...]
})

#NormalizedSnapshot: close({
	task_id:     #TaskID
	schema:      #SchemaID
	observed_at: #NonEmptyString
	entities:    [...#Entity]
	relations:   [...#Relation]
})
