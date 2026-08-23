package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlKernelRelationKind: "admits-to" | "lowers-to" | "consumed-by" | "derives-to" | "qualifies-to" | "seals-to" | "projects-to" | "realized-by" | "observed-by"

#CtrlKernelRelation: close({
	id:                core.#NonEmptyString
	from:              core.#NonEmptyString
	to:                core.#NonEmptyString
	kind:              #CtrlKernelRelationKind
	rationale:         core.#NonEmptyString
	authorityBoundary: core.#NonEmptyString
})

#CtrlUpstreamBindingRole: "semantic-identity" | "semantic-interface" | "address-space" | "typed-interchange" | "relational-execution" | "diagnostic-projection" | "execution-implementation" | "qualification-engine"

#CtrlUpstreamBinding: close({
	id:                            core.#NonEmptyString
	sourceNode:                    core.#NonEmptyString
	localNode:                     core.#NonEmptyString
	role:                          #CtrlUpstreamBindingRole
	relation:                      "consumed-by" | "projects-to" | "validated-by"
	materialization:               "current" | "projected" | "optional"
	requiredForCurrentFrontier:    bool
	mayBlockWithoutLocalConsumer:  false
	rationale:                     core.#NonEmptyString
})

// These nodes extend the source/operational graph with the profile-local
// qualified-reactive kernel and with source bindings that were previously
// represented only as monitored surfaces. Empty upstreamPaths identify ctrl
// semantic obligations rather than claimant-supplied implementation facts.
ctrlGraphNodes: {
	"scip-semantic-index": {id: "scip-semantic-index", domain: "scip", kind: "semantic-identity-schema", upstreamPaths: ["scip.proto", "bindings/"], localConsumers: ["packages/qualification-workflow", "spec/profiles", "integrations/openai"]}
	"weaver-registry-interface": {id: "weaver-registry-interface", domain: "weaver", kind: "semantic-interface-realization", upstreamPaths: ["src/registry/", "crates/", "schemas/", "docs/specs/"], localConsumers: ["projected:ctrl-feedback-interface"]}
	"fsspec-address-space": {id: "fsspec-address-space", domain: "fsspec", kind: "external-address-space", upstreamPaths: ["fsspec/"], localConsumers: ["projected:python-intel-acquisition"]}
	"arrow-columnar-interchange": {id: "arrow-columnar-interchange", domain: "arrow", kind: "typed-columnar-interchange", upstreamPaths: ["python/pyarrow/", "cpp/src/arrow/"], localConsumers: ["projected:ctrl-relational-ingress"]}
	"duckdb-relational-engine": {id: "duckdb-relational-engine", domain: "duckdb", kind: "relational-execution-substrate", upstreamPaths: ["src/", "tools/pythonpkg/"], localConsumers: ["projected:ctrl-dpi-evaluation"]}
	"ibis-expression-layer": {id: "ibis-expression-layer", domain: "ibis", kind: "relational-expression-layer", upstreamPaths: ["ibis/expr/", "ibis/backends/"], localConsumers: ["projected:ctrl-dpi-evaluation"]}
	"polars-dataframe-engine": {id: "polars-dataframe-engine", domain: "polars", kind: "dataframe-execution-option", upstreamPaths: ["crates/", "py-polars/"], localConsumers: ["projected:ctrl-dpi-evaluation"]}
	"marimo-diagnostic-runtime": {id: "marimo-diagnostic-runtime", domain: "marimo", kind: "reactive-diagnostic-projection", upstreamPaths: ["marimo/"], localConsumers: ["projected:ctrl-diagnostic-projection"]}
	"pydantic-graph-upstream": {id: "pydantic-graph-upstream", domain: "pydantic-graph", kind: "replaceable-execution-implementation", upstreamPaths: ["pydantic_graph/"], localConsumers: ["projected:cpython-control-graph"]}
	"cue-evaluator-upstream": {id: "cue-evaluator-upstream", domain: "cue", kind: "external-qualification-evaluator", upstreamPaths: ["cue/", "internal/", "cmd/cue/"], localConsumers: ["spec/"]}

	"ctrl-evaluation-world": {id: "ctrl-evaluation-world", domain: "ctrl", kind: "immutable-semantic-world", upstreamPaths: [], localConsumers: ["projected:spec/", "projected:packages/qualification-workflow"]}
	"ctrl-dpi-relations": {id: "ctrl-dpi-relations", domain: "ctrl", kind: "semantic-evaluation-ir", upstreamPaths: [], localConsumers: ["projected:spec/", "projected:packages/qualification-workflow"]}
	"ctrl-monotonic-evaluator": {id: "ctrl-monotonic-evaluator", domain: "ctrl", kind: "monotonic-derivation-engine", upstreamPaths: [], localConsumers: ["projected:packages/qualification-workflow"]}
	"ctrl-derived-closure": {id: "ctrl-derived-closure", domain: "ctrl", kind: "derived-semantic-closure", upstreamPaths: [], localConsumers: ["projected:spec/"]}
	"ctrl-cue-qualification-gate": {id: "ctrl-cue-qualification-gate", domain: "ctrl", kind: "external-qualification-gate", upstreamPaths: [], localConsumers: ["spec/"]}
	"ctrl-qualified-fixpoint": {id: "ctrl-qualified-fixpoint", domain: "ctrl", kind: "qualified-semantic-result", upstreamPaths: [], localConsumers: ["projected:packages/qualification-workflow", "projected:integrations/openai"]}
	"ctrl-sealed-bundle": {id: "ctrl-sealed-bundle", domain: "ctrl", kind: "immutable-qualified-world-commit", upstreamPaths: [], localConsumers: ["projected:packages/qualification-workflow", "projected:packages/runtime"]}
	"ctrl-diagnostic-relation": {id: "ctrl-diagnostic-relation", domain: "ctrl", kind: "canonical-feedback-relation", upstreamPaths: [], localConsumers: ["projected:integrations/openai"]}
	"ctrl-diagnostic-packet": {id: "ctrl-diagnostic-packet", domain: "ctrl", kind: "semantic-interface-object", upstreamPaths: [], localConsumers: ["projected:integrations/openai"]}
	"ctrl-effect-intent": {id: "ctrl-effect-intent", domain: "ctrl", kind: "qualified-external-effect-intent", upstreamPaths: [], localConsumers: ["projected:actuator"]}
}

