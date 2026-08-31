package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

invalidEquilibriumDistribution: gym.#SemanticIntegrityState & (emptyState & {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	equilibriumProjections: {
		"equilibrium-a": gym.#EquilibriumProjection & {
			movement: {id: "squat"}
			phase:    {id: "ascent"}
			demandResiduals: [{
				demand: {id: "demand-a"}
				residual: {
					value:    0
					unit:     "ratio"
					source:   "derived"
					evidence: [baseEvidenceLink]
				}
			}]
			contributionDistribution: {id: "missing-distribution"}
			evidence:                 [baseEvidenceLink]
			projectionVersion:        "negative-fixture-v1"
		}
	}
})
