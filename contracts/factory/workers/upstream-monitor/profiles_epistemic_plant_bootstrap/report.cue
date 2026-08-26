package epistemicplantprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#EpistemicPlantImpactReport: close({
	apiVersion: "factory.upstream-monitor.epistemic-plant-bootstrap/v2"
	kind: "EpistemicPlantBootstrapUpstreamImpactReport"
	loop: "epistemic-plant-bootstrap-upstream-contract-surface"
	signal_id: "loop_bootstrap_request"
	profile_id: "epistemic-plant-bootstrap"
	run_id: core.#NonEmptyString
	authority_revision: core.#CommitSHA
	publication_revision?: core.#CommitSHA
	subject_revision: core.#CommitSHA
	terminal_state: core.#TerminalState
	monitor_state: terminal_state
	qualification_state: core.#QualificationState
	bootstrap_baseline: bool
	sourceState: [...core.#SourceObservation] & [_, ...]
	critical: [...core.#ReportItem]
	high: [...core.#ReportItem]
	notes: [...core.#ReportItem]
	noLocalAction: [...core.#ReportItem]
	authoritySeparation: close({
		pinnedSourceOraclePreserved: bool
		guacObservationOnlyPreserved: bool
		cueQualificationAuthorityPreserved: bool
		operationalFailureInconclusivePreserved: bool
	})
	publication: close({
		bundlePath: core.#NonEmptyString
		manifestPath: core.#NonEmptyString
		latestPointerPath: core.#NonEmptyString
		exportUnit: "directory"
		complete: bool
	})
	validationNotes: close({
		authorityRead: bool
		subjectContextRead: bool
		allRequiredSourcesResolved: bool
		graphModelRead: bool
		correlationModelRead: bool
		reportProjectedFromEvidence: bool
		summaryProjectedFromEvidence: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
		bootstrapExecution: "not_executed" | "executed"
		experimentExecution: "not_executed" | "executed"
	})
})

epistemicPlantImpactReportTemplate: close({
	path: "projects/epistemic-plant-bootstrap/.agents/report-template.md"
	sections: [
		"Run identity",
		"Subject authority",
		"Source state",
		"Authority separation",
		"Dependency and admission graph",
		"Correlation lineage",
		"Critical",
		"High",
		"Notes",
		"No local action",
		"Executable validation",
		"Publication",
	]
	requireSourceQualifiedState: true
	requireAuthoritySeparation: true
	requireGraphState: true
	requireCorrelationState: true
	requireQualificationState: true
	requireBootstrapDisclosure: true
	requireUnresolvedPreservation: true
})

epistemicPlantRunSummaryTemplate: close({
	filename: "summary.md"
	mediaType: "text/markdown"
	sections: [
		"Run identity",
		"Baseline",
		"Decisions",
		"Authority separation",
		"Qualification state",
		"Subject executable validation",
		"Bundle",
	]
	requireMonitorState: true
	requireQualificationState: true
	requireSourceHeads: true
	requireDecisionCounts: true
})
