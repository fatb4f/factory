package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

referenceMechanicalSemantics: close({
	objective: gym.#MechanicalObjective & {
		id:       "squat-ascent-support"
		label:    "Squat ascent support"
		movement: {id: "squat"}
		phase:    "ascent"
	}

	demand: gym.#MechanicalDemand & {
		id:        "squat-ascent-knee-extension-moment"
		objective: {id: "squat-ascent-support"}
		target:    {kind: "joint-dof", id: "knee", dof: "flexion-extension", side: "bilateral"}
		quantity:  "moment"
		plane:     "sagittal"
		direction: "extension"
		legacyChannel: {id: "squat-knee-extension"}
	}

	contributor: gym.#Contributor & {
		id:    "squat-knee-extension-capacity-proxy"
		label: "Squat knee-extension capacity proxy"
		kind:  "functional-aggregate"
		region: {id: "anterior-thigh"}
		side:  "bilateral"
	}

	contribution: gym.#MechanicalContribution & {
		id:          "squat-ascent-knee-extension-proxy-contribution"
		movement:    {id: "squat"}
		phase:       "ascent"
		contributor: {id: "squat-knee-extension-capacity-proxy"}
		demand:      {id: "squat-ascent-knee-extension-moment"}
		effects: [{
			target:    {kind: "joint-dof", id: "knee", dof: "flexion-extension", side: "bilateral"}
			quantity:  "moment"
			sign:      "positive"
			direction: "extension"
		}]
		contractionMode: "concentric"
		evidence: [{class: "exercise-derived-proxy", sourceID: "fixture:squat-scale-position"}]
		confidence: 0.5
	}

	role: gym.#MechanicalRoleAssignment & {
		contribution: {id: "squat-ascent-knee-extension-proxy-contribution"}
		role:         "support"
		objective:    {id: "squat-ascent-support"}
		interpretationRule: "positive extension moment contributes to the admitted support objective"
		evidence: [{class: "exercise-derived-proxy", sourceID: "fixture:squat-scale-position"}]
	}

	transform: gym.#DemandTransform & {
		axis: {id: "external-load"}
		effects: [{
			demand:   {id: "squat-ascent-knee-extension-moment"}
			relation: "increase"
			confidence: 0.5
		}]
		evidence: [{class: "exercise-derived-proxy", sourceID: "fixture:external-load-axis"}]
	}

	admission: gym.#MechanicalAdmission & {
		id:       "fixture-squat-admission"
		exposure: "fixture-squat-exposure"
		position: {
			family: {id: "atg-deep-squat"}
			coordinates: [{axis: {id: "external-load"}, numeric: 0, unit: "kg", certainty: "direct"}]
		}
		basis: {
			pattern: {id: "squat"}
			demands: [{id: "squat-ascent-knee-extension-moment"}]
			legacyChannels: [{id: "squat-knee-extension"}]
			normalization: {kind: "body-mass"}
		}
		state: "admitted"
		evidence: [{class: "exercise-derived-proxy", sourceID: "fixture:squat-scale-position"}]
	}

	capacity: gym.#NormalizedCapacity & {
		id:    "fixture-squat-knee-extension-capacity"
		basis: {
			pattern: {id: "squat"}
			demands: [{id: "squat-ascent-knee-extension-moment"}]
			legacyChannels: [{id: "squat-knee-extension"}]
			normalization: {kind: "body-mass"}
		}
		value: {
			value:  1
			unit:   "ratio"
			source: "derived"
			evidence: [{class: "exercise-derived-proxy", sourceID: "fixture:squat-scale-position"}]
		}
		admission: {id: "fixture-squat-admission"}
		comparisonBasis: {
			normalizationClass: "body-mass"
			demand:             {id: "squat-ascent-knee-extension-moment"}
			movementContext:    {id: "squat"}
			phase:              "ascent"
			contractionRegime:  "concentric"
			referenceVersion:   "fixture-v1"
		}
	}

	compensationMarker: gym.#CompensationMarker & {
		id:             "fixture-excessive-pelvic-rotation"
		label:          "Excessive pelvic rotation"
		movement:       {id: "split-squat"}
		target:         {kind: "segment", id: "pelvis"}
		mechanicalType: "rotation"
		direction:      "transverse"
		phase:          "descent"
		detectionBasis: "kinematics"
	}

	provider: gym.#EvidenceProvider & {
		id:           "opensim-adapter"
		kind:         "external-model"
		adapter:      "OpenSimAdapter"
		capabilities: ["kinematics", "kinetics", "mechanical-contribution"]
		outputClass:  "model-derived"
	}
})
