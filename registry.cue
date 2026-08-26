package factory

import unit "github.com/fatb4f/factory/contracts:unit"

units: close({
	"projects.ctrl": unit.#Unit & {
		id:     "projects.ctrl"
		kind:   "project"
		agents: "projects/ctrl/.agents"
	}
	"projects.epistemic-plant-bootstrap": unit.#Unit & {
		id:     "projects.epistemic-plant-bootstrap"
		kind:   "project"
		agents: "projects/epistemic-plant-bootstrap/.agents"
	}
})

tasks: close({
	"projects.ctrl.upstream-monitor": unit.#Task & {
		id:        "projects.ctrl.upstream-monitor"
		name:      "upstream-monitor"
		unit:      "projects.ctrl"
		authority: "contracts/workers/upstream-monitor/profiles_ctrl/contract.cue"
		agent:     "projects/ctrl/.agents/AGENTS.md"
		enabled:   false
		cadence: {
			everyDays: 3
		}
	}
	"projects.epistemic-plant-bootstrap.upstream-monitor": unit.#Task & {
		id:        "projects.epistemic-plant-bootstrap.upstream-monitor"
		name:      "upstream-monitor"
		unit:      "projects.epistemic-plant-bootstrap"
		authority: "contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue"
		agent:     "projects/epistemic-plant-bootstrap/.agents/AGENTS.md"
		enabled:   false
		cadence: {
			everyDays: 3
		}
	}
})

_registryIdentity: [for id, registered in units {
	_value: registered & {id: id}
	if id =~ "^projects\\." {
		_kind: registered & {kind: "project"}
	}
	if id =~ "^academic\\." {
		_kind: registered & {kind: "academic"}
	}
	if id =~ "^world\\." {
		_kind: registered & {kind: "world"}
	}
}]

_taskIdentity: [for id, task in tasks {
	_value: task & {id: id, id: "\(task.unit).\(task.name)"}
	_unit:  units[task.unit]
}]
