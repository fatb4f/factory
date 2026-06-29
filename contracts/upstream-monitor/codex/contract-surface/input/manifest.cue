package contractsurfaceinput

// source: contracts/upstream-monitor/codex/contract-surface/input/manifest.cue
#EventKind: "pull_request" | "commit" | "release"

#ImpactDecision: "none" |
	"note" |
	"contract-update" |
	"blocking-gate"

#CandidateEvent: {
	id:     string
	kind:   #EventKind
	repo:   "openai/codex"
	ref:    "main" | "alpha-latest"
	title?: string
	path_hints?: [...string]
	text_hints?: [...string]
	matched_terms: [...string]
	classes: [...#SurfaceClass]
	surface_matches?: [...#SurfaceMatch]
}

#SurfaceMatch: {
	surface_id: string
	matched_terms: [_, ...string]
	classes: [_, ...#SurfaceClass]
	constraints:         #SurfaceConstraint
	local_contract_hint: string
}

#ImpactCandidate: #CandidateEvent & {
	matched_terms: [_, ...string]
	classes: [_, ...#SurfaceClass]
	surface_matches: [_, ...#SurfaceMatch]
	authority:             "upstream_evidence_only"
	local_authority:       "fatb4f_contracts_cue"
	decision:              #ImpactDecision
	report:                bool
	local_contract_impact: string
	suggested_local_targets?: [...string]
	tracked_issue_refs?: [...int]
}

#FilterGate: {
	name:       string
	input:      string
	constraint: string
	failure:    string
}

candidate_filter: {
	phase:               "spec_only"
	acquisition_enabled: false

	source:            source_scope
	surface_catalogue: surface_catalogue
	tracked_issues:    tracked_issues

	toolkit_role: {
		owner:         "inference"
		input_signal:  "evidence_ready"
		output_signal: "impact_ready"
		mutation:      "none"
	}

	include: {
		repo: "openai/codex"
		refs: ["main", "alpha-latest"]
		kinds: ["pull_request", "commit", "release"]
	}

	variable_surface_policy: {
		defined_by: "surface_catalogue"
		admitted_by: [
			"terms",
			"classes",
			"constraints",
			"local_contract_hint",
		]
		reject_if: [
			"no surface term match",
			"no class match",
			"no local contract impact",
			"event kind outside surface constraints",
		]
		forbid: [
			"hard-coded event path admission outside CUE",
			"semantic classification in acquisition scripts",
			"upstream evidence promoted to authority",
		]
	}

	gates: [
		{
			name:       "source_scope"
			input:      "candidate event"
			constraint: "repo, ref, and kind must match source_scope"
			failure:    "coverage_gap"
		},
		{
			name:       "surface_match"
			input:      "candidate event"
			constraint: "candidate must match at least one declared variable surface"
			failure:    "coverage_gap"
		},
		{
			name:       "local_impact"
			input:      "surface match"
			constraint: "reported candidates must declare local contract impact"
			failure:    "terminal_deferred"
		},
		{
			name:       "decision_admission"
			input:      "impact candidate"
			constraint: "decision must reduce to none, note, contract-update, or blocking-gate"
			failure:    "eval_failed"
		},
	]

	match_policy: {
		require_surface_term:                     true
		require_surface_constraint:               true
		require_local_contract_impact_for_report: true
		treat_upstream_as:                        "evidence_not_authority"
		report_only: ["note", "contract-update", "blocking-gate"]
	}

	classification: {
		allowed: [
			"protocol",
			"adapter",
			"storage",
			"policy",
			"UI",
			"docs",
			"context-window",
			"multi-agent",
			"rollout-trace",
			"mcp",
			"config",
			"security",
		]
	}

	decision_lattice: {
		none: {
			report:  false
			meaning: "matched event has no admitted local contract impact"
		}
		note: {
			report:  true
			meaning: "local contract awareness only"
		}
		"contract-update": {
			report:  true
			meaning: "local CUE contract or surface catalogue may need revision"
		}
		"blocking-gate": {
			report:  true
			meaning: "local assumptions may be invalid until a gate is reviewed"
		}
	}

	report_shape: {
		sections: [
			"Critical",
			"High",
			"Notes",
			"No local action",
		]
		required_fields: [
			"event",
			"surface_matches",
			"classification",
			"impact_decision",
			"local_contract_impact",
			"suggested_local_targets",
			"tracked_issue_refs",
		]
	}

	forbidden_initial_gate: [
		"execute search",
		"fetch openai/codex",
		"render report",
		"post issue update",
	]
}

// source: contracts/upstream-monitor/codex/contract-surface/input/manifest.cue
#EvidenceKind: "pull_request" | "commit" | "release"

#SourceRef: {
	name:     string
	kind:     "branch" | "release_line" | "tag"
	required: bool | *true
}

