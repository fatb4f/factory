package uqameventsfixtures

import events "github.com/fatb4f/factory/contracts/academic/uqam/events:uqamevents"

#Expected: close({
	status:         "bootstrap" | "comparable" | "invalidated"
	outcome:        events.#Outcome
	added:          [...string]
	changed:        [...string]
	removed:        [...string]
	baselineAction: "advance" | "hold"
})

#FixtureCase: close({
	previous?:             [...events.#NormalizedEvent]
	current:               [...events.#NormalizedEvent]
	pointerGeneration:     int & >=0
	concurrentGeneration?: int & >=1
	expected:              #Expected
})

baseEvent: events.#NormalizedEvent & {
	identity: {
		key:             "uqam:event:example"
		basis:           "primary-url"
		organizer:       "UQAM"
		canonical_title: "Example technical seminar"
		primary_url:     "https://example.uqam.ca/events/example"
	}
	title:               "Example technical seminar"
	starts_at:           "2026-09-10T18:00:00-04:00"
	location:            "Pavillon President-Kennedy"
	scope:               "technical-seminar"
	registration_status: "open"
	primary_url:         "https://example.uqam.ca/events/example"
	evidence: [{
		source:           "uqam-central-events"
		channel:          "public-web"
		ref:              "https://example.uqam.ca/events/example"
		observed_surface: "event-detail"
		acquired_at:      "2026-08-31T12:00:00-04:00"
		content_digest:   "sha256:1111111111111111111111111111111111111111111111111111111111111111"
	}]
	content_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

movedEvent: events.#NormalizedEvent & {
	identity: {
		key:             "uqam:event:example"
		basis:           "primary-url"
		organizer:       "UQAM"
		canonical_title: "Example technical seminar"
		primary_url:     "https://example.uqam.ca/events/example"
	}
	title:               "Example technical seminar"
	starts_at:           "2026-09-11T18:00:00-04:00"
	location:            "Pavillon President-Kennedy"
	scope:               "technical-seminar"
	registration_status: "open"
	primary_url:         "https://example.uqam.ca/events/example"
	evidence: [{
		source:           "uqam-central-events"
		channel:          "public-web"
		ref:              "https://example.uqam.ca/events/example"
		observed_surface: "event-detail"
		acquired_at:      "2026-09-01T12:00:00-04:00"
		content_digest:   "sha256:2222222222222222222222222222222222222222222222222222222222222222"
	}]
	content_digest: "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
}

newEvent: events.#NormalizedEvent & {
	identity: {
		key:             "uqam:event:new"
		basis:           "primary-url"
		organizer:       "UQAM"
		canonical_title: "New Python workshop"
		primary_url:     "https://example.uqam.ca/events/python-workshop"
	}
	title:               "New Python workshop"
	starts_at:           "2026-09-12T17:00:00-04:00"
	location:            "Pavillon President-Kennedy"
	scope:               "python-workshop"
	registration_status: "open"
	primary_url:         "https://example.uqam.ca/events/python-workshop"
	evidence: [{
		source:           "uqam-numerique"
		channel:          "public-web"
		ref:              "https://example.uqam.ca/events/python-workshop"
		observed_surface: "event-detail"
		acquired_at:      "2026-09-01T12:00:00-04:00"
		content_digest:   "sha256:3333333333333333333333333333333333333333333333333333333333333333"
	}]
	content_digest: "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
}

fixtures: close({
	firstRun: #FixtureCase & {
		current:           [baseEvent]
		pointerGeneration: 0
		expected: {
			status:         "bootstrap"
			outcome:        "baseline_established"
			added:          []
			changed:        []
			removed:        []
			baselineAction: "advance"
		}
	}
	unchangedRun: #FixtureCase & {
		previous:          [baseEvent]
		current:           [baseEvent]
		pointerGeneration: 1
		expected: {
			status:         "comparable"
			outcome:        "no_change"
			added:          []
			changed:        []
			removed:        []
			baselineAction: "advance"
		}
	}
	addedEvent: #FixtureCase & {
		previous:          [baseEvent]
		current:           [baseEvent, newEvent]
		pointerGeneration: 1
		expected: {
			status:         "comparable"
			outcome:        "new_matches"
			added:          ["uqam:event:new"]
			changed:        []
			removed:        []
			baselineAction: "advance"
		}
	}
	movedEvent: #FixtureCase & {
		previous:          [baseEvent]
		current:           [movedEvent]
		pointerGeneration: 1
		expected: {
			status:         "comparable"
			outcome:        "new_matches"
			added:          []
			changed:        ["uqam:event:example"]
			removed:        []
			baselineAction: "advance"
		}
	}
	removedListing: #FixtureCase & {
		previous:          [baseEvent]
		current:           []
		pointerGeneration: 1
		expected: {
			status:         "comparable"
			outcome:        "no_change"
			added:          []
			changed:        []
			removed:        ["uqam:event:example"]
			baselineAction: "advance"
		}
	}
	overlappingAdvance: #FixtureCase & {
		previous:             [baseEvent]
		current:              [baseEvent]
		pointerGeneration:    1
		concurrentGeneration: 2
		expected: {
			status:         "comparable"
			outcome:        "state_conflict"
			added:          []
			changed:        []
			removed:        []
			baselineAction: "hold"
		}
	}
})
