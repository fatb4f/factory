package ivac

#Plant: close({
	authorities:         [string]: #Authority
	actors:              [string]: #Actor
	axes:                [string]: #ClaimAxis
	evidence:            [string]: #EvidenceArtifact
	findings:            [string]: #Finding
	mandates:            [string]: #Mandate
	grounds:             [string]: #ReviewGround
	submissions:         [string]: #Submission
	decisions:           [string]: #Decision
	states:              [string]: #PlantStateSnapshot
	transitions:         [string]: #Transition
	transitionDecisions: [string]: #TransitionDecision
	grants:              [string]: #TransitionGrant
	trace:               [#TransitionRef, ...#TransitionRef]
})

// #ValidatedPlant is the executable integrity root over the canonical review
// graph. Dictionary references are resolved through explicit non-empty matches:
// indexing {[string]: T} alone is not an existence proof in CUE.
#ValidatedPlant: close({
	authorities:         [string]: #Authority
	actors:              [string]: #Actor
	axes:                [string]: #ClaimAxis
	evidence:            [string]: #EvidenceArtifact
	findings:            [string]: #Finding
	mandates:            [string]: #Mandate
	grounds:             [string]: #ReviewGround
	submissions:         [string]: #Submission
	decisions:           [string]: #Decision
	states:              [string]: #PlantStateSnapshot
	transitions:         [string]: #Transition
	transitionDecisions: [string]: #TransitionDecision
	grants:              [string]: #TransitionGrant
	trace:               [#TransitionRef, ...#TransitionRef]

	_actorIdentity: [for id, actor in actors {
		_value: actor & {id: id}
	}]

	_authorityIdentity: [for id, authority in authorities {
		_value: authority & {id: id}
	}]

	_axisIdentity: [for id, axis in axes {
		_value: axis & {id: id}
	}]

	_stateIdentity: [for id, state in states {
		_value: state & {id: id}
		_decisionMatches: [for decisionID, decision in decisions if decisionID == state.recognizedDecision.id {
			decision & {id: decisionID}
		}] & [_, ...]
		_axes: [for _, axisState in state.axes {
			_matches: [for axisID, axis in axes if axisID == axisState.axis.id {
				axis & {id: axisID}
			}] & [_, ...]
		}]
	}]

	_evidenceIntegrity: [for id, artifact in evidence {
		_value: artifact & {id: id}
		_producerMatches: [for actorID, actor in actors if actorID == artifact.producer.id {
			actor & {id: actorID}
		}] & [_, ...]
		_axes: [for axisRef in artifact.axes {
			_matches: [for axisID, axis in axes if axisID == axisRef.id {
				axis & {id: axisID}
			}] & [_, ...]
		}]
	}]

	_findingIntegrity: [for id, finding in findings {
		_value: finding & {id: id}
		_producerMatches: [for actorID, actor in actors if actorID == finding.producer.id {
			actor & {id: actorID, kind: "medical-expert" | "treating-clinician"}
		}] & [_, ...]
		_axisMatches: [for axisID, axis in axes if axisID == finding.axis.id {
			axis & {id: axisID}
		}] & [_, ...]
		_evidence: [for ref in finding.evidence {
			_matches: [for evidenceID, artifact in evidence if evidenceID == ref.id {
				artifact & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_mandateIntegrity: [for id, mandate in mandates {
		_value: mandate & {id: id}
		_principalMatches: [for actorID, actor in actors if actorID == mandate.principal.id {
			actor & {id: actorID}
		}] & [_, ...]
		_agentMatches: [for actorID, actor in actors if actorID == mandate.agent.id {
			actor & {id: actorID}
		}] & [_, ...]
		if mandate.kind == "legal" {
			_legalAgentMatches: [for actorID, actor in actors if actorID == mandate.agent.id {
				actor & {id: actorID, kind: "legal-representative"}
			}] & [_, ...]
		}
		if mandate.kind == "expert" {
			_expertAgentMatches: [for actorID, actor in actors if actorID == mandate.agent.id {
				actor & {id: actorID, kind: "medical-expert"}
			}] & [_, ...]
		}
	}]

	_groundIntegrity: [for id, ground in grounds {
		_value: ground & {id: id}
		_authorMatches: [for actorID, actor in actors if actorID == ground.author.id {
			actor & {id: actorID, kind: "legal-representative"}
		}] & [_, ...]
		_axisMatches: [for axisID, axis in axes if axisID == ground.axis.id {
			axis & {id: axisID}
		}] & [_, ...]
		_findings: [for ref in ground.findings {
			_matches: [for findingID, finding in findings if findingID == ref.id {
				finding & {id: findingID, axis: ground.axis}
			}] & [_, ...]
		}]
	}]

	_submissionIntegrity: [for id, submission in submissions {
		_value: submission & {id: id}
		_authorMatches: [for actorID, actor in actors if actorID == submission.author.id {
			actor & {id: actorID}
		}] & [_, ...]
		_grounds: [for ref in submission.grounds {
			_matches: [for groundID, ground in grounds if groundID == ref.id {
				ground & {id: groundID}
			}] & [_, ...]
		}]
		_evidence: [for ref in submission.evidence {
			_matches: [for evidenceID, artifact in evidence if evidenceID == ref.id {
				artifact & {id: evidenceID}
			}] & [_, ...]
		}]
	}]

	_decisionIdentity: [for id, decision in decisions {
		_value: decision & {id: id}
		_authorityMatches: [for actorID, actor in actors if actorID == decision.authority.id {
			actor & {id: actorID, kind: "adjudicator"}
		}] & [_, ...]
		_axes: [for _, axisDecision in decision.axes {
			_matches: [for axisID, axis in axes if axisID == axisDecision.axis.id {
				axis & {id: axisID}
			}] & [_, ...]
		}]
	}]

	_transitionIntegrity: [for id, transition in transitions {
		_value: transition & {id: id}

		_actorMatches: [for actorID, actor in actors if actorID == transition.actor.id {
			actor & {id: actorID, kind: transition.requiredActorKind}
		}] & [_, ...]
		_actor: _actorMatches[0]

		_authorityMatches: [for authorityID, authority in authorities if authorityID == transition.authority.id {
			authority & {id: authorityID, kind: transition.requiredAuthorityKind}
		}] & [_, ...]

		_capability: [for capability in _actor.capabilities if capability == transition.primitive {
			capability
		}] & [_, ...]

		_fromMatches: [for stateID, state in states if stateID == transition.fromState.id {
			state & {id: stateID}
		}] & [_, ...]
		_toMatches: [for stateID, state in states if stateID == transition.toState.id {
			state & {id: stateID}
		}] & [_, ...]

		if transition.requires != _|_ {
			_requires: [for ref in transition.requires {
				_matches: [for grantID, grant in grants if grantID == ref.id {
					grant & {id: grantID}
				}] & [_, ...]
			}]
		}

		if transition.mandate != _|_ {
			_mandateMatches: [for mandateID, mandate in mandates if mandateID == transition.mandate.id {
				mandate & {id: mandateID}
			}] & [_, ...]
		}

		if transition.primitive != "adjudicate" {
			_from: _fromMatches[0]
			_to:   _toMatches[0]
			_recognitionInvariant: _to.recognizedDecision & _from.recognizedDecision
		}
	}]

	_transitionDecisionIntegrity: [for id, decision in transitionDecisions {
		_value: decision & {id: id}
		_transitionMatches: [for transitionID, transition in transitions if transitionID == decision.transition.id {
			transition & {id: transitionID}
		}] & [_, ...]
		_transition: _transitionMatches[0]

		if decision.state == "admitted" {
			_grantMatches: [for grantID, grant in grants if grantID == decision.grant.id {
				grant & {
					id:         grantID
					decision:   {id: id}
					transition: decision.transition
					primitive:  _transition.primitive
				}
			}] & [_, ...]
		}
	}]

	_grantIntegrity: [for id, grant in grants {
		_value: grant & {id: id}
		_decisionMatches: [for decisionID, decision in transitionDecisions if decisionID == grant.decision.id {
			decision & {
				id:    decisionID
				state: "admitted"
				grant: {id: id}
			}
		}] & [_, ...]
		_transitionMatches: [for transitionID, transition in transitions if transitionID == grant.transition.id {
			transition & {id: transitionID, primitive: grant.primitive}
		}] & [_, ...]
	}]

	_traceIntegrity: [for i, ref in trace {
		_transitionMatches: [for transitionID, transition in transitions if transitionID == ref.id {
			transition & {id: transitionID}
		}] & [_, ...]

		if i > 0 {
			_previousRef: trace[i-1]
			_previousMatches: [for transitionID, transition in transitions if transitionID == _previousRef.id {
				transition & {id: transitionID}
			}] & [_, ...]
			_previous: _previousMatches[0]
			_contiguousMatches: [for transitionID, transition in transitions if transitionID == ref.id {
				transition & {id: transitionID, fromState: _previous.toState}
			}] & [_, ...]
		}
	}]
})
