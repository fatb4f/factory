package contractsurface

import (
	monitor "github.com/fatb4f/factory/contracts/upstream-monitor:upstreammonitor"
)

// source: contracts/upstream-monitor/codex/contract-surface/manifest.cue
#z0Output: {
	id:       "loop_bootstrap_request"
	producer: "z0_instruction"
	consumer: "z1_toolkit"
	payload: {
		repo:       "fatb4f/factory"
		ref:        "main"
		entrypoint: "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
		adapter:    "github_app"
	}
}

#z1Output: {
	id:       "toolkit_ready"
	producer: "z1_toolkit"
	consumer: "z2_acquisition"
	payload: {
		instruction_chain: [
			"contracts/upstream-monitor/AGENTS.md",
			"contracts/upstream-monitor/codex/AGENTS.md",
			"contracts/upstream-monitor/codex/contract-surface/AGENTS.md",
		]
		toolkit:               codex_contract_surface_toolkit.id
		initial_gate:          "signal_continuity"
		acquisition_enabled:   false
		reporting_enabled:     false
		issue_posting_enabled: false
	}
}

z0_instruction: monitor.#ComputeNode & {
	id:   "z0_instruction_bootstrap"
	zone: "z0_instruction"

	input: [{
		id:       "loop_bootstrap_request"
		producer: "scheduled_chatgpt_task"
	}]

	transform: "resolve loop entrypoint through GitHub App adapter"

	output: [#z0Output]

	eval: {
		pass: [
			"repo is explicit",
			"ref policy is explicit",
			"entrypoint AGENTS.md is explicit",
			"adapter is explicit",
		]
		fail: [
			"entrypoint inferred",
			"project files used before GitHub App",
			"non-Codex loop selected",
		]
		error_signal: "input_invalid"
	}

	next_state: [{
		from:   "z0_instruction"
		to:     "z1_toolkit"
		output: #z0Output
		input: {
			id:       "loop_bootstrap_request"
			producer: "z0_instruction"
			consumer: "z1_toolkit"
		}
		action: "continue"
	}]
}

z1_toolkit: monitor.#ComputeNode & {
	id:   "z1_toolkit_entrypoint_acceptance"
	zone: "z1_toolkit"

	input: [z0_instruction.output[0]]

	transform: "load explicit AGENTS chain and loop-local toolkit contracts without acquiring upstream evidence"

	output: [#z1Output]

	eval: {
		pass: [
			"Z1 input signal matches Z0 output signal",
			"instruction chain is explicit",
			"toolkit roles are explicit",
			"acquisition remains disabled",
			"reports and issue posting remain disabled",
		]
		fail: [
			"signal ID changed during handoff",
			"AGENTS chain inferred from layout",
			"toolkit role inferred from directory name",
			"upstream acquisition started during initial gate",
			"output mutation attempted during initial gate",
		]
		error_signal: "eval_failed"
	}

	next_state: [
		{
			from:   "z1_toolkit"
			to:     "z2_acquisition"
			output: #z1Output
			input: {
				id:       "toolkit_ready"
				producer: "z1_toolkit"
				consumer: "z2_acquisition"
			}
			action: "hold"
		},
		{
			from: "z1_toolkit"
			output: {
				id:       "terminal_abort"
				producer: "z1_toolkit"
				payload: {
					reason: "input_invalid_or_adapter_failure"
				}
			}
			action:         "abort"
			terminal:       true
			terminal_state: "terminal_abort"
		},
	]
}

codex_contract_surface_toolkit: monitor.#LoopToolkit & {
	id:     "codex_contract_surface_toolkit"
	target: "openai/codex"

	roles: {
		acquisition: {
			id: "codex_evidence_acquisition"
			input_signals: ["toolkit_ready"]
			output_signals: ["evidence_ready"]
			adapter:  "github_app"
			mutation: "none"
			constraints: [
				"disabled during initial Z0 to Z1 gate",
				"when admitted, reads only declared refs and evidence kinds",
				"does not classify semantic impact",
			]
		}

		inference: {
			id: "codex_contract_surface_inference"
			input_signals: ["evidence_ready"]
			output_signals: ["impact_ready"]
			constraints: [
				"only role allowed to classify semantic impact",
				"candidate admission is constrained by CUE surface filters",
				"upstream evidence cannot mutate local authority",
			]
		}

		formatting: {
			id: "codex_impact_formatting"
			input_signals: ["impact_ready"]
			output_signals: ["artifacts_ready"]
			constraints: [
				"renders only admitted impact decisions",
				"uses loop-local report and issue templates",
				"does not fetch or infer new evidence",
			]
		}

		output: {
			id: "codex_ledger_output"
			input_signals: ["artifacts_ready"]
			output_signals: ["terminal_success"]
			constraints: [
				"writes only declared output paths after the output gate opens",
				"issue posting requires explicit admission by issue contract",
				"no output mutation during the initial gate",
			]
		}
	}

	invariants: [
		"loop is a contained toolkit",
		"roles are declared, not inferred from layout",
		"variable surfaces are CUE-constrained inputs",
		"acquisition, inference, formatting, and output remain distinct roles",
	]
}

