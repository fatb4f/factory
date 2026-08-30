package gym

// SemanticIntegrityState is a qualification root over canonical objects. It is
// not a second storage model: its maps resolve ID-only references so CUE can
// enforce transition and referential invariants that JSON Schema cannot express.
#SemanticIntegrityState: close({
	movementPatterns: {
		[string]: #MovementPattern
	}
	objectives: {
		[string]: #MechanicalObjective
	}
	demands: {
		[string]: #MechanicalDemand
	}
	contributions: {
		[string]: #MechanicalContribution
	}
	evidence: {
		[string]: #EvidenceRecord
	}
	mechanicalAdmissions: {
		[string]: #MechanicalAdmissionDecision
	}
	mechanicalGrants: {
		[string]: #MechanicalAdmissionGrant
	}
	capacities: {
		[string]: #NormalizedCapacity
	}
	comparisonAdmissions: {
		[string]: #ComparisonAdmissionDecision
	}
	comparisonGrants: {
		[string]: #ComparisonAdmissionGrant
	}
	relations: {
		[string]: #ContextualCapacityRelation
	}
	compensationMarkers: {
		[string]: #CompensationMarker
	}
	compensationObservations: {
		[string]: #CompensationObservation
	}
	contributionDistributions: {
		[string]: #ContributionDistribution
	}
	equilibriumProjections: {
		[string]: #EquilibriumProjection
	}

	_movementIdentity: [for id, movement in movementPatterns {
		_value: movement & {id: id}
	}]

	_objectiveIntegrity: [for id, objective in objectives {
		_key:      objective & {id: id}
		_movement: movementPatterns[objective.movement.id]
		_phase: [for phase in _movement.phases if phase.id == objective.phase.id {
			phase
		}] & [_, ...]
	}]

	_demandIntegrity: [for id, demand in demands {
		_key:       demand & {id: id}
		_objective: objectives[demand.objective.id]
	}]

	_contributionIntegrity: [for id, contribution in contributions {
		_key:      contribution & {id: id}
		_movement: movementPatterns[contribution.movement.id]
		_demand:   demands[contribution.demand.id]
		_phase: [for phase in _movement.phases if phase.id == contribution.phase.id {
			phase
		}] & [_, ...]
		_evidence: [for link in contribution.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
	}]

	_evidenceIdentity: [for id, record in evidence {
		_value: record & {id: id}
	}]

	_mechanicalAdmissionIntegrity: [for id, decision in mechanicalAdmissions {
		_key: decision & {id: id}
		_evidence: [for link in decision.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
		if decision.state == "admitted" {
			_grant: mechanicalGrants[decision.grant.id] & decision.grant
		}
	}]

	_mechanicalGrantIntegrity: [for id, grant in mechanicalGrants {
		_key: grant & {id: id}
		_decision: mechanicalAdmissions[grant.decision.id] & {
			state: "admitted"
			grant: grant
			exposure: grant.exposure
		}
		_demand: demands[grant.demand.id]
		_demandInBasis: [for admittedDemand in _decision.basis.demands if admittedDemand.id == grant.demand.id {
			admittedDemand
		}] & [_, ...]
	}]

	_capacityIntegrity: [for id, capacity in capacities {
		_key: capacity & {id: id}
		_demand: demands[capacity.demand.id]
		_grant: mechanicalGrants[capacity.grant.id] & {
			demand: capacity.demand
		}
		_decision: mechanicalAdmissions[_grant.decision.id] & {
			state: "admitted"
			basis: {
				normalization: capacity.normalization
			}
		}
		_evidence: [for link in capacity.value.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
	}]

	_comparisonAdmissionIntegrity: [for id, decision in comparisonAdmissions {
		_key:   decision & {id: id}
		_left:  capacities[decision.left.id]
		_right: capacities[decision.right.id]
		_evidence: [for link in decision.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
		if decision.state == "compatible" {
			_normalization: _left.normalization & _right.normalization
			_grant: comparisonGrants[decision.grant.id] & decision.grant
		}
	}]

	_comparisonGrantIntegrity: [for id, grant in comparisonGrants {
		_key: grant & {id: id}
		_decision: comparisonAdmissions[grant.decision.id] & {
			state: "compatible"
			grant: grant
			left:  grant.left
			right: grant.right
			basis: grant.basis
		}
	}]

	_relationIntegrity: [for id, relation in relations {
		_key: relation & {id: id}
		_grant: comparisonGrants[relation.grant.id] & {
			left:  relation.source
			right: relation.target
		}
		_evidence: [for link in relation.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
	}]

	_compensationMarkerIntegrity: [for id, marker in compensationMarkers {
		_key:      marker & {id: id}
		_movement: movementPatterns[marker.movement.id]
		_phase: [for phase in _movement.phases if phase.id == marker.phase.id {
			phase
		}] & [_, ...]
	}]

	_compensationObservationIntegrity: [for id, observation in compensationObservations {
		_key: observation & {id: id}
		_marker: compensationMarkers[observation.marker.id] & {
			movement: observation.movement
			phase:    observation.phase
		}
		_evidence: [for link in observation.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
	}]

	_distributionIntegrity: [for id, distribution in contributionDistributions {
		_key:      distribution & {id: id}
		_movement: movementPatterns[distribution.movement.id]
		_demand:   demands[distribution.demand.id]
		_phase: [for phase in _movement.phases if phase.id == distribution.phase.id {
			phase
		}] & [_, ...]
		_evidence: [for link in distribution.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
	}]

	_equilibriumIntegrity: [for id, projection in equilibriumProjections {
		_movement: movementPatterns[projection.movement.id]
		_phase: [for phase in _movement.phases if phase.id == projection.phase.id {
			phase
		}] & [_, ...]
		_evidence: [for link in projection.evidence {
			_record: evidence[link.evidence.id] & {id: link.evidence.id}
		}]
	}]
})
