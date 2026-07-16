package cuestrapprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#CuestrapPurposeID: "supervisory-session-controller" | "idiomatic-cue-workbook-harness"

#AcceptedSignal: close({
	signal_id:    "loop_bootstrap_request"
	profile_id:   "cuestrap"
	target_repo:  "fatb4f/factory"
	context_repo: "fatb4f/cuestrap"
	entrypoint:   "contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md"
	adapter:      "github_app"
})

acceptedSignal: #AcceptedSignal & {
	signal_id:    "loop_bootstrap_request"
	profile_id:   "cuestrap"
	target_repo:  "fatb4f/factory"
	context_repo: "fatb4f/cuestrap"
	entrypoint:   "contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md"
	adapter:      "github_app"
}

context: close({
	repository: "fatb4f/cuestrap"
	branch:     "main"
	role:       "subject_context_not_monitor_authority"
	purposes: close({
		supervisorySessionController: close({
			id: "supervisory-session-controller"
			summary: "gopy, CUE, Pydantic, and Hypothesis implementation of a phase-sensitive supervisory controller for Codex sessions and tool use"
			technologies: ["gopy", "CUE", "Pydantic", "Hypothesis"]
			contextPaths: [
				".codex/AGENTS.md",
				".codex/config.toml",
				".codex/hooks/cuestrap_tool_supervisor.py",
				"src/cue-workbook/supervisory_hooks/contracts.cue",
				"src/cue-workbook/supervisory_hooks/models.py",
				"src/cue-workbook/supervisory_hooks/policy.py",
				"src/cue-workbook/supervisory_hooks/supervisor.py",
				"src/cue-workbook/supervisory_hooks/ledger.py",
			]
		})
		idiomaticCueWorkbookHarness: close({
			id: "idiomatic-cue-workbook-harness"
			summary: "gopy-backed Marimo workbook and browserless harness for exploring and qualifying idiomatic CUE behavior"
			technologies: ["gopy", "CUE", "Marimo"]
			contextPaths: [
				"README.md",
				"pyproject.toml",
				"src/cue-workbook/cue-workbook.py",
				"src/cue-workbook/workbook_cli.py",
				"src/cue-workbook/harness.py",
				"runner/bindings/",
				"runner/cmd/cueprobe/",
			]
		})
	})
	requiredContextReads: [
		"README.md",
		".codex/AGENTS.md",
		"pyproject.toml",
		"src/cue-workbook/supervisory_hooks/contracts.cue",
		"src/cue-workbook/supervisory_hooks/models.py",
		"src/cue-workbook/supervisory_hooks/supervisor.py",
		"src/cue-workbook/cue-workbook.py",
	]
})

authorityModel: close({
	authority: [
		"contracts/factory/workers/codex/upstream-monitor/contract.cue",
		"contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/*.cue",
		"contracts/factory/workers/codex/upstream-monitor/AGENTS.md",
		"contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md",
		"contracts/upstream-monitor/codex/cuestrap-contract-surface/output/report-template.md",
	]
	subjectContext: [
		"fatb4f/cuestrap@main repository state",
	]
	evidenceOnly: [
		"openai/codex",
		"GitHub adapter responses",
		"ChatGPT observations",
		"fatb4f/cuestrap repository observations",
		"generated factory reports",
		"generated factory evidence",
		"generated cuestrap report copies",
	]
})

channels: core.Channels
chatgptActuator: core.ChatGPTActuator

workflow: close({
	initial: "authority_read"
	states: [
		"authority_read",
		"input_admission",
		"context_acquisition",
		"main_acquisition",
		"alpha_acquisition",
		"semantic_classification",
		"report_render",
		"publication_admission",
		"factory_publication",
		"cuestrap_report_mirror",
	]
	transitions: [
		{from: "authority_read", to: "input_admission"},
		{from: "input_admission", to: "context_acquisition"},
		{from: "context_acquisition", to: "main_acquisition"},
		{from: "main_acquisition", to: "alpha_acquisition"},
		{from: "alpha_acquisition", to: "semantic_classification"},
		{from: "semantic_classification", to: "report_render"},
		{from: "report_render", to: "publication_admission"},
		{from: "publication_admission", to: "factory_publication"},
		{from: "factory_publication", to: "cuestrap_report_mirror"},
		{from: "cuestrap_report_mirror", to: "terminal_success"},
	]
	failureStates: ["terminal_abort", "terminal_deferred", "coverage_gap"]
	terminal:       "terminal_success"
})

operational: true
