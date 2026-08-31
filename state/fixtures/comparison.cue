package statefixtures

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

baselineRun: state.#RunReference & {
	task:              "academic.uqam.events"
	scope:             "uqam-montreal-technical-events"
	schema:            "uqam-events/v1"
	run_id:            "20260829T200000Z"
	observed_at:       "2026-08-29T20:00:00-04:00"
	normalized_digest: "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	bundle_path:       "academic/uqam/events/runs/20260829T200000Z"
}

baselineRef: state.#BaselineReference & {
	run:         baselineRun
	admitted_at: "2026-08-29T20:05:00-04:00"
}

bootstrap: state.#ComparisonState & {
	task:    "academic.uqam.events"
	scope:   "uqam-montreal-technical-events"
	schema:  "uqam-events/v1"
	current: currentRun
	status:  "bootstrap"
}

comparable: state.#ComparisonState & {
	task:     "academic.uqam.events"
	scope:    "uqam-montreal-technical-events"
	schema:   "uqam-events/v1"
	current:  currentRun
	status:   "comparable"
	baseline: baselineRef
}

invalidated: state.#ComparisonState & {
	task:                "academic.uqam.events"
	scope:               "uqam-montreal-technical-events"
	schema:              "uqam-events/v1"
	current:             currentRun
	status:              "invalidated"
	baseline:            baselineRef
	invalidation_reason: "normalization schema changed"
}

pointer: state.#BaselinePointer & {
	apiVersion: "factory.comparison-state.baseline/v1"
	kind:       "AdmittedComparisonBaseline"
	task:       "academic.uqam.events"
	scope:      "uqam-montreal-technical-events"
	schema:     "uqam-events/v1"
	generation: 1
	baseline:   baselineRef
}

advance: state.#BaselineAdvance & {
	task:                "academic.uqam.events"
	scope:               "uqam-montreal-technical-events"
	schema:              "uqam-events/v1"
	expected_generation: 1
	expected_digest:     "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	next: {
		apiVersion: "factory.comparison-state.baseline/v1"
		kind:       "AdmittedComparisonBaseline"
		task:       "academic.uqam.events"
		scope:      "uqam-montreal-technical-events"
		schema:     "uqam-events/v1"
		generation: 2
		baseline: {
			run:         currentRun
			admitted_at: "2026-08-30T20:05:00-04:00"
		}
	}
}
