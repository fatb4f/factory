package statenegative

import state "github.com/fatb4f/factory/contracts/state"

currentRun: state.#RunReference & {
	task:              "academic.uqam.events"
	scope:             "uqam-montreal-technical-events"
	schema:            "uqam-events/v1"
	run_id:            "20260830T200000Z"
	observed_at:       "2026-08-30T20:00:00-04:00"
	normalized_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	bundle_path:       "academic/uqam/events/runs/20260830T200000Z"
}

baselineRef: state.#BaselineReference & {
	run: {
		task:              "academic.uqam.events"
		scope:             "uqam-montreal-technical-events"
		schema:            "uqam-events/v1"
		run_id:            "20260829T200000Z"
		observed_at:       "2026-08-29T20:00:00-04:00"
		normalized_digest: "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
		bundle_path:       "academic/uqam/events/runs/20260829T200000Z"
	}
	admitted_at: "2026-08-29T20:05:00-04:00"
}

// Each case is intentionally contradictory. This package must fail validation.
bootstrapWithBaseline: state.#ComparisonState & {
	task:     "academic.uqam.events"
	scope:    "uqam-montreal-technical-events"
	schema:   "uqam-events/v1"
	current:  currentRun
	status:   "bootstrap"
	baseline: baselineRef
}

comparableWithoutBaseline: state.#ComparisonState & {
	task:    "academic.uqam.events"
	scope:   "uqam-montreal-technical-events"
	schema:  "uqam-events/v1"
	current: currentRun
	status:  "comparable"
}

invalidatedWithoutReason: state.#ComparisonState & {
	task:     "academic.uqam.events"
	scope:    "uqam-montreal-technical-events"
	schema:   "uqam-events/v1"
	current:  currentRun
	status:   "invalidated"
	baseline: baselineRef
}