ctrlKernelRelations: [...#CtrlKernelRelation] & [_, ...]
ctrlKernelRelations: [
	{id: "relational-ingress-world", from: "ctrl-relational-ingress", to: "ctrl-evaluation-world", kind: "admits-to", rationale: "source-qualified observations enter a world only through semantic admission under fixed authority and closure", authorityBoundary: "ingress records remain observations until CUE-governed admission"},
	{id: "world-dpi-lowering", from: "ctrl-evaluation-world", to: "ctrl-dpi-relations", kind: "lowers-to", rationale: "domain-specific admitted semantics are lowered into the canonical relational evaluation IR", authorityBoundary: "lowering must preserve meaning and may not redefine source semantics"},
	{id: "dpi-evaluator", from: "ctrl-dpi-relations", to: "ctrl-monotonic-evaluator", kind: "consumed-by", rationale: "the evaluator consumes lowered relations and may optimize computational topology", authorityBoundary: "query/evaluation machinery derives but does not become semantic authority"},
	{id: "evaluator-closure", from: "ctrl-monotonic-evaluator", to: "ctrl-derived-closure", kind: "derives-to", rationale: "monotonic derivation converges on a provenance-preserving closure for one immutable world", authorityBoundary: "computed termination alone does not establish qualification"},
	{id: "closure-cue-gate", from: "ctrl-derived-closure", to: "ctrl-cue-qualification-gate", kind: "consumed-by", rationale: "the externally specified CUE criterion evaluates the derived closure and required obligations", authorityBoundary: "qualification meaning remains in ctrl/spec CUE"},
	{id: "cue-gate-fixpoint", from: "ctrl-cue-qualification-gate", to: "ctrl-qualified-fixpoint", kind: "qualifies-to", rationale: "a world result becomes an admitted qualified, rejected, or inconclusive semantic fixpoint only through the external gate", authorityBoundary: "the evaluator cannot self-authorize its result"},
	{id: "fixpoint-seal", from: "ctrl-qualified-fixpoint", to: "ctrl-sealed-bundle", kind: "seals-to", rationale: "qualified world identity, authority, parameters, input closure, derivation identity, result, and provenance are committed immutably", authorityBoundary: "later signals create new worlds and never mutate a sealed bundle"},
	{id: "seal-diagnostic", from: "ctrl-sealed-bundle", to: "ctrl-diagnostic-relation", kind: "projects-to", rationale: "consumer feedback is a deterministic reduction/projection of a sealed qualified world", authorityBoundary: "diagnostic reduction is not qualification"},
	{id: "diagnostic-packet", from: "ctrl-diagnostic-relation", to: "ctrl-diagnostic-packet", kind: "projects-to", rationale: "the canonical relation is projected into the first contracted feedback semantic object", authorityBoundary: "presentation/interface shape is distinct from semantic qualification meaning"},
	{id: "packet-weaver", from: "ctrl-diagnostic-packet", to: "weaver-registry-interface", kind: "realized-by", rationale: "Weaver is the first schema-first interface realization experiment for DiagnosticPacket", authorityBoundary: "Weaver validates, resolves, evolves, and projects interfaces; it does not qualify the world"},
	{id: "weaver-codex", from: "weaver-registry-interface", to: "codex-live-runtime", kind: "projects-to", rationale: "a conformant consumer-specific projection is delivered through hook/SDK/app-server context to the parent Codex process", authorityBoundary: "Codex consumes qualified diagnostics but remains outside qualification authority"},
	{id: "fixpoint-effect", from: "ctrl-qualified-fixpoint", to: "ctrl-effect-intent", kind: "projects-to", rationale: "a qualified result may project an external effect intent", authorityBoundary: "physical actuation occurs outside the immutable evaluation world and produces observations for a future world"},
]

ctrlUpstreamBindings: [...#CtrlUpstreamBinding] & [_, ...]
ctrlUpstreamBindings: [
	{id: "scip-correlation-binding", sourceNode: "scip-semantic-index", localNode: "ctrl-correlation-identity", role: "semantic-identity", relation: "consumed-by", materialization: "projected", requiredForCurrentFrontier: true, mayBlockWithoutLocalConsumer: false, rationale: "SCIP provides the cross-file symbol/source-occurrence identity spine but cannot manufacture CPython semantics"},
	{id: "weaver-feedback-binding", sourceNode: "weaver-registry-interface", localNode: "ctrl-diagnostic-packet", role: "semantic-interface", relation: "validated-by", materialization: "projected", requiredForCurrentFrontier: true, mayBlockWithoutLocalConsumer: false, rationale: "the first shared-interface experiment validates and projects DiagnosticPacket without moving authority from CUE"},
	{id: "fsspec-acquisition-binding", sourceNode: "fsspec-address-space", localNode: "ctrl-relational-ingress", role: "address-space", relation: "consumed-by", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "fsspec is an optional address-space abstraction for acquired observations"},
	{id: "arrow-ingress-binding", sourceNode: "arrow-columnar-interchange", localNode: "ctrl-relational-ingress", role: "typed-interchange", relation: "projects-to", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "Arrow carries typed relations without acquiring semantic authority"},
	{id: "duckdb-dpi-binding", sourceNode: "duckdb-relational-engine", localNode: "ctrl-dpi-relations", role: "relational-execution", relation: "consumed-by", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "DuckDB may execute/persist lowered relations but implementation choice does not define DPI semantics"},
	{id: "ibis-dpi-binding", sourceNode: "ibis-expression-layer", localNode: "ctrl-dpi-relations", role: "relational-execution", relation: "projects-to", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "Ibis may project composable relational expressions over DPI-compatible relations"},
	{id: "polars-dpi-binding", sourceNode: "polars-dataframe-engine", localNode: "ctrl-dpi-relations", role: "relational-execution", relation: "consumed-by", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "Polars remains an optional eager/lazy dataframe execution substrate"},
	{id: "marimo-diagnostic-binding", sourceNode: "marimo-diagnostic-runtime", localNode: "ctrl-diagnostic-relation", role: "diagnostic-projection", relation: "consumed-by", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "Marimo projects live diagnostics and never becomes workflow or qualification authority"},
	{id: "pydantic-graph-executor-binding", sourceNode: "pydantic-graph-upstream", localNode: "cpython-control-graph", role: "execution-implementation", relation: "consumed-by", materialization: "optional", requiredForCurrentFrontier: false, mayBlockWithoutLocalConsumer: false, rationale: "pydantic-graph remains a replaceable execution implementation beneath CUE-defined operation semantics"},
	{id: "cue-qualification-binding", sourceNode: "cue-evaluator-upstream", localNode: "ctrl-cue-qualification-gate", role: "qualification-engine", relation: "validated-by", materialization: "current", requiredForCurrentFrontier: true, mayBlockWithoutLocalConsumer: false, rationale: "the pinned CUE evaluator realizes ctrl/spec qualification semantics while remaining external semantics rather than factory authority"},
]

ctrlSemanticKernel: close({
	status: "accepted_architectural_direction_with_projected_realization"
	semanticAuthority: "ctrl/spec CUE"
	domainSemanticObjectsRemainDistinct: true
	uniformityBeginsAfterSemanticLowering: true
	evaluationWorld: close({
		immutable: true
		dimensions: ["authority", "parameters", "admitted inputs", "base facts", "derivation rules", "provenance", "closure"]
		changeCreatesNewWorld: ["authority", "parameters", "admitted observations", "closure", "derivation rules"]
	})
	dpi: close({
		role: "canonical lowered relational semantic evaluation IR"
		meaningPreservationRequired: true
		shapePreservationRequired: false
		optimizerMayChangeComputationalTopology: true
	})
	evaluation: close({
		monotonicDerivationRequired: true
		provenancePreservationRequired: true
		computedClosureIsQualification: false
		qualificationExternallyDefined: true
		terminalSemanticStates: ["qualified", "rejected", "inconclusive"]
	})
	seal: close({
		immutable: true
		binds: ["world identity", "authority identity/digest", "parameter identity/digest", "input closure", "DPI identity", "evaluator/optimizer identity", "fixpoint identity/digest", "qualification result", "proof/provenance"]
		ledgerAppendOriented: true
	})
	boundaries: close({
		inferenceOutsideQualification: true
		actuationOutsideEvaluation: true
		negativeKnowledgeRequiresQualifiedClosure: true
		federatedAuthorityComposesThroughAdmittedQualifiedProjections: true
		telemetryIsObservationOnly: true
		relationalExecutionIsNotAuthority: true
		weaverIsInterfaceRealizationOnly: true
	})
	firstSharedInterfaceExperiment: "Weaver-backed DiagnosticPacket"
	currentFrontier: [
		"one Codex turn",
		"two or more mutation candidates",
		"one candidate admission",
		"one immutable EvaluationWorld",
		"one materialization",
		"semantic identity",
		"one static differential observation",
		"one CPython/runtime differential probe",
		"OpenTelemetry causal correlation",
		"DPI lowering",
		"one monotonic derivation",
		"one CUE qualification criterion",
		"one qualified, rejected, or inconclusive fixpoint",
		"one sealed bundle",
		"one canonical DiagnosticPacket",
		"Weaver validation/projection",
		"hook/SDK feedback into parent Codex context",
		"next Codex inference",
	]
	legacyOperationalGraphRole: "ctrlExecutionGraphContract remains a subordinate CPython/probe/telemetry operation graph and does not define the qualified-reactive semantic kernel"
})
