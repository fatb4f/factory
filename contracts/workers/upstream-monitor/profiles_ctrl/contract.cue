package ctrlprofile

import core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"

#CtrlAcceptedSignal: close({
	signal_id: "loop_bootstrap_request"
	profile_id: "ctrl"
	target_repo: "fatb4f/factory"
	context_repo: "fatb4f/ctrl"
	entrypoint: "projects/ctrl/.agents/AGENTS.md"
	adapter: "github_app"
})

ctrlAcceptedSignal: #CtrlAcceptedSignal & {
	signal_id: "loop_bootstrap_request"
	profile_id: "ctrl"
	target_repo: "fatb4f/factory"
	context_repo: "fatb4f/ctrl"
	entrypoint: "projects/ctrl/.agents/AGENTS.md"
	adapter: "github_app"
}

ctrlContext: close({
	repository: "fatb4f/ctrl"
	branch: "main"
	role: "subject_context_not_monitor_authority"
	semanticAuthority: "spec/"
	componentOwnershipSource: "control/components.cue"
	architectureContract: "contracts/workers/upstream-monitor/profiles_ctrl/topology.cue"
	semanticKernelContract: "contracts/workers/upstream-monitor/profiles_ctrl/semantic-kernel.cue"
	projectFolders: ["ctrl", "python-intel", "PyPI/wheel/PEP pipeline", "semagrams"]
	components: [
		"qualification-spec",
		"qualification-workflow",
		"ppf",
		"runtime-promptgen",
		"tdd-agent-skills",
		"openai-integration",
	]
	requiredContextReads: [
		"README.md",
		"AGENTS.md",
		"pyproject.toml",
		"uv.lock",
		".python-version",
		"control/components.cue",
		"control/source-imports.cue",
		"spec/README.md",
		"spec/AGENTS.md",
		"spec/.codex/AGENTS.md",
		"spec/.codex/config.toml",
	]
})

ctrlAuthorityModel: close({
	authority: [
		"contracts/workers/upstream-monitor/contract.cue",
		"contracts/workers/upstream-monitor/profiles_ctrl/*.cue",
		"contracts/workers/upstream-monitor/profiles_ctrl/semantic-kernel.cue",
		"contracts/workers/upstream-monitor/profiles_ctrl/correlation.cue",
		"contracts/workers/upstream-monitor/AGENTS.md",
		"projects/ctrl/.agents/AGENTS.md",
		"projects/ctrl/.agents/report-template.md",
	]
	subjectContext: ["fatb4f/ctrl@main repository state"]
	evidenceOnly: [
		"openai/codex",
		"python/cpython",
		"astral-sh/ruff",
		"scip-code/scip",
		"open-telemetry/opentelemetry-python",
		"open-telemetry/opentelemetry-python-contrib",
		"open-telemetry/semantic-conventions-genai",
		"open-telemetry/opentelemetry-python-genai",
		"open-telemetry/otel-arrow",
		"open-telemetry/weaver",
		"dlt-hub/dlt",
		"fsspec/filesystem_spec",
		"apache/arrow",
		"duckdb/duckdb",
		"ibis-project/ibis",
		"pola-rs/polars",
		"marimo-team/marimo",
		"pydantic/pydantic-ai",
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
		"project_topology_read",
		"semantic_kernel_read",
		"source_acquisition",
		"graph_projection",
		"correlation_policy_read",
		"interface_boundary_read",
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
