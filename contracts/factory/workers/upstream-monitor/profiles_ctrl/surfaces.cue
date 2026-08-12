package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

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
	{id: "cue-evaluator", source: "cue", terms: ["unification", "explicitopen", "cue vet", "cue export", "closedness", "concreteness", "reference resolution"], impactFloor: "blocking-gate", localContractHint: "external evaluator semantics underlying ctrl/spec", localPaths: ["spec/"]},
	{id: "uv-reproducibility", source: "uv", terms: ["uv lock", "--locked", "--exact", "--isolated", "workspace", "build --all-packages"], impactFloor: "note", localContractHint: "workspace lock, isolated test, and build reproducibility", localPaths: ["pyproject.toml", "uv.lock", "justfile"]},
	{id: "jj-agent-change-control", source: "jj", terms: ["workspace", "change id", "split", "conflict", "operation log"], impactFloor: "note", localContractHint: "TDD agent Jujutsu skills only; not S0 qualification authority", localPaths: ["agents/tdd/.codex/skills/"]},
]

ctrlClassificationPolicy: close({
	requireSurfaceMatch: true
	requireLocalImpactForReport: true
	requireSourceQualifiedEvidence: true
	requireGraphBindingForCpython: true
	requireProjectionBindingForCodexSchemasAndSDK: true
	upstreamRole: "evidence_only"
	allowedDecisions: ["none", "note", "contract-update", "blocking-gate"]
	severityMap: {
		none: "none"
		note: "note"
		"contract-update": "high"
		"blocking-gate": "critical"
	}
})
