package upstream_monitor

// Generated from interactive upstream-monitor report runs on 2026-06-23.
// Upstream evidence only; local CUE contracts remain authority.

openaiCodexRuns: {
	"run-001": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "initial mav2/response metadata sweep"
		branchSurfaces: ["main", "alpha-latest"]
		classes: [
			"protocol",
			"multi-agent",
			"mcp",
			"storage",
			"rollout-trace",
			"config",
			"security",
			"context-window",
		]
		impact: "contract-update"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#28561 ResponseItemMetadata.source_call_id",
			"#28368 MAv2 envelopes NEW_TASK MESSAGE FINAL_ANSWER",
			"#28685 multiAgentMode fragment",
			"#28406 turn-scoped tool router",
			"#28407 optional MCP startup",
			"#28647 MCP OAuth refresh",
			"#28656 image-generation persistence",
		]
	}
	"run-002": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "response metadata rename and item id boundary"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["protocol", "storage", "context-window", "mcp", "config", "policy", "docs", "security"]
		impact: "contract-update"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#28968 ResponseItem.metadata passthrough rename",
			"#28814 ResponseItem IDs at history boundary",
			"#28942 orchestrator skills/MCP toggles",
			"#28993 child_agents_md removal",
			"#28953 UUIDv7 context-window IDs",
			"#28914 MCP sandbox metadata scoping",
		]
	}
	"run-003": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "oauth discovery, remote env lifecycle, and context ids"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "security", "adapter", "storage", "protocol", "context-window", "config", "multi-agent"]
		impact: "contract-update"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29022 MCP OAuth protected-resource discovery",
			"#28674 remote environment connection lifecycle",
			"#28814 ResponseItem ID allocation",
			"#28953 UUIDv7 context-window IDs",
			"#28968 metadata passthrough rename",
			"#28942 orchestrator skills/MCP",
			"#28685 multiAgentMode",
		]
	}
	"run-004": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "mav2 namespace, env refresh, network approvals"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["multi-agent", "protocol", "context-window", "adapter", "rollout-trace", "config", "policy", "security", "docs"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29067 MAv2 collaboration namespace",
			"#29073 request-scoped environment context refresh",
			"#29086 raw response item compatibility note",
			"#29065 tool timing metadata",
			"#28942 orchestrator skills/MCP",
			"#28859 permission presets endpoint",
			"#28899 network approvals by environment",
			"#28958 AGENTS.md from foreign environments",
		]
	}
	"run-005": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "remote sandbox intent and inventory scope"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["security", "adapter", "policy", "storage", "rollout-trace", "config", "context-window"]
		impact: "contract-update"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29113 executor-side remote sandbox enforcement",
			"#29108 portable sandbox intent",
			"#29109 direct rollout-history parse",
			"#29093 threadId for skills/list plugin/list",
			"#29082 connector skills feature toggle",
			"0.142.0-alpha.4",
		]
	}
	"run-006": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "compacted ids, rollout budget, network gate"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["protocol", "storage", "context-window", "rollout-trace", "security", "adapter", "multi-agent", "config"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29012 compacted replacement history ResponseItem IDs",
			"#28707 rollout budget exhaustion abort lifecycle",
			"#29099 remote exec argv plus sandbox intent",
			"#28899 network approvals scoped by environment",
			"#28683 deferred executor snapshots",
			"#28792/#28685 persisted multiAgentMode",
			"#28942 orchestrator skills/MCP",
			"0.142.0-alpha.7",
		]
	}
	"run-007": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "PathUri and plugin manifest draft stack"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["adapter", "security", "protocol", "mcp", "config", "storage", "rollout-trace", "context-window", "policy"]
		impact: "blocking-gate-if-merged"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29158 PathUri URI-only deserialization",
			"#29164 cross-platform PathUri lexical helpers",
			"#29165 plugin manifest resource resolver",
			"#29166 raw apply_patch path spellings",
			"#29173 periodic plugin refresh draft",
			"#29154 settings/resume during MCP startup",
			"#28944 skills guidance instructions",
			"#28806 checkpoint-backed resume/fork",
		]
	}
	"run-008": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "recent PR lifecycle sweep"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "security", "adapter", "context-window", "storage", "config", "policy", "protocol"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29268 MCP sandbox metadata revert",
			"#29266 image writes via ExecutorFileSystem",
			"#29263 Sites preview sandbox",
			"#29259 mcp_history thread hint prototype",
			"#29256 context-window lineage IDs",
			"#29255 token-budget reminder",
			"#29252 environment world state",
			"#29249 replayable WorldState",
			"#29245 Codex Apps MCP refresh",
			"#29244 installed-plugin refresh",
			"#29181 image artifact dir",
			"#29166 apply_patch raw paths",
		]
	}
	"run-009": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "world-state/token-budget and MCP injection report"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "context-window", "security", "policy", "storage", "protocol", "config", "adapter"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29268 MCP sandbox metadata revert",
			"#29259 mcp_history thread hint injection",
			"#29256 context-window lineage IDs",
			"#29252 typed world state",
			"#29249 WorldState snapshots/diffs",
			"#29255 token-budget reminder",
			"#29263 Sites preview",
			"#29266 ExecutorFileSystem image writes",
			"0.142.0-alpha.9",
		]
	}
	"run-010": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "merged mcp_history and token-budget simplification"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "context-window", "security", "adapter", "protocol", "storage", "config", "rollout-trace", "policy"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29259 merged mcp_history/thread_hint",
			"#29108 sandbox intent transport",
			"#29295 simplify token-budget context",
			"#29255 token-budget reminder",
			"#28814 ResponseItem IDs",
			"#28942 orchestrator skills/MCP",
			"#29006 skill description model-visible cap",
			"#29042 rollout persistence/skill latency tracing",
			"0.142.0-alpha.9",
		]
	}
	"run-011": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "inline instructions and multiAgentMode simplification"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "context-window", "security", "policy", "storage", "protocol", "multi-agent", "config", "rollout-trace"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29259 MCP thread hint injection",
			"#29305 inline model instructions",
			"#29324 simplify multi-agent mode controls",
			"#29295 token-budget context",
			"#29282 live context diffing into WorldState",
			"#28806 resume/fork checkpoint optimization",
			"0.142.0-alpha.9",
		]
	}
	"run-012": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "MCP sandbox JSON and session/thread storage"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "security", "adapter", "policy", "context-window", "storage", "protocol", "multi-agent", "rollout-trace", "config", "UI"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29259 mcp_history injection",
			"#29358 codex sandbox consumes MCP sandbox state JSON",
			"#29305 inline model instructions",
			"#29324 multiAgentMode sole control",
			"#29295 token-budget context",
			"#29327 session IDs across resume",
			"#29367 thread resume/fork optimization",
			"#29352 thread-store repair ownership",
			"#29371 safety buffering event",
			"#29375 npm marketplace plugin sources",
			"#28968 ResponseItem metadata rename",
			"#28561 MAv2 source_call_id",
			"0.142.0-alpha.10",
		]
	}
	"run-013": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "safety buffering and MCP sandbox-state report"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["protocol", "UI", "policy", "mcp", "adapter", "security", "context-window", "storage", "multi-agent", "rollout-trace", "config"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29259 mcp_history injection",
			"#29371 safety buffering app-server event",
			"#29358 MCP sandbox state JSON",
			"#29305 inline model instructions",
			"#29324 multiAgentMode sole control",
			"#29327 session IDs across resume",
			"#29367 resume/fork optimization",
			"#29352 thread-store names/repair",
			"#29375 npm plugin sources",
			"#28968 ResponseItem metadata rename",
			"0.142.0-alpha.10",
		]
	}
	"run-014": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "remote sandbox execution and auto-compaction"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["adapter", "security", "protocol", "storage", "multi-agent", "rollout-trace", "config", "context-window", "policy"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29259 mcp_history injection",
			"#29113 remote executor applies sandbox intent",
			"#29108 transport sandbox intent",
			"#29327 session IDs",
			"#29371 safety buffering event",
			"#29324 multiAgentMode controls",
			"#28260 auto-compaction opt-out",
			"#29393 auto-compaction feature access",
			"#29295 token-budget context",
			"0.142.0-alpha.10",
		]
	}
	"run-015": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "PathUri strictness, app-server compatibility, local git transport"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["security", "adapter", "policy", "protocol", "UI", "storage", "multi-agent", "config", "context-window"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29470 deny Git transport for local-only ops",
			"#29158 PathUri URI-only deserialization",
			"#29472 legacy cwd strings in app-server exec events",
			"#29473 safety buffering treatment metadata",
			"#26009 threadCatalog metadata subscriptions",
			"#28968 ResponseItem metadata rename",
			"remote sandbox denial reporting after #29113",
			"#29393 auto-compaction feature access",
			"#29371 safety buffering event",
			"0.142.0-alpha.10",
		]
	}
	"run-016": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "MCP cookies, permissions rules, context-window wrapper"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "adapter", "security", "policy", "config", "context-window", "protocol", "rollout-trace", "storage", "UI"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29516 MCP HTTP Cloudflare affinity cookies",
			"#29500 permissions-scoped exec rules",
			"#29494 context_window wrapper",
			"#29493 remote stdio MCP foreign cwd",
			"#29512 Codex Apps identity in MCP clients",
			"#29514 rollout-budget initial prefill skipped",
			"#29509 app-server protocol compatibility check",
			"#29508 dynamic-tool failures in code mode",
			"#29498 rollout persistence byte metrics",
			"#29511 redundant manager state removal",
			"0.142.0",
		]
	}
	"run-017": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "AdditionalTools, imagegenbasic, MCP tool search"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "adapter", "security", "protocol", "UI", "config", "context-window", "policy", "storage", "multi-agent"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29516 MCP HTTP affinity cookies",
			"#29577 ResponseItem::AdditionalTools",
			"#29576 imagegenbasic mode",
			"#29500 permissions-scoped exec rules",
			"#29486 MCP tool search by default",
			"#29493 remote stdio MCP cwd",
			"#28360 ResponseItem metadata turn_id",
			"0.143.0-alpha.4",
			"0.142.0",
		]
	}
	"run-018": {
		schema: "factory.upstream-monitor.run.v1"
		source: "conversation:openai-codex-upstream-monitor"
		repository: "openai/codex"
		observedAt: "2026-06-23"
		title: "executor skills, manifest resolution, world-state compaction"
		branchSurfaces: ["main", "alpha-latest"]
		classes: ["mcp", "context-window", "security", "policy", "adapter", "storage", "protocol", "multi-agent", "UI", "rollout-trace", "config"]
		impact: "blocking-gate"
		localIssues: ["#42", "#47", "#48"]
		evidenceOnly: true
		events: [
			"#29516 MCP HTTP affinity cookies",
			"#29259 MCP thread hint injection",
			"#29626 executor skills without host path conversion",
			"#29620 decouple plugin manifest path resolution",
			"#29608 shutdown superseded MCP managers",
			"#29606 pin yielded code cells to request runtime",
			"#29602 namespace tools by provider capability",
			"#29591 list descendant threads",
			"#29569 unattributed network denials to parent turn",
			"#29547 current step environments for tools",
			"#29527 turn-owned WorldState for inline compaction",
			"#29521 token-budget compaction fresh context",
			"#29519 initial context-window metadata",
			"#29577 ResponseItem::AdditionalTools",
			"#28360 ResponseItem metadata turn_id",
			"0.143.0-alpha.6",
		]
	}
}
