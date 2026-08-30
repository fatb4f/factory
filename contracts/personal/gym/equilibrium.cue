package gym

#EquilibriumMetricID: string
#EquilibriumMetricRef: close({id: #EquilibriumMetricID})

#EquilibriumKind:
	"reciprocal-ratio" |
	"bilateral-asymmetry" |
	"cross-chain-ratio" |
	"controlled-rom-fraction" |
	"load-distribution" |
	"load-distribution-variability" |
	"temporal-coupling" |
	"recovery-normalized-capacity" |
	"limiter-distribution"

#EquilibriumInputRole:
	"value" |
	"left" |
	"right" |
	"agonist" |
	"antagonist" |
	"source" |
	"target" |
	"capacity" |
	"recovery"

#EquilibriumNormalization:
	"none" |
	"baseline" |
	"body-mass" |
	"protocol-reference" |
	"within-subject-range"

#EquilibriumInput: close({
	metric:         #MetricRef
	role:           #EquilibriumInputRole
	subject?:       #TargetSubject
	normalization?: #EquilibriumNormalization
})

#EquilibriumInterpretation:
	"toward-zero" |
	"toward-one" |
	"target-range" |
	"lower-variability" |
	"less-concentrated" |
	"stable-or-improving" |
	"contextual"

#EquilibriumMetric: close({
	id:             #EquilibriumMetricID
	label:          string
	kind:           #EquilibriumKind
	inputs:         [...#EquilibriumInput] & [_, ...]
	output:         #MetricRef
	protocol?:      #ProtocolRef
	interpretation: #EquilibriumInterpretation
	comparableOnly: bool
})

#EquilibriumObservationState:
	"unmeasured" |
	"baselining" |
	"within-band" |
	"outside-band" |
	"improving" |
	"regressing" |
	"insufficient-evidence"

#EquilibriumObservation: close({
	program:  #ProgramRef
	metric:   #EquilibriumMetricRef
	value?:   number
	state:    #EquilibriumObservationState
	protocol?: #ProtocolRef
	sourceIDs: [...string] & [_, ...]
})

#EquilibriumState: close({
	program: #ProgramRef
	coverage: "incomplete" | "baselining" | "sufficient"
	observations: [...#EquilibriumObservation]
})

#EquilibriumPolicy: close({
	requireComparableProtocols: bool
	requireMechanicalAdmission: bool
	requireRecoveryAdmission:   bool
	preserveSignedAsymmetry:    bool
	noScalarAggregate:          bool
	localCapacityCannotSatisfyRestorationAlone: bool
})

#ProgramEquilibrium: close({
	metrics:          [...#EquilibriumMetricRef] & [_, ...]
	primaryTargets:   [...#TargetRef] & [_, ...]
	completionTarget: #TargetRef
	policy:           #EquilibriumPolicy
})

