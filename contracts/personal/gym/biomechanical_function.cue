package gym

// Biomechanical function is modeled from the athlete's currently observed
// strategy state. A neutral or mechanically symmetric baseline is not assumed.
// Training, recovery, adaptation, and ordinary locomotion are all interpreted
// through that evolving state.

#StrategyStateID: string
#StrategyStateRef: close({id: #StrategyStateID})
#BiomechanicalFunctionalStateID: string
#BiomechanicalFunctionalStateRef: close({id: #BiomechanicalFunctionalStateID})

#StrategyEvidenceClass: "direct-observation" | "measurement" | "video" | "derived" | "framework-interpretation" | "other"

#StrategyAxis:
	"laterality" |
	"stance-bias" |
	"load-bias" |
	"rotation" |
	"translation" |
	"pelvic-orientation" |
	"thorax-orientation" |
	"rib-pelvis-relation" |
	"foot-strategy" |
	"gait-strategy" |
	"support-strategy" |
	"breathing-strategy" |
	"coordination" |
	"other"

// Strategy features are the authoritative observations/derived features.
// They can later be interpreted through external biomechanical frameworks.
#StrategyFeature: close({
	axis:       #StrategyAxis
	state:      string
	side?:      #Side
	magnitude?: #DemandEstimate
	basis:      #StrategyEvidenceClass
	confidence?: number & >=0 & <=1
	note?:      string
})

// Framework labels are interpretations, not canonical observations. This allows
// concepts such as PRI pattern labels to be attached without making the Gym
// authority depend on any one clinical or training school.
#StrategyFrameworkInterpretation: close({
	framework:   string
	label:       string
	version?:    string
	confidence?: number & >=0 & <=1
	basis?:      [...string]
	note?:       string
})

#GeneralizedStrategyStatus: "established" | "perturbed" | "reorganizing" | "consolidating" | "unstable" | "unknown"

#GeneralizedStrategyState: close({
	id:          #StrategyStateID
	status:      #GeneralizedStrategyStatus
	features:    [...#StrategyFeature]
	interpretations?: [...#StrategyFrameworkInterpretation]
	compensations?:   [...#CompensationObservationRef]
	provenance?:      #Provenance
	note?:            string
})

#FunctionalTask: close({
	context:   #FunctionalContext
	objective: string
	demand?:   #DemandProfile
	note?:     string
})

#ComplexLoadAllocation: close({
	complex:      string
	context:      #FunctionalContext
	role:         #ComplexRole
	side?:        #Side
	primary?:     bool
	adjacent?:    bool
	relativeContribution?: number & >=0 & <=1
	mechanical?:  #DemandEstimate
	stability?:   #DemandEstimate
	coordination?: #DemandEstimate
	note?:        string
})

#LoadDistributionState: close({
	allocations: [...#ComplexLoadAllocation]
	overall?:    #DemandEstimate
	note?:       string
})

#StabilizationStrategy: close({
	complexes: [...#ComplexParticipation]
	cost?:     #DemandEstimate
	note?:     string
})

#BiomechanicalStateStatus: "established" | "perturbed" | "redistributed" | "reorganizing" | "consolidating" | "unstable" | "unknown"

// This is the task-level functional solution. Load distribution and
// compensation are variables inside it rather than the parent state.
#BiomechanicalFunctionalState: close({
	id:        #BiomechanicalFunctionalStateID
	task:      #FunctionalTask
	strategy:  #StrategyStateRef
	status:    #BiomechanicalStateStatus
	loadDistribution?: #LoadDistributionState
	stabilization?:     #StabilizationStrategy
	compensations?:     [...#CompensationObservationRef]
	cost?: close({
		mechanical?:  #DemandEstimate
		integration?: #DemandEstimate
		coordination?: #DemandEstimate
		cognitive?:   #DemandEstimate
	})
	provenance?: #Provenance
	note?:       string
})

#StrategyInfluenceDomain: "training-execution" | "ambient-function" | "recovery" | "adaptation" | "reorganization"

#StrategyInfluence: close({
	strategy: #StrategyStateRef
	domain:   #StrategyInfluenceDomain
	effects:  [...string]
	confidence?: number & >=0 & <=1
	note?:    string
})

#StateTransitionTrigger: "training-exposure" | "fatigue" | "recovery" | "adaptation" | "rom-expansion" | "ambient-duty" | "compensation" | "external-task" | "other"

#BiomechanicalStateTransition: close({
	from:     #BiomechanicalFunctionalStateRef
	to:       #BiomechanicalFunctionalStateRef
	trigger:  #StateTransitionTrigger
	influences?: [...#StrategyInfluence]
	note?:    string
})

#UnilateralPurpose: "expose-strategy" | "compare-sides" | "constrain-compensation" | "modify-strategy" | "build-side-capacity" | "integration" | "other"

// Program premise describes whether a program assumes an adequate stable
// baseline or explicitly trains an observed, evolving biomechanical state.
#FunctionalBaselineAssumption: "neutral-assumed" | "stable-function-assumed" | "observed-current-state"

#ProgramBiomechanicalPremise: close({
	baseline:       #FunctionalBaselineAssumption
	strategySensitive: bool
	stateDependentProgramming?: bool
	unilateralPurposes?: [...#UnilateralPurpose]
	feedbackRequired?: bool
	note?:          string
})
