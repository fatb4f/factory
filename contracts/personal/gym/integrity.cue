package gym

// SemanticIntegrityState is a qualification root over canonical objects. It is
// not a second storage model. Referential checks iterate concrete registry keys
// and require a non-empty match because direct lookup on {[string]: T} is not
// an existence proof in CUE.
#SemanticIntegrityState: close({
	movementPatterns: {[string]: #MovementPattern}
	objectives: {[string]: #MechanicalObjective}
	demands: {[string]: #MechanicalDemand}
	contributors: {[string]: #Contributor}
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
	compensationProjections: {[string]: #CompensationProjection}
	contributionDistributions: {[string]: #ContributionDistribution}
	equilibriumProjections: {[string]: #EquilibriumProjection}

	_movementIdentity: [for id, movement in movementPatterns {
		_value: movement & {id: id}
	}]

	_objectiveIntegrity: [for id, objective in objectives {
		_key: objective & {id: id}
		_movementMatches: [for movementID, movement in movementPatterns if movementID == objective.movement.id {
			movement & {id: movementID}
		}] & [_, ...]
		_movement: _movementMatches[0]
		_phase: [for phase in _movement.phases if phase.id == objective.phase.id {
			phase
		}] & [_, ...]
	}]

	_demandIntegrity: [for id, demand in demands {
		_key: demand & {id: id}
		_objectiveMatches: [for objectiveID, objective in objectives if objectiveID == demand.objective.id {
			objective & {id: objectiveID}
		}] & [_, ...]
	}]

	_contributorIdentity: [for id, contributor in contributors {
		_value: contributor & {id: id}
	}]

	_contributionIntegrity: [for id, contribution in contributions {
		_key: contribution & {id: id}
		_movementMatches: [for movementID, movement in movementPatterns if movementID == contribution.movement.id {
			movement & {id: movementID}
		}] & [_, ...]
		_movement: _movementMatches[0]
		_phase: [for phase in _movement.phases if phase.id == contribution.phase.id {
			phase
		}] & [_, ...]
		_contributorMatches: [for contributorID, contributor in contributors if contributorID == contribution.contributor.id {
			contributor & {id: contributorID}
		}] & [_, ...]
		_demandMatches: [for demandID, demand in demands if demandID == contribution.demand.id {
			demand & {id: demandID}
		}] & [_, ...]
		_demand: _demandMatches[0]
		_objectiveMatches: [for objectiveID, objective in objectives if objectiveID == _demand.objective.id {
			objective & {
				id:       objectiveID
				movement: contribution.movement
				phase:    contribution.phase
			}
		}] & [_, ...]
		_evidence: [for link in contribution.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_evidenceIdentity: [for id, record in evidence {
		_value: record & {id: id}
	}]

	_mechanicalAdmissionIntegrity: [for id, decision in mechanicalAdmissions {
		_key: decision & {id: id}
		_evidence: [for link in decision.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
		if decision.state == "admitted" {
			_grantMatches: [for grantID, grant in mechanicalGrants if grantID == decision.grant.id {
				grant & decision.grant & {id: grantID}
			}] & [_, ...]
		}
	}]

	_mechanicalGrantIntegrity: [for id, grant in mechanicalGrants {
		_key: grant & {id: id}
		_decisionMatches: [for decisionID, decision in mechanicalAdmissions if decisionID == grant.decision.id {
			decision & {
				id:       decisionID
				state:    "admitted"
				grant:    grant
				exposure: grant.exposure
			}
		}] & [_, ...]
		_decision: _decisionMatches[0]
		_demandMatches: [for demandID, demand in demands if demandID == grant.demand.id {
			demand & {id: demandID}
		}] & [_, ...]
		_demandInBasis: [for admittedDemand in _decision.basis.demands if admittedDemand.id == grant.demand.id {
			admittedDemand
		}] & [_, ...]
	}]

	_capacityIntegrity: [for id, capacity in capacities {
		_key: capacity & {id: id}
		_demandMatches: [for demandID, demand in demands if demandID == capacity.demand.id {
			demand & {id: demandID}
		}] & [_, ...]
		_grantMatches: [for grantID, grant in mechanicalGrants if grantID == capacity.grant.id {
			grant & {id: grantID, demand: capacity.demand}
		}] & [_, ...]
		_grant: _grantMatches[0]
		_decisionMatches: [for decisionID, decision in mechanicalAdmissions if decisionID == _grant.decision.id {
			decision & {
				id:    decisionID
				state: "admitted"
				basis: {normalization: capacity.normalization}
			}
		}] & [_, ...]
		_evidence: [for link in capacity.value.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_comparisonAdmissionIntegrity: [for id, decision in comparisonAdmissions {
		_key: decision & {id: id}
		_leftMatches: [for capacityID, capacity in capacities if capacityID == decision.left.id {
			capacity & {id: capacityID}
		}] & [_, ...]
		_left: _leftMatches[0]
		_rightMatches: [for capacityID, capacity in capacities if capacityID == decision.right.id {
			capacity & {id: capacityID}
		}] & [_, ...]
		_right: _rightMatches[0]
		_evidence: [for link in decision.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
		if decision.state == "compatible" {
			_normalization: _left.normalization & _right.normalization
			_grantMatches: [for grantID, grant in comparisonGrants if grantID == decision.grant.id {
				grant & decision.grant & {id: grantID}
			}] & [_, ...]
		}
	}]

	_comparisonGrantIntegrity: [for id, grant in comparisonGrants {
		_key: grant & {id: id}
		_decisionMatches: [for decisionID, decision in comparisonAdmissions if decisionID == grant.decision.id {
			decision & {
				id:    decisionID
				state: "compatible"
				grant: grant
				left:  grant.left
				right: grant.right
				basis: grant.basis
			}
		}] & [_, ...]
	}]

	_relationIntegrity: [for id, relation in relations {
		_key: relation & {id: id}
		_grantMatches: [for grantID, grant in comparisonGrants if grantID == relation.grant.id {
			grant & {
				id:    grantID
				left:  relation.source
				right: relation.target
			}
		}] & [_, ...]
		_evidence: [for link in relation.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_compensationMarkerIntegrity: [for id, marker in compensationMarkers {
		_key: marker & {id: id}
		_movementMatches: [for movementID, movement in movementPatterns if movementID == marker.movement.id {
			movement & {id: movementID}
		}] & [_, ...]
		_movement: _movementMatches[0]
		_phase: [for phase in _movement.phases if phase.id == marker.phase.id {
			phase
		}] & [_, ...]
	}]

	_compensationObservationIntegrity: [for id, observation in compensationObservations {
		_key: observation & {id: id}
		_markerMatches: [for markerID, marker in compensationMarkers if markerID == observation.marker.id {
			marker & {
				id:       markerID
				movement: observation.movement
				phase:    observation.phase
			}
		}] & [_, ...]
		_evidence: [for link in observation.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_compensationProjectionIntegrity: [for id, projection in compensationProjections {
		_key: projection & {id: id}
		_movementMatches: [for movementID, movement in movementPatterns if movementID == projection.movement.id {
			movement & {id: movementID}
		}] & [_, ...]
		_observations: [for observationRef in projection.observations {
			_matches: [for observationID, observation in compensationObservations if observationID == observationRef.id {
				observation & {id: observationID, movement: projection.movement}
			}] & [_, ...]
		}]
		if projection.qualifications != _|_ {
			_qualifications: [for qualification in projection.qualifications {
				_matches: [for observationID, observation in compensationObservations if observationID == qualification.observation.id {
					observation & {id: observationID, movement: projection.movement}
				}] & [_, ...]
			}]
		}
	}]

	_distributionIntegrity: [for id, distribution in contributionDistributions {
		_key: distribution & {id: id}
		_movementMatches: [for movementID, movement in movementPatterns if movementID == distribution.movement.id {
			movement & {id: movementID}
		}] & [_, ...]
		_movement: _movementMatches[0]
		_phase: [for phase in _movement.phases if phase.id == distribution.phase.id {
			phase
		}] & [_, ...]
		_demandMatches: [for demandID, demand in demands if demandID == distribution.demand.id {
			demand & {id: demandID}
		}] & [_, ...]
		_demand: _demandMatches[0]
		_objectiveMatches: [for objectiveID, objective in objectives if objectiveID == _demand.objective.id {
			objective & {
				id:       objectiveID
				movement: distribution.movement
				phase:    distribution.phase
			}
		}] & [_, ...]
		_entries: [for entry in distribution.entries {
			_contributorMatches: [for contributorID, contributor in contributors if contributorID == entry.contributor.id {
				contributor & {id: contributorID}
			}] & [_, ...]
			if entry.contribution != _|_ {
				_contributionMatches: [for contributionID, contribution in contributions if contributionID == entry.contribution.id {
					contribution & {
						id:          contributionID
						movement:    distribution.movement
						phase:       distribution.phase
						demand:      distribution.demand
						contributor: entry.contributor
					}
				}] & [_, ...]
			}
		}]
		_evidence: [for link in distribution.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_equilibriumIntegrity: [for id, projection in equilibriumProjections {
		_movementMatches: [for movementID, movement in movementPatterns if movementID == projection.movement.id {
			movement & {id: movementID}
		}] & [_, ...]
		_movement: _movementMatches[0]
		_phase: [for phase in _movement.phases if phase.id == projection.phase.id {
			phase
		}] & [_, ...]
		_demandResiduals: [for residual in projection.demandResiduals {
			_matches: [for demandID, demand in demands if demandID == residual.demand.id {
				demand & {id: demandID}
			}] & [_, ...]
		}]
		if projection.contributionDistribution != _|_ {
			_distributionMatches: [for distributionID, distribution in contributionDistributions if distributionID == projection.contributionDistribution.id {
				distribution & {
					id:       distributionID
					movement: projection.movement
					phase:    projection.phase
				}
			}] & [_, ...]
		}
		if projection.distributionResidual != _|_ {
			_currentMatches: [for distributionID, distribution in contributionDistributions if distributionID == projection.distributionResidual.current.id {
				distribution & {id: distributionID}
			}] & [_, ...]
			_referenceMatches: [for distributionID, distribution in contributionDistributions if distributionID == projection.distributionResidual.reference.id {
				distribution & {id: distributionID}
			}] & [_, ...]
		}
		if projection.compensation != _|_ {
			_compensationMatches: [for compensationID, compensation in compensationProjections if compensationID == projection.compensation.id {
				compensation & {id: compensationID, movement: projection.movement}
			}] & [_, ...]
		}
		_evidence: [for link in projection.evidence {
			_matches: [for evidenceID, record in evidence if evidenceID == link.evidence.id {
				record & {id: evidenceID}
			}] & [_, ...]
		}]
	}]
})
