package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

baseMovement: gym.#MovementPattern & {
	id:    "squat"
	label: "Integrity fixture squat"
	plane: "sagittal"
	channels: [{id: "squat-knee-extension", joint: "knee", action: "extension"}]
	phases: [
		{id: "descent", kind: "eccentric", motion: [{joint: "knee", action: "flexion"}], activeDemand: [{id: "squat-knee-extension"}]},
		{id: "ascent", kind: "concentric", motion: [{joint: "knee", action: "extension"}], activeDemand: [{id: "squat-knee-extension"}]},
	]
}

baseObjective: gym.#MechanicalObjective & {
	id:       "obj"
	label:    "Squat ascent support"
	movement: {id: "squat"}
	phase:    {id: "ascent"}
}

baseDemand: gym.#MechanicalDemand & {
	id:        "demand-a"
	objective: {id: "obj"}
	target:    {kind: "joint-dof", id: "knee", dof: "flexion-extension"}
	quantity:  "moment"
	plane:     "sagittal"
	direction: "extension"
}

baseEvidence: gym.#EvidenceRecord & {
	id:       "e1"
	class:    "exercise-derived-proxy"
	sourceID: "fixture:e1"
}

baseEvidenceLink: gym.#EvidenceLink & {
	evidence: {id: "e1"}
	role:     "source"
	ordinal:  0
}

basePosition: gym.#ScalePosition & {
	family: {id: "fixture-family"}
	coordinates: [{axis: {id: "external-load"}, numeric: 1, unit: "kg", certainty: "direct"}]
}

leftAdmission: gym.#MechanicalAdmissionDecision & {
	id:       "adm-left"
	exposure: "exp-left"
	position: basePosition
	basis: {
		pattern:       {id: "squat"}
		demands:       [{id: "demand-a"}]
		normalization: {kind: "body-mass"}
	}
	state:    "admitted"
	evidence: [baseEvidenceLink]
	grant: {
		id:       "grant-left"
		decision: {id: "adm-left"}
		exposure: "exp-left"
		demand:   {id: "demand-a"}
	}
}

rightAdmissionBodyMass: gym.#MechanicalAdmissionDecision & {
	id:       "adm-right"
	exposure: "exp-right"
	position: basePosition
	basis: {
		pattern:       {id: "squat"}
		demands:       [{id: "demand-a"}]
		normalization: {kind: "body-mass"}
	}
	state:    "admitted"
	evidence: [baseEvidenceLink]
	grant: {
		id:       "grant-right"
		decision: {id: "adm-right"}
		exposure: "exp-right"
		demand:   {id: "demand-a"}
	}
}

rightAdmissionSelfBaseline: gym.#MechanicalAdmissionDecision & {
	id:       "adm-right"
	exposure: "exp-right"
	position: basePosition
	basis: {
		pattern:       {id: "squat"}
		demands:       [{id: "demand-a"}]
		normalization: {kind: "self-baseline"}
	}
	state:    "admitted"
	evidence: [baseEvidenceLink]
	grant: {
		id:       "grant-right"
		decision: {id: "adm-right"}
		exposure: "exp-right"
		demand:   {id: "demand-a"}
	}
}

leftCapacity: gym.#NormalizedCapacity & {
	id:            "cap-left"
	demand:        {id: "demand-a"}
	grant:         {id: "grant-left"}
	normalization: {kind: "body-mass"}
	value: {
		value:    1
		unit:     "ratio"
		source:   "derived"
		evidence: [baseEvidenceLink]
	}
}

rightCapacityBodyMass: gym.#NormalizedCapacity & {
	id:            "cap-right"
	demand:        {id: "demand-a"}
	grant:         {id: "grant-right"}
	normalization: {kind: "body-mass"}
	value: {
		value:    1
		unit:     "ratio"
		source:   "derived"
		evidence: [baseEvidenceLink]
	}
}

rightCapacitySelfBaseline: gym.#NormalizedCapacity & {
	id:            "cap-right"
	demand:        {id: "demand-a"}
	grant:         {id: "grant-right"}
	normalization: {kind: "self-baseline"}
	value: {
		value:    1
		unit:     "ratio"
		source:   "derived"
		evidence: [baseEvidenceLink]
	}
}

comparisonBasis: gym.#ComparisonBasis & {
	movementContext:    {id: "squat"}
	phase:              {id: "ascent"}
	contractionRegime:  "concentric"
	referenceVersion:   "negative-fixture-v1"
}

emptyState: {
	movementPatterns: {squat: baseMovement}
	objectives:       {}
	demands:          {}
	contributions:    {}
	evidence:         {e1: baseEvidence}
	mechanicalAdmissions: {}
	mechanicalGrants:     {}
	capacities:           {}
	comparisonAdmissions: {}
	comparisonGrants:     {}
	relations:            {}
	compensationMarkers:      {}
	compensationObservations: {}
	contributionDistributions: {}
	equilibriumProjections:    {}
}

validBodyMassPair: {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	mechanicalAdmissions: {
		"adm-left":  leftAdmission
		"adm-right": rightAdmissionBodyMass
	}
	mechanicalGrants: {
		"grant-left":  leftAdmission.grant
		"grant-right": rightAdmissionBodyMass.grant
	}
	capacities: {
		"cap-left":  leftCapacity
		"cap-right": rightCapacityBodyMass
	}
}

validMixedNormalizationPair: {
	objectives: {obj: baseObjective}
	demands:    {"demand-a": baseDemand}
	mechanicalAdmissions: {
		"adm-left":  leftAdmission
		"adm-right": rightAdmissionSelfBaseline
	}
	mechanicalGrants: {
		"grant-left":  leftAdmission.grant
		"grant-right": rightAdmissionSelfBaseline.grant
	}
	capacities: {
		"cap-left":  leftCapacity
		"cap-right": rightCapacitySelfBaseline
	}
}
