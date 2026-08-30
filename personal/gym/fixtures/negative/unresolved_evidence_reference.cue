package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

badContribution: gym.#MechanicalContribution & {
	id:          "bad-evidence-contribution"
	movement:    {id: "squat"}
	phase:       {id: "ascent"}
	contributor: {id: "fixture-contributor"}
	demand:      {id: "demand-a"}
	effects: [{
		target:   {kind: "joint-dof", id: "knee", dof: "flexion-extension"}
		quantity: "moment"
		sign:     "positive"
	}]
	evidence: [{evidence: {id: "missing-evidence"}, role: "source"}]
}

invalid: gym.#SemanticIntegrityState & emptyState & {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	contributions: {"bad-evidence-contribution": badContribution}
}
