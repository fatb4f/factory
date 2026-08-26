package epistemicplantprofile

import core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"

#EpistemicPlantRunEvidence: close({
	apiVersion: "factory.upstream-monitor.epistemic-plant-bootstrap.evidence/v2"
	kind: "EpistemicPlantBootstrapUpstreamEvidence"
	run_id: core.#NonEmptyString
	profile_id: "epistemic-plant-bootstrap"
	terminal_state: core.#TerminalState
	monitor_state: terminal_state
	qualification_state: core.#QualificationState
	authority_revision: core.#CommitSHA
	publication_revision?: core.#CommitSHA
	subject_revision: core.#CommitSHA
	bootstrap_baseline: bool
	sources: [...core.#SourceObservation] & [_, ...]
	graph: close({
		nodesObserved: [...core.#NonEmptyString] & [_, ...]
		edgesEvaluated: [...core.#NonEmptyString] & [_, ...]
		testBindingsEvaluated: [...core.#NonEmptyString]
		probeBindingsEvaluated: [...core.#NonEmptyString]
	})
	items: [...core.#ReportItem]
	authoritySeparation: close({
		pinnedSourceRemainsOracle: bool
		guacRemainsObservationOnly: bool
		cueRemainsQualificationAuthority: bool
		operationalFailureRemainsInconclusive: bool
	})
	validation: close({
		authorityRead: bool
		subjectContextRead: bool
		allRequiredSourcesResolved: bool
		graphModelRead: bool
		correlationModelRead: bool
		publicationPlanRead: bool
		forbiddenAttractorsChecked: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
		bootstrapExecution: "not_executed" | "executed"
		unitExecution: "not_executed" | "executed"
		experimentExecution: "not_executed" | "executed"
		reportProjectionOnly: bool
		summaryProjectionOnly: bool
	})
})

epistemicPlantEvidenceModel: close({
	semanticSourceForMarkdown: "evidence.json"
	requireExactSourceRevisionWhenResolved: true
	requireSourceAndChannelOnEveryObservation: true
	requireGraphNodeBindingForImpactItems: true
	requirePinnedSourceAndGuacEvidenceSeparated: true
	requireCueAndPythonAdmissionRolesSeparated: true
	requireUpstreamTestAndLocalProbeDistinction: true
	requireQualificationStateIndependentOfMonitorState: true
	requireAuthoritySeparationDisclosure: true
	forbidGuacCandidateAsAdmittedFact: true
	forbidGuacProvenanceAsAdmissionOracle: true
	forbidBackendIdentifierAsStableSemanticIdentity: true
	forbidOperationalFailureAsSemanticRejection: true
	forbidQualifyPassAsSupportedHypothesis: true
	forbidCycloneDXForecastAsPinnedFixtureRewrite: true
	bootstrapMayEstablishBaselineWithoutHistoricalDelta: true
})
