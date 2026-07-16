package upstreammonitor

#ReportItem: close({
	id: #NonEmptyString
	channels: [_, ...#ChannelID]
	severity: #Severity
	impactDecision: #ImpactDecision
	title: #NonEmptyString
	summary: #NonEmptyString
	surfaceMatches: [_, ...#NonEmptyString]
	evidence: [_, ...#NonEmptyString]
	localContractImpact?: #NonEmptyString
	suggestedLocalTargets?: [...#NonEmptyString]
	trackedIssueRefs?: [...int]
})

#ImpactReport: close({
	apiVersion: "factory.upstream-monitor.codex/v1"
	kind: "CodexImpactReport"
	loop: "codex-contract-surface"
	signal_id: "loop_bootstrap_request"
	run_id: #NonEmptyString
	channels: close({
		main: #ChannelObservation & {channel: "main"}
		"latest-alpha-cli": #ChannelObservation & {channel: "latest-alpha-cli"}
	})
	critical: [...#ReportItem]
	high: [...#ReportItem]
	notes: [...#ReportItem]
	noLocalAction: [...#ReportItem]
	validationNotes: close({
		authorityRead: bool
		channelsKeptDistinct: bool
		publicationPlanRead: bool
		forbiddenAttractorsChecked: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
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
	requireSeparateChannelState: true
	requireUnresolvedPreservation: true
})
