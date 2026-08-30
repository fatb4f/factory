package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

referenceMechanicalSemantics: close({
	evidence: close({
		scalePosition: gym.#EvidenceRecord & {
			id:       "fixture-scale-position"
			class:    "exercise-derived-proxy"
			sourceID: "fixture:squat-scale-position"
		}
		externalLoad: gym.#EvidenceRecord & {
			id:       "fixture-external-load-axis"
			class:    "exercise-derived-proxy"
			sourceID: "fixture:external-load-axis"
		}
		compensationVideo: gym.#EvidenceRecord & {
			id:       "fixture-compensation-video"
			class:    "direct-mechanical"
			sourceID: "fixture:split-squat-video"
			provider: {id: "fixture-video-provider"}
			method:   "kinematic-marker"
			modelVersion: "fixture-v1"
		}
	})

	objective: gym.#MechanicalObjective & {
		id:       "squat-ascent-support"
		label:    "Squat ascent support"
		movement: {id: "squat"}
		phase:    {id: "ascent"}
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
		phase:       {id: "ascent"}
		contributor: {id: "squat-knee-extension-capacity-proxy"}
		demand:      {id: "squat-ascent-knee-extension-moment"}
		effects: [{
			target:    {kind: "joint-dof", id: "knee", dof: "flexion-extension", side: "bilateral"}
			quantity:  "moment"
			sign:      "positive"
			direction: "extension"
		}]
		contractionMode: "concentric"
		evidence: [{evidence: {id: "fixture-scale-position"}, role: "source", ordinal: 0}]
		confidence: 0.5
	}

	role: gym.#MechanicalRoleAssignment & {
		contribution: {id: "squat-ascent-knee-extension-proxy-contribution"}
		role:         "support"
		objective:    {id: "squat-ascent-support"}
		interpretationRule: "positive extension moment contributes to the admitted support objective"
		evidence: [{evidence: {id: "fixture-scale-position"}, role: "supporting", ordinal: 0}]
	}

	transform: gym.#DemandTransform & {
		axis: {id: "external-load"}
		effects: [{
			demand:   {id: "squat-ascent-knee-extension-moment"}
			relation: "increase"
			confidence: 0.5
		}]
		evidence: [{evidence: {id: "fixture-external-load-axis"}, role: "source", ordinal: 0}]
	}

	admission: gym.#MechanicalAdmissionDecision & {
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
		evidence: [{evidence: {id: "fixture-scale-position"}, role: "source", ordinal: 0}]
		grant: {
			id:       "fixture-squat-knee-extension-grant"
			decision: {id: "fixture-squat-admission"}
			exposure: "fixture-squat-exposure"
			demand:   {id: "squat-ascent-knee-extension-moment"}
		}
	}

	capacity: gym.#NormalizedCapacity & {
		id:     "fixture-squat-knee-extension-capacity"
		demand: {id: "squat-ascent-knee-extension-moment"}
		value: {
			value:  1
			unit:   "ratio"
			source: "derived"
			evidence: [{evidence: {id: "fixture-scale-position"}, role: "derivation-input", ordinal: 0}]
		}
		grant:         {id: "fixture-squat-knee-extension-grant"}
		normalization: {kind: "body-mass"}
	}

	compensationMarker: gym.#CompensationMarker & {
		id:             "fixture-excessive-pelvic-rotation"
		label:          "Excessive pelvic rotation"
		movement:       {id: "split-squat"}
		target:         {kind: "segment", id: "pelvis"}
		mechanicalType: "rotation"
		direction:      "transverse"
		phase:          {id: "descent"}
		detectionBasis: "kinematics"
	}

	compensationObservation: gym.#CompensationObservation & {
		id:       "fixture-pelvic-rotation-observation"
		marker:   {id: "fixture-excessive-pelvic-rotation"}
		movement: {id: "split-squat"}
		phase:    {id: "descent"}
		side:     "right"
		peak: {
			value:  8
			unit:   "deg"
			source: "measured"
			evidence: [{evidence: {id: "fixture-compensation-video"}, role: "source", ordinal: 0}]
		}
		evidence: [{evidence: {id: "fixture-compensation-video"}, role: "source", ordinal: 0}]
	}

	provider: gym.#EvidenceProvider & {
		id:           "fixture-video-provider"
		kind:         "video"
		adapter:      "VideoKinematicsAdapter"
		capabilities: ["kinematics"]
		outputClass:  "direct-mechanical"
	}

	executor: gym.#OperationExecutor & {
		id:         "fixture-ibis-executor"
		runtime:    "ibis"
		operations: ["normalization", "comparison", "projection"]
		adapter:    "GymIbisExecutor"
	}
})

// This fixture exercises the complete referential transition path. It proves
// that the demand-specific grant resolves to an admitted decision and that the
// resulting capacity, phase identities, evidence links and compensation context
// are mutually consistent.
referenceMechanicalIntegrity: gym.#SemanticIntegrityState & {
	movementPatterns: {
		squat:         referenceMovementPatterns.squat
		"split-squat": referenceMovementPatterns.splitSquat
	}
	objectives: {
		"squat-ascent-support": referenceMechanicalSemantics.objective
	}
	demands: {
		"squat-ascent-knee-extension-moment": referenceMechanicalSemantics.demand
	}
	contributions: {
		"squat-ascent-knee-extension-proxy-contribution": referenceMechanicalSemantics.contribution
	}
	evidence: {
		"fixture-scale-position":       referenceMechanicalSemantics.evidence.scalePosition
		"fixture-external-load-axis":   referenceMechanicalSemantics.evidence.externalLoad
		"fixture-compensation-video":   referenceMechanicalSemantics.evidence.compensationVideo
	}
	mechanicalAdmissions: {
		"fixture-squat-admission": referenceMechanicalSemantics.admission
	}
	mechanicalGrants: {
		"fixture-squat-knee-extension-grant": referenceMechanicalSemantics.admission.grant
	}
	capacities: {
		"fixture-squat-knee-extension-capacity": referenceMechanicalSemantics.capacity
	}
	comparisonAdmissions: {}
	comparisonGrants:     {}
	relations:            {}
	compensationMarkers: {
		"fixture-excessive-pelvic-rotation": referenceMechanicalSemantics.compensationMarker
	}
	compensationObservations: {
		"fixture-pelvic-rotation-observation": referenceMechanicalSemantics.compensationObservation
	}
	contributionDistributions: {}
	equilibriumProjections:    {}
}
