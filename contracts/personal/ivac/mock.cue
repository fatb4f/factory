package ivac

// Public, de-identified structural fixture. Provider identities and personal
// medical facts are runtime bindings and deliberately do not appear here.
mockReviewPlant: #ValidatedPlant & {
	authorities: {
		personal: {id: "personal", kind: "personal"}
		legal:    {id: "legal", kind: "legal"}
		clinical: {id: "clinical", kind: "clinical"}
		review:   {id: "review", kind: "adjudicative"}
	}

	actors: {
		claimant: {
			id: "claimant"
			kind: "claimant"
			capabilities: ["preserve", "disclose", "submit", "supplement", "close-record", "accept", "escalate"]
		}
		counsel: {
			id: "counsel"
			kind: "legal-representative"
			capabilities: ["preserve", "commission", "disclose", "qualify", "bind", "submit", "supplement", "close-record", "escalate"]
		}
		independentExpert: {
			id: "independentExpert"
			kind: "medical-expert"
			capabilities: ["observe", "opine", "assert"]
		}
		reviewAuthority: {
			id: "reviewAuthority"
			kind: "adjudicator"
			capabilities: ["adjudicate"]
		}
	}

	axes: {
		primary:       {id: "primary", label: "primary recognized axis"}
		supplementalA: {id: "supplementalA", label: "supplemental axis A"}
		supplementalB: {id: "supplementalB", label: "supplemental axis B"}
		supplementalC: {id: "supplementalC", label: "supplemental axis C"}
	}

	evidence: {
		initialDecision: {
			id: "initialDecision"
			class: "administrative-decision"
			producer: {id: "reviewAuthority"}
			axes: [{id: "primary"}]
		}
		expertReport: {
			id: "expertReport"
			class: "expert-report"
			producer: {id: "independentExpert"}
			axes: [{id: "primary"}]
		}
		legalSubmission: {
			id: "legalSubmission"
			class: "legal-submission"
			producer: {id: "counsel"}
			axes: [{id: "primary"}]
		}
	}

	findings: {
		primaryFunctional: {
			id: "primaryFunctional"
			kind: "functional-limitation"
			axis: {id: "primary"}
			producer: {id: "independentExpert"}
			evidence: [{id: "expertReport"}]
			assertion: "independent expert finding sufficient for mock qualification"
		}
		primaryPermanence: {
			id: "primaryPermanence"
			kind: "permanence"
			axis: {id: "primary"}
			producer: {id: "independentExpert"}
			evidence: [{id: "expertReport"}]
			assertion: "independent expert permanence finding for mock qualification"
		}
	}

	mandates: {
		legal: {
			id: "legal"
			kind: "legal"
			principal: {id: "claimant"}
			agent: {id: "counsel"}
			scope: ["preserve", "commission", "disclose", "qualify", "bind", "submit", "supplement", "close-record", "escalate"]
			state: "active"
		}
		expert: {
			id: "expert"
			kind: "expert"
			principal: {id: "counsel"}
			agent: {id: "independentExpert"}
			scope: ["observe", "opine", "assert"]
			state: "active"
		}
	}

	grounds: {
		primaryReassessment: {
			id: "primaryReassessment"
			axis: {id: "primary"}
			author: {id: "counsel"}
			findings: [{id: "primaryFunctional"}, {id: "primaryPermanence"}]
			requestedAction: "reassess recognized state from the admitted evidence"
		}
	}

	submissions: {
		reviewPackage: {
			id: "reviewPackage"
			author: {id: "counsel"}
			grounds: [{id: "primaryReassessment"}]
			evidence: [{id: "initialDecision"}, {id: "expertReport"}, {id: "legalSubmission"}]
			state: "complete"
		}
	}

	decisions: {
		initial: {
			id: "initial"
			kind: "initial"
			authority: {id: "reviewAuthority"}
			outcome: "recognized"
			axes: {
				primary: {axis: {id: "primary"}, band: "baseline"}
			}
		}
		reviewed: {
			id: "reviewed"
			kind: "review"
			authority: {id: "reviewAuthority"}
			outcome: "revised"
			axes: {
				primary: {axis: {id: "primary"}, band: "revised"}
			}
		}
	}

	states: {
		s0: {
			id: "s0"
			procedural: "review-window-open"
			record: "targeted"
			axes: {
				primary:       {axis: {id: "primary"}, state: "recognized", recognizedBand: "baseline"}
				supplementalA: {axis: {id: "supplementalA"}, state: "hypothesis"}
				supplementalB: {axis: {id: "supplementalB"}, state: "hypothesis"}
				supplementalC: {axis: {id: "supplementalC"}, state: "hypothesis"}
			}
			submission: "none"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s1: {
			id: "s1"
			procedural: "review-preserved"
			record: "targeted"
			axes: s0.axes
			submission: "protective"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s2: {
			id: "s2"
			procedural: "review-active"
			record: "expert-ready"
			axes: s1.axes
			submission: "protective"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s3: {
			id: "s3"
			procedural: "review-active"
			record: "expert-ready"
			axes: s2.axes
			submission: "protective"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s4: {
			id: "s4"
			procedural: "review-active"
			record: "expert-ready"
			axes: {
				primary:       {axis: {id: "primary"}, state: "documented", recognizedBand: "baseline"}
				supplementalA: s3.axes.supplementalA
				supplementalB: s3.axes.supplementalB
				supplementalC: s3.axes.supplementalC
			}
			submission: "protective"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s5: {
			id: "s5"
			procedural: "review-active"
			record: "expert-ready"
			axes: {
				primary:       {axis: {id: "primary"}, state: "expert-supported", recognizedBand: "baseline"}
				supplementalA: s4.axes.supplementalA
				supplementalB: s4.axes.supplementalB
				supplementalC: s4.axes.supplementalC
			}
			submission: "supplementing"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s6: {
			id: "s6"
			procedural: "review-active"
			record: "expert-ready"
			axes: s5.axes
			submission: "supplementing"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s7: {
			id: "s7"
			procedural: "review-active"
			record: "closed-for-submission"
			axes: s6.axes
			submission: "supplementing"
			adjudication: "none"
			recognizedDecision: {id: "initial"}
		}
		s8: {
			id: "s8"
			procedural: "review-active"
			record: "closed-for-submission"
			axes: {
				primary:       {axis: {id: "primary"}, state: "submitted", recognizedBand: "baseline"}
				supplementalA: s7.axes.supplementalA
				supplementalB: s7.axes.supplementalB
				supplementalC: s7.axes.supplementalC
			}
			submission: "complete"
			adjudication: "pending"
			recognizedDecision: {id: "initial"}
		}
		s9: {
			id: "s9"
			procedural: "review-decided"
			record: "closed-for-submission"
			axes: {
				primary:       {axis: {id: "primary"}, state: "recognized", recognizedBand: "revised"}
				supplementalA: s8.axes.supplementalA
				supplementalB: s8.axes.supplementalB
				supplementalC: s8.axes.supplementalC
			}
			submission: "complete"
			adjudication: "favorable"
			recognizedDecision: {id: "reviewed"}
		}
	}

	transitions: {
		preserve: {
			id: "preserve"
			primitive: "preserve"
			actor: {id: "counsel"}
			authority: {id: "legal"}
			fromState: {id: "s0"}
			toState: {id: "s1"}
			mandate: {id: "legal"}
			outputs: ["review-protected"]
			requiredActorKind: "legal-representative"
			requiredAuthorityKind: "legal"
		}
		commission: {
			id: "commission"
			primitive: "commission"
			actor: {id: "counsel"}
			authority: {id: "legal"}
			fromState: {id: "s1"}
			toState: {id: "s2"}
			requires: [{id: "g-preserve"}]
			mandate: {id: "expert"}
			inputs: ["targeted-record", "expert-questions"]
			outputs: ["accepted-expert-mandate"]
			requiredActorKind: "legal-representative"
			requiredAuthorityKind: "legal"
		}
		disclose: {
			id: "disclose"
			primitive: "disclose"
			actor: {id: "counsel"}
			authority: {id: "legal"}
			fromState: {id: "s2"}
			toState: {id: "s3"}
			requires: [{id: "g-commission"}]
			mandate: {id: "legal"}
			inputs: ["targeted-record"]
			outputs: ["expert-record-snapshot"]
			requiredActorKind: "legal-representative"
			requiredAuthorityKind: "legal"
		}
		observe: {
			id: "observe"
			primitive: "observe"
			actor: {id: "independentExpert"}
			authority: {id: "clinical"}
			fromState: {id: "s3"}
			toState: {id: "s4"}
			requires: [{id: "g-disclose"}]
			inputs: ["expert-record-snapshot"]
			outputs: ["clinical-observation-set"]
			requiredActorKind: "medical-expert"
			requiredAuthorityKind: "clinical"
		}
		opine: {
			id: "opine"
			primitive: "opine"
			actor: {id: "independentExpert"}
			authority: {id: "clinical"}
			fromState: {id: "s4"}
			toState: {id: "s5"}
			requires: [{id: "g-observe"}]
			mandate: {id: "expert"}
			inputs: ["clinical-observation-set"]
			outputs: ["expertReport", "primaryFunctional", "primaryPermanence"]
			requiredActorKind: "medical-expert"
			requiredAuthorityKind: "clinical"
		}
		qualify: {
			id: "qualify"
			primitive: "qualify"
			actor: {id: "counsel"}
			authority: {id: "legal"}
			fromState: {id: "s5"}
			toState: {id: "s6"}
			requires: [{id: "g-opine"}]
			mandate: {id: "legal"}
			inputs: ["primaryFunctional", "primaryPermanence"]
			outputs: ["primaryReassessment"]
			requiredActorKind: "legal-representative"
			requiredAuthorityKind: "legal"
		}
		bind: {
			id: "bind"
			primitive: "bind"
			actor: {id: "counsel"}
			authority: {id: "legal"}
			fromState: {id: "s6"}
			toState: {id: "s7"}
			requires: [{id: "g-qualify"}]
			mandate: {id: "legal"}
			inputs: ["initialDecision", "expertReport", "primaryReassessment"]
			outputs: ["legalSubmission"]
			requiredActorKind: "legal-representative"
			requiredAuthorityKind: "legal"
		}
		submit: {
			id: "submit"
			primitive: "submit"
			actor: {id: "counsel"}
			authority: {id: "legal"}
			fromState: {id: "s7"}
			toState: {id: "s8"}
			requires: [{id: "g-bind"}]
			mandate: {id: "legal"}
			inputs: ["legalSubmission", "expertReport", "primaryReassessment"]
			outputs: ["reviewPackage"]
			requiredActorKind: "legal-representative"
			requiredAuthorityKind: "legal"
		}
		adjudicate: {
			id: "adjudicate"
			primitive: "adjudicate"
			actor: {id: "reviewAuthority"}
			authority: {id: "review"}
			fromState: {id: "s8"}
			toState: {id: "s9"}
			requires: [{id: "g-submit"}]
			inputs: ["reviewPackage"]
			outputs: ["reviewed"]
			requiredActorKind: "adjudicator"
			requiredAuthorityKind: "adjudicative"
		}
	}

	transitionDecisions: {
		"d-preserve": {
			id: "d-preserve"
			transition: {id: "preserve"}
			state: "admitted"
			grant: {id: "g-preserve"}
		}
		"d-commission": {
			id: "d-commission"
			transition: {id: "commission"}
			state: "admitted"
			grant: {id: "g-commission"}
		}
		"d-disclose": {
			id: "d-disclose"
			transition: {id: "disclose"}
			state: "admitted"
			grant: {id: "g-disclose"}
		}
		"d-observe": {
			id: "d-observe"
			transition: {id: "observe"}
			state: "admitted"
			grant: {id: "g-observe"}
		}
		"d-opine": {
			id: "d-opine"
			transition: {id: "opine"}
			state: "admitted"
			grant: {id: "g-opine"}
		}
		"d-qualify": {
			id: "d-qualify"
			transition: {id: "qualify"}
			state: "admitted"
			grant: {id: "g-qualify"}
		}
		"d-bind": {
			id: "d-bind"
			transition: {id: "bind"}
			state: "admitted"
			grant: {id: "g-bind"}
		}
		"d-submit": {
			id: "d-submit"
			transition: {id: "submit"}
			state: "admitted"
			grant: {id: "g-submit"}
		}
		"d-adjudicate": {
			id: "d-adjudicate"
			transition: {id: "adjudicate"}
			state: "admitted"
			grant: {id: "g-adjudicate"}
		}
	}

	grants: {
		"g-preserve": {
			id: "g-preserve"
			decision: {id: "d-preserve"}
			transition: {id: "preserve"}
			primitive: "preserve"
		}
		"g-commission": {
			id: "g-commission"
			decision: {id: "d-commission"}
			transition: {id: "commission"}
			primitive: "commission"
		}
		"g-disclose": {
			id: "g-disclose"
			decision: {id: "d-disclose"}
			transition: {id: "disclose"}
			primitive: "disclose"
		}
		"g-observe": {
			id: "g-observe"
			decision: {id: "d-observe"}
			transition: {id: "observe"}
			primitive: "observe"
		}
		"g-opine": {
			id: "g-opine"
			decision: {id: "d-opine"}
			transition: {id: "opine"}
			primitive: "opine"
		}
		"g-qualify": {
			id: "g-qualify"
			decision: {id: "d-qualify"}
			transition: {id: "qualify"}
			primitive: "qualify"
		}
		"g-bind": {
			id: "g-bind"
			decision: {id: "d-bind"}
			transition: {id: "bind"}
			primitive: "bind"
		}
		"g-submit": {
			id: "g-submit"
			decision: {id: "d-submit"}
			transition: {id: "submit"}
			primitive: "submit"
		}
		"g-adjudicate": {
			id: "g-adjudicate"
			decision: {id: "d-adjudicate"}
			transition: {id: "adjudicate"}
			primitive: "adjudicate"
		}
	}

	trace: [
		{id: "preserve"},
		{id: "commission"},
		{id: "disclose"},
		{id: "observe"},
		{id: "opine"},
		{id: "qualify"},
		{id: "bind"},
		{id: "submit"},
		{id: "adjudicate"},
	]
}
