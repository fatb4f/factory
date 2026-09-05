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
	"projects.engineering-pocs": unit.#Unit & {
		id:     "projects.engineering-pocs"
		kind:   "project"
		agents: "projects/engineering-pocs/.agents"
	}
	"academic.uqam": unit.#Unit & {
		id:     "academic.uqam"
		kind:   "academic"
		agents: "academic/uqam/.agents"
	}
	"world.engineering-signals": unit.#Unit & {
		id:     "world.engineering-signals"
		kind:   "world"
		agents: "world/engineering-signals/.agents"
	}
	"world.industrial-signals": unit.#Unit & {
		id:     "world.industrial-signals"
		kind:   "world"
		agents: "world/industrial-signals/.agents"
	}
	"world.industrial-constraints": unit.#Unit & {
		id:     "world.industrial-constraints"
		kind:   "world"
		agents: "world/industrial-constraints/.agents"
	}
	"world.canada-clean-energy": unit.#Unit & {
		id:     "world.canada-clean-energy"
		kind:   "world"
		agents: "world/canada-clean-energy/.agents"
	}
	"world.canada-climate-readiness": unit.#Unit & {
		id:     "world.canada-climate-readiness"
		kind:   "world"
		agents: "world/canada-climate-readiness/.agents"
	}
	"world.financial-signals": unit.#Unit & {
		id:     "world.financial-signals"
		kind:   "world"
		agents: "world/financial-signals/.agents"
	}
	"world.resource-allocation": unit.#Unit & {
		id:     "world.resource-allocation"
		kind:   "world"
		agents: "world/resource-allocation/.agents"
	}
	"world.financial-opportunities": unit.#Unit & {
		id:     "world.financial-opportunities"
		kind:   "world"
		agents: "world/financial-opportunities/.agents"
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
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"projects.epistemic-plant-bootstrap.upstream-monitor": unit.#Task & {
		id:        "projects.epistemic-plant-bootstrap.upstream-monitor"
		name:      "upstream-monitor"
		unit:      "projects.epistemic-plant-bootstrap"
		authority: "contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/contract.cue"
		agent:     "projects/epistemic-plant-bootstrap/.agents/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"projects.engineering-pocs.qualify": unit.#Task & {
		id:        "projects.engineering-pocs.qualify"
		name:      "qualify"
		unit:      "projects.engineering-pocs"
		authority: "contracts/projects/engineering-pocs/contract.cue"
		agent:     "projects/engineering-pocs/.agents/AGENTS.md"
		enabled:   false
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"academic.uqam.events": unit.#Task & {
		id:        "academic.uqam.events"
		name:      "events"
		unit:      "academic.uqam"
		authority: "contracts/academic/uqam/events/contract.cue"
		agent:     "academic/uqam/.agents/events/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"academic.uqam.catalog": unit.#Task & {
		id:        "academic.uqam.catalog"
		name:      "catalog"
		unit:      "academic.uqam"
		authority: "contracts/academic/uqam/catalog/contract.cue"
		agent:     "academic/uqam/.agents/catalog/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.engineering-signals.monitor": unit.#Task & {
		id:        "world.engineering-signals.monitor"
		name:      "monitor"
		unit:      "world.engineering-signals"
		authority: "contracts/world/engineering-signals/contract.cue"
		agent:     "world/engineering-signals/.agents/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.industrial-signals.monitor": unit.#Task & {
		id:        "world.industrial-signals.monitor"
		name:      "monitor"
		unit:      "world.industrial-signals"
		authority: "contracts/world/industrial-signals/contract.cue"
		agent:     "world/industrial-signals/.agents/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.industrial-constraints.monitor": unit.#Task & {
		id:        "world.industrial-constraints.monitor"
		name:      "monitor"
		unit:      "world.industrial-constraints"
		authority: "contracts/world/industrial-constraints/contract.cue"
		agent:     "world/industrial-constraints/.agents/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.canada-clean-energy.monitor": unit.#Task & {
		id:        "world.canada-clean-energy.monitor"
		name:      "monitor"
		unit:      "world.canada-clean-energy"
		authority: "contracts/world/canada-clean-energy/contract.cue"
		agent:     "world/canada-clean-energy/.agents/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.canada-climate-readiness.monitor": unit.#Task & {
		id:        "world.canada-climate-readiness.monitor"
		name:      "monitor"
		unit:      "world.canada-climate-readiness"
		authority: "contracts/world/canada-climate-readiness/contract.cue"
		agent:     "world/canada-climate-readiness/.agents/AGENTS.md"
		enabled:   true
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.financial-signals.monitor": unit.#Task & {
		id:        "world.financial-signals.monitor"
		name:      "monitor"
		unit:      "world.financial-signals"
		authority: "contracts/world/financial-signals/contract.cue"
		agent:     "world/financial-signals/.agents/AGENTS.md"
		enabled:   false
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.resource-allocation.correlate": unit.#Task & {
		id:        "world.resource-allocation.correlate"
		name:      "correlate"
		unit:      "world.resource-allocation"
		authority: "contracts/world/resource-allocation/contract.cue"
		agent:     "world/resource-allocation/.agents/AGENTS.md"
		enabled:   false
		cadence: {frequency: "weekly", weekday: "monday"}
	}
	"world.financial-opportunities.qualify": unit.#Task & {
		id:        "world.financial-opportunities.qualify"
		name:      "qualify"
		unit:      "world.financial-opportunities"
		authority: "contracts/world/financial-opportunities/contract.cue"
		agent:     "world/financial-opportunities/.agents/AGENTS.md"
		enabled:   false
		cadence: {frequency: "weekly", weekday: "monday"}
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
