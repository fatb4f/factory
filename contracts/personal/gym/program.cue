package gym

#ProgramID: string
#ProgramRef: close({id: #ProgramID})
#ProgramStatus: "draft" | "baselining" | "active" | "hold" | "completed" | "retired"

#RecoveryBudget: close({
	maxEnergyDrop?:        int & >=0 & <=4
	maxCognitiveDrop?:     int & >=0 & <=4
	maxDoms?:              int & >=0 & <=5
	maxMovementAlteredH?:  number & >=0
	maxRecoveredByH?:      number & >=0
})

#ProgressionDimension: close({
	name: string
	order: int & >=0
})

#BlockPolicy: close({
	progressionPriority: [...#ProgressionDimension]
	progressOneDimensionAtATime?: bool
	timeTriggersReviewOnly?:       bool
})

#Program: close({
	id:               #ProgramID
	name:             string
	status:           #ProgramStatus
	chains:           [...#ChainRef]
	targets:          [...#TargetRef]
	compositeTargets?: [...#TargetRef]
	equilibrium?:      #ProgramEquilibrium
	recoveryBudget:   #RecoveryBudget
	blockPolicy:      #BlockPolicy
	dataRequirements: [...#DataRequirement]
})

#ExerciseMapping: close({
	exercise:               #ExerciseRef
	primaryChains:          [...#ChainRef]
	secondaryChains?:       [...#ChainRef]
	constraintInterfaces?:  [...#ChainRef]
	controllableDimensions: [...string]
	observableMetrics:      [...#MetricRef]
})

#ProgramCoverage: close({
	program: #ProgramRef
	observabilityComplete: bool
	controllabilityComplete: bool
	equilibriumObservabilityComplete?: bool
	unobservedTargets?: [...#TargetRef]
	unactuatedTargets?: [...#TargetRef]
	unobservedEquilibriumMetrics?: [...#EquilibriumMetricRef]
})
