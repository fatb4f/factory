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
	"academic.uqam": unit.#Unit & {
		id:     "academic.uqam"
		kind:   "academic"
		agents: "academic/uqam/.agents"
	}
	"world.industrial-constraints": unit.#Unit & {
		id:     "world.industrial-constraints"
		kind:   "world"
		agents: "world/industrial-constraints/.agents"
	}
	"personal.gym": unit.#Unit & {
		id:     "personal.gym"
		kind:   "personal"
		agents: "personal/gym/.agents"
	}
})

tasks: close({
	"projects.ctrl.upstream-monitor": unit.#Task & {
		id:        "projects.ctrl.upstream-monitor"
		name:      "upstream-monitor"
		unit:      "projects.ctrl"
		authority: "contracts/workers/upstream-monitor/profiles_ctrl/contract.cue"
		agent:     "projects/ctrl/.agents/AGENTS.md"
		enabled:   true
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
		enabled:   true
		cadence: {
			everyDays: 3
		}
	}
	"academic.uqam.events": unit.#Task & {
		id:        "academic.uqam.events"
		name:      "events"
		unit:      "academic.uqam"
		authority: "contracts/academic/uqam/events/contract.cue"
		agent:     "academic/uqam/.agents/events/AGENTS.md"
		enabled:   true
		cadence: {
			everyDays: 1
		}
	}
	"world.industrial-constraints.monitor": unit.#Task & {
		id:        "world.industrial-constraints.monitor"
		name:      "monitor"
		unit:      "world.industrial-constraints"
		authority: "contracts/world/industrial-constraints/contract.cue"
		agent:     "world/industrial-constraints/.agents/AGENTS.md"
		enabled:   false
		cadence: {
			everyDays: 7
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
	if id =~ "^personal\\." {
		_kind: registered & {kind: "personal"}
	}
}]

_taskIdentity: [for id, task in tasks {
	_value: task & {id: id, id: "\(task.unit).\(task.name)"}
	_unit:  units[task.unit]
}]
