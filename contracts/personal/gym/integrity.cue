package gym

// Resolve only keys that are concretely present in a registry. Direct lookup on
// a CUE pattern map such as {[string]: T} is not an existence proof: an absent
// key can still evaluate to T. Requiring a non-empty comprehension match makes
// referential integrity explicit.
#RegistryResolution: {
	registry: {[string]: _}
	refID:    string
	matches: [for key, value in registry if key == refID {
		value
	}] & [_, ...]
	value: matches[0]
}

// SemanticIntegrityState is a qualification root over canonical objects. It is
// not a second storage model: its maps resolve ID-only references so CUE can
// enforce transition and referential invariants that JSON Schema cannot express.
#SemanticIntegrityState: close({
	movementPatterns: {[string]: #MovementPattern}
	objectives: {[string]: #MechanicalObjective}
	demands: {[string]: #MechanicalDemand}
	contributions: {[string]: #MechanicalContribution}
	evidence: {[string]: #EvidenceRecord}
	mechanicalAdmissions: {[string]: #MechanicalAdmissionDecision}
	mechanicalGrants: {[string]: #MechanicalAdmissionGrant}
	capacities: {[string]: #NormalizedCapacity}
	comparisonAdmissions: {[string]: #ComparisonAdmissionDecision}
	comparisonGrants: {[string]: #ComparisonAdmissionGrant}
	relations: {[string]: #ContextualCapacityRelation}
	compensationMarkers: {[string]: #CompensationMarker}
	compensationObservations: {[string]: #CompensationObservation}
	contributionDistributions: {[string]: #ContributionDistribution}
	equilibriumProjections: {[string]: #EquilibriumProjection}

	_movementIdentity: [for id, movement in movementPatterns {
		_value: movement & {id: id}
	}]

	_objectiveIntegrity: [for id, objective in objectives {
		_key: objective & {id: id}
		_movementResolution: #RegistryResolution & {
			registry: movementPatterns
			refID:    objective.movement.id
		}
		_movement: _movementResolution.value & {id: objective.movement.id}
		_phase: [for phase in _movement.phases if phase.id == objective.phase.id {
			phase
		}] & [_, ...]
	}]

	_demandIntegrity: [for id, demand in demands {
		_key: demand & {id: id}
		_objectiveResolution: #RegistryResolution & {
			registry: objectives
			refID:    demand.objective.id
		}
		_objective: _objectiveResolution.value & {id: demand.objective.id}
	}]

	_contributionIntegrity: [for id, contribution in contributions {
		_key: contribution & {id: id}
		_movementResolution: #RegistryResolution & {
			registry: movementPatterns
			refID:    contribution.movement.id
		}
		_movement: _movementResolution.value & {id: contribution.movement.id}
		_demandResolution: #RegistryResolution & {
			registry: demands
			refID:    contribution.demand.id
		}
		_demand: _demandResolution.value & {id: contribution.demand.id}
		_phase: [for phase in _movement.phases if phase.id == contribution.phase.id {
			phase
		}] & [_, ...]
		_evidence: [for link in contribution.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
	}]

	_evidenceIdentity: [for id, record in evidence {
		_value: record & {id: id}
	}]

	_mechanicalAdmissionIntegrity: [for id, decision in mechanicalAdmissions {
		_key: decision & {id: id}
		_evidence: [for link in decision.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
		if decision.state == "admitted" {
			_grantResolution: #RegistryResolution & {
				registry: mechanicalGrants
				refID:    decision.grant.id
			}
			_grant: _grantResolution.value & decision.grant & {id: decision.grant.id}
		}
	}]

	_mechanicalGrantIntegrity: [for id, grant in mechanicalGrants {
		_key: grant & {id: id}
		_decisionResolution: #RegistryResolution & {
			registry: mechanicalAdmissions
			refID:    grant.decision.id
		}
		_decision: _decisionResolution.value & {
			id:       grant.decision.id
			state:    "admitted"
			grant:    grant
			exposure: grant.exposure
		}
		_demandResolution: #RegistryResolution & {
			registry: demands
			refID:    grant.demand.id
		}
		_demand: _demandResolution.value & {id: grant.demand.id}
		_demandInBasis: [for admittedDemand in _decision.basis.demands if admittedDemand.id == grant.demand.id {
			admittedDemand
		}] & [_, ...]
	}]

	_capacityIntegrity: [for id, capacity in capacities {
		_key: capacity & {id: id}
		_demandResolution: #RegistryResolution & {
			registry: demands
			refID:    capacity.demand.id
		}
		_demand: _demandResolution.value & {id: capacity.demand.id}
		_grantResolution: #RegistryResolution & {
			registry: mechanicalGrants
			refID:    capacity.grant.id
		}
		_grant: _grantResolution.value & {
			id:     capacity.grant.id
			demand: capacity.demand
		}
		_decisionResolution: #RegistryResolution & {
			registry: mechanicalAdmissions
			refID:    _grant.decision.id
		}
		_decision: _decisionResolution.value & {
			id:    _grant.decision.id
			state: "admitted"
			basis: {normalization: capacity.normalization}
		}
		_evidence: [for link in capacity.value.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
	}]

	_comparisonAdmissionIntegrity: [for id, decision in comparisonAdmissions {
		_key: decision & {id: id}
		_leftResolution: #RegistryResolution & {
			registry: capacities
			refID:    decision.left.id
		}
		_left: _leftResolution.value & {id: decision.left.id}
		_rightResolution: #RegistryResolution & {
			registry: capacities
			refID:    decision.right.id
		}
		_right: _rightResolution.value & {id: decision.right.id}
		_evidence: [for link in decision.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
		if decision.state == "compatible" {
			_normalization: _left.normalization & _right.normalization
			_grantResolution: #RegistryResolution & {
				registry: comparisonGrants
				refID:    decision.grant.id
			}
			_grant: _grantResolution.value & decision.grant & {id: decision.grant.id}
		}
	}]

	_comparisonGrantIntegrity: [for id, grant in comparisonGrants {
		_key: grant & {id: id}
		_decisionResolution: #RegistryResolution & {
			registry: comparisonAdmissions
			refID:    grant.decision.id
		}
		_decision: _decisionResolution.value & {
			id:    grant.decision.id
			state: "compatible"
			grant: grant
			left:  grant.left
			right: grant.right
			basis: grant.basis
		}
	}]

	_relationIntegrity: [for id, relation in relations {
		_key: relation & {id: id}
		_grantResolution: #RegistryResolution & {
			registry: comparisonGrants
			refID:    relation.grant.id
		}
		_grant: _grantResolution.value & {
			id:    relation.grant.id
			left:  relation.source
			right: relation.target
		}
		_evidence: [for link in relation.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
	}]

	_compensationMarkerIntegrity: [for id, marker in compensationMarkers {
		_key: marker & {id: id}
		_movementResolution: #RegistryResolution & {
			registry: movementPatterns
			refID:    marker.movement.id
		}
		_movement: _movementResolution.value & {id: marker.movement.id}
		_phase: [for phase in _movement.phases if phase.id == marker.phase.id {
			phase
		}] & [_, ...]
	}]

	_compensationObservationIntegrity: [for id, observation in compensationObservations {
		_key: observation & {id: id}
		_markerResolution: #RegistryResolution & {
			registry: compensationMarkers
			refID:    observation.marker.id
		}
		_marker: _markerResolution.value & {
			id:       observation.marker.id
			movement: observation.movement
			phase:    observation.phase
		}
		_evidence: [for link in observation.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
	}]

	_distributionIntegrity: [for id, distribution in contributionDistributions {
		_key: distribution & {id: id}
		_movementResolution: #RegistryResolution & {
			registry: movementPatterns
			refID:    distribution.movement.id
		}
		_movement: _movementResolution.value & {id: distribution.movement.id}
		_demandResolution: #RegistryResolution & {
			registry: demands
			refID:    distribution.demand.id
		}
		_demand: _demandResolution.value & {id: distribution.demand.id}
		_phase: [for phase in _movement.phases if phase.id == distribution.phase.id {
			phase
		}] & [_, ...]
		_evidence: [for link in distribution.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
	}]

	_equilibriumIntegrity: [for id, projection in equilibriumProjections {
		_movementResolution: #RegistryResolution & {
			registry: movementPatterns
			refID:    projection.movement.id
		}
		_movement: _movementResolution.value & {id: projection.movement.id}
		_phase: [for phase in _movement.phases if phase.id == projection.phase.id {
			phase
		}] & [_, ...]
		_evidence: [for link in projection.evidence {
			_resolution: #RegistryResolution & {
				registry: evidence
				refID:    link.evidence.id
			}
			_record: _resolution.value & {id: link.evidence.id}
		}]
	}]
})
