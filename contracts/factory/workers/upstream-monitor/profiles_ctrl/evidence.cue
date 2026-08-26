package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlRunEvidence: close({
	apiVersion: "factory.upstream-monitor.ctrl.evidence/v3"
	kind: "CtrlUpstreamEvidence"
	run_id: core.#NonEmptyString
	profile_id: "ctrl"
	dispatcher?: #CtrlDispatcherContext
	terminal_state: core.#TerminalState
	monitor_state: terminal_state
	qualification_state: core.#QualificationState
	authority_revision: core.#CommitSHA
	publication_revision?: core.#CommitSHA
	ctrl_revision: core.#CommitSHA
	bootstrap_baseline: bool
	sources: [...core.#SourceObservation] & [_, ...]
	graph: close({
		nodesObserved: [...core.#NonEmptyString] & [_, ...]
		edgesEvaluated: [...core.#NonEmptyString] & [_, ...]
		kernelRelationsEvaluated: [...core.#NonEmptyString]
		upstreamBindingsEvaluated: [...core.#NonEmptyString]
		testBindingsEvaluated: [...core.#NonEmptyString]
		probeBindingsEvaluated: [...core.#NonEmptyString]
	})
	items: [...core.#ReportItem]
	validation: close({
		authorityRead: bool
		ctrlContextRead: bool
		projectTopologyRead: bool
		semanticKernelRead: bool
		sourceChannelsDistinct: bool
		graphModelRead: bool
		correlationCarrierPolicyRead: bool
		interfaceBoundaryRead: bool
		publicationPlanRead: bool
		forbiddenAttractorsChecked: bool
		cueExecution: "not_available_to_github_app" | "executed_elsewhere"
		executableCpythonProbes: "not_executed" | "executed"
		executableRegrtest: "not_executed" | "executed"
		executableAstralCorrelation: "not_executed" | "executed"
		executableScipCorrelation: "not_executed" | "executed"
		executableOtelPipeline: "not_executed" | "executed"
		executableOtlpOtapRoundtrip: "not_executed" | "executed"
		executableRelationalProjection: "not_executed" | "executed"
		executableSemanticKernel: "not_executed" | "executed"
		executableWeaverProjection: "not_executed" | "executed"
		reportProjectionOnly: bool
		summaryProjectionOnly: bool
	})
})

ctrlEvidenceModel: close({
	semanticSourceForMarkdown: "evidence.json"
	requireExactSourceRevisionWhenResolved: true
	requireSourceAndChannelOnEveryObservation: true
	requireProjectTopologyBindingForCrossProjectClaims: true
	requireComponentOwnershipBoundary: true
	requireSemanticKernelBindingForKernelClaims: true
	requireUpstreamBindingForScipAndProjectionSources: true
	requireGraphNodeBindingForCpythonItems: true
	requireProjectionEdgeBindingForCodexSchemaSDKItems: true
	requireAnalyzerGraphBindingForAstralItems: true
	requireAnalyzerAndCpythonEvidenceSeparated: true
	requireScipIdentitySeparatedFromCpythonSemantics: true
	requireTelemetryGraphBindingForOtelItems: true
	requireTelemetryAndSemanticEvidenceSeparated: true
	requireExternalObservationAndExecutionObservationSeparation: true
	requireAdmissionBeforeExternalRecordFactStatus: true
	requireEvaluationWorldIdentityOnKernelCorrelation: true
	requireTraceAndSemanticIdentitySeparation: true
	requireAgentToolMutationLineage: true
	requireTelemetryCarrierPolicy: true
	requireOtlpOtapProjectionIdentity: true
	requireOtlpOtapP0TraceOnly: true
	requireRelationalProjectionAuthoritySeparation: true
	requireRelationalExecutionSeparatedFromDpiSemantics: true
	requireWeaverInterfaceAuthoritySeparation: true
	requireWorldScopedEvaluation: true
	requireMeaningPreservingDpiLowering: true
	requireComputedClosureAndQualifiedFixpointSeparation: true
	requireExternalCueQualificationGate: true
	requireSealedBundleImmutability: true
	requireNewWorldOnAdmittedInputOrParameterChange: true
	requireNegativeKnowledgeClosureWitness: true
	requireInferenceAndActuationOutsideQualificationKernel: true
	requireFederatedQualifiedProjectionAdmission: true
	requireUpstreamTestAndLocalProbeDistinction: true
	requireQualificationStateIndependentOfMonitorState: true
	forbidAnalyzerVerdictAsRuntimeTruth: true
	forbidAnalyzerOverrideOfCpythonEvidence: true
	forbidScipIdentityAsRuntimeTruth: true
	forbidTelemetryVerdictAsQualification: true
	forbidTelemetryAsStaticSemanticAuthority: true
	forbidGenericInstrumentationAsDomainProbeReplacement: true
	forbidRelationalProjectionAsQualification: true
	forbidRelationalExecutorAsDpiAuthority: true
	forbidWeaverAsQualificationAuthority: true
	forbidComputedClosureAsAutomaticQualification: true
	forbidWorldMutationAfterInstantiation: true
	forbidSealedBundleMutation: true
	forbidAbsenceAsFalseWithoutClosure: true
	forbidBulkSemanticIdentityBaggageProjection: true
	forbidSensitivePayloadTelemetryCarrier: true
	forbidOtlpOtapSemanticEnrichmentByInference: true
	forbidPhysicalArrowLayoutInP0SemanticComparator: true
	forbidUpstreamTestVerdictAsQualification: true
	bootstrapMayEstablishBaselineWithoutHistoricalDelta: true
})
