package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

invalid: gym.#SemanticIntegrityState & emptyState & {
	objectives: {
		"bad-phase-objective": gym.#MechanicalObjective & {
			id:       "bad-phase-objective"
			label:    "Unknown phase objective"
			movement: {id: "squat"}
			phase:    {id: "mid-stance"}
		}
	}
}
