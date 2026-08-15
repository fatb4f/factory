package ctrlprofile

ctrlForbiddenAttractors: [
	"fatb4f/ctrl repository state treated as monitor authority",
	"upstream repository state treated as factory authority",
	"source channel compared without source identity",
	"cpython/main forecast treated as active Python 3.14 baseline",
	"CUE master treated as the pinned evaluator revision",
	"Codex Rust protocol, generated schema, Python SDK, and runtime collapsed into one observation",
	"rollout evidence treated as equivalent to live runtime without declared reconstruction correlation",
	"CPython source change classified without dependency-graph binding",
	"CPython regrtest pass treated as ctrl qualification",
	"test.libregrtest imported as a stable ctrl dependency",
	"Astral static analyzer output treated as CPython runtime/compiler authority",
	"Ruff and ty analyzer observations collapsed into CPython observations",
	"unresolved Astral symbol or import resolution promoted to a runtime fact",
	"Astral main forecast treated as the lock-selected ctrl analyzer baseline",
	"OpenTelemetry span, metric, log, or event treated as a qualification verdict",
	"OpenTelemetry telemetry treated as AST, symbol, scope, compiler, or runtime semantic authority",
	"generic contrib instrumentation treated as a substitute for CPython or qualification semantic probes",
	"GenAI semantic conventions treated as ctrl qualification authority",
	"OTAP projection treated as adding semantic facts not present in OTLP or declared ctrl correlation identity",
	"OTLP and OTAP observations collapsed without transport/projection identity",
	"dlt external facts collapsed into OpenTelemetry execution observations",
	"trace_id or span_id treated as a stable semantic symbol/probe identity",
	"Marimo notebook state treated as workflow or qualification authority",
	"pydantic-graph treated as semantic graph authority",
	"claimant-supplied probe verdict substituted for normalized observation",
	"run artifact written outside runs/<run_id>/",
	"manifest published before report, summary, and evidence",
	"latest pointer updated before manifest seal",
	"cross-repository write",
]

ctrlValidationAssertions: close({
	acceptedSignalExact: true
	profileIDExact: true
	contextRepositoryExact: true
	ctrlSpecAuthorityPreserved: true
	sourceQualifiedEvidenceRequired: true
	codexChannelsDistinct: true
	cpythonChannelsDistinct: true
	cuePinAndForecastDistinct: true
	astralSourceExplicit: true
	astralAnalyzerEvidenceOnly: true
	astralLockBaselineDistinctFromMainForecast: true
	astralCpythonCorrelationExplicit: true
	cpythonEvidencePrecedenceOnConflict: true
	otelSourcesExplicit: true
	otelTelemetryEvidenceOnly: true
	otelGenericAndDomainInstrumentationSeparated: true
	otelGenaiSemconvNotQualificationAuthority: true
	otelTraceIdentityDistinctFromSemanticIdentity: true
	otlpOtapProjectionExplicit: true
	otlpOtapRoundtripPreservationRequired: true
	dltExternalFactsDistinctFromRuntimeTelemetry: true
	codexProjectionEdgesExplicit: true
	cpythonDependencyEdgesExplicit: true
	regrtestUpstreamEvidenceOnly: true
	localProbesSeparateFromRegrtest: true
	marimoProjectionOnly: true
	executorReplaceable: true
	libregrtestLibraryDependencyForbidden: true
	factoryRunArtifactsCoLocated: true
	bundleManifestSealsArtifacts: true
	latestPointerOnly: true
	crossRepositoryWritesForbidden: true
	issueUpdatesForbidden: true
	workflowClosed: true
})

ctrlValidationPlan: close({
	commands: [
		"cue fmt --check contract.cue profiles_ctrl/*.cue",
		"cue vet -c=false ./...",
		"cue export ./profiles_ctrl -e publicContract --out json",
	]
	adapterLimitation: "The GitHub App actuator cannot execute CUE, CPython regrtest, local probes, Astral analyzer correlation, OpenTelemetry pipelines, OTLP/OTAP round-trip checks, Marimo, or pydantic-graph. Executable validation belongs to repository CI or a checked local environment."
})
