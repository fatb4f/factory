package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

badMarker: gym.#CompensationMarker & {
	id:             "marker-phase"
	label:          "Phase-bound marker"
	movement:       {id: "squat"}
	target:         {kind: "segment", id: "pelvis"}
	mechanicalType: "rotation"
	phase:          {id: "descent"}
	detectionBasis: "kinematics"
}

badObservation: gym.#CompensationObservation & {
	id:       "observation-phase"
	marker:   {id: "marker-phase"}
	movement: {id: "squat"}
	phase:    {id: "ascent"}
	evidence: [baseEvidenceLink]
}

invalid: gym.#SemanticIntegrityState & emptyState & {
	compensationMarkers:      {"marker-phase": badMarker}
	compensationObservations: {"observation-phase": badObservation}
}