source_scope: {
	upstream_repo: "openai/codex"

	refs: {
		main: {
			name: "main"
			kind: "branch"
		}
		alpha_latest: {
			name: "alpha-latest"
			kind: "release_line"
		}
	}

	evidence_kinds: [
		"pull_request",
		"commit",
		"release",
	]

	authority: {
		upstream: "evidence_only"
		local:    "cue_contracts_agents_templates"
	}

	initial_gate: {
		acquisition_enabled: false
		reason:              "Z0 to Z1 handoff scaffold only"
	}
}

// source: contracts/upstream-monitor/codex/contract-surface/input/manifest.cue
#SurfaceClass: "protocol" |
	"adapter" |
	"storage" |
	"policy" |
	"UI" |
	"docs" |
	"context-window" |
	"multi-agent" |
	"rollout-trace" |
	"mcp" |
	"config" |
	"security"

#SurfaceConstraint: {
	require_any_term:             bool | *true
	require_class:                bool | *true
	require_local_contract_hint:  bool | *true
	report_requires_local_impact: bool | *true
	admissible_event_kinds: [...#EvidenceKind]
	impact_floor: #ImpactDecision | *"note"
}

#Surface: {
	id: string
	terms: [_, ...string]
	classes: [_, ...#SurfaceClass]
	constraints:         #SurfaceConstraint
	local_contract_hint: string
}

surface_catalogue: [
	{
		id: "response_item"
		terms: ["ResponseItem", "ResponseItemMetadata"]
		classes: ["protocol"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "contract-update"
		}
		local_contract_hint: "response item schema and metadata contracts"
	},
	{
		id: "agent_messages"
		terms: ["AgentMessage", "InterAgentCommunication", "NEW_TASK", "MESSAGE", "FINAL_ANSWER"]
		classes: ["protocol", "multi-agent"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "contract-update"
		}
		local_contract_hint: "agent message envelope and lifecycle contracts"
	},
	{
		id: "agent_path"
		terms: ["AgentPath"]
		classes: ["adapter", "protocol"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit"]
			impact_floor: "note"
		}
		local_contract_hint: "agent path routing and adapter identity contracts"
	},
	{
		id: "context_fragments"
		terms: ["session_prefix", "context fragments", "fragment", "fragments"]
		classes: ["context-window", "adapter"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "contract-update"
		}
		local_contract_hint: "context injection and prompt fragment contracts"
	},
	{
		id: "rollout_trace"
		terms: ["rollout_trace", "rollout trace"]
		classes: ["rollout-trace", "storage"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "note"
		}
		local_contract_hint: "rollout trace evidence and replay contracts"
	},
	{
		id: "thread_store"
		terms: ["thread_store", "thread store", "rollout storage", "rollout_store"]
		classes: ["storage", "rollout-trace"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "contract-update"
		}
		local_contract_hint: "thread and rollout storage contracts"
	},
	{
		id: "mcp_handlers"
		terms: ["MCP", "resource handler", "tool handler", "resources/list", "tools/call"]
		classes: ["mcp", "adapter"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "contract-update"
		}
		local_contract_hint: "MCP resource/tool handler contracts"
	},
	{
		id: "agents_instructions"
		terms: ["AGENTS.md", "developer instructions", "developer_instruction", "instructions"]
		classes: ["policy", "docs"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "blocking-gate"
		}
		local_contract_hint: "AGENTS and policy instruction chain contracts"
	},
	{
		id: "config_feature_flags"
		terms: ["feature flag", "feature_flags", "config", "experimental"]
		classes: ["config"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "note"
		}
		local_contract_hint: "configuration and rollout-gate contracts"
	},
	{
		id: "security_boundary"
		terms: ["sandbox", "approval", "permissions", "auth", "token", "secret"]
		classes: ["security", "policy"]
		constraints: {
			admissible_event_kinds: ["pull_request", "commit", "release"]
			impact_floor: "blocking-gate"
		}
		local_contract_hint: "security boundary and approval contracts"
	},
]

// source: contracts/upstream-monitor/codex/contract-surface/input/manifest.cue
#TrackedIssue: {
	repo:         "fatb4f/factory"
	number:       int
	role:         string
	impact_floor: "note" | "contract-update" | "blocking-gate"
}

tracked_issues: []
