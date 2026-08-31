package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

invalidDanglingContributor: gym.#SemanticIntegrityState & (emptyState & {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	contributions: {
		"contribution-a": gym.#MechanicalContribution & {
			id:          "contribution-a"
			movement:    {id: "squat"}
			phase:       {id: "ascent"}
			contributor: {id: "missing-contributor"}
			demand:      {id: "demand-a"}
			effects: [{
				target:    {kind: "joint-dof", id: "knee", dof: "flexion-extension"}
				quantity:  "moment"
				sign:      "positive"
				direction: "extension"
			}]
			evidence: [baseEvidenceLink]
		}
	}
})
