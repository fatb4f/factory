package cuestrapprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#CuestrapPurposeImpact: close({
	purpose:        #CuestrapPurposeID
	impactDecision: core.#ImpactDecision
	summary:        core.#NonEmptyString
	surfaceMatches: [...core.#NonEmptyString]
})

#CuestrapImpactReport: close({
	apiVersion:        "factory.upstream-monitor.codex.cuestrap/v1"
	kind:              "CuestrapCodexImpactReport"
	loop:              "cuestrap-codex-contract-surface"
	signal_id:         "loop_bootstrap_request"
	profile_id:        "cuestrap"
	run_id:            core.#NonEmptyString
	factory_revision:  core.#CommitSHA
	cuestrap_revision: core.#CommitSHA
	channels: close({
		main: core.#ChannelObservation & {channel: "main"}
		"latest-alpha-cli": core.#ChannelObservation & {channel: "latest-alpha-cli"}
	})
	purposeImpact: close({
		supervisorySessionController: #CuestrapPurposeImpact & {
			purpose: "supervisory-session-controller"
		}
		idiomaticCueWorkbookHarness: #CuestrapPurposeImpact & {
			purpose: "idiomatic-cue-workbook-harness"
		}
	})
	critical: [...core.#ReportItem]
	high: [...core.#ReportItem]
	notes: [...core.#ReportItem]
	noLocalAction: [...core.#ReportItem]
	bundle: close({
		factoryPath:              core.#NonEmptyString
		factoryManifestPath:      core.#NonEmptyString
		factoryLatestPointerPath: core.#NonEmptyString
		exportUnit:               "directory"
		factoryComplete:          bool
	})
	trackingIssue: close({
		repository:          "fatb4f/cuestrap"
		number:              9
		updatePolicy:        "every_run"
		mutation:            "append_comment"
		dedupeKey:           core.#NonEmptyString
		commentURL?:         core.#NonEmptyString
		appended:            bool
		duplicateSuppressed: bool
	})
	validationNotes: close({
		authorityRead:                       bool
		cuestrapContextRead:                 bool
		channelsKeptDistinct:                bool
		publicationPlanRead:                 bool
		forbiddenAttractorsChecked:          bool
		factoryRunBundlePublished:           bool
		factoryBundleManifestSealed:         bool
		latestPointerUpdated:                bool
		noCuestrapRepositoryArtifactsWritten: bool
		noCuestrapPlumbingWritten:           bool
		trackingIssueResolved:               bool
		trackingIssueAppended:               bool
		trackingIssueDeduplicated:           bool
		trackingIssueBodyUnchanged:          bool
		cueExecution:                        "not_available_to_github_app" | "executed_elsewhere"
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
		"Tracking issue",
		"Validation notes",
	]
	requireSeparateChannelState:    true
	requirePurposeImpact:           true
	requireCuestrapRevision:        true
	requireUnresolvedPreservation:  true
	requireFactoryBundleDisclosure: true
	requireTrackingIssueDisclosure: true
})

cuestrapRunSummaryTemplate: close({
	filename:  "summary.md"
	mediaType: "text/markdown"
	sections: [
		"Run identity",
		"CUEstrap context",
		"Channel delta",
		"Purpose decisions",
		"Factory run bundle",
		"Tracking issue",
		"Validation",
	]
	requireChannelHeads:     true
	requirePurposeDecisions: true
	requireTerminalState:    true
	requireTrackingIssue:    true
})