transition_closure: {
	expected_path: [
		"z0_instruction",
		"z1_toolkit",
		"z2_acquisition",
		"z3_compute",
		"z4_output",
		"terminal_success",
	]

	failure_terminals: [
		"terminal_abort",
		"terminal_deferred",
		"coverage_gap",
	]

	initial_gate: {
		proof:            "Z0.output.signal_id == Z1.input.signal_id"
		z0_output_signal: z0_instruction.output[0].id
		z1_input_signal:  z1_toolkit.input[0].id
	}
}

// source: contracts/upstream-monitor/codex/contract-surface/manifest.cue
upstreamCodexImpactReportTemplate: #ImpactReport & {
	impacts: {
		critical: []
		high: []
		notes: []
		noLocalAction: []
	}
	suggestedLocalTargets: []
	unresolvedEvidence: []
}

upstreamCodexPublicationPlan: #PublicationPlan & {
	report: {
		run: {
			pathPattern: "contracts/upstream-monitor/codex/contract-surface/reports/runs/<run_id>.codex-impact.md"
			pathRegex:   "^contracts/upstream-monitor/codex/contract-surface/reports/runs/[0-9]{8}T[0-9]{6}Z\\\\.codex-impact\\\\.md$"
		}
		latest: {
			path: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
		}
	}
	evidence: {
		run: {
			pathPattern: "contracts/upstream-monitor/codex/contract-surface/evidence/runs/<run_id>.codex-impact.report.json"
			pathRegex:   "^contracts/upstream-monitor/codex/contract-surface/evidence/runs/[0-9]{8}T[0-9]{6}Z\\\\.codex-impact\\\\.report\\\\.json$"
		}
		latest: {
			path: "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json"
		}
	}
	issueTargets: {}
}

upstreamCodexScheduledTaskPrompt: """
	Use the GitHub App to operate on fatb4f/factory@main.
	
	Load and follow the instruction chain in order:
	
	1. contracts/upstream-monitor/AGENTS.md
	2. contracts/upstream-monitor/codex/AGENTS.md
	3. contracts/upstream-monitor/codex/contract-surface/AGENTS.md
	
	Input signal:
	
	```text
	signal_id: loop_bootstrap_request
	target_repo: fatb4f/factory
	entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
	adapter: github_app
	```
	
	Task:
	
	Run the Codex contract-surface upstream-monitor loop through the admitted report/publication surface. Use the loop-local CUE files as authority. Use upstream openai/codex only as evidence. Apply the fixed report template from `upstreamCodexImpactReportTemplate`. Use `upstreamCodexPublicationPlan` for any repo report path or issue update target.
	
	Required constraints:
	
	- Do not create report artifacts outside `contracts/upstream-monitor/codex/contract-surface/reports/`.
	- Do not create evidence artifacts outside `contracts/upstream-monitor/codex/contract-surface/evidence/`.
	- Do not update issues unless the issue target is declared by the publication plan.
	- Do not treat ChatGPT output, GitHub adapter output, or upstream Codex state as authority.
	- Keep unresolved upstream signals, including alpha-latest, unresolved unless concrete branch/ref/tag evidence is available.
	
	Expected output:
	
	- concise run report
	- repo-local report artifact if publication is admitted
	- issue update summary only for declared targets
	- validation notes for CUE exports and forbidden-attractor checks
	"""

// source: contracts/upstream-monitor/codex/contract-surface/manifest.cue
#PublicationMode: "repo-report" | "issue-comment" | "closed-issue-note"

#IssueUpdateCandidate: {
	issue:  int
	mode:   #PublicationMode
	target: "active-work" | "umbrella-status" | "closed-issue-archive"
	body:   string
}

#RunID: =~"^[0-9]{8}T[0-9]{6}Z$"

#RepoReportArtifact: {
	kind:          "markdown-report"
	path:          =~"^contracts/upstream-monitor/codex/contract-surface/reports/[^/]+\\.md$"
	generatedFrom: "upstreamCodexImpactReportTemplate"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
}

#RunReportArtifact: {
	kind:          "markdown-report"
	path:          =~"^contracts/upstream-monitor/codex/contract-surface/reports/runs/[0-9]{8}T[0-9]{6}Z\\.codex-impact\\.md$"
	generatedFrom: "upstreamCodexImpactReportTemplate"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
	retention:     "durable-run-record"
}

#LatestReportProjection: {
	kind:          "markdown-report"
	path:          "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
	generatedFrom: "run-report-artifact"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
	projection:    "latest-run-pointer"
}

