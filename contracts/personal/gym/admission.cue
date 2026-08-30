package gym

#MechanicalAdmissionDecisionID: string
#MechanicalAdmissionDecisionRef: close({id: #MechanicalAdmissionDecisionID})
#MechanicalAdmissionGrantID: string
#MechanicalAdmissionGrantRef: close({id: #MechanicalAdmissionGrantID})
#NormalizedCapacityID: string
#NormalizedCapacityRef: close({id: #NormalizedCapacityID})
#NormalizedCapacityVectorID: string
#NormalizedCapacityVectorRef: close({id: #NormalizedCapacityVectorID})
#CapacityAggregateID: string
#CapacityAggregateRef: close({id: #CapacityAggregateID})
#ComparisonAdmissionDecisionID: string
#ComparisonAdmissionDecisionRef: close({id: #ComparisonAdmissionDecisionID})
#ComparisonAdmissionGrantID: string
#ComparisonAdmissionGrantRef: close({id: #ComparisonAdmissionGrantID})

// 0.4.0 compatibility aliases. New code should use the Decision names to make
// the distinction between a decision and the capability it emits explicit.
#MechanicalAdmissionID: #MechanicalAdmissionDecisionID
#MechanicalAdmissionRef: #MechanicalAdmissionDecisionRef
#ComparisonAdmissionID: #ComparisonAdmissionDecisionID
#ComparisonAdmissionRef: #ComparisonAdmissionDecisionRef

#MechanicalAdmissionState: "admitted" | "partial" | "rejected" | "unknown"

// An exposure may present several demands for admission. Capacity, however, is
// always produced one demand at a time through a demand-specific grant.
#MechanicalDemandBasis: close({
	pattern:       #MovementPatternRef
	demands:       [...#MechanicalDemandRef] & [_, ...]
	legacyChannels?: [...#DemandChannelRef]
	normalization: #NormalizationBasis
})

#MechanicalAdmissionGrant: close({
	id:       #MechanicalAdmissionGrantID
	decision: #MechanicalAdmissionDecisionRef
	exposure: #ExposureID
	demand:   #MechanicalDemandRef
})

#MechanicalAdmissionGranted: close({
	id:       #MechanicalAdmissionDecisionID
	exposure: #ExposureID
	position: #ScalePosition
	basis:    #MechanicalDemandBasis
	state:    "admitted"
	reasons?: [...string]
	evidence: [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
	grant:    #MechanicalAdmissionGrant
})

#MechanicalAdmissionNotGranted: close({
	id:       #MechanicalAdmissionDecisionID
	exposure: #ExposureID
	position: #ScalePosition
	basis:    #MechanicalDemandBasis
	state:    "partial" | "rejected" | "unknown"
	reasons?: [...string]
	evidence: [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
})

// Only the admitted branch contains a grant. The semantic-integrity registry
// additionally proves that a referenced grant resolves to that successful
// decision and to a demand actually covered by its basis.
#MechanicalAdmissionDecision:
	#MechanicalAdmissionGranted |
	#MechanicalAdmissionNotGranted

#MechanicalAdmission: #MechanicalAdmissionDecision

// ComparisonBasis adds compatibility context only. Normalization authority
// remains on each NormalizedCapacity and is checked when compatibility is
// granted; it is intentionally not repeated here.
#ComparisonBasis: close({
	movementContext:    #MovementPatternRef
	phase?:             #PatternPhaseRef
	contractionRegime?: #ContractionMode
	romBasis?:           string
	loadBasis?:          string
	temporalBasis?:      string
	referenceVersion:    string
})

// Capacity is demand-specific. A plural admitted demand basis can therefore
// produce several capacities, never an unexplained scalar over a demand vector.
#NormalizedCapacity: close({
	id:            #NormalizedCapacityID
	demand:        #MechanicalDemandRef
	value:         #DerivedScalar
	grant:         #MechanicalAdmissionGrantRef
	normalization: #NormalizationBasis
})

#NormalizedCapacityVector: close({
	id:      #NormalizedCapacityVectorID
	entries: [...#NormalizedCapacityRef] & [_, ...]
})

// Any vector-to-scalar operation is explicit, evidence-bearing and versioned.
#CapacityAggregate: close({
	id:       #CapacityAggregateID
	vector:   #NormalizedCapacityVectorRef
	value:    #DerivedScalar
	method:   string
	weights?: [...number]
	executor?: #OperationExecutorRef
	version:  string
	evidence: [...#EvidenceLink] & [_, ...]
})

#ComparisonAdmissionState: "compatible" | "incompatible" | "unknown"

#ComparisonAdmissionGrant: close({
	id:       #ComparisonAdmissionGrantID
	decision: #ComparisonAdmissionDecisionRef
	left:     #NormalizedCapacityRef
	right:    #NormalizedCapacityRef
	basis:    #ComparisonBasis
})

#ComparisonAdmissionCompatible: close({
	id:     #ComparisonAdmissionDecisionID
	left:   #NormalizedCapacityRef
	right:  #NormalizedCapacityRef
	basis:  #ComparisonBasis
	state:  "compatible"
	reasons?: [...string]
	evidence: [...#EvidenceLink] & [_, ...]
	grant:   #ComparisonAdmissionGrant
})

#ComparisonAdmissionNotCompatible: close({
	id:     #ComparisonAdmissionDecisionID
	left:   #NormalizedCapacityRef
	right:  #NormalizedCapacityRef
	basis:  #ComparisonBasis
	state:  "incompatible" | "unknown"
	reasons?: [...string]
	evidence: [...#EvidenceLink] & [_, ...]
})

#ComparisonAdmissionDecision:
	#ComparisonAdmissionCompatible |
	#ComparisonAdmissionNotCompatible

#ComparisonAdmission: #ComparisonAdmissionDecision

#ContextualCapacityRelationType:
	"agonist-antagonist" |
	"support" |
	"bilateral" |
	"joint-sharing" |
	"proximal-distal" |
	"pattern-balance" |
	"short-long-range" |
	"complementary" |
	"competitive" |
	"associated" |
	"candidate-compensatory" |
	"qualified-compensatory"

#CapacityRelationContext: close({
	movement: #MovementPatternRef
	phase?:   #PatternPhaseRef
	geometry?: string
	role?:    #MechanicalRole
})

#ContextualCapacityRelation: close({
	id:           string
	source:       #NormalizedCapacityRef
	target:       #NormalizedCapacityRef
	grant:        #ComparisonAdmissionGrantRef
	relationType: #ContextualCapacityRelationType
	context:      #CapacityRelationContext
	expectedRelation?: string
	observed?:    #DerivedScalar
	evidence:     [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
})
