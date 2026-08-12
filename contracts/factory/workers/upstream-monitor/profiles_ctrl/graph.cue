package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

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
]

ctrlExecutionGraphContract: close({
	semanticDefinition: "CUE"
	transportProjection: "Pydantic"
	initialExecutorCandidate: "pydantic-graph"
	interactiveProjectionCandidate: "marimo"
	staticAnalyzerSubstrate: "Astral Rust: Ruff parser/AST/index plus ty resolver/semantic machinery"
	marimoAuthority: false
	executorAuthority: false
	astralAnalyzerAuthority: false
	cpythonSemanticPrecedenceOnConflict: true
	operations: [
		"ResolveRevision",
		"ResolveBuild",
		"MapChangedPaths",
		"AcquireAstralAnalysis",
		"ResolveSubsystemClosure",
		"SelectRegrtests",
		"SelectProbes",
		"RunRegrtests",
		"RunProbes",
		"CorrelateStaticDynamic",
		"NormalizeEvidence",
		"CorrelateEvidence",
		"Qualify",
	]
	regrtestProcessBoundary: "./python -m test"
	forbidLibregrtestLibraryDependency: true
})
