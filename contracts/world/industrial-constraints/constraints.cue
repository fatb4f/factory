package industrialconstraints

#ConstraintState:
	"unknown" |
	"latent" |
	"emerging" |
	"binding" |
	"relieving" |
	"resolved"

#ConstraintMechanism:
	"capacity" |
	"lead-time" |
	"input-availability" |
	"energy" |
	"infrastructure" |
	"logistics" |
	"workforce" |
	"capital" |
	"regulation" |
	"technology"

#Confidence: "low" | "moderate" | "high"
#ConstraintBasis: "single-observation" | "multi-record-correlation"

#RelationRef: close({
	kind: "relation"
	id:   #RecordID
})

#ConstraintEvidenceItem: close({
	record: #RecordRef
	class:  #EvidenceClass
})

#ConstraintClaim: close({
	kind:              "constraint-claim"
	id:                #RecordID
	subject:           #EntityRef
	mechanism:         #ConstraintMechanism
	state:             #ConstraintState
	basis:             #ConstraintBasis
	evidence:          [...#ConstraintEvidenceItem] & [_, ...]
	affectedRelations: [...#RelationRef]
	confidence:        #Confidence
	assessment?:       #AssessmentRef
}) & (
	{
		state:    "binding"
		basis:    "multi-record-correlation"
		evidence: [#ConstraintEvidenceItem, #ConstraintEvidenceItem, ...#ConstraintEvidenceItem]
	} |
	{
		state: "unknown" | "latent" | "emerging" | "relieving" | "resolved"
	}
)
