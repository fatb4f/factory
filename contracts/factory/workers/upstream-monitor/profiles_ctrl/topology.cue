package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlProjectStatus: "concrete" | "architectural" | "materialization" | "future"

#CtrlProjectFolder: close({
	id: core.#NonEmptyString
	folder: core.#NonEmptyString
	status: #CtrlProjectStatus
	role: core.#NonEmptyString
	parent?: core.#NonEmptyString
	authorityRole: core.#NonEmptyString
	owns: [...core.#NonEmptyString] & [_, ...]
	mustNotOwn: [...core.#NonEmptyString]
	flow?: [...core.#NonEmptyString]
})

ctrlProjectFolders: [string]: #CtrlProjectFolder

ctrlProjectFolders: {
	ctrl: {
		id: "ctrl"
		folder: "ctrl"
		status: "concrete"
		role: "repo-backed Codex mutation-control, qualification, and qualified-reactive world-evaluation experiment"
		authorityRole: "spec/ and CUE own semantic law, admission, closure, and qualification; parent Codex is the sole adaptive inference authority"
		owns: [
			"repository mutation control",
			"qualification contracts and verdict derivation",
			"projected immutable EvaluationWorld, DPI lowering, qualified-fixpoint, and sealed-world lifecycle",
			"Codex actuation through codex-sdk/app-server adapters",
			"agent/tool/MCP/repository/probe/evidence/world correlation",
			"projected deterministic diagnostic feedback relation",
			"federation-only compatibility evaluation",
		]
		mustNotOwn: [
			"upstream analyzer semantics",
			"CPython language/compiler/runtime semantics",
			"Weaver interface realization semantics as qualification authority",
			"heuristic inference inside monotonic qualification",
			"physical actuation inside an immutable evaluation world",
			"component-local package ownership belonging to sibling projects",
		]
	}
	"python-intel": {
		id: "python-intel"
		folder: "python-intel"
		status: "architectural"
		role: "Python-led software observation and interpretation architecture producing typed observations for ctrl admission"
		authorityRole: "observation/evaluation architecture only; not an analyzer and not qualification authority"
		owns: [
			"normalized static, package, build-time, and runtime observations",
			"semantic identity and cross-provider correlation",
			"typed software observations suitable for admission into ctrl EvaluationWorld instances",
		]
		mustNotOwn: [
			"CPython semantic authority",
			"Ruff or ty analyzer semantics",
			"ctrl admission, closure, or qualification verdicts",
		]
	}
	"pypi-wheel-pep-pipeline": {
		id: "pypi-wheel-pep-pipeline"
		folder: "PyPI/wheel/PEP pipeline"
		status: "materialization"
		role: "first concrete materialization workload for python-intel and the ctrl admission/lowering model"
		parent: "python-intel"
		authorityRole: "acquisition and observation pipeline; records require provenance/admission before fact status and relational execution does not become semantic authority"
		owns: [
			"PyPI API and index acquisition",
			"PEP, metadata, wheel, sdist, pyproject, build-system, source, installed-distribution, and runtime-probe observations",
			"normalization and candidate relational projection",
		]
		mustNotOwn: [
			"qualification authority",
			"runtime truth inferred from packaging metadata alone",
			"DPI semantic meaning delegated to a query engine",
		]
		flow: ["acquire", "normalize", "observe", "admit", "instantiate world", "lower", "derive", "qualify", "seal", "Arrow", "DuckDB", "Ibis", "Marimo"]
	}
	semagrams: {
		id: "semagrams"
		folder: "semagrams"
		status: "future"
		role: "future human-facing semantic mutation-transition model intended to fold into ctrl"
		authorityRole: "design substrate only until admitted into ctrl/spec; human mutation topology may lower to a different DPI computational topology"
		owns: [
			"relational mutation candidate representation",
			"precondition, transition, predicted-effect, required-observation, and qualification-contract structure",
		]
		mustNotOwn: [
			"current executable qualification authority",
			"DPI machine topology as human semantic meaning",
			"self-authorizing adapter or patch semantics",
		]
		flow: ["Preconditions", "TransitionGraph", "PredictedEffects", "RequiredObservations", "QualificationContract", "EvaluationWorld", "DPI lowering"]
	}
}

ctrlArchitecturePolicy: close({
	projectSeparationRequired: true
	componentLocalOwnershipRequired: true
	siblingPathDependenciesForbidden: true
	crossProjectClaimsRequireProvenance: true
	ctrlFederationRole: "pins, contract references, admitted qualified projections, federation-only evaluations, compatibility scenarios, and assembly commands"
	adapterRule: "adapters_observe_cue_derives_and_gates"
	scriptAuthority: false
	qualifiedReactiveKernel: ["semantic admission", "immutable EvaluationWorld", "DPI lowering", "monotonic derivation", "external CUE qualification", "qualified fixpoint", "immutable sealed bundle", "deterministic projection or effect intent", "new observation creates new EvaluationWorld"]
	pythonIntelPipeline: ["acquire", "normalize", "observe", "correlate", "admit", "lower", "evaluate", "project"]
	relationalProjection: ["fsspec", "Arrow", "DuckDB", "Ibis", "Polars", "Marimo"]
	interfaceProjection: ["canonical diagnostic relation", "DiagnosticPacket", "Weaver", "Codex-native context"]
	providerRoles: close({
		scip: "cross-file semantic symbol identity and source occurrence correlation"
		cpython: "Python language/compiler/runtime semantic authority"
		ruff_ty: "static analyzer observations"
		regrtest_pytest: "behavioral observations"
		ctrl_probes: "local executable witnesses lowered from ProbeSpec"
		dlt: "external API/JSON/file observation acquisition"
		fsspec: "optional external address-space abstraction"
		opentelemetry: "runtime execution and causal observation"
		arrow: "typed columnar interchange"
		duckdb: "optional relational persistence/execution substrate"
		ibis: "optional composable relational expression projection"
		polars: "optional dataframe/lazy execution substrate"
		marimo: "interactive diagnostic projection only"
		pydantic_graph: "replaceable typed execution-graph implementation only"
		weaver: "semantic interface validation, resolution, compatibility, conformance, and deterministic projection only"
		cue: "semantic law, admission/closure constraints, qualification derivation and gating authority under ctrl/spec"
	})
	kernelRoles: close({
		evaluation_world: "immutable authority/parameter/input/rule/provenance/closure boundary"
		dpi: "meaning-preserving lowered relational semantic evaluation IR"
		monotonic_evaluator: "provenance-preserving derivation engine; never authority"
		qualified_fixpoint: "derived closure that has satisfied the externally defined qualification contract"
		sealed_bundle: "immutable qualified world commit and append-oriented ledger entry"
		inference: "non-monotonic candidate generation/ranking outside qualification"
		actuation: "physical effect realization outside the sealed evaluation world"
	})
})
