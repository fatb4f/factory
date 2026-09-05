package industrialconstraints

#EvidenceClass:
	"source-record" |
	"measurement" |
	"event-observation" |
	"event" |
	"relation" |
	"correlation" |
	"institutional-response" |
	"coverage-gap"

#EvidenceItem: close({
	record: #RecordRef
	class:  #EvidenceClass
})

#ClaimRef: close({
	id: #RecordID
})

#AssessmentRef: close({
	id: #RecordID
})

#EvidenceClaim: close({
	kind:        "claim"
	id:          #RecordID
	proposition: string
	subject?:    #EntityRef
	evidence:    [...#EvidenceItem] & [_, ...]
})

#AssessmentState: "supported" | "contradicted" | "insufficient-evidence"

#CoverageGap: close({
	id:          string
	description: string
	affects:     [...#RecordRef]
})

#Assessment: close({
	kind:         "assessment"
	id:           #RecordID
	claim:        #ClaimRef
	state:        #AssessmentState
	evidence:     [...#EvidenceItem]
	coverageGaps: [...#CoverageGap]
})
