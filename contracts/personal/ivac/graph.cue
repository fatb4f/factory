package ivac

#ID: string & !=""
#ActorID: #ID
#AuthorityID: #ID
#ClaimAxisID: #ID
#EvidenceArtifactID: #ID
#FindingID: #ID
#MandateID: #ID
#ReviewGroundID: #ID
#SubmissionID: #ID
#DecisionID: #ID
#PlantStateID: #ID
#TransitionID: #ID
#TransitionDecisionID: #ID
#TransitionGrantID: #ID

#ActorRef: close({id: #ActorID})
#AuthorityRef: close({id: #AuthorityID})
#ClaimAxisRef: close({id: #ClaimAxisID})
#EvidenceArtifactRef: close({id: #EvidenceArtifactID})
#FindingRef: close({id: #FindingID})
#MandateRef: close({id: #MandateID})
#ReviewGroundRef: close({id: #ReviewGroundID})
#SubmissionRef: close({id: #SubmissionID})
#DecisionRef: close({id: #DecisionID})
#PlantStateRef: close({id: #PlantStateID})
#TransitionRef: close({id: #TransitionID})
#TransitionDecisionRef: close({id: #TransitionDecisionID})
#TransitionGrantRef: close({id: #TransitionGrantID})

#TransitionPrimitive:
	"preserve" |
	"commission" |
	"disclose" |
	"observe" |
	"opine" |
	"assert" |
	"qualify" |
	"bind" |
	"submit" |
	"supplement" |
	"close-record" |
	"adjudicate" |
	"accept" |
	"escalate"

#ActorKind:
	"claimant" |
	"legal-representative" |
	"medical-expert" |
	"treating-clinician" |
	"adjudicator"

#AuthorityKind: "personal" | "legal" | "clinical" | "adjudicative"

#Actor: close({
	id:           #ActorID
	kind:         #ActorKind
	label?:       string
	capabilities: [#TransitionPrimitive, ...#TransitionPrimitive]
})

#Authority: close({
	id:    #AuthorityID
	kind:  #AuthorityKind
	label?: string
})

#ClaimAxis: close({
	id:    #ClaimAxisID
	label: string
})

#AxisState: close({
	axis: #ClaimAxisRef
	state:
		"hypothesis" |
		"documented" |
		"expert-supported" |
		"causally-supported" |
		"permanence-supported" |
		"submitted" |
		"recognized" |
		"rejected"
	recognizedBand?: string
})

#EvidenceClass:
	"administrative-decision" |
	"medical-record" |
	"clinical-report" |
	"expert-report" |
	"objective-test" |
	"legal-submission" |
	"legal-work-product"

#EvidenceArtifact: close({
	id:       #EvidenceArtifactID
	class:    #EvidenceClass
	producer: #ActorRef
	axes:     [#ClaimAxisRef, ...#ClaimAxisRef]
	source?:  string
})

#FindingKind:
	"diagnosis" |
	"persistent-symptom" |
	"functional-limitation" |
	"permanence" |
	"consolidation" |
	"causal-opinion" |
	"aggravation-opinion" |
	"prognosis" |
	"other"

#Finding: close({
	id:        #FindingID
	kind:      #FindingKind
	axis:      #ClaimAxisRef
	producer:  #ActorRef
	evidence:  [#EvidenceArtifactRef, ...#EvidenceArtifactRef]
	assertion: string & !=""
})

#MandateKind: "legal" | "expert"

#Mandate: close({
	id:        #MandateID
	kind:      #MandateKind
	principal: #ActorRef
	agent:     #ActorRef
	scope:     [#TransitionPrimitive, ...#TransitionPrimitive]
	state:     "proposed" | "active" | "complete" | "terminated"
})

#ReviewGround: close({
	id:       #ReviewGroundID
	axis:     #ClaimAxisRef
	author:   #ActorRef
	findings: [#FindingRef, ...#FindingRef]
	requestedAction: string & !=""
})

#Submission: close({
	id:       #SubmissionID
	author:   #ActorRef
	grounds:  [#ReviewGroundRef, ...#ReviewGroundRef]
	evidence: [#EvidenceArtifactRef, ...#EvidenceArtifactRef]
	state:    "protective" | "supplementing" | "complete"
})

#DecisionKind: "initial" | "review"

#Decision: close({
	id:        #DecisionID
	kind:      #DecisionKind
	authority: #ActorRef
	outcome:   "recognized" | "partially-revised" | "revised" | "maintained"
	axes: [string]: close({
		axis: #ClaimAxisRef
		band: string
	})
})

#ProceduralState:
	"initial-decision" |
	"review-window-open" |
	"review-preserved" |
	"review-active" |
	"review-decided" |
	"taq-eligible"

#RecordState: "open" | "targeted" | "expert-ready" | "closed-for-submission"
#SubmissionState: "none" | "protective" | "supplementing" | "complete"
#AdjudicationState: "none" | "pending" | "partial" | "favorable" | "unfavorable"

#PlantStateSnapshot: close({
	id:                 #PlantStateID
	procedural:         #ProceduralState
	record:             #RecordState
	axes:               [string]: #AxisState
	submission:         #SubmissionState
	adjudication:       #AdjudicationState
	recognizedDecision: #DecisionRef
})
