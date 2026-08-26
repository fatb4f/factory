package epistemicplantbootstrap

import profile "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor/profiles_epistemic_plant_bootstrap:epistemicplantprofile"

UpstreamMonitorMapping: close({
	id:        "projects.epistemic-plant-bootstrap.upstream-monitor"
	authority: "contracts/factory/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue"
	acceptedSignal: profile.#EpistemicPlantAcceptedSignal & {
		signal_id:    "loop_bootstrap_request"
		profile_id:   "epistemic-plant-bootstrap"
		target_repo:  "fatb4f/factory"
		context_repo: "fatb4f/epistemic-plant-bootstrap"
		entrypoint:   "contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/AGENTS.md"
		adapter:      "github_app"
	}
	adapter: close({
		contract:  "projects/epistemic-plant-bootstrap/upstream-monitor/contract.cue"
		procedure: "projects/epistemic-plant-bootstrap/.agents/adapters/upstream-monitor.md"
	})
	publicationRoot: "contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface"
})
