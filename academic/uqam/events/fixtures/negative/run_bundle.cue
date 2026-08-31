package uqameventsnegative

import events "github.com/fatb4f/factory/contracts/academic/uqam/events:uqamevents"

fixtureRunRef: events.#EventRunReference & {
	task:              "academic.uqam.events"
	scope:             "uqam-montreal-technical-events"
	schema:            "uqam-events/v1"
	run_id:            "20260830T200000Z"
	observed_at:       "2026-08-30T20:00:00-04:00"
	normalized_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	bundle_path:       "academic/uqam/events/runs/20260830T200000Z"
}

fixtureManifest: events.#RunManifest & {
	apiVersion:        "factory.uqam-events.run-bundle/v1"
	kind:              "UQAMEventsRunBundle"
	run_id:            fixtureRunRef.run_id
	task_id:           "academic.uqam.events"
	schema:            "uqam-events/v1"
	observed_at:       fixtureRunRef.observed_at
	normalized_digest: fixtureRunRef.normalized_digest
	decision_digest:   "sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
	export_unit:       "directory"
	normalized_path:   "normalized.json"
	decision_path:     "decision.json"
}

// Incomplete required acquisition must never establish or advance a baseline.
incompleteBaselineAdvance: events.#RunBundle & {
	currentRun: fixtureRunRef
	manifest:   fixtureManifest
	acquisition: {
		complete:         false
		observed_sources: ["uqam-central-events", "uqam-numerique"]
		gaps:             ["uqam-information-diffusion"]
	}
	events: []
	comparison: {
		comparison_state: {
			task:    "academic.uqam.events"
			scope:   "uqam-montreal-technical-events"
			schema:  "uqam-events/v1"
			current: fixtureRunRef
			status:  "bootstrap"
		}
	}
	decision: {
		outcome:             "baseline_established"
		baseline_action:     "advance"
		reported_event_keys: []
		reason:              "invalid"
	}
	pointer: {
		action:              "hold"
		reason:              "source_gap"
		expected_generation: 0
	}
}
