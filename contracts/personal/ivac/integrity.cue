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
		_decision: decisions[state.recognizedDecision.id]
		_axes: [for _, axisState in state.axes {
			_axis: axes[axisState.axis.id]
		}]
	}]

	_evidenceIntegrity: [for id, artifact in evidence {
		_value: artifact & {id: id}
		_producer: actors[artifact.producer.id]
		_axes: [for axisRef in artifact.axes {
			_axis: axes[axisRef.id]
		}]
	}]

	_findingIntegrity: [for id, finding in findings {
		_value: finding & {id: id}
		_producer: actors[finding.producer.id] & {
			kind: "medical-expert" | "treating-clinician"
		}
		_axis: axes[finding.axis.id]
		_evidence: [for ref in finding.evidence {
			_artifact: evidence[ref.id]
		}]
	}]

	_mandateIntegrity: [for id, mandate in mandates {
		_value: mandate & {id: id}
		_principal: actors[mandate.principal.id]
		_agent: actors[mandate.agent.id]
		if mandate.kind == "legal" {
			_legalAgent: actors[mandate.agent.id] & {kind: "legal-representative"}
		}
		if mandate.kind == "expert" {
			_expertAgent: actors[mandate.agent.id] & {kind: "medical-expert"}
		}
	}]

	_groundIntegrity: [for id, ground in grounds {
		_value: ground & {id: id}
		_author: actors[ground.author.id] & {kind: "legal-representative"}
		_axis: axes[ground.axis.id]
		_findings: [for ref in ground.findings {
			_finding: findings[ref.id] & {axis: ground.axis}
		}]
	}]

	_submissionIntegrity: [for id, submission in submissions {
		_value: submission & {id: id}
		_author: actors[submission.author.id]
		_grounds: [for ref in submission.grounds {
			_ground: grounds[ref.id]
		}]
		_evidence: [for ref in submission.evidence {
			_artifact: evidence[ref.id]
		}]
	}]

	_decisionIdentity: [for id, decision in decisions {
		_value: decision & {id: id}
		_authorityActor: actors[decision.authority.id] & {kind: "adjudicator"}
		_axes: [for _, axisDecision in decision.axes {
			_axis: axes[axisDecision.axis.id]
		}]
	}]

	_transitionIntegrity: [for id, transition in transitions {
		_value: transition & {id: id}
		_actor: actors[transition.actor.id] & {kind: transition.requiredActorKind}
		_authority: authorities[transition.authority.id] & {kind: transition.requiredAuthorityKind}
		_capability: [for capability in actors[transition.actor.id].capabilities if capability == transition.primitive {
			capability
		}] & [_, ...]
		_from: states[transition.fromState.id]
		_to: states[transition.toState.id]
		_requires: [for ref in transition.requires {
			_grant: grants[ref.id]
		}]
		if transition.mandate != _|_ {
			_mandate: mandates[transition.mandate.id]
		}
		if transition.primitive != "adjudicate" {
			_recognitionInvariant: states[transition.toState.id].recognizedDecision &
				states[transition.fromState.id].recognizedDecision
		}
	}]

	_transitionDecisionIntegrity: [for id, decision in transitionDecisions {
		_value: decision & {id: id}
		_transition: transitions[decision.transition.id]
		if decision.state == "admitted" {
			_grant: grants[decision.grant.id] & {
				decision:   {id: id}
				transition: decision.transition
				primitive:  transitions[decision.transition.id].primitive
			}
		}
	}]

	_grantIdentity: [for id, grant in grants {
		_value: grant & {id: id}
		_decision: transitionDecisions[grant.decision.id] & {
			state: "admitted"
			grant: {id: id}
		}
		_transition: transitions[grant.transition.id] & {primitive: grant.primitive}
	}]

	_traceIntegrity: [for i, ref in trace {
		_transition: transitions[ref.id]
		if i > 0 {
			_previousRef: trace[i-1]
			_previous: transitions[_previousRef.id]
			_contiguous: transitions[ref.id] & {fromState: _previous.toState}
		}
	}]

})
