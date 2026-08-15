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
		role: "repo-backed Codex mutation-control and qualification experiment"
		authorityRole: "spec/ and CUE own qualification semantics; parent Codex is the sole adaptive inference authority"
		owns: [
			"repository mutation control",
			"qualification contracts and verdict derivation",
			"Codex actuation through codex-sdk/app-server adapters",
			"agent/tool/MCP/repository/probe/evidence correlation",
			"federation-only compatibility evaluation",
		]
		mustNotOwn: [
			"upstream analyzer semantics",
			"CPython language/compiler/runtime semantics",
			"component-local package ownership belonging to sibling projects",
		]
	}
	"python-intel": {
		id: "python-intel"
		folder: "python-intel"
		status: "architectural"
		role: "Python-led observation and evaluation substrate"
		authorityRole: "observation/evaluation architecture only; not an analyzer and not qualification authority"
		owns: [
			"normalized static, package, build-time, and runtime observations",
			"semantic identity and cross-provider correlation",
			"typed relational projections for diagnosis",
		]
		mustNotOwn: [
			"CPython semantic authority",
			"Ruff or ty analyzer semantics",
			"ctrl qualification verdicts",
		]
	}
	"pypi-wheel-pep-pipeline": {
		id: "pypi-wheel-pep-pipeline"
		folder: "PyPI/wheel/PEP pipeline"
		status: "materialization"
		role: "first concrete materialization of python-intel"
		parent: "python-intel"
		authorityRole: "acquisition and observation pipeline; records require provenance/admission before fact status"
		owns: [
			"PyPI API and index acquisition",
			"PEP, metadata, wheel, sdist, pyproject, build-system, source, installed-distribution, and runtime-probe observations",
			"normalization and relational projection",
		]
		mustNotOwn: [
			"qualification authority",
			"runtime truth inferred from packaging metadata alone",
		]
		flow: ["acquire", "normalize", "analyze", "correlate", "evaluate", "Arrow", "DuckDB", "Ibis", "Marimo"]
	}
	semagrams: {
		id: "semagrams"
		folder: "semagrams"
		status: "future"
		role: "future mutation-graph qualification substrate intended to fold into ctrl"
		authorityRole: "design substrate only until admitted into ctrl/spec"
		owns: [
			"relational mutation candidate representation",
			"precondition, transition, predicted-effect, required-observation, and qualification-contract structure",
		]
		mustNotOwn: [
			"current executable qualification authority",
			"self-authorizing adapter or patch semantics",
		]
		flow: ["Preconditions", "TransitionGraph", "PredictedEffects", "RequiredObservations", "QualificationContract"]
	}
}

ctrlArchitecturePolicy: close({
	projectSeparationRequired: true
	componentLocalOwnershipRequired: true
	siblingPathDependenciesForbidden: true
	crossProjectClaimsRequireProvenance: true
	ctrlFederationRole: "pins, contract references, federation-only evaluations, compatibility scenarios, and assembly commands"
	adapterRule: "adapters_observe_cue_derives_and_gates"
	scriptAuthority: false
	pythonIntelPipeline: ["acquire", "normalize", "analyze", "correlate", "evaluate", "project"]
	relationalProjection: ["Arrow", "DuckDB", "Ibis", "Marimo"]
	providerRoles: close({
		scip: "cross-file semantic symbol identity and source occurrence correlation"
		cpython: "Python language/compiler/runtime semantic authority"
		ruff_ty: "static analyzer observations"
		regrtest_pytest: "behavioral observations"
		ctrl_probes: "local executable witnesses lowered from ProbeSpec"
		dlt: "external API/JSON/file observation acquisition"
		opentelemetry: "runtime execution and causal observation"
		arrow: "typed columnar interchange"
		duckdb: "relational substrate"
		ibis: "semantic relational query projection"
		marimo: "interactive diagnostic projection only"
		pydantic_graph: "replaceable typed execution-graph implementation only"
		cue: "qualification derivation and gating authority under ctrl/spec"
	})
})
