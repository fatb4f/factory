package uqameventsfixtures

import events "github.com/fatb4f/factory/contracts/academic/uqam/events"

baselineRunRef: events.#EventRunReference & {
	task:              "academic.uqam.events"
	scope:             "uqam-montreal-technical-events"
	schema:            "uqam-events/v1"
	run_id:            "20260829T200000Z"
	observed_at:       "2026-08-29T20:00:00-04:00"
	normalized_digest: "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	bundle_path:       "academic/uqam/events/runs/20260829T200000Z"
}

currentRunRef: events.#EventRunReference & {
	task:              "academic.uqam.events"
	scope:             "uqam-montreal-technical-events"
	schema:            "uqam-events/v1"
	run_id:            "20260830T200000Z"
	observed_at:       "2026-08-30T20:00:00-04:00"
	normalized_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	bundle_path:       "academic/uqam/events/runs/20260830T200000Z"
}

manifest: events.#RunManifest & {
	apiVersion:        "factory.uqam-events.run-bundle/v1"
	kind:              "UQAMEventsRunBundle"
	run_id:            currentRunRef.run_id
	task_id:           "academic.uqam.events"
	schema:            "uqam-events/v1"
	observed_at:       currentRunRef.observed_at
	normalized_digest: currentRunRef.normalized_digest
	decision_digest:   "sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
	export_unit:       "directory"
	normalized_path:   "normalized.json"
	decision_path:     "decision.json"
}

completeAcquisition: events.#CompleteAcquisitionCoverage & {
	complete: true
	observed_sources: [
		"uqam-central-events",
		"uqam-numerique",
		"uqam-information-diffusion",
	]
	gaps: []
}

baselineRef: {
	run:         baselineRunRef
	admitted_at: "2026-08-29T20:05:00-04:00"
}

bootstrapRun: events.#RunBundle & {
	currentRun: currentRunRef
	manifest:   manifest
	acquisition: completeAcquisition
	events: [baseEvent]
	comparison: {
		comparison_state: {
			task:    "academic.uqam.events"
			scope:   "uqam-montreal-technical-events"
			schema:  "uqam-events/v1"
			current: currentRunRef
			status:  "bootstrap"
		}
	}
	decision: {
		outcome:             "baseline_established"
		baseline_action:     "advance"
		reported_event_keys: []
		reason:              "complete first acquisition establishes the comparison baseline"
	}
	pointer: {
		action: "advance"
		transition: {
			task:                "academic.uqam.events"
			scope:               "uqam-montreal-technical-events"
			schema:              "uqam-events/v1"
			expected_generation: 0
			next: {
				apiVersion: "factory.comparison-state.baseline/v1"
				kind:       "AdmittedComparisonBaseline"
				task:       "academic.uqam.events"
				scope:      "uqam-montreal-technical-events"
				schema:     "uqam-events/v1"
				generation: 1
				baseline: {
					run:         currentRunRef
					admitted_at: "2026-08-30T20:05:00-04:00"
				}
			}
		}
	}
}

sourceGapRun: events.#RunBundle & {
	currentRun: currentRunRef
	manifest:   manifest
	acquisition: {
		complete:         false
		observed_sources: ["uqam-central-events", "uqam-numerique"]
		gaps:             ["uqam-information-diffusion"]
	}
	events: [baseEvent]
	decision: {
		outcome:             "source_gap"
		baseline_action:     "hold"
		reported_event_keys: []
		reason:              "required discovery source unavailable"
	}
	pointer: {
		action:              "hold"
		reason:              "source_gap"
		expected_generation: 1
	}
}

noChangeRun: events.#RunBundle & {
	currentRun: currentRunRef
	manifest:   manifest
	acquisition: completeAcquisition
	events: [baseEvent]
	comparison: {
		comparison_state: {
			task:     "academic.uqam.events"
			scope:    "uqam-montreal-technical-events"
			schema:   "uqam-events/v1"
			current:  currentRunRef
			status:   "comparable"
			baseline: baselineRef
		}
		delta: {added: [], changed: [], removed: []}
	}
	decision: {
		outcome:             "no_change"
		baseline_action:     "advance"
		reported_event_keys: []
		reason:              "no added or materially changed events"
	}
	pointer: {
		action: "advance"
		transition: {
			task:                "academic.uqam.events"
			scope:               "uqam-montreal-technical-events"
			schema:              "uqam-events/v1"
			expected_generation: 1
			next: {
				apiVersion: "factory.comparison-state.baseline/v1"
				kind:       "AdmittedComparisonBaseline"
				task:       "academic.uqam.events"
				scope:      "uqam-montreal-technical-events"
				schema:     "uqam-events/v1"
				generation: 2
				baseline: {
					run:         currentRunRef
					admitted_at: "2026-08-30T20:05:00-04:00"
				}
			}
		}
	}
}

newMatchesRun: events.#RunBundle & {
	currentRun: currentRunRef
	manifest:   manifest
	acquisition: completeAcquisition
	events: [baseEvent, newEvent]
	comparison: {
		comparison_state: {
			task:     "academic.uqam.events"
			scope:    "uqam-montreal-technical-events"
			schema:   "uqam-events/v1"
			current:  currentRunRef
			status:   "comparable"
			baseline: baselineRef
		}
		delta: {added: [newEvent], changed: [], removed: []}
	}
	decision: {
		outcome:             "new_matches"
		baseline_action:     "advance"
		reported_event_keys: ["uqam:event:new"]
		reason:              "one newly reportable event"
	}
	pointer: noChangeRun.pointer
}

comparisonGapRun: events.#RunBundle & {
	currentRun: currentRunRef
	manifest:   manifest
	acquisition: completeAcquisition
	events: [baseEvent]
	comparison: {
		comparison_state: {
			task:                "academic.uqam.events"
			scope:               "uqam-montreal-technical-events"
			schema:              "uqam-events/v1"
			current:             currentRunRef
			status:              "invalidated"
			baseline:            baselineRef
			invalidation_reason: "normalization schema changed"
		}
	}
	decision: {
		outcome:             "comparison_gap"
		baseline_action:     "hold"
		reported_event_keys: []
		reason:              "baseline is not comparable"
	}
	pointer: {
		action:              "hold"
		reason:              "comparison_gap"
		expected_generation: 1
	}
}

stateConflictRun: events.#RunBundle & {
	currentRun: currentRunRef
	manifest:   manifest
	acquisition: completeAcquisition
	events: [baseEvent]
	comparison: noChangeRun.comparison
	decision: {
		outcome:             "state_conflict"
		baseline_action:     "hold"
		reported_event_keys: []
		reason:              "baseline pointer generation advanced concurrently"
	}
	pointer: {
		action:              "hold"
		reason:              "cas_conflict"
		expected_generation: 1
		observed_generation: 2
	}
}
