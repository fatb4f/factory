package upstreammonitor

#CuestrapPurposeImpact: close({
	purpose:        #CuestrapPurposeID
	impactDecision: #ImpactDecision
	summary:        #NonEmptyString
	surfaceMatches: [...#NonEmptyString]
})

#CuestrapImpactReport: close({
	apiVersion: "factory.upstream-monitor.codex.cuestrap/v1"
	kind:       "CuestrapCodexImpactReport"
	loop:       "cuestrap-codex-contract-surface"
	signal_id:  "loop_bootstrap_request"
	profile_id: "cuestrap"
	run_id:     #NonEmptyString
	factory_revision:  #CommitSHA
	cuestrap_revision: #CommitSHA
	channels: close({
		main:               #ChannelObservation & {channel: "main"}
		"latest-alpha-cli": #ChannelObservation & {channel: "latest-alpha-cli"}
	})
	purposeImpact: close({
		supervisorySessionController: #CuestrapPurposeImpact & {
			purpose: "supervisory-session-controller"
		}
		idiomaticCueWorkbookHarness: #CuestrapPurposeImpact & {
			purpose: "idiomatic-cue-workbook-harness"
		}
	})
	critical:      [...#ReportItem]
	high:          [...#ReportItem]
	notes:         [...#ReportItem]
	noLocalAction: [...#ReportItem]
	validationNotes: close({
		authorityRead:             bool
		cuestrapContextRead:       bool
		channelsKeptDistinct:      bool
		publicationPlanRead:       bool
		forbiddenAttractorsChecked: bool
		factoryArtifactsPublished: bool
		cuestrapReportMirrored:    bool
		mirrorContentEquivalent:   bool
		noCuestrapPlumbingWritten: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
	})
})

cuestrapCodexImpactReportTemplate: close({
	path: "contracts/upstream-monitor/codex/cuestrap-contract-surface/output/report-template.md"
	sections: [
		"Run identity",
		"CUEstrap context state",
		"Channel state: main",
		"Channel state: latest-alpha-cli",
		"Purpose impact: supervisory session controller",
		"Purpose impact: idiomatic CUE workbook harness",
		"Critical",
		"High",
		"Notes",
		"No local action",
		"Publication",
		"Validation notes",
	]
	requireSeparateChannelState: true
	requirePurposeImpact:        true
	requireCuestrapRevision:     true
	requireUnresolvedPreservation: true
	requireMirrorDisclosure:     true
})
