package gym

ankleKneePelvisTargets: close({
	"distal-push-off": #Target & {
		id: "distal-push-off"
		label: "Available distal push-off"
		subject: {chain: {id: "distal-foot-ankle"}}
		metric: {id: "ankle-push-off-state"}
		criterion: {kind: "state", value: "normal"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3}
	}
	"stance-load-distribution": #Target & {
		id: "stance-load-distribution"
		label: "Bilateral stance load distribution trend"
		subject: {chain: {id: "global-stance-support"}}
		metric: {id: "stance-asymmetry-ratio"}
		criterion: {kind: "trend", value: "toward-zero"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "dual-scale-neutral-stance-v1"}}
	}
	"stance-load-stability": #Target & {
		id: "stance-load-stability"
		label: "Stable bilateral stance redistribution"
		subject: {chain: {id: "global-stance-support"}}
		metric: {id: "stance-asymmetry-variability"}
		criterion: {kind: "trend", value: "lower-variability"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "dual-scale-neutral-stance-v1"}}
	}
	"posterior-clean-rom": #Target & {
		id: "posterior-clean-rom"
		label: "GHR clean working range"
		subject: {exercise: {id: "ghr"}}
		metric: {id: "clean-rom-stage"}
		criterion: {kind: "trend", value: "higher"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3}
	}
	"posterior-quality": #Target & {
		id: "posterior-quality"
		label: "Posterior-chain mechanical admission"
		subject: {chain: {id: "posterior-chain"}}
		metric: {id: "mechanical-admission"}
		criterion: {kind: "state", value: "clean"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3}
	}
	"anterior-clean-rom": #Target & {
		id: "anterior-clean-rom"
		label: "Reverse Nordic clean working range"
		subject: {exercise: {id: "reverse-nordic"}}
		metric: {id: "clean-rom-stage"}
		criterion: {kind: "trend", value: "higher"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3}
	}
	"anterior-quality": #Target & {
		id: "anterior-quality"
		label: "Anterior knee-hip mechanical admission"
		subject: {chain: {id: "anterior-knee-hip"}}
		metric: {id: "mechanical-admission"}
		criterion: {kind: "state", value: "clean"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3}
	}
	"frontal-pelvic-quality": #Target & {
		id: "frontal-pelvic-quality"
		label: "Frontal pelvic mechanical admission"
		subject: {chain: {id: "frontal-pelvic"}}
		metric: {id: "mechanical-admission"}
		criterion: {kind: "state", value: "clean"}
		priority: "supporting"
		evidence: {minimumComparableRuns: 3}
	}
	"trunk-pelvis-quality": #Target & {
		id: "trunk-pelvis-quality"
		label: "Trunk-pelvis mechanical admission"
		subject: {chain: {id: "trunk-pelvis"}}
		metric: {id: "mechanical-admission"}
		criterion: {kind: "state", value: "clean"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3}
	}
	"bilateral-capacity-balance": #Target & {
		id: "bilateral-capacity-balance"
		label: "Bilateral admitted-capacity redistribution"
		subject: {global: true}
		metric: {id: "bilateral-capacity-asymmetry"}
		criterion: {kind: "trend", value: "toward-zero"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"reciprocal-capacity-balance": #Target & {
		id: "reciprocal-capacity-balance"
		label: "Agonist-antagonist capacity equilibrium"
		subject: {global: true}
		metric: {id: "reciprocal-capacity-ratio"}
		criterion: {kind: "trend", value: "toward-stable-band"}
		priority: "monitor"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"anterior-posterior-balance": #Target & {
		id: "anterior-posterior-balance"
		label: "Anterior-posterior capacity equilibrium"
		subject: {global: true}
		metric: {id: "anterior-posterior-capacity-ratio"}
		criterion: {kind: "trend", value: "toward-stable-band"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"distal-proximal-balance": #Target & {
		id: "distal-proximal-balance"
		label: "Distal-proximal capacity equilibrium"
		subject: {global: true}
		metric: {id: "distal-proximal-capacity-ratio"}
		criterion: {kind: "trend", value: "toward-stable-band"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"frontal-sagittal-balance": #Target & {
		id: "frontal-sagittal-balance"
		label: "Frontal-sagittal capacity equilibrium"
		subject: {global: true}
		metric: {id: "frontal-sagittal-capacity-ratio"}
		criterion: {kind: "trend", value: "toward-stable-band"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"controlled-rom-balance": #Target & {
		id: "controlled-rom-balance"
		label: "Controlled fraction of available range"
		subject: {global: true}
		metric: {id: "controlled-rom-fraction"}
		criterion: {kind: "trend", value: "higher"}
		priority: "supporting"
		evidence: {minimumComparableRuns: 3, protocol: {id: "rom-control-baseline-v1"}}
	}
	"limiter-redistribution": #Target & {
		id: "limiter-redistribution"
		label: "Limiter demand redistributes across regions"
		subject: {global: true}
		metric: {id: "limiter-concentration"}
		criterion: {kind: "trend", value: "less-concentrated"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"recovery-normalized-redistribution": #Target & {
		id: "recovery-normalized-redistribution"
		label: "Capacity redistribution remains inside recovery budget"
		subject: {global: true}
		metric: {id: "recovery-normalized-capacity-state"}
		criterion: {kind: "trend", value: "stable-or-improving"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "capacity-equilibrium-review-v1"}}
	}
	"gait-state": #Target & {
		id: "gait-state"
		label: "Available gait pattern"
		subject: {global: true}
		metric: {id: "gait-state"}
		criterion: {kind: "state", value: "normal"}
		priority: "supporting"
		evidence: {minimumComparableRuns: 3}
	}
	"recovery-budget": #Target & {
		id: "recovery-budget"
		label: "Session remains inside systemic recovery budget"
		subject: {global: true}
		metric: {id: "recovery-cost"}
		criterion: {kind: "state", value: "low-or-moderate"}
		priority: "primary"
		evidence: {minimumComparableRuns: 3, protocol: {id: "recovery-check-v1"}}
	}
})

