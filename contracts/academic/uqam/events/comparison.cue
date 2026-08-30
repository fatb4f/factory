package uqamevents

import state "github.com/fatb4f/factory/contracts/state"

#MaterialChange:
	"date-time" |
	"location" |
	"registration" |
	"scope" |
	"details"

#ChangedEvent: close({
	key:     #NonEmptyString
	before:  #NormalizedEvent
	after:   #NormalizedEvent
	changes: [...#MaterialChange] & [_, ...]
})

#Delta: close({
	added:   [...#NormalizedEvent]
	changed: [...#ChangedEvent]
	removed: [...#NormalizedEvent]
})

#Outcome:
	"baseline_established" |
	"no_change" |
	"new_matches" |
	"source_gap" |
	"comparison_gap" |
	"state_conflict"

#ComparisonResult: close({
	comparison_state: state.#ComparisonState
	delta?:           #Delta

	if comparison_state.status == "bootstrap" {
		delta?: _|_
	}
	if comparison_state.status == "comparable" {
		delta: #Delta
	}
	if comparison_state.status == "invalidated" {
		delta?: _|_
	}
})

#Decision: close({
	outcome:             #Outcome
	baseline_action:     "advance" | "hold"
	reported_event_keys: [...#NonEmptyString]
	reason:              #NonEmptyString

	if outcome == "baseline_established" {
		baseline_action:     "advance"
		reported_event_keys: []
	}
	if outcome == "no_change" {
		baseline_action:     "advance"
		reported_event_keys: []
	}
	if outcome == "new_matches" {
		baseline_action:     "advance"
		reported_event_keys: [...#NonEmptyString] & [_, ...]
	}
	if outcome == "source_gap" {
		baseline_action:     "hold"
		reported_event_keys: []
	}
	if outcome == "comparison_gap" {
		baseline_action:     "hold"
		reported_event_keys: []
	}
	if outcome == "state_conflict" {
		baseline_action:     "hold"
		reported_event_keys: []
	}
})

comparisonPolicy: close({
	identity: close({
		preferred: [
			"source-event-id",
			"primary-url",
			"organizer-title-source",
		]
		mutableFieldsExcluded: [
			"starts_at",
			"ends_at",
			"location",
			"registration_status",
			"scope",
		]
	})
	materialChanges: [
		"date-time",
		"location",
		"registration",
		"scope",
		"details",
	]
	removedEventPolicy: "state-only-unless-primary-source-confirms-cancellation"
	firstComparableState: "bootstrap"
	firstRunOutcome:      "baseline_established"
})
