package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

incompatibleDecision: gym.#ComparisonAdmissionDecision & {
	id:       "cmp-incompatible"
	left:     {id: "cap-left"}
	right:    {id: "cap-right"}
	basis:    comparisonBasis
	state:    "incompatible"
	reasons:  ["fixture incompatibility"]
	evidence: [baseEvidenceLink]
}

fabricatedComparisonGrant: gym.#ComparisonAdmissionGrant & {
	id:       "comparison-grant-incompatible"
	decision: {id: "cmp-incompatible"}
	left:     {id: "cap-left"}
	right:    {id: "cap-right"}
	basis:    comparisonBasis
}

invalid: gym.#SemanticIntegrityState & emptyState & validBodyMassPair & {
	comparisonAdmissions: {"cmp-incompatible": incompatibleDecision}
	comparisonGrants: {"comparison-grant-incompatible": fabricatedComparisonGrant}
	relations: {
		"bad-relation": gym.#ContextualCapacityRelation & {
			id:           "bad-relation"
			source:       {id: "cap-left"}
			target:       {id: "cap-right"}
			grant:        {id: "comparison-grant-incompatible"}
			relationType: "bilateral"
			context:      {movement: {id: "squat"}, phase: {id: "ascent"}}
			evidence:     [baseEvidenceLink]
		}
	}
}
