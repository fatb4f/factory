package resourceallocation

#DomainID:
	"world.engineering-signals" |
	"world.industrial-constraints" |
	"world.canada-clean-energy" |
	"world.canada-climate-readiness" |
	"world.financial-signals"

#ExternalGraphSnapshotRef: close({
	domain:   #DomainID
	snapshot: string
	revision: string
})

#ExternalNodeRef: close({
	snapshot: #ExternalGraphSnapshotRef
	node:     string
})

#ExternalPathRef: close({
	snapshot: #ExternalGraphSnapshotRef
	records:  [string, ...string]
})

#BridgeKind:
	"same-real-world-subject" |
	"engineering-industrial-translation" |
	"resource-demand-on" |
	"resource-supply-of" |
	"policy-applies-to" |
	"resilience-obligation-on" |
	"legal-issuer-of" |
	"reported-by-segment" |
	"economic-interest-of" |
	"financially-exposed-to"

#BridgeHypothesisState: "proposed" | "validating" | "supported" | "contradicted" | "coverage-gap"

#BridgeHypothesis: close({
	id:               string
	left:             #ExternalNodeRef
	right:            #ExternalNodeRef
	kind:             #BridgeKind
	rationale:        string
	expectedEvidence: [string, ...string]
	falsifiers:       [...string]
	state:            #BridgeHypothesisState
})

#AdmittedBridge: close({
	id:         string
	left:       #ExternalNodeRef
	right:      #ExternalNodeRef
	kind:       #BridgeKind
	hypothesis: string
	claims:     [string, ...string]
})

#ResourceKind:
	"physical-capacity" |
	"material" |
	"energy" |
	"infrastructure-capacity" |
	"logistics-capacity" |
	"workforce-capacity" |
	"manufacturing-capacity" |
	"compute-capacity"

#SharedResourceRef: close({id: string})
#ResourceDemandRef: close({id: string})
#InterventionCandidateRef: close({id: string})

#SharedResource: close({
	id:              string
	kind:            #ResourceKind
	representations: [#ExternalNodeRef, #ExternalNodeRef, ...#ExternalNodeRef]
	identityClaims:  [string, ...string]
})

#ResourceDemand: close({
	id:        string
	resource:  #SharedResourceRef
	demander:  #ExternalNodeRef
	path:      #ExternalPathRef
	quantity?: close({value: number, unit: string})
	claims:    [string, ...string]
})

#CrossGraphConjunction: close({
	id:       string
	resource: #SharedResourceRef
	demands:  [#ResourceDemandRef, #ResourceDemandRef, ...#ResourceDemandRef]
	bridges:  [...string]
	claims:   [string, ...string]
	state:    "supported" | "contradicted" | "coverage-gap"
})

#InterventionMechanism:
	"capacity-expansion" |
	"substitution" |
	"utilization-improvement" |
	"lead-time-reduction" |
	"repair-remanufacture" |
	"demand-reduction" |
	"risk-reduction" |
	"coordination-improvement"

#InterventionCandidate: close({
	id:                string
	resource:          #SharedResourceRef
	mechanism:         #InterventionMechanism
	demandsRelieved:   [#ResourceDemandRef, ...#ResourceDemandRef]
	engineeringBasis?: #ExternalPathRef
	claims:            [...string]
})

#QualificationDimension: close({
	name:     string
	value?:   number
	unit?:    string
	evidence: [...string]
})

#FinancialQualifier: close({
	candidate:         #InterventionCandidateRef
	financialSnapshot: #ExternalGraphSnapshotRef & {domain: "world.financial-signals"}
	dimensions:        [#QualificationDimension, ...#QualificationDimension]
	state:             "supported" | "insufficient-evidence" | "contradicted"
})

#AllocationDecision: close({
	resource:        #SharedResourceRef
	candidates:      [#InterventionCandidateRef, ...#InterventionCandidateRef]
	qualifications:  [...string]
	selected:        [...#InterventionCandidateRef]
	rationaleClaims: [string, ...string]
	state:           "admit" | "reject" | "coverage-gap"
})

#Contract: close({
	id:        "world.resource-allocation"
	kind:      "world"
	execution: "contract-only" | "correlation"
	authority: close({
		semantic:  "contracts/world/resource-allocation"
		procedure: "world/resource-allocation/.agents"
	})
})

contract: #Contract & {
	id: "world.resource-allocation"
	execution: "contract-only"
	authority: {
		semantic:  "contracts/world/resource-allocation"
		procedure: "world/resource-allocation/.agents"
	}
}
