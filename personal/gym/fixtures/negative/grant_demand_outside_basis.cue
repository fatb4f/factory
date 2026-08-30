package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

secondDemand: gym.#MechanicalDemand & {
	id:        "demand-b"
	objective: {id: "obj"}
	target:    {kind: "joint-dof", id: "hip", dof: "flexion-extension"}
	quantity:  "moment"
	plane:     "sagittal"
	direction: "extension"
}

badDecision: gym.#MechanicalAdmissionDecision & {
	id:       "adm-wrong-demand"
	exposure: "exp-wrong-demand"
	position: basePosition
	basis: {
		pattern:       {id: "squat"}
		demands:       [{id: "demand-a"}]
		normalization: {kind: "body-mass"}
	}
	state:    "admitted"
	evidence: [baseEvidenceLink]
	grant: {
		id:       "grant-wrong-demand"
		decision: {id: "adm-wrong-demand"}
		exposure: "exp-wrong-demand"
		demand:   {id: "demand-b"}
	}
}

invalid: gym.#SemanticIntegrityState & emptyState & {
	objectives: {obj: baseObjective}
	demands: {
		"demand-a": baseDemand
		"demand-b": secondDemand
	}
	mechanicalAdmissions: {"adm-wrong-demand": badDecision}
	mechanicalGrants:     {"grant-wrong-demand": badDecision.grant}
}
