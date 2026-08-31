package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

invalidDistributionContributor: gym.#SemanticIntegrityState & (emptyState & {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	contributionDistributions: {
		"distribution-a": gym.#ContributionDistribution & {
			id:       "distribution-a"
			movement: {id: "squat"}
			phase:    {id: "ascent"}
			demand:   {id: "demand-a"}
			entries: [{contributor: {id: "missing-contributor"}, allocation: 1}]
			evidence: [baseEvidenceLink]
			projectionVersion: "negative-fixture-v1"
		}
	}
})
