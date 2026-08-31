package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

referenceDistribution: gym.#ContributionDistribution & {
	id:       "fixture-squat-ascent-distribution"
	movement: {id: "squat"}
	phase:    {id: "ascent"}
	demand:   {id: "squat-ascent-knee-extension-moment"}
	entries: [{
		contributor:  {id: "squat-knee-extension-capacity-proxy"}
		contribution: {id: "squat-ascent-knee-extension-proxy-contribution"}
		allocation:   1
	}]
	evidence:          [{evidence: {id: "fixture-scale-position"}, role: "derivation-input", ordinal: 0}]
	projectionVersion: "fixture-v1"
}

referenceEquilibrium: gym.#EquilibriumProjection & {
	movement: {id: "squat"}
	phase:    {id: "ascent"}
	demandResiduals: [{
		demand: {id: "squat-ascent-knee-extension-moment"}
		residual: {
			value:    0
			unit:     "ratio"
			source:   "derived"
			evidence: [{evidence: {id: "fixture-scale-position"}, role: "derivation-input", ordinal: 0}]
		}
	}]
	contributionDistribution: {id: "fixture-squat-ascent-distribution"}
	evidence:                 [{evidence: {id: "fixture-scale-position"}, role: "derivation-input", ordinal: 0}]
	projectionVersion:        "fixture-v1"
}

referenceEquilibriumIntegrity: gym.#SemanticIntegrityState & {
	movementPatterns: {
		squat: referenceMovementPatterns.squat
	}
	objectives: {
		"squat-ascent-support": referenceMechanicalSemantics.objective
	}
	demands: {
		"squat-ascent-knee-extension-moment": referenceMechanicalSemantics.demand
	}
	contributors: {
		"squat-knee-extension-capacity-proxy": referenceMechanicalSemantics.contributor
	}
	contributions: {
		"squat-ascent-knee-extension-proxy-contribution": referenceMechanicalSemantics.contribution
	}
	evidence: {
		"fixture-scale-position": referenceMechanicalSemantics.evidence.scalePosition
	}
	mechanicalAdmissions: {}
	mechanicalGrants:     {}
	capacities:           {}
	comparisonAdmissions: {}
	comparisonGrants:     {}
	relations:            {}
	compensationMarkers:      {}
	compensationObservations: {}
	compensationProjections:  {}
	contributionDistributions: {
		"fixture-squat-ascent-distribution": referenceDistribution
	}
	equilibriumProjections: {
		"fixture-squat-ascent-equilibrium": referenceEquilibrium
	}
}
