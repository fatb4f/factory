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

#Delta: close({added: [...#NormalizedEvent], changed: [...#ChangedEvent], removed: [...#NormalizedEvent]})
#NoReportableDelta: #Delta & {added: [], changed: []}
#AddedDelta: #Delta & {added: [...#NormalizedEvent] & [_, ...]}
#ChangedDelta: #Delta & {changed: [...#ChangedEvent] & [_, ...]}
#ReportableDelta: #AddedDelta | #ChangedDelta

#Outcome: "baseline_established" | "no_change" | "new_matches" | "source_gap" | "comparison_gap" | "state_conflict"
#BootstrapComparisonResult: close({comparison_state: state.#BootstrapComparisonState})
#ComparableComparisonResult: close({comparison_state: state.#ComparableComparisonState, delta: #Delta})
#InvalidatedComparisonResult: close({comparison_state: state.#InvalidatedComparisonState})
#ComparisonResult: #BootstrapComparisonResult | #ComparableComparisonResult | #InvalidatedComparisonResult

#BaselineEstablishedDecision: close({outcome: "baseline_established", baseline_action: "advance", reported_event_keys: [], reason: #NonEmptyString})
#NoChangeDecision: close({outcome: "no_change", baseline_action: "advance", reported_event_keys: [], reason: #NonEmptyString})
#NewMatchesDecision: close({outcome: "new_matches", baseline_action: "advance", reported_event_keys: [...#NonEmptyString] & [_, ...], reason: #NonEmptyString})
#SourceGapDecision: close({outcome: "source_gap", baseline_action: "hold", reported_event_keys: [], reason: #NonEmptyString})
#ComparisonGapDecision: close({outcome: "comparison_gap", baseline_action: "hold", reported_event_keys: [], reason: #NonEmptyString})
#StateConflictDecision: close({outcome: "state_conflict", baseline_action: "hold", reported_event_keys: [], reason: #NonEmptyString})
#Decision: #BaselineEstablishedDecision | #NoChangeDecision | #NewMatchesDecision | #SourceGapDecision | #ComparisonGapDecision | #StateConflictDecision

comparisonPolicy: close({
	identity: close({
		preferred: ["source-event-id", "primary-url", "organizer-title-source"]
		mutableFieldsExcluded: ["kind", "starts_at", "ends_at", "location", "registration_status", "scope", "organizer_entity_id", "venue_entity_id"]
	})
	materialChanges: ["date-time", "location", "registration", "scope", "details"]
	catalogProjectionChangePolicy: "derived-context-only-not-reportable-by-itself"
	removedEventPolicy: "state-only-unless-primary-source-confirms-cancellation"
	firstComparableState: "bootstrap"
	firstRunOutcome: "baseline_established"
})
