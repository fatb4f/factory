package factory

import unit "github.com/fatb4f/factory/contracts/factory:unit"

units: close({
	"projects.ctrl": unit.#Unit & {
		id:        "projects.ctrl"
		kind:      "project"
		authority: "projects/ctrl/contract.cue"
		agents:    "projects/ctrl/.agents"
		tasks: {
			"upstream-monitor": {
				id:        "projects.ctrl.upstream-monitor"
				authority: "projects/ctrl/contract.cue"
				adapter:   "projects/ctrl/.agents/adapters/upstream-monitor.md"
			}
		}
		outputs: {}
	}
	"projects.epistemic-plant-bootstrap": unit.#Unit & {
		id:        "projects.epistemic-plant-bootstrap"
		kind:      "project"
		authority: "projects/epistemic-plant-bootstrap/contract.cue"
		agents:    "projects/epistemic-plant-bootstrap/.agents"
		tasks: {
			"upstream-monitor": {
				id:        "projects.epistemic-plant-bootstrap.upstream-monitor"
				authority: "projects/epistemic-plant-bootstrap/contract.cue"
				adapter:   "projects/epistemic-plant-bootstrap/.agents/adapters/upstream-monitor.md"
			}
		}
		outputs: {}
	}
})

_registryIdentity: [for id, registered in units {
	let unitID = id
	_id:    unitID & #UnitID
	_value: registered & {id: unitID}
	if id =~ "^projects\\." {
		_kind: registered & {kind: "project"}
	}
	if id =~ "^academic\\." {
		_kind: registered & {kind: "academic"}
	}
	if id =~ "^world\\." {
		_kind: registered & {kind: "world"}
	}
	_tasks: [for name, task in registered.tasks {
		task & {id: "\(unitID).\(name)"}
	}]
	_outputs: [for name, output in registered.outputs {
		output & {id: "\(unitID).\(name)"}
	}]
}]
