package gym

#CompensationMarkerID: string
#CompensationMarkerRef: close({id: #CompensationMarkerID})
#CompensationObservationID: string
#CompensationObservationRef: close({id: #CompensationObservationID})
#CompensationProjectionID: string
#CompensationProjectionRef: close({id: #CompensationProjectionID})

#CompensationMechanicalType:
	"rotation" |
	"translation" |
	"stabilization" |
	"bracing" |
	"unloading" |
	"shortening" |
	"load-transfer"

#CompensationDetectionBasis:
	"kinematics" |
	"kinetics" |
	"force" |
	"model" |
	"exercise-proxy" |
	"qualitative"

#CompensationEnvelope: close({
	basis:  string
	min?:   number
	max?:   number
	state?: string
	unit?:  #Unit
})

// A marker defines an observable alternative task solution. It does not by
// itself declare the observation pathological, causal, or dysfunctional.
#CompensationMarker: close({
	id:              #CompensationMarkerID
	label:           string
	movement:        #MovementPatternRef
	target:          #MechanicalTarget
	mechanicalType:  #CompensationMechanicalType
	direction?:      string
	phase:           #PatternPhaseRef
	expectedEnvelope?: #CompensationEnvelope
	detectionBasis:  #CompensationDetectionBasis
	normalizationBasis?: #NormalizationBasis
})

#CompensationObservation: close({
	id:       #CompensationObservationID
	marker:   #CompensationMarkerRef
	movement: #MovementPatternRef
	phase:    #PatternPhaseRef
	side?:    #Side
	onset?:   #DerivedScalar
	peak?:    #DerivedScalar
	integral?: #DerivedScalar
	duration?: #DerivedScalar
	deviationFromReference?: #DerivedScalar
	confidence?: number & >=0 & <=1
	evidence: [...#EvidenceLink] & [_, ...]
})

#CompensationRelationType:
	"co-occurring" |
	"inverse-association" |
	"positive-association" |
	"demand-redistribution-candidate" |
	"substitution-candidate" |
	"qualified-compensatory"

#CompensationRelation: close({
	capacity:     #NormalizedCapacityRef
	marker:       #CompensationMarkerRef
	relationType: #CompensationRelationType
	lag?:         number
	strength?:    number
	uncertainty?: #Uncertainty
	evidence:     [...#EvidenceLink] & [_, ...]
})

#CompensationQualifier:
	"excessive-magnitude" |
	"excessive-duration" |
	"premature-onset" |
	"persistence" |
	"increasing-with-load" |
	"capacity-limiting" |
	"demand-displacing" |
	"recovery-cost" |
	"pain-associated" |
	"instability-associated" |
	"downstream-constraint"

#CompensationClassification:
	"nominal-variation" |
	"adaptive" |
	"compensatory" |
	"dysfunctional"

// The observation never declares itself dysfunctional. A versioned policy
// performs that qualification against an explicit reference basis.
#CompensationQualification: close({
	observation:   #CompensationObservationRef
	referenceBasis: string
	qualifiers:    [...#CompensationQualifier]
	classification: #CompensationClassification
	uncertainty?:  #Uncertainty
	evidence:      [...#EvidenceLink] & [_, ...]
	policyVersion: string
})

#CompensationProjection: close({
	id:             #CompensationProjectionID
	movement:       #MovementPatternRef
	observations:   [...#CompensationObservationRef]
	qualifications?: [...#CompensationQualification]
	projectionVersion: string
})
