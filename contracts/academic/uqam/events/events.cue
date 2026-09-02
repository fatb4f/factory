package uqamevents

import (
	catalog "github.com/fatb4f/factory/contracts/academic/uqam/catalog"
	state "github.com/fatb4f/factory/contracts/state"
)

#NonEmptyString: string & != ""
#URL:            string & =~"^https?://"

#SourceObservation: close({
	source:           #NonEmptyString
	channel:          #NonEmptyString
	ref:              #NonEmptyString
	observed_surface: #NonEmptyString
	acquired_at:      #NonEmptyString
	content_digest:   state.#SHA256
})

#IdentityBasis: "source-event-id" | "primary-url" | "organizer-title-source"
#EventIdentity: close({
	key:              #NonEmptyString
	basis:            #IdentityBasis
	organizer:        #NonEmptyString
	canonical_title:  #NonEmptyString
	primary_url:      #URL
	source_event_id?: #NonEmptyString
})

#RegistrationStatus: "open" | "closed" | "waitlist" | "not-required" | "unknown"
#EventKind: "academic" | "technical" | "community" | "student-group" | "association" | "cafe" | "career" | "funding" | "support" | "recreation" | "cultural"

#CatalogContext: close({run: catalog.#CatalogRunReference})

#NormalizedEvent: close({
	identity: #EventIdentity
	// Optional in v1 so the existing admitted baseline remains valid.
	kind?: #EventKind
	title:      #NonEmptyString
	starts_at:  #NonEmptyString
	ends_at?:   #NonEmptyString
	location?:  #NonEmptyString
	scope?:     #NonEmptyString
	registration_status: #RegistrationStatus
	// Derived identity projections; never part of stable event identity.
	organizer_entity_id?: catalog.#EntityID
	venue_entity_id?:     catalog.#EntityID
	primary_url:    #URL
	evidence:       [...#SourceObservation] & [_, ...]
	content_digest: state.#SHA256
})
