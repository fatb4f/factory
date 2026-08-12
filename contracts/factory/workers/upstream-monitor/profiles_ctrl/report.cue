package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlImpactReport: close({
	apiVersion: "factory.upstream-monitor.ctrl/v1"
	kind: "CtrlUpstreamImpactReport"
	loop: "ctrl-upstream-contract-surface"
	signal_id: "loop_bootstrap_request"
	profile_id: "ctrl"
	run_id: core.#NonEmptyString
	factory_revision: core.#CommitSHA
	ctrl_revision: core.#CommitSHA
	terminal_state: core.#TerminalState
	bootstrap_baseline: bool
	sourceState: [...core.#SourceObservation] & [_, ...]
	critical: [...core.#ReportItem]
	high: [...core.#ReportItem]
	notes: [...core.#ReportItem]
	noLocalAction: [...core.#ReportItem]
	publication: close({
		bundlePath: core.#NonEmptyString
		manifestPath: core.#NonEmptyString
		latestPointerPath: core.#NonEmptyString
		exportUnit: "directory"
		complete: bool
	})
	validationNotes: close({
		authorityRead: bool
		ctrlContextRead: bool
		allRequiredSourcesResolved: bool
		graphModelRead: bool
		reportProjectedFromEvidence: bool
		summaryProjectedFromEvidence: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
		regrtestExecution: "not_executed_bootstrap" | "executed"
		probeExecution: "not_executed_bootstrap" | "executed"
	})
})

ctrlImpactReportTemplate: close({
	path: "contracts/upstream-monitor/ctrl/contract-surface/output/report-template.md"
	sections: [
		"Run identity",
		"Subject context",
		"Source state",
		"Codex projection graph",
		"CPython operational graph",
		"Critical",
		"High",
		"Notes",
		"No local action",
		"Publication",
		"Validation notes",
	]
	requireSourceQualifiedState: true
	requireCodexProjectionState: true
	requireCpythonOperationalState: true
	requireBootstrapDisclosure: true
	requireUnresolvedPreservation: true
})

ctrlRunSummaryTemplate: close({
	filename: "summary.md"
	mediaType: "text/markdown"
	sections: [
		"Run identity",
		"Baseline",
		"Decisions",
		"Operationalization gap",
		"Bundle",
		"Validation",
	]
	requireTerminalState: true
	requireSourceHeads: true
	requireDecisionCounts: true
})
