package uqamevents

import (
	"list"
	state "github.com/fatb4f/factory/contracts/state"
)

#TaskID:   "academic.uqam.events"
#SchemaID: "uqam-events/v1"
#ScopeID:  "uqam-montreal-technical-events"

#SourceRole: "required-discovery" | "optional-primary"
#RequiredSourceID:
	"uqam-central-events" |
	"uqam-numerique" |
	"uqam-information-diffusion"

requiredSourceIDs: [
	"uqam-central-events",
	"uqam-numerique",
	"uqam-information-diffusion",
]

#SourceSpec: close({
	id:      #NonEmptyString
	role:    #SourceRole
	channel: "public-web" | "organizer-web" | "community-web"
})

#CompleteAcquisitionCoverage: close({
	complete:         true
	observed_sources: [...#RequiredSourceID]
	gaps:             []
	_requiredCoverage: [for id in requiredSourceIDs {
		list.Contains(observed_sources, id) & true
	}]
})

#IncompleteAcquisitionCoverage: close({
	complete:         false
	observed_sources: [...#RequiredSourceID]
	gaps:             [#RequiredSourceID, ...#RequiredSourceID]
	_requiredPartition: [for id in requiredSourceIDs {
		observed: list.Contains(observed_sources, id)
		gap:      list.Contains(gaps, id)
		covered:  (list.Contains(observed_sources, id) || list.Contains(gaps, id)) & true
		exclusive: (!(list.Contains(observed_sources, id) && list.Contains(gaps, id))) & true
	}]
})

#AcquisitionCoverage:
	#CompleteAcquisitionCoverage |
	#IncompleteAcquisitionCoverage

#EventRunReference: state.#RunReference & {
	task:   #TaskID
	scope:  #ScopeID
	schema: #SchemaID
}

#EventBaselinePointer: state.#BaselinePointer & {
	task:   #TaskID
	scope:  #ScopeID
	schema: #SchemaID
	baseline: {
		run: #EventRunReference
	}
}

#RunManifest: close({
	apiVersion:        "factory.uqam-events.run-bundle/v1"
	kind:              "UQAMEventsRunBundle"
	run_id:            state.#RunID
	task_id:           #TaskID
	schema:            #SchemaID
	observed_at:       #NonEmptyString
	normalized_digest: state.#SHA256
	decision_digest:   state.#SHA256
	export_unit:       "directory"
	normalized_path:   #NonEmptyString
	decision_path:     #NonEmptyString
})

#PointerAdvance: close({
	action: "advance"
	transition: state.#BaselineAdvance & {
		task:   #TaskID
		scope:  #ScopeID
		schema: #SchemaID
		next:   #EventBaselinePointer
	}
	_generationInvariant: transition.next.generation & (transition.expected_generation + 1)
})

#PointerHold: close({
	action:              "hold"
	reason:              "source_gap" | "comparison_gap"
	expected_generation: int & >=0
})

#StateConflictHold: close({
	action:              "hold"
	reason:              "cas_conflict"
	expected_generation: int & >=0
	observed_generation: int & >=1
	_generationsDiffer:  (observed_generation != expected_generation) & true
})

#SourceGapRun: close({
	currentRun: #EventRunReference
	manifest: #RunManifest & {
		run_id:            currentRun.run_id
		observed_at:       currentRun.observed_at
		normalized_digest: currentRun.normalized_digest
	}
	acquisition: #IncompleteAcquisitionCoverage
	events:      [...#NormalizedEvent]
	decision:    #SourceGapDecision
	pointer:     #PointerHold & {reason: "source_gap"}
})

#BootstrapRun: close({
	currentRun: #EventRunReference
	manifest: #RunManifest & {
		run_id:            currentRun.run_id
		observed_at:       currentRun.observed_at
		normalized_digest: currentRun.normalized_digest
	}
	acquisition: #CompleteAcquisitionCoverage
	events:      [...#NormalizedEvent]
	comparison: #BootstrapComparisonResult & {
		comparison_state: {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
	}
	decision: #BaselineEstablishedDecision
	pointer: #PointerAdvance & {
		transition: {
			expected_generation: 0
			next: {
				baseline: {run: currentRun}
			}
		}
	}
})

#ComparableNoChangeRun: close({
	currentRun: #EventRunReference
	manifest: #RunManifest & {
		run_id:            currentRun.run_id
		observed_at:       currentRun.observed_at
		normalized_digest: currentRun.normalized_digest
	}
	acquisition: #CompleteAcquisitionCoverage
	events:      [...#NormalizedEvent]
	comparison: #ComparableComparisonResult & {
		comparison_state: {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
		delta: #NoReportableDelta
	}
	decision: #NoChangeDecision
	pointer: #PointerAdvance & {
		transition: {
			expected_generation: int & >=1
			next: {baseline: {run: currentRun}}
		}
	}
})

