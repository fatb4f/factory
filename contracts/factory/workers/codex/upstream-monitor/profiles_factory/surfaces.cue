package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#Surface: close({
	id: core.#NonEmptyString
	terms: [_, ...core.#NonEmptyString]
	classes: [_, ...core.#SurfaceClass]
	impactFloor:       core.#ImpactDecision
	localContractHint: core.#NonEmptyString
})

surfaceCatalogue: [
	{id: "response-items", terms: ["ResponseItem", "TurnItem", "thread history", "image generation"], classes: ["protocol"], impactFloor: "contract-update", localContractHint: "response and thread item schemas"},
	{id: "agent-messages", terms: ["AgentMessage", "InterAgentCommunication", "NEW_TASK", "FINAL_ANSWER"], classes: ["protocol", "multi-agent"], impactFloor: "contract-update", localContractHint: "agent message envelope and lifecycle contracts"},
	{id: "context-fragments", terms: ["session_prefix", "context fragment", "compact", "compaction"], classes: ["context-window", "adapter"], impactFloor: "contract-update", localContractHint: "context injection, compaction, and prompt-fragment contracts"},
	{id: "rollout-trace", terms: ["rollout_trace", "thread_store", "rollout store"], classes: ["rollout-trace", "storage"], impactFloor: "note", localContractHint: "thread, rollout, and replay evidence contracts"},
	{id: "mcp-tools", terms: ["MCP", "tools/call", "approval metadata", "elicitation", "connector"], classes: ["mcp", "adapter", "policy"], impactFloor: "contract-update", localContractHint: "MCP tool lifecycle and policy contracts"},
	{id: "instructions", terms: ["AGENTS.md", "developer instructions", "skill namespace", "plugin manifest"], classes: ["policy", "docs"], impactFloor: "blocking-gate", localContractHint: "instruction chain and skill discovery contracts"},
	{id: "configuration", terms: ["feature flag", "config", "managed layers", "system_overlay", "experimental"], classes: ["config"], impactFloor: "note", localContractHint: "configuration layering and rollout-gate contracts"},
	{id: "authentication", terms: ["auth", "token", "login", "account", "permissions", "sandbox"], classes: ["security", "policy"], impactFloor: "blocking-gate", localContractHint: "authentication, authorization, sandbox, and approval contracts"},
	{id: "release-channel", terms: ["workspace.package.version", "latest-alpha-cli", "release", "alpha"], classes: ["release", "config"], impactFloor: "note", localContractHint: "main versus alpha release-channel evidence"},
]

classificationPolicy: close({
	requireSurfaceMatch:         true
	requireLocalImpactForReport: true
	upstreamRole:                "evidence_only"
	allowedDecisions: ["none", "note", "contract-update", "blocking-gate"]
	severityMap: {
		none:              "none"
		note:              "note"
		"contract-update": "high"
		"blocking-gate":   "critical"
	}
})
