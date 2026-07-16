package cuestrapprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#Surface: close({
	id:                core.#NonEmptyString
	terms:             [_, ...core.#NonEmptyString]
	classes:           [_, ...core.#SurfaceClass]
	impactFloor:       core.#ImpactDecision
	localContractHint: core.#NonEmptyString
	purposes:          [_, ...#CuestrapPurposeID]
	localPaths:        [_, ...core.#NonEmptyString]
})

surfaceCatalogue: [
	{
		id: "codex-hook-ingress"
		terms: ["PreToolUse", "PostToolUse", "hook_event_name", "hookSpecificOutput", "permissionDecision", "tool_use_id"]
		classes: ["protocol", "adapter", "policy"]
		impactFloor: "blocking-gate"
		localContractHint: "closed Codex hook ingress and response envelopes"
		purposes: ["supervisory-session-controller"]
		localPaths: [".codex/config.toml", ".codex/hooks/cuestrap_tool_supervisor.py", "src/cue-workbook/supervisory_hooks/contracts.cue", "src/cue-workbook/supervisory_hooks/models.py"]
	},
	{
		id: "session-turn-identity"
		terms: ["session_id", "turn_id", "transcript_path", "permission_mode", "model", "session ID", "turn ID"]
		classes: ["protocol", "storage"]
		impactFloor: "contract-update"
		localContractHint: "run, attempt, session, and turn identity binding"
		purposes: ["supervisory-session-controller"]
		localPaths: ["src/cue-workbook/supervisory_hooks/models.py", "src/cue-workbook/supervisory_hooks/supervisor.py", "src/cue-workbook/supervisory_hooks/ledger.py"]
	},
	{
		id: "tool-dispatch-classification"
		terms: ["tool_name", "tool_input", "tool_response", "Bash", "apply_patch", "unified shell", "tool dispatch"]
		classes: ["adapter", "policy", "protocol"]
		impactFloor: "blocking-gate"
		localContractHint: "phase-sensitive tool classification and mutation/evaluation gates"
		purposes: ["supervisory-session-controller"]
		localPaths: ["src/cue-workbook/supervisory_hooks/policy.py", "src/cue-workbook/supervisory_hooks/supervisor.py"]
	},
	{
		id: "permission-sandbox-approval"
		terms: ["permission_mode", "bypassPermissions", "dontAsk", "acceptEdits", "sandbox", "approval", "permissions", "authorization"]
		classes: ["security", "policy"]
		impactFloor: "blocking-gate"
		localContractHint: "permission-mode vocabulary, sandbox behavior, and fail-closed admission"
		purposes: ["supervisory-session-controller"]
		localPaths: ["src/cue-workbook/supervisory_hooks/contracts.cue", "src/cue-workbook/supervisory_hooks/models.py", "src/cue-workbook/supervisory_hooks/policy.py"]
	},
	{
		id: "mcp-code-mode"
		terms: ["MCP", "tools/call", "resources/list", "list_sessions", "execute_code", "code mode", "marimo", "structuredContent"]
		classes: ["mcp", "adapter", "protocol"]
		impactFloor: "contract-update"
		localContractHint: "MCP dispatch, Marimo code-mode transactions, and structured observations"
		purposes: ["supervisory-session-controller", "idiomatic-cue-workbook-harness"]
		localPaths: [".codex/config.toml", "src/cue-workbook/workbook_cli.py", "src/cue-workbook/cue-workbook.py", "src/cue-workbook/supervisory_hooks/policy.py"]
	},
	{
		id: "tool-result-error-semantics"
		terms: ["tool response", "tool result", "isError", "reported error", "content", "structuredContent", "additionalContext"]
		classes: ["protocol", "mcp", "adapter"]
		impactFloor: "contract-update"
		localContractHint: "post-tool outcome classification, quarantine, and raw observation handling"
		purposes: ["supervisory-session-controller", "idiomatic-cue-workbook-harness"]
		localPaths: ["src/cue-workbook/supervisory_hooks/supervisor.py", "src/cue-workbook/supervisory_hooks/policy.py", "src/cue-workbook/harness.py"]
	},
	{
		id: "instruction-skill-policy"
		terms: ["AGENTS.md", "developer instructions", "skill", "plugin manifest", "instruction chain", "dynamic skill"]
		classes: ["policy", "docs"]
		impactFloor: "blocking-gate"
		localContractHint: "repository-local Codex policy, session phases, and tool-use constraints"
		purposes: ["supervisory-session-controller", "idiomatic-cue-workbook-harness"]
		localPaths: [".codex/AGENTS.md", ".codex/config.toml"]
	},
	{
		id: "context-turn-lifecycle"
		terms: ["session_prefix", "context fragment", "compaction", "turn context", "context window", "conversation state"]
		classes: ["context-window", "adapter", "storage"]
		impactFloor: "contract-update"
		localContractHint: "session continuity, turn attempts, and workbook/controller context boundaries"
		purposes: ["supervisory-session-controller", "idiomatic-cue-workbook-harness"]
		localPaths: ["src/cue-workbook/supervisory_hooks/supervisor.py", "src/cue-workbook/cue-workbook.py", "src/cue-workbook/workbook_cli.py"]
	},
	{
		id: "multi-agent-session-control"
		terms: ["multi-agent", "subagent", "spawn", "agent role", "agent job", "notification"]
		classes: ["multi-agent", "protocol", "policy"]
		impactFloor: "note"
		localContractHint: "future supervisory ownership and session/attempt boundaries across agents"
		purposes: ["supervisory-session-controller"]
		localPaths: ["src/cue-workbook/supervisory_hooks/models.py", "src/cue-workbook/supervisory_hooks/supervisor.py"]
	},
	{
		id: "release-channel"
		terms: ["workspace.package.version", "latest-alpha-cli", "release", "alpha", "CLI version"]
		classes: ["release", "config"]
		impactFloor: "note"
		localContractHint: "independent main and alpha baselines for supported hook and MCP behavior"
		purposes: ["supervisory-session-controller", "idiomatic-cue-workbook-harness"]
		localPaths: [".codex/config.toml", "README.md"]
	},
]

classificationPolicy: close({
	requireSurfaceMatch:          true
	requireLocalImpactForReport:  true
	requirePurposeAssignment:     true
	requireCurrentContextRead:    true
	upstreamRole:                 "evidence_only"
	contextRepositoryRole:        "subject_context_not_monitor_authority"
	allowedDecisions:             ["none", "note", "contract-update", "blocking-gate"]
	severityMap: {
		none:              "none"
		note:              "note"
		"contract-update": "high"
		"blocking-gate":  "critical"
	}
})
