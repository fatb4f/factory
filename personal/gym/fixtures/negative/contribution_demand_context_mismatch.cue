package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

mismatchedObjective: gym.#MechanicalObjective & {
	id:       "obj-descent"
	label:    "Squat descent objective"
	movement: {id: "squat"}
	phase:    {id: "descent"}
}

mismatchedDemand: gym.#MechanicalDemand & {
	id:        "demand-descent"
	objective: {id: "obj-descent"}
	target:    {kind: "joint-dof", id: "knee", dof: "flexion-extension"}
	quantity:  "moment"
	plane:     "sagittal"
	direction: "extension"
}

invalidContributionContext: gym.#SemanticIntegrityState & (emptyState & {
	objectives: {"obj-descent": mismatchedObjective}
	demands:    {"demand-descent": mismatchedDemand}
	contributors: {"contributor-a": baseContributor}
	contributions: {
		"contribution-a": gym.#MechanicalContribution & {
			id:          "contribution-a"
			movement:    {id: "squat"}
			phase:       {id: "ascent"}
			contributor: {id: "contributor-a"}
			demand:      {id: "demand-descent"}
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
