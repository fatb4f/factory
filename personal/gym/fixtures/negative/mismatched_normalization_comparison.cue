package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

compatibleDespiteMismatch: gym.#ComparisonAdmissionDecision & {
	id:       "cmp-mismatch"
	left:     {id: "cap-left"}
	right:    {id: "cap-right"}
	basis:    comparisonBasis
	state:    "compatible"
	evidence: [baseEvidenceLink]
	grant: {
		id:       "comparison-grant-mismatch"
		decision: {id: "cmp-mismatch"}
		left:     {id: "cap-left"}
		right:    {id: "cap-right"}
		basis:    comparisonBasis
	}
}

invalid: gym.#SemanticIntegrityState & emptyState & validMixedNormalizationPair & {
	comparisonAdmissions: {"cmp-mismatch": compatibleDespiteMismatch}
	comparisonGrants: {"comparison-grant-mismatch": compatibleDespiteMismatch.grant}
}
