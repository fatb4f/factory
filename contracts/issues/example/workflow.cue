package issue

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_workflowPrimitive: impl.#MakePrimitive & {
	in: {
		name: "#CodexManifestSliceWorkflow"
		role: "ordered Codex procedure for expanding compact constructor manifests into patch work"
		requiredFields: ["inputs", "steps", "authority", "outputs", "validation", "completion"]
		constraints: [
			"read issue with gh issue view",
			"open manifest path when present",
			"read constructor authority from contracts/meta/impl",
			"expand manifest into concrete target CUE files",
			"run generated validation plan",
			"return completion report",
		]
		closed: true
	}
}

codexManifestSliceWorkflow: {
	kind: "codex-manifest-slice-workflow"
	inputs: ["gh issue view", "optional manifest path", "contracts/meta/impl"]
	authority: "CUE manifests and contracts/meta/impl"
	steps: [
		"read issue with gh issue view",
		"open manifest path when present",
		"read constructor authority from contracts/meta/impl",
		"expand manifest into concrete target CUE files",
		"run generated validation plan",
		"return completion report",
	]
	outputs: ["patch", "normalized issue manifest", "validation plan", "completion report"]
	validation: [
		"cue vet ./contracts/issues/example",
		"cue export ./contracts/issues/example -e codexManifestSliceWorkflow",
		"cue export ./contracts/issues/example -e codexManifestSliceCompletionContract",
	]
	primitive: _workflowPrimitive.out
}

codexManifestSliceCompletionContract: (impl.#MakeCompletionReport & {
	in: {
		primitives: [_workflowPrimitive.out.name]
		surfaces: ["codexManifestSliceWorkflow", "codexManifestSliceCompletionContract"]
		fixtures: ["negative.materializerScopeCreep"]
		checks: ["materializerScopeCreep"]
		commands: codexManifestSliceWorkflow.validation
		evidence: ["workflow export", "completion contract export", "validation command list"]
	}
}).out
