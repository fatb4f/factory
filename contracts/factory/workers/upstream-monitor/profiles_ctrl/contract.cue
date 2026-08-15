package ctrlprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#CtrlAcceptedSignal: close({
	signal_id: "loop_bootstrap_request"
	profile_id: "ctrl"
	target_repo: "fatb4f/factory"
	context_repo: "fatb4f/ctrl"
	entrypoint: "contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md"
	adapter: "github_app"
})

ctrlAcceptedSignal: #CtrlAcceptedSignal & {
	signal_id: "loop_bootstrap_request"
	profile_id: "ctrl"
	target_repo: "fatb4f/factory"
	context_repo: "fatb4f/ctrl"
	entrypoint: "contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md"
	adapter: "github_app"
}

ctrlContext: close({
	repository: "fatb4f/ctrl"
	branch: "main"
	role: "subject_context_not_monitor_authority"
	semanticAuthority: "spec/"
	components: [
		"qualification-spec",
		"qualification-workflow",
		"ppf",
		"runtime-promptgen",
		"tdd-agent-skills",
		"openai-integration",
		"observation-acquisition",
		"telemetry-fabric",
	]
	requiredContextReads: [
		"README.md",
		"AGENTS.md",
		"pyproject.toml",
		"uv.lock",
		".python-version",
		"control/components.cue",
		"spec/README.md",
		"spec/AGENTS.md",
		"spec/.codex/AGENTS.md",
		"spec/.codex/config.toml",
	]
})

ctrlAuthorityModel: close({
	authority: [
		"contracts/factory/workers/upstream-monitor/contract.cue",
		"contracts/factory/workers/upstream-monitor/profiles_ctrl/*.cue",
		"contracts/factory/workers/upstream-monitor/profiles_ctrl/correlation.cue",
		"contracts/factory/workers/upstream-monitor/AGENTS.md",
		"contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md",
		"contracts/upstream-monitor/ctrl/contract-surface/output/report-template.md",
	]
	subjectContext: ["fatb4f/ctrl@main repository state"]
	evidenceOnly: [
		"openai/codex",
		"python/cpython",
		"astral-sh/ruff",
		"open-telemetry/opentelemetry-python",
		"open-telemetry/opentelemetry-python-contrib",
		"open-telemetry/semantic-conventions-genai",
		"open-telemetry/opentelemetry-python-genai",
		"open-telemetry/otel-arrow",
		"dlt-hub/dlt",
		"cue-lang/cue",
		"astral-sh/uv",
		"jj-vcs/jj",
		"GitHub adapter responses",
		"ChatGPT observations",
		"generated run bundles",
	]
})

ctrlWorkflow: close({
	initial: "authority_read"
	states: [
		"authority_read",
		"input_admission",
		"context_acquisition",
		"source_acquisition",
		"graph_projection",
		"correlation_policy_read",
		"test_probe_binding",
		"semantic_classification",
		"report_render",
		"summary_render",
		"publication_admission",
		"bundle_publication",
		"manifest_seal",
		"latest_pointer_update",
	]
	terminal: "terminal_success"
	failureStates: ["terminal_abort", "terminal_deferred", "coverage_gap"]
})

chatgptActuator: core.ChatGPTActuator
ctrlOperational: true
