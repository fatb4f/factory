package industrialsignals

#IndustrialSignalRecord: close({
	kind:        "industrial-signal"
	id:          #RecordID
	signalClass: #SignalClass
	actor?:      #EntityRef
	subject:     #EntityRef
	surface:     #IndustrialSurface
	observedAt?: #Timestamp
	value?:      #TypedValue
	provenance:  #Provenance
	evidence:    [...#RecordRef] & [_, ...]
})

#IndustrialActionRecord: close({
	kind:       "industrial-action"
	id:         #RecordID
	actionKind: #ActionKind
	actor:      #EntityRef
	subjects:   [...#EntityRef] & [_, ...]
	surface:    #IndustrialSurface
	announcedAt?: #Timestamp
	startedAt?:   #Timestamp
	completedAt?: #Timestamp
	provenance: #Provenance
	evidence:   [...#RecordRef] & [_, ...]
})

#ResponseHypothesis: close({
	kind:              "response-hypothesis"
	id:                #RecordID
	signal:            #RecordRef & {kind: "industrial-signal"}
	action:            #RecordRef & {kind: "industrial-action"}
	proposedMechanism: string
	evidence:          [...#RecordRef] & [_, ...]
	state:             "hypothesis"
})

#AdmittedResponse: close({
	kind:   "admitted-response"
	id:     #RecordID
	signal: #RecordRef & {kind: "industrial-signal"}
	action: #RecordRef & {kind: "industrial-action"}
	basis:  "actor-explicit" | "contractual-link" | "qualified-correlation"
	evidence: [...#RecordRef] & [_, ...]
	state: "admitted"
})

#InnovationExposure: close({
	kind:       "innovation-exposure"
	id:         #RecordID
	actor:      #EntityRef
	innovation: #EntityRef
	state:      #AdoptionState
	facility?:  #EntityRef
	project?:   #EntityRef
	observedAt: #Timestamp
	provenance: #Provenance
	evidence:   [...#RecordRef] & [_, ...]
})

#OutcomeObservation: close({
	kind:      "outcome-observation"
	id:        #RecordID
	subject:   #EntityRef
	action?:   #RecordRef & {kind: "industrial-action"}
	dimension: #OutcomeDimension
	direction: #OutcomeDirection
	value?:    #TypedValue
	observedAt: #Timestamp
	provenance: #Provenance
	evidence:   [...#RecordRef] & [_, ...]
})

#FundingAward: close({
	kind:       "funding-award"
	id:         #RecordID
	funder:     #EntityRef
	recipient:  #EntityRef
	project?:   #EntityRef
	program:    string
	instrument: #FundingInstrument
	announcedAmount?: #Money
	authorizedAmount?: #Money
	announcedAt?:  #Timestamp
	authorizedAt?: #Timestamp
	conditions?: [...string]
	provenance: #Provenance
	evidence:   [...#RecordRef] & [_, ...]
})

#FundingFlow: close({
	kind:     "funding-flow"
	id:       #RecordID
	award:    #RecordRef & {kind: "funding-award"}
	recipient: #EntityRef
	flowKind: #FundingFlowKind
	amount?:  #Money
	spendCategory?: #SpendCategory
	purpose?: string
	counterparty?: #EntityRef
	occurredAt: #Timestamp
	basis:      #FundingEvidenceBasis
	provenance: #Provenance
	evidence:   [...#RecordRef] & [_, ...]
})

#ProjectMilestone: close({
	kind:          "project-milestone"
	id:            #RecordID
	project:       #EntityRef
	actors:        [...#EntityRef] & [_, ...]
	milestoneKind: #MilestoneKind
	state:         #MilestoneState
	targetAt?:     #Timestamp
	observedAt:    #Timestamp
	provenance:    #Provenance
	evidence:      [...#RecordRef] & [_, ...]
})

#FundingAccountabilityCoverage: close({
	kind:       "funding-accountability-coverage"
	id:         #RecordID
	award:      #RecordRef & {kind: "funding-award"}
	recipient:  #EntityRef
	disbursement:     #AccountabilityCoverageState
	expenditure:      #AccountabilityCoverageState
	milestoneProgress: #AccountabilityCoverageState
	outcome:          #AccountabilityCoverageState
	evidence:         [...#RecordRef]
	coverageGaps:     [...string]
})

#GraphRecord:
	#Entity |
	#ActorRoleAssignment |
	#IndustrialSignalRecord |
	#IndustrialActionRecord |
	#ResponseHypothesis |
	#AdmittedResponse |
	#InnovationExposure |
	#OutcomeObservation |
	#FundingAward |
	#FundingFlow |
	#ProjectMilestone |
	#FundingAccountabilityCoverage

#IndustrialGraphSnapshot: close({
	snapshotID:      string
	generatedAt:     #Timestamp
	observedThrough: #Timestamp
	digest:          #Digest
	records:         [...#GraphRecord]
})
