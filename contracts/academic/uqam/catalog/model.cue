package uqamcatalog

import (
	state "github.com/fatb4f/factory/contracts/state"
	unit "github.com/fatb4f/factory/contracts:unit"
)

#NonEmptyString: string & != ""
#URL:            string & =~"^https?://"

#ObservationID: string & =~"^obs:[a-z0-9][a-z0-9._:-]*$"
#EntityID:      string & =~"^uqam:[a-z0-9][a-z0-9._:-]*$"
#RelationID:    string & =~"^rel:[a-z0-9][a-z0-9._:-]*$"

#SourceObservation: close({
	id:               #ObservationID
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
#Audience: "student" | "staff" | "researcher" | "alumni" | "public"

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
	evidence: [...#ObservationID] & [_, ...]
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
	evidence:     [...#ObservationID] & [_, ...]
})

#ObservationSet: close({observations: [...#SourceObservation]})
#EntitySet: close({entities: [...#Entity]})
#RelationSet: close({relations: [...#Relation]})

#ShardKind: "observations" | "entities" | "relations"
#ShardReference: close({
	kind:   #ShardKind
	path:   unit.#RepositoryPath
	digest: state.#SHA256
	rows:   int & >=0
})
#ObservationShardReference: #ShardReference & {kind: "observations"}
#EntityShardReference:      #ShardReference & {kind: "entities"}
#RelationShardReference:    #ShardReference & {kind: "relations"}

// The admitted normalized artifact is an index. Its digest transitively seals
// every shard through these digest-qualified references.
#NormalizedSnapshot: close({
	task_id:     #TaskID
	schema:      #SchemaID
	observed_at: #NonEmptyString
	observations:    #ObservationShardReference
	entity_shards:   [...#EntityShardReference] & [_, ...]
	relation_shards: [...#RelationShardReference]
})
