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
})

ankleKneePelvisDataRequirements: [...#DataRequirement] & [
	{id: "req-distal-state", target: {id: "distal-push-off"}, metric: {id: "ankle-push-off-state"}, protocol: {id: "recovery-check-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-dual-scale", target: {id: "stance-load-distribution"}, metric: {id: "stance-asymmetry-ratio"}, protocol: {id: "dual-scale-neutral-stance-v1"}, requirement: "recommended", minimumEvidence: 3},
	{id: "req-posterior-rom", target: {id: "posterior-clean-rom"}, metric: {id: "clean-rom-stage"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-posterior-video", target: {id: "posterior-clean-rom"}, metric: {id: "eccentric-duration"}, protocol: {id: "ghr-side-video-v1"}, requirement: "recommended", minimumEvidence: 1},
	{id: "req-posterior-quality", target: {id: "posterior-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-anterior-rom", target: {id: "anterior-clean-rom"}, metric: {id: "clean-rom-stage"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-anterior-quality", target: {id: "anterior-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-frontal-quality", target: {id: "frontal-pelvic-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-core-quality", target: {id: "trunk-pelvis-quality"}, metric: {id: "mechanical-admission"}, protocol: {id: "session-mechanical-capture-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-gait", target: {id: "gait-state"}, metric: {id: "gait-state"}, protocol: {id: "recovery-check-v1"}, requirement: "required", minimumEvidence: 3},
	{id: "req-recovery", target: {id: "recovery-budget"}, metric: {id: "recovery-cost"}, protocol: {id: "recovery-check-v1"}, requirement: "required", minimumEvidence: 3},
]

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
		{id: "posterior-clean-rom"},
		{id: "posterior-quality"},
		{id: "anterior-clean-rom"},
		{id: "anterior-quality"},
		{id: "frontal-pelvic-quality"},
		{id: "trunk-pelvis-quality"},
		{id: "gait-state"},
		{id: "recovery-budget"},
	]
	compositeTargets: [{id: "posterior-admitted"}, {id: "anterior-admitted"}, {id: "integrated-support"}]
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
