package ivac

#TransitionBase: {
	id:        #TransitionID
	primitive: #TransitionPrimitive
	actor:     #ActorRef
	authority: #AuthorityRef
	fromState: #PlantStateRef
	toState:   #PlantStateRef

	requires?: [...#TransitionGrantRef]
	mandate?:  #MandateRef
	inputs?:   [...#ID]
	outputs?:  [...#ID]

	requiredActorKind:     #ActorKind
	requiredAuthorityKind: #AuthorityKind
}

#PreserveTransition: close(#TransitionBase & {
	primitive: "preserve"
	requiredActorKind: "claimant" | "legal-representative"
	requiredAuthorityKind: "personal" | "legal"
})

#CommissionTransition: close(#TransitionBase & {
	primitive: "commission"
	requiredActorKind: "legal-representative"
	requiredAuthorityKind: "legal"
	mandate: #MandateRef
})

#DiscloseTransition: close(#TransitionBase & {
	primitive: "disclose"
	requiredActorKind: "claimant" | "legal-representative"
	requiredAuthorityKind: "personal" | "legal"
})

#ObserveTransition: close(#TransitionBase & {
	primitive: "observe"
	requiredActorKind: "medical-expert" | "treating-clinician"
	requiredAuthorityKind: "clinical"
})

#OpineTransition: close(#TransitionBase & {
	primitive: "opine"
	requiredActorKind: "medical-expert"
	requiredAuthorityKind: "clinical"
	mandate: #MandateRef
})

#AssertTransition: close(#TransitionBase & {
	primitive: "assert"
	requiredActorKind: "medical-expert" | "treating-clinician"
	requiredAuthorityKind: "clinical"
})

#QualifyTransition: close(#TransitionBase & {
	primitive: "qualify"
	requiredActorKind: "legal-representative"
	requiredAuthorityKind: "legal"
	mandate: #MandateRef
})

#BindTransition: close(#TransitionBase & {
	primitive: "bind"
	requiredActorKind: "legal-representative"
	requiredAuthorityKind: "legal"
	mandate: #MandateRef
})

#SubmitTransition: close(#TransitionBase & {
	primitive: "submit"
	requiredActorKind: "claimant" | "legal-representative"
	requiredAuthorityKind: "personal" | "legal"
})

#SupplementTransition: close(#TransitionBase & {
	primitive: "supplement"
	requiredActorKind: "claimant" | "legal-representative"
	requiredAuthorityKind: "personal" | "legal"
})

#CloseRecordTransition: close(#TransitionBase & {
	primitive: "close-record"
	requiredActorKind: "claimant" | "legal-representative"
	requiredAuthorityKind: "personal" | "legal"
})

#AdjudicateTransition: close(#TransitionBase & {
	primitive: "adjudicate"
	requiredActorKind: "adjudicator"
	requiredAuthorityKind: "adjudicative"
})

#AcceptTransition: close(#TransitionBase & {
	primitive: "accept"
	requiredActorKind: "claimant"
	requiredAuthorityKind: "personal"
})

#EscalateTransition: close(#TransitionBase & {
	primitive: "escalate"
	requiredActorKind: "claimant" | "legal-representative"
	requiredAuthorityKind: "personal" | "legal"
})

#Transition:
	#PreserveTransition |
	#CommissionTransition |
	#DiscloseTransition |
	#ObserveTransition |
	#OpineTransition |
	#AssertTransition |
	#QualifyTransition |
	#BindTransition |
	#SubmitTransition |
	#SupplementTransition |
	#CloseRecordTransition |
	#AdjudicateTransition |
	#AcceptTransition |
	#EscalateTransition

#TransitionGrant: close({
	id:         #TransitionGrantID
	decision:   #TransitionDecisionRef
	transition: #TransitionRef
	primitive:  #TransitionPrimitive
})

#TransitionDecisionGranted: close({
	id:         #TransitionDecisionID
	transition: #TransitionRef
	state:      "admitted"
	reasons?:   [...string]
	grant:      #TransitionGrantRef
})

#TransitionDecisionNotGranted: close({
	id:         #TransitionDecisionID
	transition: #TransitionRef
	state:      "rejected" | "blocked" | "unknown"
	reasons:    [string, ...string]
})

#TransitionDecision: #TransitionDecisionGranted | #TransitionDecisionNotGranted
