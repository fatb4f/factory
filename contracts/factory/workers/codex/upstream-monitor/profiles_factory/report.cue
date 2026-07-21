package factoryprofile

import (
	"list"
	core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"
)

#ImpactReport: close({
	apiVersion:     "factory.upstream-monitor.codex/v1"
	kind:           "CodexImpactReport"
	loop:           "codex-contract-surface"
	signal_id:      "loop_bootstrap_request"
	profile_id:     "factory"
	run_id:         core.#NonEmptyString
	terminal_state: core.#TerminalState
	correction?:    core.#CorrectionLineage
	channels: close({
		main:               core.#ChannelObservation & {channel: "main"}
		"latest-alpha-cli": core.#ChannelObservation & {channel: "latest-alpha-cli"}
	})
	observations: [...core.#ClassifiedObservation]
	surfaceCoverage: close({
		for surface in surfaceCatalogue {
			(surface.id): core.#SurfaceCoverage & {
				surfaceID:       surface.id
				channelsScanned: ["main", "latest-alpha-cli"]
			}
		}
	})
	critical: [...core.#EvidenceBackedReportItem & {
		severity:            "critical"
		impactDecision:      "blocking-gate"
		localContractImpact: core.#NonEmptyString
	}]
	high: [...core.#EvidenceBackedReportItem & {
		severity:            "high"
		impactDecision:      "contract-update"
		localContractImpact: core.#NonEmptyString
	}]
	notes: [...core.#EvidenceBackedReportItem & {
		severity:            "note"
		impactDecision:      "note"
		localContractImpact: core.#NonEmptyString
	}]
	noLocalAction: [...core.#EvidenceBackedReportItem & {
		severity:       "none"
		impactDecision: "none"
	}]
	bundle: close({
		path:              core.#NonEmptyString
		manifestPath:      core.#NonEmptyString
		latestPointerPath: core.#NonEmptyString
		exportUnit:        "directory"
		complete:          bool
	})
	validationNotes: close({
		authorityRead:              bool
		channelsKeptDistinct:       bool
		publicationPlanRead:        bool
		forbiddenAttractorsChecked: bool
		runArtifactsCoLocated:      bool
		bundleManifestSealed:       bool
		latestPointerOnly:          bool
		typedEvidenceBound:         bool
		observationLedgerComplete:  bool
		surfaceCoverageComplete:    bool
		projectionOnlyRendering:    bool
		cueExecution:               "not_available_to_github_app" | "executed_elsewhere"
	})

	_allItems:              list.Concat([critical, high, notes, noLocalAction])
	_observationIDs:        [for observation in observations {observation.id}]
	_observationIDsUnique:  list.UniqueItems(_observationIDs)
	_observationIDsUnique:  true
	_reportItemIDs:         [for item in _allItems {item.id}]
	_reportItemIDsUnique:   list.UniqueItems(_reportItemIDs)
	_reportItemIDsUnique:   true
	_bindingObservationIDs: [for item in _allItems for binding in item.evidenceBindings {binding.observationID}]

	_observationsByID: {
		for observation in observations {
			(observation.id): observation
		}
	}
	_reportItemObservationCoverage: [for observation in observations {
		list.Contains(_bindingObservationIDs, observation.id)
	}]
	_reportItemObservationCoverage: [...true]

	_reportItemIDCoverage: [for observation in observations {
		list.Contains(_reportItemIDs, observation.reportItemID)
	}]
	_reportItemIDCoverage: [...true]

	_bindingObservationKnown: [for item in _allItems for binding in item.evidenceBindings {
		list.Contains(_observationIDs, binding.observationID)
	}]
	_bindingObservationKnown: [...true]

	_bindingLedgerConsistency: [for item in _allItems for binding in item.evidenceBindings {
		_observationsByID[binding.observationID] & {
			id:             binding.observationID
			reportItemID:   binding.reportItemID
			channel:        binding.channel
			path:           binding.path
			surfaceMatches: binding.surfaceMatches
			observation:    binding.observation
			decision:       item.impactDecision
			severity:       item.severity
		}
	}]

	_surfaceObservationRefsKnown: [for _, coverage in surfaceCoverage for observationRef in coverage.observationRefs {
		list.Contains(_observationIDs, observationRef)
	}]
	_surfaceObservationRefsKnown: [...true]

	_surfaceCoverageConsistency: [for _, coverage in surfaceCoverage for observationRef in coverage.observationRefs {
		list.Contains(_observationsByID[observationRef].surfaceMatches, coverage.surfaceID)
	}]
	_surfaceCoverageConsistency: [...true]

	_observationSurfaceCoverage: [for observation in observations for surfaceID in observation.surfaceMatches {
		list.Contains(surfaceCoverage[surfaceID].observationRefs, observation.id)
	}]
	_observationSurfaceCoverage: [...true]
})

evidenceModel: close({
	version:                   "v2"
	reportItems:               "typed_evidence_bindings"
	observationLedger:         "required"
	surfaceCoverageLedger:     "required_for_every_declared_surface"
	claims:                    "bound_to_observation_refs_and_cover_all_bindings"
	identities:                "unique_observation_report_item_binding_and_claim_ids"
	decisionSeverityAlignment: "ledger_binding_and_bucket_exact"
	markdownProjectionSource:  "evidence.json"
	independentMarkdownClaims: false
	sealedRunMutation:         false
	correctionMode:            "superseding_run_with_lineage"
})

upstreamCodexImpactReportTemplate: close({
	path: "contracts/upstream-monitor/codex/contract-surface/output/report-template.md"
	sections: [
		"Run identity",
		"Correction lineage",
		"Channel state: main",
		"Channel state: latest-alpha-cli",
		"Critical",
		"High",
		"Notes",
		"No local action",
		"Publication",
		"Validation notes",
	]
	requireSeparateChannelState:   true
	requireUnresolvedPreservation: true
	renderFromEvidenceJSONOnly:    true
	forbidIndependentClaims:       true
	requireTypedClaimProjection:   true
})

upstreamCodexRunSummaryTemplate: close({
	filename:  "summary.md"
	mediaType: "text/markdown"
	sections: [
		"Run identity",
		"Correction lineage",
		"Channel delta",
		"Impact decisions",
		"Run bundle",
		"Validation",
	]
	requireChannelHeads:        true
	requireImpactCounts:        true
	requireTerminalState:       true
	renderFromEvidenceJSONOnly: true
	forbidIndependentClaims:    true
})
