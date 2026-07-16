package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#AcceptedSignal: close({
	signal_id:   "loop_bootstrap_request"
	target_repo: "fatb4f/factory"
	entrypoint:  "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
	adapter:     "github_app"
})

acceptedSignal: #AcceptedSignal & {
	signal_id:   "loop_bootstrap_request"
	target_repo: "fatb4f/factory"
	entrypoint:  "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
	adapter:     "github_app"
}

authorityModel: close({
	authority: [
		"contracts/factory/workers/codex/upstream-monitor/contract.cue",
		"contracts/factory/workers/codex/upstream-monitor/profiles_factory/*.cue",
		"contracts/factory/workers/codex/upstream-monitor/AGENTS.md",
		"contracts/upstream-monitor/**/AGENTS.md",
		"contracts/upstream-monitor/codex/contract-surface/output/report-template.md",
	]
	evidenceOnly: [
		"openai/codex",
		"GitHub adapter responses",
		"ChatGPT observations",
		"generated run bundles",
		"legacy generated reports and evidence",
	]
})

channels:        core.Channels
chatgptActuator: core.ChatGPTActuator

workflow: close({
	initial: "authority_read"
	states: [
		"authority_read",
		"input_admission",
		"main_acquisition",
		"alpha_acquisition",
		"semantic_classification",
		"report_render",
		"summary_render",
		"publication_admission",
		"bundle_publication",
		"bundle_manifest_seal",
		"latest_pointer_update",
	]
	transitions: [
		{from: "authority_read", to: "input_admission"},
		{from: "input_admission", to: "main_acquisition"},
		{from: "main_acquisition", to: "alpha_acquisition"},
		{from: "alpha_acquisition", to: "semantic_classification"},
		{from: "semantic_classification", to: "report_render"},
		{from: "report_render", to: "summary_render"},
		{from: "summary_render", to: "publication_admission"},
		{from: "publication_admission", to: "bundle_publication"},
		{from: "bundle_publication", to: "bundle_manifest_seal"},
		{from: "bundle_manifest_seal", to: "latest_pointer_update"},
		{from: "latest_pointer_update", to: "terminal_success"},
	]
	failureStates: ["terminal_abort", "terminal_deferred", "coverage_gap"]
	terminal: "terminal_success"
})

operational: true
