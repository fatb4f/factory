package gym

#MechanicalAdmissionID: string
#MechanicalAdmissionRef: close({id: #MechanicalAdmissionID})
#NormalizedCapacityID: string
#NormalizedCapacityRef: close({id: #NormalizedCapacityID})
#ComparisonAdmissionID: string
#ComparisonAdmissionRef: close({id: #ComparisonAdmissionID})

#MechanicalAdmissionState: "admitted" | "partial" | "rejected" | "unknown"

// New analytical basis is expressed directly in mechanical demands. The legacy
// #DemandBasis remains available for existing standards and migration fixtures.
#MechanicalDemandBasis: close({
	pattern:       #MovementPatternRef
	demands:       [...#MechanicalDemandRef] & [_, ...]
	legacyChannels?: [...#DemandChannelRef]
	normalization: #NormalizationBasis
})

// Mechanical admission answers whether the observed scale position actually
// exposes the stated demand basis. It is separate from comparison admission.
#MechanicalAdmission: close({
	id:       #MechanicalAdmissionID
	exposure: #ExposureID
	position: #ScalePosition
	basis:    #MechanicalDemandBasis
	state:    #MechanicalAdmissionState
	reasons?: [...string]
	evidence: [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
})

#ComparisonBasis: close({
	normalizationClass: #NormalizationKind
	demand?:             #MechanicalDemandRef
	legacyChannel?:      #DemandChannelRef
	movementContext:     #MovementPatternRef
	phase?:              string
	contractionRegime?:  #ContractionMode
	romBasis?:           string
	loadBasis?:          string
	temporalBasis?:      string
	referenceVersion:    string
})

#NormalizedCapacity: close({
	id:        #NormalizedCapacityID
	basis:     #MechanicalDemandBasis
	value:     #DerivedScalar
	admission: #MechanicalAdmissionRef
	comparisonBasis: #ComparisonBasis
})

#ComparisonAdmissionState: "compatible" | "incompatible" | "unknown"

#ComparisonAdmission: close({
	id:     #ComparisonAdmissionID
	left:   #NormalizedCapacityRef
	right:  #NormalizedCapacityRef
	basis:  #ComparisonBasis
	state:  #ComparisonAdmissionState
	reasons?: [...string]
	evidence: [...#EvidenceLink] & [_, ...]
})

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
	phase?:   string
	geometry?: string
	role?:    #MechanicalRole
})

#ContextualCapacityRelation: close({
	id:         string
	source:     #NormalizedCapacityRef
	target:     #NormalizedCapacityRef
	admission:  #ComparisonAdmissionRef
	relationType: #ContextualCapacityRelationType
	context:    #CapacityRelationContext
	expectedRelation?: string
	observed?:  #DerivedScalar
	evidence:   [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
})