#ComparableNewMatchesRun: close({
	currentRun: #EventRunReference
	manifest: #RunManifest & {
		run_id:            currentRun.run_id
		observed_at:       currentRun.observed_at
		normalized_digest: currentRun.normalized_digest
	}
	acquisition: #CompleteAcquisitionCoverage
	events:      [...#NormalizedEvent]
	comparison: #ComparableComparisonResult & {
		comparison_state: {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
		delta: #ReportableDelta
	}
	decision: #NewMatchesDecision
	pointer: #PointerAdvance & {
		transition: {
			expected_generation: int & >=1
			next: {baseline: {run: currentRun}}
		}
	}
})

#ComparisonGapRun: close({
	currentRun: #EventRunReference
	manifest: #RunManifest & {
		run_id:            currentRun.run_id
		observed_at:       currentRun.observed_at
		normalized_digest: currentRun.normalized_digest
	}
	acquisition: #CompleteAcquisitionCoverage
	events:      [...#NormalizedEvent]
	comparison: #InvalidatedComparisonResult & {
		comparison_state: {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
	}
	decision: #ComparisonGapDecision
	pointer:  #PointerHold & {reason: "comparison_gap"}
})

#StateConflictRun: close({
	currentRun: #EventRunReference
	manifest: #RunManifest & {
		run_id:            currentRun.run_id
		observed_at:       currentRun.observed_at
		normalized_digest: currentRun.normalized_digest
	}
	acquisition: #CompleteAcquisitionCoverage
	events:      [...#NormalizedEvent]
	comparison:  #BootstrapComparisonResult | #ComparableComparisonResult
	decision:    #StateConflictDecision
	pointer:     #StateConflictHold
})

#RunBundle:
	#SourceGapRun |
	#BootstrapRun |
	#ComparableNoChangeRun |
	#ComparableNewMatchesRun |
	#ComparisonGapRun |
	#StateConflictRun

#AuthorityBoundary: close({
	semantic:        "contracts/academic/uqam/events"
	procedure:       "academic/uqam/.agents/events"
	runs:            "academic/uqam/events/runs"
	baselinePointer: "academic/uqam/events/state/admitted-baseline.json"
	reportTemplate:  "academic/uqam/.agents/events/report-template.md"
})

#Contract: close({
	id:     #TaskID
	kind:   "academic-event-watch"
	schema: #SchemaID
	scope:  #ScopeID

	authority: #AuthorityBoundary

	sources: close({
		required: close({
			"uqam-central-events": #SourceSpec & {
				id:      "uqam-central-events"
				role:    "required-discovery"
				channel: "public-web"
			}
			"uqam-numerique": #SourceSpec & {
				id:      "uqam-numerique"
				role:    "required-discovery"
				channel: "public-web"
			}
			"uqam-information-diffusion": #SourceSpec & {
				id:      "uqam-information-diffusion"
				role:    "required-discovery"
				channel: "public-web"
			}
		})
		optionalSourceClasses: [
			"uqam-unit",
			"uqam-student-group",
			"montreal-technical-community",
		]
	})

	state: close({
		storeContract:   "contracts/state/comparison.cue"
		firstRunStatus:  "bootstrap"
		firstRunOutcome: "baseline_established"
		pointerUpdate:   "compare-and-swap"
	})

	publication: close({
		reportOnlyAddedOrMateriallyChanged:      true
		reportRemovedOnlyOnConfirmedCancellation: true
		manifestSealsNormalizedAndDecision:      true
	})
})

contract: #Contract & {
	id:     "academic.uqam.events"
	kind:   "academic-event-watch"
	schema: "uqam-events/v1"
	scope:  "uqam-montreal-technical-events"
	authority: {
		semantic:        "contracts/academic/uqam/events"
		procedure:       "academic/uqam/.agents/events"
		runs:            "academic/uqam/events/runs"
		baselinePointer: "academic/uqam/events/state/admitted-baseline.json"
		reportTemplate:  "academic/uqam/.agents/events/report-template.md"
	}
	sources: {
		required: {
			"uqam-central-events": {
				id:      "uqam-central-events"
				role:    "required-discovery"
				channel: "public-web"
			}
			"uqam-numerique": {
				id:      "uqam-numerique"
				role:    "required-discovery"
				channel: "public-web"
			}
			"uqam-information-diffusion": {
				id:      "uqam-information-diffusion"
				role:    "required-discovery"
				channel: "public-web"
			}
		}
		optionalSourceClasses: [
			"uqam-unit",
			"uqam-student-group",
			"montreal-technical-community",
		]
	}
	state: {
		storeContract:   "contracts/state/comparison.cue"
		firstRunStatus:  "bootstrap"
		firstRunOutcome: "baseline_established"
		pointerUpdate:   "compare-and-swap"
	}
	publication: {
		reportOnlyAddedOrMateriallyChanged:      true
		reportRemovedOnlyOnConfirmedCancellation: true
		manifestSealsNormalizedAndDecision:      true
	}
}
