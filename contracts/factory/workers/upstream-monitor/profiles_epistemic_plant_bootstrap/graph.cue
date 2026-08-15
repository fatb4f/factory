package epistemicplantprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

epistemicPlantGraphNodes: [string]: core.#GraphNode

epistemicPlantGraphNodes: {
	"pinned-source-documents": {id: "pinned-source-documents", domain: "subject", kind: "semantic-authority", upstreamPaths: [], localConsumers: ["fixtures/corpus", "src/epistemic_plant/source.py"]}
	"cyclonedx-source-extractor": {id: "cyclonedx-source-extractor", domain: "cyclonedx", kind: "source-projection", upstreamPaths: ["schema/", "bom-1.4.schema.json"], localConsumers: ["src/epistemic_plant/source.py", "tests/test_source.py"]}
	"guac-ingestion": {id: "guac-ingestion", domain: "guac", kind: "acquisition", upstreamPaths: ["cmd/guacone/", "cmd/guacgql/"], localConsumers: ["src/epistemic_plant/guac.py"]}
	"guac-graphql-contract": {id: "guac-graphql-contract", domain: "guac", kind: "query-contract", upstreamPaths: ["pkg/assembler/", "pkg/assembler/graphql/", "cmd/guacgql/"], localConsumers: ["queries/dependencies.graphql", "src/epistemic_plant/guac.py"]}
	"guac-coordinate-normalizer": {id: "guac-coordinate-normalizer", domain: "subject", kind: "normalization", upstreamPaths: [], localConsumers: ["src/epistemic_plant/guac.py", "src/epistemic_plant/model.py"]}
	"graph-generation": {id: "graph-generation", domain: "subject", kind: "deterministic-transition", upstreamPaths: [], localConsumers: ["src/epistemic_plant/guac.py", "src/epistemic_plant/model.py", "src/epistemic_plant/experiment.py"]}
	"gemara-evidence": {id: "gemara-evidence", domain: "gemara", kind: "evidence-vocabulary", upstreamPaths: ["evidence/", "result/"], localConsumers: ["spec/schema.cue", "src/epistemic_plant/model.py"]}
	"admission-policy": {id: "admission-policy", domain: "subject", kind: "semantic-policy", upstreamPaths: [], localConsumers: ["src/epistemic_plant/admission.py", "spec/schema.cue"]}
	"cue-qualification": {id: "cue-qualification", domain: "cue", kind: "semantic-validator", upstreamPaths: ["cue/", "internal/core/", "internal/eval/"], localConsumers: ["src/epistemic_plant/qualification.py", "spec/schema.cue", "spec/poc.cue"]}
	"admission-receipts": {id: "admission-receipts", domain: "subject", kind: "traceability", upstreamPaths: [], localConsumers: ["src/epistemic_plant/admission.py", "src/epistemic_plant/model.py", "spec/schema.cue"]}
	"epistemic-observation": {id: "epistemic-observation", domain: "subject", kind: "derived-observation", upstreamPaths: [], localConsumers: ["src/epistemic_plant/experiment.py", "spec/schema.cue"]}
	"fresh-run-determinism": {id: "fresh-run-determinism", domain: "subject", kind: "qualification-invariant", upstreamPaths: [], localConsumers: ["src/epistemic_plant/experiment.py", "tests/eval/test_poc.py", "HYPOTHESIS_PROBLEM_STATEMENT.md"]}
	"bootstrap-gate": {id: "bootstrap-gate", domain: "subject", kind: "dependency-gate", upstreamPaths: [], localConsumers: ["scripts/bootstrap_check.py", "cue.mod/module.cue", "src/epistemic_plant/constants.py"]}
	"promotion-gate": {id: "promotion-gate", domain: "subject", kind: "decision-gate", upstreamPaths: [], localConsumers: ["scripts/evaluate.py", "spec/poc.cue", "justfile"]}
}