ankleKneePelvisCompositeTargets: close({
	"posterior-admitted": #CompositeTarget & {
		id: "posterior-admitted"
		label: "Posterior exposure advances without exceeding recovery budget"
		all: [{id: "posterior-clean-rom"}, {id: "posterior-quality"}, {id: "trunk-pelvis-quality"}, {id: "recovery-budget"}]
		sustain: {comparableRuns: 3, windowRuns: 5}
	}
	"anterior-admitted": #CompositeTarget & {
		id: "anterior-admitted"
		label: "Anterior exposure advances without exceeding recovery budget"
		all: [{id: "anterior-clean-rom"}, {id: "anterior-quality"}, {id: "frontal-pelvic-quality"}, {id: "trunk-pelvis-quality"}, {id: "recovery-budget"}]
		sustain: {comparableRuns: 3, windowRuns: 5}
	}
	"integrated-support": #CompositeTarget & {
		id: "integrated-support"
		label: "Distal-to-pelvic support integration"
		all: [{id: "distal-push-off"}, {id: "stance-load-distribution"}, {id: "frontal-pelvic-quality"}, {id: "trunk-pelvis-quality"}, {id: "gait-state"}]
		sustain: {comparableRuns: 3, windowRuns: 5}
	}
	"redistribution-equilibrium": #CompositeTarget & {
		id: "redistribution-equilibrium"
		label: "Multi-region capacity redistribution equilibrium"
		all: [
			{id: "stance-load-distribution"},
			{id: "stance-load-stability"},
			{id: "bilateral-capacity-balance"},
			{id: "anterior-posterior-balance"},
			{id: "distal-proximal-balance"},
			{id: "frontal-sagittal-balance"},
			{id: "limiter-redistribution"},
			{id: "recovery-normalized-redistribution"},
			{id: "recovery-budget"},
		]
		sustain: {comparableRuns: 3, windowRuns: 5}
	}
	"restored-capacity-equilibrium": #CompositeTarget & {
		id: "restored-capacity-equilibrium"
		label: "Capacity restoration with redistribution equilibrium"
		all: [{id: "posterior-admitted"}, {id: "anterior-admitted"}, {id: "integrated-support"}, {id: "redistribution-equilibrium"}]
		sustain: {comparableRuns: 3, windowRuns: 5}
	}
})

