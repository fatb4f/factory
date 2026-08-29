package gym

#IssueStatus: "open" | "monitoring" | "resolved" | "dormant"
#IssueEvidenceRelation: "supports" | "contradicts" | "context"
#IssueTrendDirection: "improving" | "stable" | "worsening" | "mixed" | "unknown"
#IssueConfidence: "insufficient" | "provisional" | "moderate" | "high"

#IssueDefinition: close({
	id:          #IssueID
	title:       string
	createdAt:   #Timestamp
	status:      #IssueStatus
	description?: string
})

#IssueEvidenceSource: close({
	kind: "observation" | "recovery" | "measurement" | "session-assessment"
	id:   string
})

#IssueEvidence: close({
	id:       #IssueEvidenceID
	issue:    #IssueID
	relation: #IssueEvidenceRelation
	source:   #IssueEvidenceSource
	exercise?: #ExerciseRef
	side?:     #Side
	at?:       #Timestamp
	note?:     string
})

#IssueProjection: close({
	issue:          #IssueDefinition
	supporting:     int & >=0
	contradicting:  int & >=0
	contextual:     int & >=0
	contexts?:      [...string]
	trend:          #IssueTrendDirection
	confidence:     #IssueConfidence
	evidence:       [...#IssueEvidence]
})

#AssociationProjection: close({
	subjectMetric: string
	condition:     string
	observations:  int & >=0
	direction:     "positive" | "negative" | "none" | "mixed" | "unknown"
	confidence:    #IssueConfidence
	causalClaim:   false
	sources:       [...string]
})
