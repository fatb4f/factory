package ctrlprofile

import core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"

#CtrlSurface: close({
	id: core.#NonEmptyString
	source: core.#NonEmptyString
	terms: [...core.#NonEmptyString] & [_, ...]
	impactFloor: core.#ImpactDecision
	localContractHint: core.#NonEmptyString
	localPaths: [...core.#NonEmptyString]
})

ctrlSurfaceCatalogue: [
	{id: "codex-protocol", source: "codex", terms: ["app-server-protocol", "ClientRequest", "ServerRequest", "ServerNotification", "turn", "thread", "MCP"], impactFloor: "contract-update", localContractHint: "agent/app-server protocol and controller request/response contracts", localPaths: ["spec/.codex/", "agents/tdd/.codex/", "integrations/openai/"]},
	{id: "codex-schema-projection", source: "codex", terms: ["schema/json", "config.schema.json", "schema_fixtures", "export schema"], impactFloor: "contract-update", localContractHint: "generated protocol/config schema projection consistency", localPaths: ["spec/.codex/config.toml", "integrations/openai/"]},
	{id: "codex-python-sdk", source: "codex", terms: ["sdk/python", "openai_codex", "generated/v2", "update_sdk_artifacts", "app server integration"], impactFloor: "contract-update", localContractHint: "Python-native Codex control adapter and generated transport bindings", localPaths: ["integrations/openai/", "packages/runtime/"]},
	{id: "codex-hooks-tools-policy", source: "codex", terms: ["PreToolUse", "PostToolUse", "apply_patch", "tool_exec", "permission", "sandbox", "approval", "mcp_servers"], impactFloor: "blocking-gate", localContractHint: "tool interception, policy, permission, and MCP execution boundary", localPaths: ["spec/.codex/config.toml", "spec/.codex/AGENTS.md", "agents/tdd/.codex/"]},
	{id: "codex-rollout-lineage", source: "codex", terms: ["rollout", "rollout_trace", "rollout reconstruction", "rollout migration", "rollout lineage", "thread store", "truncation"], impactFloor: "contract-update", localContractHint: "replayable session/thread evidence, lineage, reconstruction, migration, and truncation semantics", localPaths: ["packages/runtime/", "integrations/openai/"]},

	{id: "cpython-source-model", source: "cpython", terms: ["tokenize", "ast", "symtable", "compile", "code object", "dis", "frame", "traceback", "importlib", "inspect", "sys.monitoring"], impactFloor: "contract-update", localContractHint: "Python semantic/introspection evidence substrate", localPaths: ["packages/ppf/", "packages/qualification-workflow/", "spec/"]},
	{id: "cpython-regrtest", source: "cpython", terms: ["Lib/test/regrtest.py", "Lib/test/libregrtest", "python -m test", "testresult", "run_workers"], impactFloor: "contract-update", localContractHint: "upstream behavioral oracle selected by subsystem dependency closure", localPaths: ["spec/profiles/", "packages/qualification-workflow/"]},
	{id: "cpython-operational-probes", source: "cpython", terms: ["probe", "observation", "normalized instruction", "monitoring event", "frame correlation", "source position"], impactFloor: "contract-update", localContractHint: "local executable witnesses for CPython behavior", localPaths: ["spec/profiles/", "packages/qualification-workflow/"]},
	{id: "cpython-dependency-dag", source: "cpython", terms: ["parser", "AST", "symtable", "compiler", "bytecode", "eval", "monitoring", "frames", "importlib", "inspect"], impactFloor: "contract-update", localContractHint: "explicit source-to-subsystem dependency graph for impact propagation and test/probe selection", localPaths: ["spec/profiles/"]},
	{id: "cpython-control-executor", source: "cpython", terms: ["RunProbeRequest", "RunRegrtestSliceRequest", "CompareRevisionRequest", "graph executor", "marimo", "pydantic-graph"], impactFloor: "contract-update", localContractHint: "operational CPython plant: typed requests, graph execution, process adapters, normalized evidence, interactive projection", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},

	{id: "astral-parser-ast", source: "astral-python", terms: ["ruff_python_parser", "ruff_python_ast", "source range", "lexer", "parser", "AST"], impactFloor: "note", localContractHint: "Rust parser/AST observation plane correlated against CPython syntax and AST probes", localPaths: ["packages/ppf/", "packages/qualification-workflow/", "spec/profiles/"]},
	{id: "astral-static-semantic-index", source: "astral-python", terms: ["ruff_python_semantic", "ruff_python_index", "ruff_index", "ruff_db", "salsa", "binding", "scope"], impactFloor: "note", localContractHint: "Rust static semantic/index machinery used to avoid rebuilding solved source-analysis infrastructure", localPaths: ["packages/ppf/", "packages/qualification-workflow/", "spec/profiles/"]},
	{id: "astral-module-resolution", source: "astral-python", terms: ["ty_module_resolver", "ty_site_packages", "ruff_python_importer", "module resolution", "site-packages", "search path"], impactFloor: "note", localContractHint: "Rust module/import resolution evidence correlated with importlib and repository identity", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},
	{id: "astral-type-semantics", source: "astral-python", terms: ["ty_python_core", "ty_python_semantic", "type inference", "diagnostic", "symbol", "constraint"], impactFloor: "note", localContractHint: "ty semantic/type evidence as an analyzer observation, never CPython semantic authority", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},
	{id: "astral-ide-observation", source: "astral-python", terms: ["ty_ide", "ty_server", "ruff_server", "hover", "definition", "references", "document symbols"], impactFloor: "note", localContractHint: "IDE/LSP-facing projections for python-intel correlation and operator diagnostics", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},
	{id: "scip-semantic-identity", source: "scip", terms: ["SCIP", "scip.proto", "symbol", "occurrence", "document", "relationship", "definition", "reference", "source range"], impactFloor: "contract-update", localContractHint: "cross-file symbol identity spine joining analyzer occurrences to CPython/runtime/evaluation-world evidence without overriding CPython semantics", localPaths: ["packages/qualification-workflow/", "spec/profiles/", "integrations/openai/"]},

	{id: "otel-python-runtime", source: "otel-python-core", terms: ["trace", "span", "event", "metric", "log", "context", "OTLP", "TracerProvider", "MeterProvider"], impactFloor: "contract-update", localContractHint: "standard execution-observation and causal-context substrate for qualification runs", localPaths: ["packages/qualification-workflow/", "packages/runtime/", "spec/profiles/"]},
	{id: "otel-contrib-providers", source: "otel-python-contrib", terms: ["instrumentation", "BaseInstrumentor", "opentelemetry-instrumentation", "requests", "asyncio", "threading", "sqlite", "sqlalchemy", "system metrics"], impactFloor: "contract-update", localContractHint: "generic provider adapters acquire runtime plumbing while custom ctrl probes focus on semantic gaps", localPaths: ["packages/qualification-workflow/", "packages/runtime/"]},
	{id: "otel-genai-semantic-model", source: "otel-genai-semconv", terms: ["GenAI", "MCP", "OpenAI", "spans", "metrics", "events", "Weaver", "model", "YAML", "reference"], impactFloor: "contract-update", localContractHint: "machine-readable GenAI/MCP observation vocabulary and generation/compliance precedent for ctrl semantic telemetry extensions", localPaths: ["integrations/openai/", "spec/profiles/"]},
	{id: "otel-python-genai-realization", source: "otel-python-genai", terms: ["opentelemetry-util-genai", "openai", "openai-agents", "spans", "metrics", "logs", "instrumentation"], impactFloor: "note", localContractHint: "Python realization template for agent/model/tool observations sharing trace context with qualification execution", localPaths: ["integrations/openai/", "packages/runtime/"]},
	{id: "otel-arrow-otap", source: "otel-arrow", terms: ["OTAP", "OTLP", "Arrow", "record batch", "lossless", "star schema", "Arrow IPC"], impactFloor: "contract-update", localContractHint: "columnar telemetry transport preserving OpenTelemetry trace semantics without a bespoke SpanExporter-to-Arrow bridge", localPaths: ["packages/qualification-workflow/", "packages/runtime/", "spec/profiles/"]},
	{id: "otel-arrow-dataflow", source: "otel-arrow", terms: ["Dataflow Engine", "embeddable", "DataFusion", "Parquet", "durable buffer", "routing", "sampling", "filtering", "transform"], impactFloor: "note", localContractHint: "optional embeddable telemetry acquisition/transform/persistence engine below ctrl evidence interpretation", localPaths: ["packages/runtime/", "spec/profiles/"]},
	{id: "weaver-semantic-interface", source: "weaver", terms: ["registry", "resolve", "check", "diff", "schema", "template", "generate", "compatibility", "live check"], impactFloor: "contract-update", localContractHint: "projected DiagnosticPacket semantic-interface validation/resolution/conformance/projection; CUE remains semantic and qualification authority", localPaths: ["projected:integrations/openai/feedback", "projected:spec/feedback"]},
	{id: "dlt-external-observations", source: "dlt", terms: ["pipeline", "source", "resource", "extract", "normalize", "load", "Arrow", "DuckDB"], impactFloor: "note", localContractHint: "external records/claims are acquired observations requiring provenance and admission before fact status; they remain distinct from execution telemetry", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},
	{id: "fsspec-address-space", source: "fsspec", terms: ["fsspec", "AbstractFileSystem", "filesystem", "open_files", "url_to_fs"], impactFloor: "note", localContractHint: "optional external address-space abstraction for acquisition; addressability does not establish truth or admission", localPaths: ["projected:python-intel/acquisition"]},

	{id: "arrow-typed-relations", source: "arrow", terms: ["Arrow", "Table", "RecordBatch", "Schema", "IPC", "PyArrow"], impactFloor: "note", localContractHint: "typed columnar interchange for normalized python-intel/ctrl observations and lowered relations", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},
	{id: "duckdb-relational-substrate", source: "duckdb", terms: ["DuckDB", "relation", "SQL", "Arrow", "Parquet", "extension"], impactFloor: "note", localContractHint: "optional relational persistence/execution over admitted or lowered relations; never DPI semantic or qualification authority", localPaths: ["projected:packages/qualification-workflow/", "projected:spec/profiles/"]},
	{id: "ibis-semantic-query", source: "ibis", terms: ["Ibis", "Expr", "Table", "backend", "DuckDB", "Polars", "Arrow"], impactFloor: "note", localContractHint: "backend-independent relational expression projection; expression structure does not define contracted DPI meaning", localPaths: ["projected:packages/qualification-workflow/", "projected:spec/profiles/"]},
	{id: "polars-dataframe-execution", source: "polars", terms: ["Polars", "LazyFrame", "DataFrame", "Expr", "collect", "Arrow"], impactFloor: "note", localContractHint: "optional eager/lazy dataframe execution for relational projections; never semantic or qualification authority", localPaths: ["projected:packages/qualification-workflow/"]},
	{id: "marimo-diagnostic-projection", source: "marimo", terms: ["marimo", "reactive", "notebook", "app", "SQL", "DuckDB", "Arrow"], impactFloor: "note", localContractHint: "interactive diagnostic/workbench projection only; notebook state is never workflow, sealed-world, or qualification authority", localPaths: ["projected:packages/qualification-workflow/"]},
	{id: "pydantic-graph-executor", source: "pydantic-graph", terms: ["pydantic_graph", "Graph", "GraphRun", "BaseNode", "End"], impactFloor: "note", localContractHint: "replaceable typed execution-graph implementation for CPython/probe orchestration; CUE remains graph semantics and qualification authority", localPaths: ["packages/qualification-workflow/", "spec/profiles/"]},

	{id: "cue-evaluator", source: "cue", terms: ["unification", "explicitopen", "cue vet", "cue export", "closedness", "concreteness", "reference resolution"], impactFloor: "blocking-gate", localContractHint: "pinned external evaluator semantics realizing ctrl/spec semantic law, admission/closure constraints, and qualification gates", localPaths: ["spec/"]},
	{id: "uv-reproducibility", source: "uv", terms: ["uv lock", "--locked", "--exact", "--isolated", "workspace", "build --all-packages"], impactFloor: "note", localContractHint: "workspace lock, isolated test, and build reproducibility", localPaths: ["pyproject.toml", "uv.lock", "justfile"]},
	{id: "jj-agent-change-control", source: "jj", terms: ["workspace", "change id", "split", "conflict", "operation log"], impactFloor: "note", localContractHint: "TDD agent Jujutsu skills only; not S0 qualification authority", localPaths: ["agents/tdd/.codex/skills/"]},
]

ctrlClassificationPolicy: close({
	requireSurfaceMatch: true
	requireLocalImpactForReport: true
	requireSourceQualifiedEvidence: true
	requireGraphBindingForCpython: true
	requireProjectionBindingForCodexSchemasAndSDK: true
	requireAnalyzerGraphBindingForAstral: true
	requireAnalyzerAuthoritySeparation: true
	requireScipUpstreamBinding: true
	requireTelemetryGraphBindingForOtel: true
	requireTelemetryAuthoritySeparation: true
	requireExternalObservationAndExecutionObservationSeparation: true
	requireAdmissionBeforeExternalRecordFactStatus: true
	requireProjectTopologyBindingForCrossProjectClaims: true
	requireProjectionAuthoritySeparation: true
	requireSemanticKernelBindingForKernelClaims: true
	requireUpstreamBindingForRelationalInterfaceSources: true
	requireWeaverAuthoritySeparation: true
	requireMaterializedLocalConsumerForBlockingImpact: true
	upstreamRole: "evidence_only"
	allowedDecisions: ["none", "note", "contract-update", "blocking-gate"]
	severityMap: {
		none: "none"
		note: "note"
		"contract-update": "high"
		"blocking-gate": "critical"
	}
})
