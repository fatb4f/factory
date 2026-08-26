package ctrlprofile

import core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"

ctrlGraphNodes: [string]: core.#GraphNode

ctrlGraphNodes: {
	"codex-rust-protocol": {id: "codex-rust-protocol", domain: "codex", kind: "protocol-source", upstreamPaths: ["codex-rs/protocol/", "codex-rs/app-server-protocol/src/protocol/"], localConsumers: ["integrations/openai", "spec/.codex", "agents/tdd/.codex"]}
	"codex-json-schema": {id: "codex-json-schema", domain: "codex", kind: "schema-projection", upstreamPaths: ["codex-rs/app-server-protocol/schema/json/", "codex-rs/core/config.schema.json"], localConsumers: ["integrations/openai", "spec/.codex/config.toml"]}
	"codex-python-sdk": {id: "codex-python-sdk", domain: "codex", kind: "python-projection", upstreamPaths: ["sdk/python/src/openai_codex/", "sdk/python/scripts/update_sdk_artifacts.py"], localConsumers: ["integrations/openai", "packages/runtime"]}
	"codex-live-runtime": {id: "codex-live-runtime", domain: "codex", kind: "runtime", upstreamPaths: ["codex-rs/app-server/", "codex-rs/core/"], localConsumers: ["spec/.codex", "agents/tdd/.codex"]}
	"codex-rollout-store": {id: "codex-rollout-store", domain: "codex", kind: "rollout", upstreamPaths: ["codex-rs/rollout/", "codex-rs/thread-store/", "codex-rs/rollout-trace/"], localConsumers: ["packages/runtime", "integrations/openai"]}
	"codex-rollout-reconstruction": {id: "codex-rollout-reconstruction", domain: "codex", kind: "replay", upstreamPaths: ["codex-rs/core/src/session/rollout_reconstruction.rs", "codex-rs/thread-store/src/local/rollout_lineage.rs"], localConsumers: ["packages/runtime", "integrations/openai"]}

	"cpython-parser": {id: "cpython-parser", domain: "cpython", kind: "source", upstreamPaths: ["Parser/", "Lib/tokenize.py"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"cpython-ast": {id: "cpython-ast", domain: "cpython", kind: "semantic", upstreamPaths: ["Python/ast.c", "Lib/ast.py"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"cpython-symtable": {id: "cpython-symtable", domain: "cpython", kind: "semantic", upstreamPaths: ["Python/symtable.c", "Lib/symtable.py"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"cpython-compiler": {id: "cpython-compiler", domain: "cpython", kind: "compiler", upstreamPaths: ["Python/compile.c", "Python/codegen.c"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"cpython-code-object": {id: "cpython-code-object", domain: "cpython", kind: "runtime-identity", upstreamPaths: ["Objects/codeobject.c", "Include/cpython/code.h"], localConsumers: ["packages/qualification-workflow"]}
	"cpython-bytecode": {id: "cpython-bytecode", domain: "cpython", kind: "instruction-model", upstreamPaths: ["Lib/dis.py", "Python/bytecodes.c", "Python/generated_cases.c.h"], localConsumers: ["packages/qualification-workflow"]}
	"cpython-eval": {id: "cpython-eval", domain: "cpython", kind: "runtime", upstreamPaths: ["Python/ceval.c", "Python/executor_cases.c.h"], localConsumers: ["packages/qualification-workflow"]}
	"cpython-frames": {id: "cpython-frames", domain: "cpython", kind: "runtime-observation", upstreamPaths: ["Objects/frameobject.c", "Include/internal/pycore_frame.h"], localConsumers: ["packages/qualification-workflow"]}
	"cpython-monitoring": {id: "cpython-monitoring", domain: "cpython", kind: "runtime-observation", upstreamPaths: ["Python/instrumentation.c", "Include/cpython/monitoring.h"], localConsumers: ["packages/qualification-workflow"]}
	"cpython-importlib": {id: "cpython-importlib", domain: "cpython", kind: "module-identity", upstreamPaths: ["Lib/importlib/", "Python/import.c"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"cpython-inspect": {id: "cpython-inspect", domain: "cpython", kind: "introspection", upstreamPaths: ["Lib/inspect.py"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"cpython-regrtest": {id: "cpython-regrtest", domain: "cpython", kind: "upstream-test-runner", upstreamPaths: ["Lib/test/regrtest.py", "Lib/test/libregrtest/"], localConsumers: ["packages/qualification-workflow"]}
	"cpython-probes": {id: "cpython-probes", domain: "ctrl", kind: "local-probe-family", upstreamPaths: [], localConsumers: ["spec/profiles", "packages/qualification-workflow"]}
	"cpython-control-graph": {id: "cpython-control-graph", domain: "ctrl", kind: "execution-graph", upstreamPaths: [], localConsumers: ["spec/profiles", "packages/qualification-workflow"]}
	"cpython-marimo-workbench": {id: "cpython-marimo-workbench", domain: "ctrl", kind: "interactive-projection", upstreamPaths: [], localConsumers: ["packages/qualification-workflow"]}

	"astral-db-index": {id: "astral-db-index", domain: "astral-python", kind: "incremental-analysis-db", upstreamPaths: ["crates/ruff_db/", "crates/ruff_index/", "crates/ruff_python_index/"], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}
	"astral-parser": {id: "astral-parser", domain: "astral-python", kind: "rust-parser", upstreamPaths: ["crates/ruff_python_parser/"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"astral-ast": {id: "astral-ast", domain: "astral-python", kind: "rust-ast", upstreamPaths: ["crates/ruff_python_ast/"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"astral-ruff-semantic": {id: "astral-ruff-semantic", domain: "astral-python", kind: "static-semantic", upstreamPaths: ["crates/ruff_python_semantic/"], localConsumers: ["packages/ppf", "packages/qualification-workflow"]}
	"astral-module-resolver": {id: "astral-module-resolver", domain: "astral-python", kind: "module-resolver", upstreamPaths: ["crates/ty_module_resolver/", "crates/ty_site_packages/", "crates/ruff_python_importer/"], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}
	"astral-ty-core": {id: "astral-ty-core", domain: "astral-python", kind: "type-core", upstreamPaths: ["crates/ty_python_core/", "crates/ty_static/"], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}
	"astral-ty-semantic": {id: "astral-ty-semantic", domain: "astral-python", kind: "type-semantic", upstreamPaths: ["crates/ty_python_semantic/"], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}
	"astral-ide": {id: "astral-ide", domain: "astral-python", kind: "ide-projection", upstreamPaths: ["crates/ty_ide/", "crates/ty_server/", "crates/ruff_server/"], localConsumers: ["packages/qualification-workflow"]}
	"astral-cpython-correlation": {id: "astral-cpython-correlation", domain: "ctrl", kind: "static-dynamic-correlation", upstreamPaths: [], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}

	"otel-python-api-sdk": {id: "otel-python-api-sdk", domain: "otel-python-core", kind: "telemetry-api-sdk", upstreamPaths: ["opentelemetry-api/", "opentelemetry-sdk/", "exporter/"], localConsumers: ["packages/qualification-workflow", "packages/runtime", "spec/profiles"]}
	"otel-contrib-instrumentors": {id: "otel-contrib-instrumentors", domain: "otel-python-contrib", kind: "provider-adapters", upstreamPaths: ["opentelemetry-instrumentation/", "instrumentation/"], localConsumers: ["packages/qualification-workflow", "packages/runtime"]}
	"otel-genai-semconv-model": {id: "otel-genai-semconv-model", domain: "otel-genai-semconv", kind: "semantic-convention-model", upstreamPaths: ["model/", "docs/", "reference/"], localConsumers: ["integrations/openai", "spec/profiles"]}
	"otel-python-genai-instrumentation": {id: "otel-python-genai-instrumentation", domain: "otel-python-genai", kind: "genai-provider-adapters", upstreamPaths: ["instrumentation/", "util/opentelemetry-util-genai/"], localConsumers: ["integrations/openai", "packages/runtime"]}
	"otel-otlp": {id: "otel-otlp", domain: "otel-python-core", kind: "telemetry-transport", upstreamPaths: ["exporter/"], localConsumers: ["packages/qualification-workflow", "packages/runtime"]}
	"otel-arrow-otap": {id: "otel-arrow-otap", domain: "otel-arrow", kind: "columnar-telemetry-protocol", upstreamPaths: ["docs/otap-spec.md", "docs/data_model.md"], localConsumers: ["packages/qualification-workflow", "packages/runtime", "spec/profiles"]}
	"otel-arrow-recordbatch": {id: "otel-arrow-recordbatch", domain: "otel-arrow", kind: "arrow-record-batches", upstreamPaths: ["docs/data_model.md", "rust/otap-dataflow/crates/pdata/"], localConsumers: ["packages/qualification-workflow", "packages/runtime"]}
	"otel-arrow-dataflow": {id: "otel-arrow-dataflow", domain: "otel-arrow", kind: "embeddable-dataflow", upstreamPaths: ["rust/otap-dataflow/"], localConsumers: ["packages/runtime", "spec/profiles"]}
	"otel-arrow-storage": {id: "otel-arrow-storage", domain: "otel-arrow", kind: "columnar-persistence", upstreamPaths: ["rust/otap-dataflow/", "docs/data_model.md"], localConsumers: ["packages/runtime", "packages/qualification-workflow"]}
	"dlt-external-observations": {id: "dlt-external-observations", domain: "dlt", kind: "external-observation-acquisition", upstreamPaths: ["dlt/"], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}
	"ctrl-observation-context": {id: "ctrl-observation-context", domain: "ctrl", kind: "causal-observation-context", upstreamPaths: [], localConsumers: ["packages/qualification-workflow", "packages/runtime", "integrations/openai"]}
	"ctrl-correlation-identity": {id: "ctrl-correlation-identity", domain: "ctrl", kind: "semantic-correlation-identity", upstreamPaths: [], localConsumers: ["packages/qualification-workflow", "spec/profiles", "integrations/openai"]}
	"ctrl-relational-ingress": {id: "ctrl-relational-ingress", domain: "ctrl", kind: "arrow-relational-ingress", upstreamPaths: [], localConsumers: ["packages/qualification-workflow", "spec/profiles"]}
}

ctrlGraphEdges: [...core.#GraphEdge] & [_, ...]
ctrlGraphEdges: [
	{id: "codex-protocol-schema", from: "codex-rust-protocol", to: "codex-json-schema", kind: "projects-to", rationale: "exported JSON schemas project app-server protocol/config contracts"},
	{id: "codex-schema-sdk", from: "codex-json-schema", to: "codex-python-sdk", kind: "projects-to", rationale: "Python SDK generated transport artifacts must remain consistent with exported protocol schemas"},
	{id: "codex-protocol-runtime", from: "codex-rust-protocol", to: "codex-live-runtime", kind: "consumed-by", rationale: "app-server runtime implements the protocol"},
	{id: "codex-runtime-rollout", from: "codex-live-runtime", to: "codex-rollout-store", kind: "observed-by", rationale: "rollouts persist execution/thread observations"},
	{id: "codex-rollout-replay", from: "codex-rollout-store", to: "codex-rollout-reconstruction", kind: "projects-to", rationale: "stored rollout lineage is reconstructed into replayable session state"},

	{id: "cpython-parser-ast", from: "cpython-parser", to: "cpython-ast", kind: "depends-on", rationale: "AST construction consumes parsed syntax"},
	{id: "cpython-ast-symtable", from: "cpython-ast", to: "cpython-symtable", kind: "depends-on", rationale: "symbol-table analysis consumes AST scope structure"},
	{id: "cpython-symtable-compiler", from: "cpython-symtable", to: "cpython-compiler", kind: "depends-on", rationale: "compiler lowering consumes lexical binding classification"},
	{id: "cpython-compiler-code", from: "cpython-compiler", to: "cpython-code-object", kind: "projects-to", rationale: "compiler emits code objects"},
	{id: "cpython-code-bytecode", from: "cpython-code-object", to: "cpython-bytecode", kind: "projects-to", rationale: "code objects expose executable instruction streams"},
	{id: "cpython-bytecode-eval", from: "cpython-bytecode", to: "cpython-eval", kind: "consumed-by", rationale: "evaluation executes bytecode/instruction representation"},
	{id: "cpython-eval-frames", from: "cpython-eval", to: "cpython-frames", kind: "observed-by", rationale: "execution materializes frame state used for correlation"},
	{id: "cpython-eval-monitoring", from: "cpython-eval", to: "cpython-monitoring", kind: "observed-by", rationale: "sys.monitoring instrumentation observes interpreter events"},
	{id: "cpython-import-inspect", from: "cpython-importlib", to: "cpython-inspect", kind: "depends-on", rationale: "introspection/source lookup depends on module identity and origin"},
	{id: "cpython-dag-regrtest", from: "cpython-control-graph", to: "cpython-regrtest", kind: "validated-by", rationale: "dependency closure selects the upstream regression-test slice"},
	{id: "cpython-dag-probes", from: "cpython-control-graph", to: "cpython-probes", kind: "validated-by", rationale: "dependency closure selects local executable witnesses"},
	{id: "cpython-probes-workbench", from: "cpython-probes", to: "cpython-marimo-workbench", kind: "consumed-by", rationale: "Marimo projects typed operations and normalized observations; it is not authority"},

	{id: "astral-parser-ast", from: "astral-parser", to: "astral-ast", kind: "projects-to", rationale: "Ruff parser projects source into its Rust Python AST"},
	{id: "astral-ast-ruff-semantic", from: "astral-ast", to: "astral-ruff-semantic", kind: "consumed-by", rationale: "Ruff static semantic analysis consumes the shared Rust AST"},
	{id: "astral-db-ty-semantic", from: "astral-db-index", to: "astral-ty-semantic", kind: "consumed-by", rationale: "ty semantic analysis depends on Ruff database/index machinery and Salsa-backed indices"},
	{id: "astral-ast-ty-semantic", from: "astral-ast", to: "astral-ty-semantic", kind: "consumed-by", rationale: "ty semantic analysis consumes Ruff parser/AST infrastructure"},
	{id: "astral-resolver-ty-semantic", from: "astral-module-resolver", to: "astral-ty-semantic", kind: "consumed-by", rationale: "ty semantic analysis consumes module and site-packages resolution"},
	{id: "astral-core-ty-semantic", from: "astral-ty-core", to: "astral-ty-semantic", kind: "consumed-by", rationale: "ty semantic analysis consumes its Python type core and static vocabulary"},
	{id: "astral-ty-ide", from: "astral-ty-semantic", to: "astral-ide", kind: "projects-to", rationale: "IDE/server surfaces project analyzer semantics into navigation and diagnostics"},
	{id: "astral-ruff-correlation", from: "astral-ruff-semantic", to: "astral-cpython-correlation", kind: "consumed-by", rationale: "ctrl correlates Ruff static binding/scope observations without promoting them to CPython authority"},
	{id: "astral-ty-correlation", from: "astral-ty-semantic", to: "astral-cpython-correlation", kind: "consumed-by", rationale: "ctrl correlates ty type/module observations without treating inferred types as runtime truth"},
	{id: "cpython-ast-correlation", from: "cpython-ast", to: "astral-cpython-correlation", kind: "consumed-by", rationale: "CPython AST probes provide dynamic/compiler-side comparison evidence"},
	{id: "cpython-symtable-correlation", from: "cpython-symtable", to: "astral-cpython-correlation", kind: "consumed-by", rationale: "CPython lexical binding classification remains authoritative when analyzer resolution differs"},
	{id: "cpython-import-correlation", from: "cpython-importlib", to: "astral-cpython-correlation", kind: "consumed-by", rationale: "runtime module identity and origin qualify analyzer module-resolution observations"},
	{id: "astral-correlation-probes", from: "astral-cpython-correlation", to: "cpython-probes", kind: "validated-by", rationale: "local probes validate material analyzer/runtime disagreements and preserve both observations"},

	{id: "otel-core-observation", from: "otel-python-api-sdk", to: "ctrl-observation-context", kind: "consumed-by", rationale: "ctrl uses OpenTelemetry API/SDK context and signals as the generic execution-observation substrate"},
	{id: "otel-contrib-observation", from: "otel-contrib-instrumentors", to: "ctrl-observation-context", kind: "consumed-by", rationale: "generic Python integration instrumentors observe execution plumbing without replacing semantic probes"},
	{id: "otel-genai-model-realization", from: "otel-genai-semconv-model", to: "otel-python-genai-instrumentation", kind: "projects-to", rationale: "Python GenAI instrumentations realize GenAI semantic conventions"},
	{id: "otel-genai-observation", from: "otel-python-genai-instrumentation", to: "ctrl-observation-context", kind: "consumed-by", rationale: "agent/model/tool/MCP observations share the qualification run's trace context"},
	{id: "codex-otel-observation", from: "codex-live-runtime", to: "ctrl-observation-context", kind: "observed-by", rationale: "Codex agent and tool execution can be captured in the same causal trace as analysis and qualification work"},
	{id: "cpython-otel-observation", from: "cpython-control-graph", to: "ctrl-observation-context", kind: "observed-by", rationale: "CPython control operations emit execution observations without surrendering semantic authority"},
	{id: "probe-otel-observation", from: "cpython-probes", to: "ctrl-observation-context", kind: "observed-by", rationale: "domain-specific CPython probes attach semantic identifiers to causal telemetry"},
	{id: "astral-otel-correlation", from: "astral-cpython-correlation", to: "ctrl-correlation-identity", kind: "projects-to", rationale: "static/dynamic correlation emits stable semantic join identities separate from trace identity"},
	{id: "probe-correlation-identity", from: "cpython-probes", to: "ctrl-correlation-identity", kind: "projects-to", rationale: "probe and source identities bridge semantic evidence into execution telemetry"},
	{id: "correlation-context", from: "ctrl-correlation-identity", to: "ctrl-observation-context", kind: "consumed-by", rationale: "carrier policy projects only admitted semantic join keys into span/event/baggage carriers while preserving trace identity separately"},
	{id: "otel-context-otlp", from: "ctrl-observation-context", to: "otel-otlp", kind: "projects-to", rationale: "execution observations are exported through OTLP while retaining causal context"},
	{id: "otlp-otap", from: "otel-otlp", to: "otel-arrow-otap", kind: "projects-to", rationale: "OTel-Arrow provides non-lossy bidirectional conversion between OTLP and the columnar OTAP representation"},
	{id: "otap-recordbatch", from: "otel-arrow-otap", to: "otel-arrow-recordbatch", kind: "projects-to", rationale: "OTAP represents telemetry as multiple Arrow record batches arranged by signal"},
	{id: "recordbatch-dataflow", from: "otel-arrow-recordbatch", to: "otel-arrow-dataflow", kind: "consumed-by", rationale: "the embeddable Rust dataflow engine operates directly on columnar telemetry"},
	{id: "dataflow-storage", from: "otel-arrow-dataflow", to: "otel-arrow-storage", kind: "projects-to", rationale: "dataflow processors can persist durable Arrow IPC buffers and Parquet outputs"},
	{id: "otel-relational-ingress", from: "otel-arrow-storage", to: "ctrl-relational-ingress", kind: "projects-to", rationale: "Arrow IPC/Parquet telemetry becomes queryable relational input without inventing another telemetry schema"},
	{id: "dlt-relational-ingress", from: "dlt-external-observations", to: "ctrl-relational-ingress", kind: "projects-to", rationale: "externally acquired records/claims and execution telemetry converge at the relational/Arrow boundary while retaining separate provenance and admission state"},
]

ctrlTestBindings: [...core.#TestBinding] & [_, ...]
ctrlTestBindings: [
	{id: "test-compiler", node: "cpython-compiler", upstreamTests: ["test_compile", "test_compiler_assemble", "test_dis"], invocation: "./python -m test <selected tests>"},
	{id: "test-monitoring", node: "cpython-monitoring", upstreamTests: ["test_monitoring", "test_sys_settrace"], invocation: "./python -m test <selected tests>"},
	{id: "test-import", node: "cpython-importlib", upstreamTests: ["test_importlib", "test_import"], invocation: "./python -m test <selected tests>"},
	{id: "test-inspect", node: "cpython-inspect", upstreamTests: ["test_inspect"], invocation: "./python -m test <selected tests>"},
]

ctrlProbeBindings: [...core.#ProbeBinding] & [_, ...]
ctrlProbeBindings: [
	{id: "probe-ast", node: "cpython-ast", probe: "ast-shape", observations: ["node topology", "source positions"], normalization: ["stable node/type fields only"]},
	{id: "probe-symtable", node: "cpython-symtable", probe: "binding-graph", observations: ["local/global/nonlocal/free/cell/parameter classification"], normalization: ["stable binding categories"]},
	{id: "probe-compile", node: "cpython-compiler", probe: "compile-code-object", observations: ["code object identity", "nested code objects", "source positions"], normalization: ["exclude addresses and process-local identities"]},
	{id: "probe-dis", node: "cpython-bytecode", probe: "instruction-sequence", observations: ["opcode semantic sequence", "source position mapping"], normalization: ["exclude unstable offsets unless explicitly contracted"]},
	{id: "probe-monitoring", node: "cpython-monitoring", probe: "monitoring-events", observations: ["ordered event stream", "tool/event registration behavior"], normalization: ["exclude timing"]},
	{id: "probe-frame", node: "cpython-frames", probe: "frame-source-correlation", observations: ["frame/code/source linkage", "lasti/line correlation"], normalization: ["exclude object addresses"]},
	{id: "probe-import", node: "cpython-importlib", probe: "module-spec", observations: ["ModuleSpec", "origin", "loader identity class"], normalization: ["normalize repository root"]},
	{id: "probe-inspect", node: "cpython-inspect", probe: "inspect-source", observations: ["signature", "code/source identity", "source range"], normalization: ["normalize repository root"]},
	{id: "probe-astral-ast-correlation", node: "astral-cpython-correlation", probe: "astral-cpython-ast", observations: ["parser acceptance", "node topology", "source ranges", "syntax-version disagreement"], normalization: ["normalize source paths", "preserve analyzer and CPython identities separately"]},
	{id: "probe-astral-binding-correlation", node: "astral-cpython-correlation", probe: "astral-cpython-bindings", observations: ["Ruff/ty binding resolution", "CPython symtable classification", "disagreement class"], normalization: ["preserve unresolved analyzer state", "CPython evidence wins semantic conflicts"]},
	{id: "probe-astral-import-correlation", node: "astral-cpython-correlation", probe: "astral-cpython-imports", observations: ["analyzer module resolution", "ModuleSpec", "origin", "site-packages identity"], normalization: ["normalize repository and environment roots"]},
	{id: "probe-otel-causal-correlation", node: "ctrl-observation-context", probe: "otel-causal-correlation", observations: ["trace/span lineage", "qualification run identity", "repository revision", "operation identity", "probe/symbol/source occurrence/evidence join keys", "agent/tool lineage"], normalization: ["preserve trace and semantic identities separately", "apply ctrlTelemetryCarrierPolicy", "telemetry cannot manufacture missing semantic identity"]},
	{id: "probe-otlp-otap-roundtrip", node: "otel-arrow-otap", probe: "otlp-otap-roundtrip", observations: ["trace resource identity", "instrumentation scope", "trace_id/span_id/parent_span_id", "trace_state", "timestamps", "span kind/status", "span attributes", "events and event attributes", "links and link attributes", "ctrl correlation attributes"], normalization: ["canonicalize OTLP trace semantics before and after OTAP conversion", "ignore record-batch partitioning", "ignore dictionary encoding", "ignore batch and column ordering", "ignore physical Arrow representation"]},
]

ctrlExecutionGraphContract: close({
	semanticDefinition: "CUE"
	transportProjection: "Pydantic"
	initialExecutorCandidate: "pydantic-graph"
	interactiveProjectionCandidate: "marimo"
	staticAnalyzerSubstrate: "Astral Rust: Ruff parser/AST/index plus ty resolver/semantic machinery"
	executionObservationSubstrate: "OpenTelemetry Python API/SDK plus contrib and GenAI instrumentors"
	columnarTelemetrySubstrate: "OTel-Arrow OTAP / Arrow RecordBatches / Arrow IPC / Parquet"
	externalObservationAcquisitionSubstrate: "dlt"
	correlationCarrierPolicy: "ctrlTelemetryCarrierPolicy"
	marimoAuthority: false
	executorAuthority: false
	astralAnalyzerAuthority: false
	telemetryAuthority: false
	cpythonSemanticPrecedenceOnConflict: true
	operations: [
		"ResolveRevision",
		"ResolveBuild",
		"MapChangedPaths",
		"AcquireExternalObservations",
		"StartObservationContext",
		"AcquireAstralAnalysis",
		"ResolveSubsystemClosure",
		"SelectRegrtests",
		"SelectProbes",
		"RunRegrtests",
		"RunProbes",
		"EmitDomainObservations",
		"CorrelateStaticDynamic",
		"ExportOTLP",
		"ProjectOTAP",
		"PersistColumnarObservations",
		"NormalizeEvidence",
		"CorrelateEvidence",
		"Qualify",
	]
	regrtestProcessBoundary: "./python -m test"
	telemetryBoundary: "OTLP traces -> OTAP -> Arrow RecordBatches"
	otlpOtapP0: close({
		signal: "traces"
		canonicalComparison: "canonical OTLP trace semantics before conversion == canonical OTLP trace semantics after OTAP round-trip"
		included: ["resource identity", "instrumentation scope", "trace_id", "span_id", "parent_span_id", "trace_state", "timestamps", "span kind", "span status", "attributes", "events", "event attributes", "links", "link attributes", "ctrl correlation attributes"]
		excludedPhysical: ["record-batch partitioning", "dictionary encoding", "batch ordering", "column ordering", "physical Arrow representation"]
		deferredSignals: ["metrics", "logs"]
	})
	forbidLibregrtestLibraryDependency: true
	forbidTelemetryAsQualificationVerdict: true
	forbidOtelAsStaticSemanticAuthority: true
	forbidAcquisitionAdapterFactPromotion: true
})
