package gym

#TargetID: string
#TargetRef: close({id: #TargetID})

#TargetPriority: "primary" | "supporting" | "monitor"
#CriterionKind: "minimum" | "maximum" | "range" | "state" | "stage"

#Criterion: close({
	kind:  #CriterionKind
	min?:  number
	max?:  number
	value?: string | number
})

#EvidenceRequirement: close({
	minimumComparableRuns?: int & >=1
	windowRuns?:            int & >=1
	protocol?:              #ProtocolRef
})

#TargetSubject: close({
	chain?:    #ChainRef
	exercise?: #ExerciseRef
	region?:   #BodyRegionRef
	global?:   bool
})

#Target: close({
	id:        #TargetID
	label:     string
	subject:   #TargetSubject
	metric:    #MetricRef
	criterion: #Criterion
	priority:  #TargetPriority
	evidence?: #EvidenceRequirement
})

#CompositeTarget: close({
	id:      #TargetID
	label:   string
	all?:    [...#TargetRef]
	any?:    [...#TargetRef]
	sustain?: close({
		comparableRuns: int & >=1
		windowRuns?:    int & >=1
	})
})

#DataRequirement: close({
	id:          string
	target:      #TargetRef
	metric:      #MetricRef
	protocol?:   #ProtocolRef
	requirement: "required" | "recommended" | "optional"
	minimumEvidence?: int & >=1
})