#RunEvidenceArtifact: {
	kind:      "json-evidence"
	path:      =~"^contracts/upstream-monitor/codex/contract-surface/evidence/runs/[0-9]{8}T[0-9]{6}Z\\.codex-impact\\.report\\.json$"
	authority: false
	retention: "durable-run-record"
}

#LatestEvidenceProjection: {
	kind:       "json-evidence"
	path:       "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json"
	authority:  false
	projection: "latest-run-pointer"
}

#RunArtifactTarget: {
	pathPattern: string
	pathRegex:   string
	authority:   false
	retention:   "durable-run-record"
}

#LatestProjectionTarget: {
	path:       string
	authority:  false
	projection: "latest-run-pointer"
}

#ReportPublicationTargets: {
	run: #RunArtifactTarget & {
		pathPattern: "contracts/upstream-monitor/codex/contract-surface/reports/runs/<run_id>.codex-impact.md"
		pathRegex:   "^contracts/upstream-monitor/codex/contract-surface/reports/runs/[0-9]{8}T[0-9]{6}Z\\\\.codex-impact\\\\.md$"
	}
	latest: #LatestProjectionTarget & {
		path: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
	}
}

#EvidencePublicationTargets: {
	run: #RunArtifactTarget & {
		pathPattern: "contracts/upstream-monitor/codex/contract-surface/evidence/runs/<run_id>.codex-impact.report.json"
		pathRegex:   "^contracts/upstream-monitor/codex/contract-surface/evidence/runs/[0-9]{8}T[0-9]{6}Z\\\\.codex-impact\\\\.report\\\\.json$"
	}
	latest: #LatestProjectionTarget & {
		path: "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json"
	}
}

#PublicationPlan: {
	apiVersion: "factory.upstream-monitor.codex/v0"
	kind:       "CodexReportPublicationPlan"

	issue:    69
	adapter:  "github_app"
	mutation: "declared-output-only"

	report:   #ReportPublicationTargets
	evidence: #EvidencePublicationTargets

	issueTargets: {
		"42"?: #IssueUpdateCandidate & {
			issue:  42
			mode:   "issue-comment"
			target: "active-work"
		}
		"45"?: #IssueUpdateCandidate & {
			issue:  45
			mode:   "issue-comment"
			target: "umbrella-status"
		}
		"47"?: #IssueUpdateCandidate & {
			issue:  47
			mode:   "closed-issue-note"
			target: "closed-issue-archive"
		}
		"48"?: #IssueUpdateCandidate & {
			issue:  48
			mode:   "closed-issue-note"
			target: "closed-issue-archive"
		}
	}

	invariants: [
		"run artifacts are durable projections/evidence, not authority",
		"latest artifacts are overwriteable projections of the most recent admitted run",
		"ChatGPT applies the fixed template but does not own semantic admission",
		"GitHub App writes only declared publication targets",
		"unresolved upstream signals remain unresolved evidence until ref/tag/branch proof exists",
	]
}

// source: contracts/upstream-monitor/codex/contract-surface/manifest.cue
#ImpactSeverity: "critical" | "high" | "note" | "no-local-action"

#ImpactClass: "mcp" |
	"security" |
	"storage" |
	"adapter" |
	"protocol" |
	"rollout-trace" |
	"ui" |
	"multi-agent" |
	"context-window" |
	"config" |
	"policy"

#UpstreamSignalStatus: "admitted" | "unresolved" | "ignored"

#UpstreamEvent: {
	id:           string
	upstreamRepo: "openai/codex"
	kind:         "pull_request" | "branch_or_ref" | "release" | "unknown"
	status:       #UpstreamSignalStatus
	evidence: [...string]
	refs?: [...string]
	note?: string
}

#ImpactItem: {
	event:    #UpstreamEvent
	severity: #ImpactSeverity
	classes: [...#ImpactClass]
	impact:      string
	localReason: string
	localTargets?: [...string]
	issueUpdates?: [...#IssueUpdateCandidate]
}

#ImpactReport: {
	apiVersion: "factory.upstream-monitor.codex/v0"
	kind:       "CodexImpactReport"

	metadata: {
		issue:       69
		loop:        "codex-contract-surface"
		generatedBy: "scheduled-chatgpt-task"
		authority:   "cue-owned-report-shape"
	}

	source: {
		upstreamRepo: "openai/codex"
		targetRepo:   "fatb4f/factory"
		entrypoint:   "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
		adapter:      "github_app"
	}

	template: {
		id: "codex-impact-report-fixed-v0"
		sections: [
			"critical",
			"high",
			"notes",
			"noLocalAction",
			"suggestedLocalTargets",
			"issueUpdates",
		]
	}

	impacts: {
		critical: *([]) | [...#ImpactItem]
		high: *([]) | [...#ImpactItem]
		notes: *([]) | [...#ImpactItem]
		noLocalAction: *([]) | [...#ImpactItem]
	}

	suggestedLocalTargets: *([]) | [...string]
	unresolvedEvidence: *([]) | [...#UpstreamEvent]
}
