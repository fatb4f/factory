package uqamevents

import state "github.com/fatb4f/factory/contracts/state"

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

#IdentityBasis:
	"source-event-id" |
	"primary-url" |
	"organizer-title-source"

#EventIdentity: close({
	key:             #NonEmptyString
	basis:           #IdentityBasis
	organizer:       #NonEmptyString
	canonical_title: #NonEmptyString
	primary_url:     #URL
	source_event_id?: #NonEmptyString
})

#RegistrationStatus:
	"open" |
	"closed" |
	"waitlist" |
	"not-required" |
	"unknown"

#NormalizedEvent: close({
	identity: #EventIdentity

	title:      #NonEmptyString
	starts_at:  #NonEmptyString
	ends_at?:   #NonEmptyString
	location?:  #NonEmptyString
	scope?:     #NonEmptyString
	registration_status: #RegistrationStatus

	primary_url: #URL
	evidence:    [...#SourceObservation] & [_, ...]
	content_digest: state.#SHA256
})