ankleKneePelvisDataRequirements: [...#DataRequirement] & [
	{id: "req-distal-state", target: {id: "distal-push-off"}, metric: {id: "ankle-push-off-state"}, protocol: {id: "recovery-check-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-dual-scale", target: {id: "stance-load-distribution"}, metric: {id: "stance-asymmetry-ratio"}, protocol: {id: "dual-scale-neutral-stance-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-dual-scale-stability", target: {id: "stance-load-stability"}, metric: {id: "stance-asymmetry-variability"}, protocol: {id: "dual-scale-neutral-stance-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-posterior-rom", target: {id: "posterior-clean-rom"}, metric: {id: "clean-rom-stage"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-posterior-video", target: {id: "posterior-clean-rom"}, metric: {id: "eccentric-duration"}, protocol: {id: "ghr-side-video-v1"}, requirement: "recommended", minimumEvidence: 1},
	{id: "req-posterior-quality", target: {id: "posterior-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-anterior-rom", target: {id: "anterior-clean-rom"}, metric: {id: "clean-rom-stage"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-anterior-quality", target: {id: "anterior-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-frontal-quality", target: {id: "frontal-pelvic-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-core-quality", target: {id: "trunk-pelvis-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-bilateral-capacity", target: {id: "bilateral-capacity-balance"}, metric: {id: "bilateral-capacity-asymmetry"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-reciprocal-capacity", target: {id: "reciprocal-capacity-balance"}, metric: {id: "reciprocal-capacity-ratio"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "recommended", minimumEvidence: 3},
	{id: "req-ap-equilibrium", target: {id: "anterior-posterior-balance"}, metric: {id: "anterior-posterior-capacity-ratio"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-distal-proximal-equilibrium", target: {id: "distal-proximal-balance"}, metric: {id: "distal-proximal-capacity-ratio"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-frontal-sagittal-equilibrium", target: {id: "frontal-sagittal-balance"}, metric: {id: "frontal-sagittal-capacity-ratio"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-controlled-rom", target: {id: "controlled-rom-balance"}, metric: {id: "controlled-rom-fraction"}, protocol: {id: "rom-control-baseline-v1"}, requirement: "recommended", minimumEvidence: 3},
	{id: "req-limiter-redistribution", target: {id: "limiter-redistribution"}, metric: {id: "limiter-concentration"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-recovery-normalized-redistribution", target: {id: "recovery-normalized-redistribution"}, metric: {id: "recovery-normalized-capacity-state"}, protocol: {id: "capacity-equilibrium-review-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-gait", target: {id: "gait-state"}, metric: {id: "gait-state"}, protocol: {id: "recovery-check-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-recovery", target: {id: "recovery-budget"}, metric: {id: "recovery-cost"}, protocol: {id: "recovery-check-v1"}, requirement: "required", minimumEvidence: 3},
]

ankleKneePelvisEquilibrium: #ProgramEquilibrium & {
	metrics: [
		{id: "stance-load-redistribution"},
		{id: "stance-load-stability"},
		{id: "bilateral-capacity-equilibrium"},
		{id: "reciprocal-capacity-equilibrium"},
		{id: "anterior-posterior-equilibrium"},
		{id: "distal-proximal-equilibrium"},
		{id: "frontal-sagittal-equilibrium"},
		{id: "rom-control-equilibrium"},
		{id: "limiter-redistribution"},
		{id: "recovery-normalized-capacity"},
	]
	primaryTargets: [
		{id: "stance-load-distribution"},
		{id: "stance-load-stability"},
		{id: "bilateral-capacity-balance"},
		{id: "anterior-posterior-balance"},
		{id: "distal-proximal-balance"},
		{id: "frontal-sagittal-balance"},
		{id: "limiter-redistribution"},
		{id: "recovery-normalized-redistribution"},
	]
	completionTarget: {id: "restored-capacity-equilibrium"}
	policy: {
		requireComparableProtocols: true
		requireMechanicalAdmission: true
		requireRecoveryAdmission: true
		preserveSignedAsymmetry: true
		noScalarAggregate: true
		localCapacityCannotSatisfyRestorationAlone: true
	}
}

ankleKneePelvisStabilityProgram: #Program & {
	id: "ankle-knee-pelvis-stability"
	name: "Ankle to knee to pelvis stability"
	status: "baselining"
	chains: [
		{id: "distal-foot-ankle"},
		{id: "anterior-knee-hip"},
		{id: "posterior-chain"},
		{id: "frontal-pelvic"},
		{id: "trunk-pelvis"},
		{id: "contralateral-cross-support"},
		{id: "global-stance-support"},
	]
	targets: [
		{id: "distal-push-off"},
		{id: "stance-load-distribution"},
		{id: "stance-load-stability"},
		{id: "posterior-clean-rom"},
		{id: "posterior-quality"},
		{id: "anterior-clean-rom"},
		{id: "anterior-quality"},
		{id: "frontal-pelvic-quality"},
		{id: "trunk-pelvis-quality"},
		{id: "bilateral-capacity-balance"},
		{id: "reciprocal-capacity-balance"},
		{id: "anterior-posterior-balance"},
		{id: "distal-proximal-balance"},
		{id: "frontal-sagittal-balance"},
		{id: "controlled-rom-balance"},
		{id: "limiter-redistribution"},
		{id: "recovery-normalized-redistribution"},
		{id: "gait-state"},
		{id: "recovery-budget"},
	]
	compositeTargets: [
		{id: "posterior-admitted"},
		{id: "anterior-admitted"},
		{id: "integrated-support"},
		{id: "redistribution-equilibrium"},
		{id: "restored-capacity-equilibrium"},
	]
	equilibrium: ankleKneePelvisEquilibrium
	recoveryBudget: {
		maxEnergyDrop: 2
		maxCognitiveDrop: 2
		maxDoms: 4
		maxMovementAlteredH: 48
		maxRecoveredByH: 72
	}
	blockPolicy: {
		progressionPriority: [
			{name: "quality-gate", order: 0},
			{name: "range", order: 1},
			{name: "reps", order: 2},
			{name: "assistance", order: 3},
			{name: "external-load", order: 4},
		]
		progressOneDimensionAtATime: true
		timeTriggersReviewOnly: true
	}
	dataRequirements: ankleKneePelvisDataRequirements
}
