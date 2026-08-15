package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlImpactReport: close({
	apiVersion: "factory.upstream-monitor.ctrl/v2"
	kind: "CtrlUpstreamImpactReport"
	loop: "ctrl-upstream-contract-surface"
	signal_id: "loop_bootstrap_request"
	profile_id: "ctrl"
	run_id: core.#NonEmptyString
	authority_revision: core.#CommitSHA
	publication_revision?: core.#CommitSHA
	ctrl_revision: core.#CommitSHA
	terminal_state: core.#TerminalState
	monitor_state: terminal_state
	qualification_state: core.#QualificationState
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
		correlationCarrierPolicyRead: bool
		reportProjectedFromEvidence: bool
		summaryProjectedFromEvidence: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
		regrtestExecution: "not_executed" | "executed"
		probeExecution: "not_executed" | "executed"
		otelPipelineExecution: "not_executed" | "executed"
		otlpOtapRoundtripExecution: "not_executed" | "executed"
	})
})

ctrlImpactReportTemplate: close({
	path: "contracts/upstream-monitor/ctrl/contract-surface/output/report-template.md"
	sections: [
		"Run identity",
		"Subject context",
		"Source state",
		"Codex projection graph",
		"Python semantic and operational graph",
		"Observation and acquisition graph",
		"Correlation carrier policy",
		"P0 executable frontier",
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
	requireAstralStaticState: true
	requireOtelAcquisitionState: true
	requireOtelArrowProjectionState: true
	requireExternalObservationState: true
	requireCorrelationCarrierPolicy: true
	requireQualificationState: true
	requireP0TraceRoundtripScope: true
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
		"Qualification state",
		"Operationalization gap",
		"Bundle",
		"Validation",
	]
	requireMonitorState: true
	requireQualificationState: true
	requireSourceHeads: true
	requireDecisionCounts: true
})
