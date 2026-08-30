package gym

#EvidenceID: string
#EvidenceRef: close({id: #EvidenceID})
#EvidenceProviderID: string
#EvidenceProviderRef: close({id: #EvidenceProviderID})
#OperationExecutorID: string
#OperationExecutorRef: close({id: #OperationExecutorID})

#EvidenceClass:
	"direct-mechanical" |
	"model-derived" |
	"physiological" |
	"exercise-derived-proxy" |
	"qualitative-observation"

// Compatibility alias for the 0.4.0 name. Evidence is now generic rather than
// scoped to contribution-producing systems.
#ContributionEvidenceClass: #EvidenceClass

#EvidenceRole:
	"source" |
	"supporting" |
	"derivation-input" |
	"reference" |
	"qualification"

#DerivedSource: "measured" | "derived" | "estimated" | "imputed"

#Uncertainty: close({
	kind?:       "interval" | "score" | "qualitative"
	lower?:      number
	upper?:      number
	confidence?: number & >=0 & <=1
	note?:       string
})

// Evidence records own provider/method/model provenance. Semantic objects point
// to them through ordered links instead of flattening provenance into each row.
#EvidenceRecord: close({
	id:           #EvidenceID
	class:        #EvidenceClass
	sourceID:     string
	provider?:    #EvidenceProviderRef
	method?:      string
	modelVersion?: string
	confidence?:  number & >=0 & <=1
	uncertainty?: #Uncertainty
})

#EvidenceLink: close({
	evidence: #EvidenceRef
	role:     #EvidenceRole
	ordinal?: int & >=0
})

// Derived values never masquerade as observations. Evidence and uncertainty
// remain part of the value contract while evidence details live in the registry.
#DerivedScalar: close({
	value:       number
	unit?:       #Unit
	source:      #DerivedSource
	evidence:    [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
})

#EvidenceProviderCapability:
	"kinematics" |
	"kinetics" |
	"force" |
	"emg" |
	"mechanical-contribution"

#EvidenceProvider: close({
	id:           #EvidenceProviderID
	kind:         "external-model" | "device" | "video" | "manual"
	adapter?:     string
	version?:     string
	capabilities: [...#EvidenceProviderCapability] & [_, ...]
	outputClass:  #EvidenceClass
})

#OperationKind:
	"demand-transform" |
	"normalization" |
	"comparison" |
	"projection" |
	"aggregation"

#OperationRuntime:
	"python" |
	"ibis" |
	"duckdb" |
	"bigquery" |
	"malloy" |
	string

// Executors compute Gym-defined operations. Runtime choice never determines
// semantic meaning; the operation contract and typed output do.
#OperationExecutor: close({
	id:         #OperationExecutorID
	runtime:    #OperationRuntime
	operations: [...#OperationKind] & [_, ...]
	adapter?:   string
	version?:   string
})