equilibriumMetrics: close({
	"stance-load-redistribution": #EquilibriumMetric & {
		id: "stance-load-redistribution"
		label: "Bilateral stance load redistribution"
		kind: "load-distribution"
		inputs: [
			{metric: {id: "left-scale-load"}, role: "left", normalization: "body-mass"},
			{metric: {id: "right-scale-load"}, role: "right", normalization: "body-mass"},
		]
		output: {id: "stance-asymmetry-ratio"}
		protocol: {id: "dual-scale-neutral-stance-v1"}
		interpretation: "toward-zero"
		comparableOnly: true
	}
	"stance-load-stability": #EquilibriumMetric & {
		id: "stance-load-stability"
		label: "Stance asymmetry variability"
		kind: "load-distribution-variability"
		inputs: [{metric: {id: "stance-asymmetry-ratio"}, role: "value", normalization: "none"}]
		output: {id: "stance-asymmetry-variability"}
		protocol: {id: "dual-scale-neutral-stance-v1"}
		interpretation: "lower-variability"
		comparableOnly: true
	}
	"bilateral-capacity-equilibrium": #EquilibriumMetric & {
		id: "bilateral-capacity-equilibrium"
		label: "Bilateral admitted-capacity asymmetry"
		kind: "bilateral-asymmetry"
		inputs: [
			{metric: {id: "normalized-capacity-index"}, role: "left", normalization: "baseline"},
			{metric: {id: "normalized-capacity-index"}, role: "right", normalization: "baseline"},
		]
		output: {id: "bilateral-capacity-asymmetry"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "toward-zero"
		comparableOnly: true
	}
	"reciprocal-capacity-equilibrium": #EquilibriumMetric & {
		id: "reciprocal-capacity-equilibrium"
		label: "Agonist-antagonist admitted-capacity ratio"
		kind: "reciprocal-ratio"
		inputs: [
			{metric: {id: "normalized-capacity-index"}, role: "agonist", normalization: "baseline"},
			{metric: {id: "normalized-capacity-index"}, role: "antagonist", normalization: "baseline"},
		]
		output: {id: "reciprocal-capacity-ratio"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "target-range"
		comparableOnly: true
	}
	"anterior-posterior-equilibrium": #EquilibriumMetric & {
		id: "anterior-posterior-equilibrium"
		label: "Anterior-posterior admitted-capacity ratio"
		kind: "cross-chain-ratio"
		inputs: [
			{metric: {id: "normalized-capacity-index"}, role: "source", subject: {chain: {id: "anterior-knee-hip"}}, normalization: "baseline"},
			{metric: {id: "normalized-capacity-index"}, role: "target", subject: {chain: {id: "posterior-chain"}}, normalization: "baseline"},
		]
		output: {id: "anterior-posterior-capacity-ratio"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "target-range"
		comparableOnly: true
	}
	"distal-proximal-equilibrium": #EquilibriumMetric & {
		id: "distal-proximal-equilibrium"
		label: "Distal-proximal admitted-capacity ratio"
		kind: "cross-chain-ratio"
		inputs: [
			{metric: {id: "normalized-capacity-index"}, role: "source", subject: {chain: {id: "distal-foot-ankle"}}, normalization: "baseline"},
			{metric: {id: "normalized-capacity-index"}, role: "target", subject: {chain: {id: "trunk-pelvis"}}, normalization: "baseline"},
		]
		output: {id: "distal-proximal-capacity-ratio"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "target-range"
		comparableOnly: true
	}
	"frontal-sagittal-equilibrium": #EquilibriumMetric & {
		id: "frontal-sagittal-equilibrium"
		label: "Frontal-sagittal admitted-capacity ratio"
		kind: "cross-chain-ratio"
		inputs: [
			{metric: {id: "normalized-capacity-index"}, role: "source", subject: {chain: {id: "frontal-pelvic"}}, normalization: "baseline"},
			{metric: {id: "normalized-capacity-index"}, role: "target", subject: {chain: {id: "posterior-chain"}}, normalization: "baseline"},
		]
		output: {id: "frontal-sagittal-capacity-ratio"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "target-range"
		comparableOnly: true
	}
	"rom-control-equilibrium": #EquilibriumMetric & {
		id: "rom-control-equilibrium"
		label: "Controlled fraction of available range"
		kind: "controlled-rom-fraction"
		inputs: [
			{metric: {id: "clean-rom-stage"}, role: "capacity", normalization: "within-subject-range"},
			{metric: {id: "available-rom-stage"}, role: "value", normalization: "within-subject-range"},
		]
		output: {id: "controlled-rom-fraction"}
		protocol: {id: "rom-control-baseline-v1"}
		interpretation: "toward-one"
		comparableOnly: true
	}
	"limiter-redistribution": #EquilibriumMetric & {
		id: "limiter-redistribution"
		label: "Limiter concentration across regions"
		kind: "limiter-distribution"
		inputs: [{metric: {id: "limiter-onset"}, role: "value", normalization: "none"}]
		output: {id: "limiter-concentration"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "less-concentrated"
		comparableOnly: true
	}
	"recovery-normalized-capacity": #EquilibriumMetric & {
		id: "recovery-normalized-capacity"
		label: "Capacity redistribution within recovery budget"
		kind: "recovery-normalized-capacity"
		inputs: [
			{metric: {id: "normalized-capacity-index"}, role: "capacity", normalization: "baseline"},
			{metric: {id: "recovery-cost"}, role: "recovery", normalization: "none"},
		]
		output: {id: "recovery-normalized-capacity-state"}
		protocol: {id: "capacity-equilibrium-review-v1"}
		interpretation: "stable-or-improving"
		comparableOnly: true
	}
})
