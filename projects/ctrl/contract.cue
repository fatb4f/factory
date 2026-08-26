package ctrl

import profile "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor/profiles_ctrl:ctrlprofile"

UpstreamMonitorMapping: close({
	id:        "projects.ctrl.upstream-monitor"
	authority: "contracts/factory/workers/upstream-monitor/profiles_ctrl/contract.cue"
	acceptedSignal: profile.#CtrlAcceptedSignal & {
		signal_id:    "loop_bootstrap_request"
		profile_id:   "ctrl"
		target_repo:  "fatb4f/factory"
		context_repo: "fatb4f/ctrl"
		entrypoint:   "contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md"
		adapter:      "github_app"
	}
	adapter: close({
		contract:  "projects/ctrl/upstream-monitor/contract.cue"
		procedure: "projects/ctrl/.agents/adapters/upstream-monitor.md"
	})
	publicationRoot: "contracts/upstream-monitor/ctrl/contract-surface"
})
