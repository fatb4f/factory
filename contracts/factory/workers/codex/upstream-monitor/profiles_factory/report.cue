package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#ImpactReport: close({
	apiVersion: "factory.upstream-monitor.codex/v1"
	kind:       "CodexImpactReport"
	loop:       "codex-contract-surface"
	signal_id:  "loop_bootstrap_request"
	profile_id: "factory"
	run_id:     core.#NonEmptyString
	channels: close({
		main: core.#ChannelObservation & {channel: "main"}
		"latest-alpha-cli": core.#ChannelObservation & {channel: "latest-alpha-cli"}
	})
	critical: [...core.#ReportItem]
	high: [...core.#ReportItem]
	notes: [...core.#ReportItem]
	noLocalAction: [...core.#ReportItem]
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
		cueExecution:               "not_available_to_github_app" | "executed_elsewhere"
	})
})

upstreamCodexImpactReportTemplate: close({
	path: "contracts/upstream-monitor/codex/contract-surface/output/report-template.md"
	sections: [
		"Run identity",
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
})

upstreamCodexRunSummaryTemplate: close({
	filename:  "summary.md"
	mediaType: "text/markdown"
	sections: [
		"Run identity",
		"Channel delta",
		"Impact decisions",
		"Run bundle",
		"Validation",
	]
	requireChannelHeads:  true
	requireImpactCounts:  true
	requireTerminalState: true
})
