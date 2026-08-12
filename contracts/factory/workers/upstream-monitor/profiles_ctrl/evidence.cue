package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlRunEvidence: close({
	apiVersion: "factory.upstream-monitor.ctrl.evidence/v1"
	kind: "CtrlUpstreamEvidence"
	run_id: core.#NonEmptyString
	profile_id: "ctrl"
	terminal_state: core.#TerminalState
	factory_revision: core.#CommitSHA
	ctrl_revision: core.#CommitSHA
	bootstrap_baseline: bool
	sources: [...core.#SourceObservation] & [_, ...]
	graph: close({
		nodesObserved: [...core.#NonEmptyString] & [_, ...]
		edgesEvaluated: [...core.#NonEmptyString] & [_, ...]
		testBindingsEvaluated: [...core.#NonEmptyString]
		probeBindingsEvaluated: [...core.#NonEmptyString]
	})
	items: [...core.#ReportItem]
	validation: close({
		authorityRead: bool
		ctrlContextRead: bool
		sourceChannelsDistinct: bool
		graphModelRead: bool
		publicationPlanRead: bool
		forbiddenAttractorsChecked: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
		executableCpythonProbes: "not_executed_bootstrap" | "executed"
		executableRegrtest: "not_executed_bootstrap" | "executed"
		reportProjectionOnly: bool
		summaryProjectionOnly: bool
	})
})

ctrlEvidenceModel: close({
	semanticSourceForMarkdown: "evidence.json"
	requireExactSourceRevisionWhenResolved: true
	requireSourceAndChannelOnEveryObservation: true
	requireGraphNodeBindingForCpythonItems: true
	requireProjectionEdgeBindingForCodexSchemaSDKItems: true
	requireUpstreamTestAndLocalProbeDistinction: true
	forbidUpstreamTestVerdictAsQualification: true
	bootstrapMayEstablishBaselineWithoutHistoricalDelta: true
})
