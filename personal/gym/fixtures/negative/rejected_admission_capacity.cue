package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

rejectedDecision: gym.#MechanicalAdmissionDecision & {
	id:       "adm-rejected"
	exposure: "exp-rejected"
	position: basePosition
	basis: {
		pattern:       {id: "squat"}
		demands:       [{id: "demand-a"}]
		normalization: {kind: "body-mass"}
	}
	state:    "rejected"
	reasons:  ["fixture rejection"]
	evidence: [baseEvidenceLink]
}

fabricatedGrant: gym.#MechanicalAdmissionGrant & {
	id:       "grant-rejected"
	decision: {id: "adm-rejected"}
	exposure: "exp-rejected"
	demand:   {id: "demand-a"}
}

invalid: gym.#SemanticIntegrityState & emptyState & {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	mechanicalAdmissions: {"adm-rejected": rejectedDecision}
	mechanicalGrants:     {"grant-rejected": fabricatedGrant}
	capacities: {
		"cap-rejected": gym.#NormalizedCapacity & {
			id:            "cap-rejected"
			demand:        {id: "demand-a"}
			grant:         {id: "grant-rejected"}
			normalization: {kind: "body-mass"}
			value: {value: 1, source: "derived", evidence: [baseEvidenceLink]}
		}
	}
}