epistemicPlantGraphEdges: [...core.#GraphEdge] & [_, ...]
epistemicPlantGraphEdges: [
	{id: "source-spec-extractor", from: "cyclonedx-source-extractor", to: "pinned-source-documents", kind: "projects-to", rationale: "CycloneDX structure is projected into exact source dependency pairs while local fixture bytes remain the authority"},
	{id: "source-ingest", from: "pinned-source-documents", to: "guac-ingestion", kind: "consumed-by", rationale: "the same digest-pinned corpus is ingested into a fresh GUAC graph"},
	{id: "ingest-query", from: "guac-ingestion", to: "guac-graphql-contract", kind: "observed-by", rationale: "IsDependency queries observe the graph created from the pinned corpus"},
	{id: "query-normalize", from: "guac-graphql-contract", to: "guac-coordinate-normalizer", kind: "projects-to", rationale: "volatile graph response structure is normalized to stable package coordinates and provenance witnesses"},
	{id: "normalize-generation", from: "guac-coordinate-normalizer", to: "graph-generation", kind: "projects-to", rationale: "normalized relationships participate in a content-addressed graph generation"},
	{id: "source-admission", from: "pinned-source-documents", to: "admission-policy", kind: "consumed-by", rationale: "admission requires exact closure over pinned source declarations"},
	{id: "generation-admission", from: "graph-generation", to: "admission-policy", kind: "consumed-by", rationale: "GUAC graph candidates are inputs to admission, never admitted facts by themselves"},
	{id: "gemara-admission", from: "gemara-evidence", to: "admission-policy", kind: "consumed-by", rationale: "Gemara supplies the evidence/result vocabulary for proposed evaluations"},
	{id: "admission-cue", from: "admission-policy", to: "cue-qualification", kind: "validated-by", rationale: "CUE independently verifies source closure and proposal consistency"},
	{id: "admission-receipt", from: "cue-qualification", to: "admission-receipts", kind: "projects-to", rationale: "qualified decisions close candidate, evidence, verdict, and transition lineage"},
	{id: "receipt-observation", from: "admission-receipts", to: "epistemic-observation", kind: "projects-to", rationale: "epistemic observations are deterministic projections over admitted receipt digests"},
	{id: "generation-determinism", from: "graph-generation", to: "fresh-run-determinism", kind: "validated-by", rationale: "two independent graph generations must canonicalize identically"},
	{id: "receipt-determinism", from: "admission-receipts", to: "fresh-run-determinism", kind: "validated-by", rationale: "two admission runs must canonicalize identically"},
	{id: "observation-determinism", from: "epistemic-observation", to: "fresh-run-determinism", kind: "validated-by", rationale: "two observation projections must canonicalize identically"},
	{id: "bootstrap-qualification", from: "bootstrap-gate", to: "cue-qualification", kind: "validated-by", rationale: "module pins, imported schema closure, fixture digests, and compilation must validate before semantic qualification"},
	{id: "qualification-promotion", from: "fresh-run-determinism", to: "promotion-gate", kind: "validated-by", rationale: "promotion requires a supported, fully recorded experiment after executable qualification"},
]

epistemicPlantTestBindings: [string]: core.#TestBinding
epistemicPlantTestBindings: {
	"source-closure": {id: "source-closure", node: "pinned-source-documents", upstreamTests: ["tests/test_source.py"], invocation: "uv run --frozen --no-sync pytest tests/test_source.py"}
	"guac-contract": {id: "guac-contract", node: "guac-graphql-contract", upstreamTests: ["tests/test_guac.py"], invocation: "uv run --frozen --no-sync pytest tests/test_guac.py"}
	"admission-contract": {id: "admission-contract", node: "admission-policy", upstreamTests: ["tests/test_admission.py"], invocation: "uv run --frozen --no-sync pytest tests/test_admission.py"}
	"qualification-contract": {id: "qualification-contract", node: "cue-qualification", upstreamTests: ["tests/test_qualification.py"], invocation: "uv run --frozen --no-sync pytest tests/test_qualification.py"}
	"experiment-contract": {id: "experiment-contract", node: "fresh-run-determinism", upstreamTests: ["tests/eval/test_poc.py"], invocation: "uv run --frozen --no-sync pytest tests/eval/test_poc.py"}
}

epistemicPlantProbeBindings: [string]: core.#ProbeBinding
epistemicPlantProbeBindings: {
	bootstrap: {
		id: "bootstrap"
		node: "bootstrap-gate"
		probe: "just bootstrap-check"
		observations: ["module pin resolves", "imported CUE schema closure is stable", "fixture digests match", "specialization compiles"]
		normalization: ["retain exit status and deterministic assertion payload", "exclude runtime timestamps"]
	}
	quality: {
		id: "quality"
		node: "bootstrap-gate"
		probe: "just check"
		observations: ["ruff lint", "ruff format", "ty typecheck", "unit test result"]
		normalization: ["retain command status", "summarize failing checks by stable test/check identity"]
	}
	vet: {
		id: "vet"
		node: "cue-qualification"
		probe: "just vet"
		observations: ["CUE structural and relational contract validity"]
		normalization: ["retain exit status and schema diagnostics"]
	}
	eval: {
		id: "eval"
		node: "fresh-run-determinism"
		probe: "just eval"
		observations: ["two fresh GUAC graph generations", "admission decisions", "epistemic observations", "experiment verdict"]
		normalization: ["compare canonical graph/admission/observation forms", "exclude volatile backend IDs, ordering, and runtime timestamps"]
	}
	qualify: {
		id: "qualify"
		node: "promotion-gate"
		probe: "just qualify"
		observations: ["bootstrap gate", "implementation checks", "CUE vet", "experiment evaluation"]
		normalization: ["distinguish executable qualification from hypothesis verdict"]
	}
	promote: {
		id: "promote"
		node: "promotion-gate"
		probe: "just promote"
		observations: ["supported result", "recorded interfaces", "recorded limitations"]
		normalization: ["promotion is a local gate and does not imply publication"]
	}
}
