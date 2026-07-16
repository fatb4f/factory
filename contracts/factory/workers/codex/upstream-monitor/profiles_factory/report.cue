package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#ImpactReport: close({
	apiVersion: "factory.upstream-monitor.codex/v1"
	kind:       "CodexImpactReport"
	loop:       "codex-contract-surface"
	signal_id:  "loop_bootstrap_request"
	run_id:     core.#NonEmptyString
	channels: close({
		main: core.#ChannelObservation & {channel: "main"}
		"latest-alpha-cli": core.#ChannelObservation & {channel: "latest-alpha-cli"}
	})
	critical: [...core.#ReportItem]
	high: [...core.#ReportItem]
	notes: [...core.#ReportItem]
	noLocalAction: [...core.#ReportItem]
	validationNotes: close({
		authorityRead:              bool
		channelsKeptDistinct:       bool
		publicationPlanRead:        bool
		forbiddenAttractorsChecked: bool
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
		"Validation notes",
	]
	requireSeparateChannelState:   true
	requireUnresolvedPreservation: true
})
