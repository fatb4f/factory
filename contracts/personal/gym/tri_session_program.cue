package gym

#TriSessionKind: "posterior" | "anterior" | "distal-integrated"
#TriSessionPhase: "activation" | "primer" | "main" | "integration" | "core" | "downregulation"
#TriSessionRole: "activation-gate" | "primer" | "primary" | "secondary" | "integration" | "core" | "downregulation"

#RepRange: close({
	min: int & >=1
	max: int & >=1
})

#HoldRangeSeconds: close({
	min: number & >0
	max: number & >0
})

#SessionExercisePrescription: close({
	exercise: #ExerciseRef
	phase:    #TriSessionPhase
	role:     #TriSessionRole
	sets?:    int & >=1
	reps?:    #RepRange
	hold?:    #HoldRangeSeconds
	optional?: bool
	assistance?: string
	intent?:     string
	constraints?: [...string]
	stopOn?:      [...string]
	progression?: [...string]
})

#TriSessionTemplate: close({
	kind:      #TriSessionKind
	objective: string
	invariant: string
	exposures: [...#SessionExercisePrescription]
	completion?: close({
		mechanicalFailureAllowed?: bool
		compensationAllowed?:      bool
		requiresGaitReadout?:      bool
	})
})

#TriSessionTransitionPolicy: close({
	sequence: [#TriSessionKind, #TriSessionKind, #TriSessionKind]
	fixedWeekdays: bool
	recoveryGated: bool
	posteriorRecoveryHours?: #RepRange
	anteriorRecoveryHours?:  #RepRange
	distalRecoveryHours?:    #RepRange
	advanceOnlyInsideRecoveryBudget: bool
})

#TriSessionObservationPolicy: close({
	mechanicalQualityRequired: bool
	recoveryCostRequired:      bool
	partialRunsComparable:     bool
	progressOneDimensionAtATime: bool
})

#TriSessionProgram: close({
	id:       string
	program:  #ProgramRef
	version:  string
	status:   "draft" | "baselining" | "active" | "hold" | "retired"
	invariant: string
	sessions: [#TriSessionTemplate, #TriSessionTemplate, #TriSessionTemplate]
	transition:  #TriSessionTransitionPolicy
	observation: #TriSessionObservationPolicy
})

ankleKneePelvisTriSessionV1: #TriSessionProgram & {
	id:      "ankle-knee-pelvis-tri-session-v1"
	program: {id: "ankle-knee-pelvis-stability"}
	version: "v1"
	status:  "baselining"
	invariant: "Maintain pelvic organization while progressively transferring more force through the chain at equal or lower systemic recovery cost."

	sessions: [
		{
			kind: "posterior"
			objective: "Restore posterior-chain force transfer from distal control through hamstring and glute output while preserving lumbopelvic organization."
			invariant: "GHR depth, assistance, load, or volume may advance only while ankle, femoral, pelvic, and lumbar constraints remain admitted."
			exposures: [
				{exercise: {id: "ankle-inversion-eversion"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 10}, intent: "Make distal control available without fatigue."},
				{exercise: {id: "calf-raise-neutral"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 10}, constraints: ["ankle-neutral", "no-calf-burn"], intent: "Establish plantar-flexor output without aggressive plantar flexion."},
				{exercise: {id: "heel-dig-bridge"}, phase: "activation", role: "activation-gate", sets: 2, hold: {min: 10, max: 15}, intent: "Acquire hamstring tension before long-lever loading.", constraints: ["graded-tension", "no-cramping"]},
				{exercise: {id: "cross-supported-bridge-march"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 5, max: 6}, intent: "Establish low-cost trunk-pelvis control."},
				{exercise: {id: "reverse-hyper"}, phase: "primer", role: "primer", sets: 2, reps: {min: 8, max: 12}, intent: "Bring glute-pelvis-hamstring complex online before GHR.", constraints: ["very-light-load", "pelvis-organized", "no-lumbar-swing", "stop-before-fatigue"]},
				{exercise: {id: "ghr"}, phase: "main", role: "primary", sets: 3, reps: {min: 5, max: 8}, assistance: "enough-to-preserve-control", constraints: ["ankle-neutral", "femoral-position-organized", "hamstring-acquired-before-rep", "hips-torso-stacked", "pelvis-neutral", "slow-eccentric", "no-lumbar-rescue"], stopOn: ["pelvic-rotation-or-tilt", "lumbar-takeover", "delayed-hamstring-acquisition", "gastroc-cramp-threat", "medial-hamstring-cramp-threat", "femoral-control-loss"], progression: ["increase-clean-eccentric-rom", "reduce-assistance", "increase-reps-or-load"]},
				{exercise: {id: "reverse-hyper"}, phase: "main", role: "secondary", sets: 3, reps: {min: 8, max: 12}, constraints: ["hip-driven-extension", "controlled-turnaround", "small-controlled-eccentric-end-range", "no-lumbar-substitution"]},
				{exercise: {id: "assisted-slrdl"}, phase: "integration", role: "integration", sets: 2, reps: {min: 5, max: 8}, optional: true, intent: "Integrate femoral negotiation under a stable pelvis."},
				{exercise: {id: "copenhagen"}, phase: "core", role: "core", sets: 2, hold: {min: 10, max: 20}, constraints: ["short-lever", "hips-torso-stacked", "no-rib-flare", "no-pelvic-rotation", "no-hip-hike"]},
				{exercise: {id: "treadmill-walk"}, phase: "downregulation", role: "downregulation", sets: 1, intent: "Easy cyclical gait and circulation; no conditioning target.", constraints: ["easy-pace", "no-push-off-chasing", "stop-if-gait-degrades"]},
			]
			completion: {mechanicalFailureAllowed: false, compensationAllowed: false, requiresGaitReadout: true}
		},
		{
			kind: "anterior"
			objective: "Restore anterior hip, knee-extension, and rotational femoral capacity while maintaining pelvic and trunk organization."
			invariant: "Step-up, ATG split-squat, reverse-Nordic, and direct hip-flexion depth or load advance only while femoral, pelvic, and trunk constraints remain admitted."
			exposures: [
				{exercise: {id: "ankle-dorsiflexion"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 12}, intent: "Establish distal anterior control without fatigue."},
				{exercise: {id: "dead-bug"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 5, max: 8}, intent: "Establish anterior trunk-pelvis control."},
				{exercise: {id: "backward-walk"}, phase: "primer", role: "primer", sets: 1, optional: true, intent: "Low-cost backward locomotion or resisted backward walking to prepare knee extension without conditioning fatigue.", constraints: ["low-fatigue", "controlled-knee-track"]},
				{exercise: {id: "poliquin-step-up"}, phase: "primer", role: "primer", sets: 2, reps: {min: 5, max: 8}, intent: "Prime unilateral knee-extension control and expose femur-pelvis tracking before deeper loading.", constraints: ["pelvis-organized", "controlled-knee-track", "no-hip-hike"], stopOn: ["pelvic-position-loss", "uncontrolled-femoral-rotation"], progression: ["increase-clean-step-height", "reduce-hand-support", "add-external-load"]},
				{exercise: {id: "atg-split-squat"}, phase: "main", role: "primary", sets: 2, reps: {min: 5, max: 8}, intent: "Load deep unilateral knee flexion while testing rear-hip extension and cross-pelvic force transfer.", constraints: ["pelvis-organized", "controlled-knee-track", "rear-hip-extension-without-lumbar-extension"], stopOn: ["pelvic-position-loss", "lumbar-substitution", "uncontrolled-knee-or-femoral-rotation"], progression: ["increase-clean-rom", "reduce-front-foot-elevation-or-assistance", "add-external-load"]},
				{exercise: {id: "reverse-nordic"}, phase: "main", role: "primary", sets: 3, reps: {min: 5, max: 8}, constraints: ["hips-extended", "ribs-stacked", "pelvis-organized", "starting-knee-spacing-preserved", "no-lumbar-extension-for-depth"], stopOn: ["pelvic-position-loss", "lumbar-substitution", "uncontrolled-knee-separation-or-femoral-rotation"], progression: ["increase-clean-rom", "slow-eccentric", "improve-controlled-concentric-reversal", "add-external-load"]},
				{exercise: {id: "resisted-hip-flexion"}, phase: "main", role: "secondary", sets: 2, reps: {min: 6, max: 10}, intent: "Directly load hip flexion with cable, ankle attachment, or controlled foot-suspended resistance; active dorsiflexion may be coupled deliberately.", constraints: ["pelvis-organized", "ribs-stacked", "no-lumbar-arching", "controlled-eccentric", "no-momentum"], stopOn: ["pelvic-position-loss", "lumbar-substitution", "uncontrolled-pelvic-rotation"], progression: ["increase-clean-rom", "increase-reps", "increase-external-load"]},
				{exercise: {id: "curtsey-stepdown"}, phase: "integration", role: "integration", sets: 2, reps: {min: 5, max: 8}, intent: "Expose femoral rotation and frontal-plane control under a stable pelvis.", constraints: ["pelvis-organized", "controlled-knee-track"]},
				{exercise: {id: "assisted-slrdl"}, phase: "integration", role: "integration", sets: 2, reps: {min: 5, max: 8}, optional: true, intent: "Low-load cross-chain integration; keep session anterior-dominant."},
				{exercise: {id: "ghd-knee-to-chest"}, phase: "core", role: "core", sets: 2, reps: {min: 5, max: 8}, constraints: ["bent-knee-first", "hips-near-pad-edge", "ribs-down", "posterior-pelvic-curl-at-finish", "no-lumbar-arching"], progression: ["increase-controlled-rom", "increase-lever-length"]},
				{exercise: {id: "treadmill-walk"}, phase: "downregulation", role: "downregulation", sets: 1, intent: "Restore easy gait without adding loaded stretching."},
			]
			completion: {mechanicalFailureAllowed: false, compensationAllowed: false, requiresGaitReadout: true}
		},
		{
			kind: "distal-integrated"
			objective: "Increase foot-ankle and tibial control, then test whether corrected distal mechanics survive propagation through femur, pelvis, and trunk."
			invariant: "This is the lowest-load and highest-observation session; movement quality outranks fatigue."
			exposures: [
				{exercise: {id: "ankle-inversion-eversion"}, phase: "activation", role: "primary", sets: 2, reps: {min: 8, max: 12}, intent: "Direct distal adaptive exposure."},
				{exercise: {id: "calf-raise-neutral"}, phase: "main", role: "primary", sets: 2, reps: {min: 6, max: 10}, constraints: ["controlled-plantarflexion", "clean-foot-pressure-transition"]},
				{exercise: {id: "ankle-dorsiflexion"}, phase: "main", role: "secondary", sets: 2, reps: {min: 8, max: 12}},
				{exercise: {id: "assisted-slrdl"}, phase: "integration", role: "integration", sets: 2, reps: {min: 5, max: 8}, intent: "Test distal correction under unilateral proximal demand."},
				{exercise: {id: "curtsey-stepdown"}, phase: "integration", role: "integration", sets: 2, reps: {min: 5, max: 8}, optional: true},
				{exercise: {id: "cross-supported-bridge-march"}, phase: "core", role: "core", sets: 2, reps: {min: 5, max: 8}, intent: "Cross-chain trunk-pelvis integration."},
				{exercise: {id: "pallof-press"}, phase: "core", role: "core", sets: 2, reps: {min: 5, max: 8}, optional: true},
				{exercise: {id: "roman-chair-side-bend"}, phase: "core", role: "core", sets: 2, reps: {min: 5, max: 8}, optional: true, constraints: ["start-with-isometric-or-small-rom", "pelvis-fixed", "no-hip-hike"], progression: ["increase-rom", "then-add-load"]},
				{exercise: {id: "treadmill-walk"}, phase: "downregulation", role: "downregulation", sets: 1, intent: "Read heel loading, pronation, midstance, resupination, and push-off."},
				{exercise: {id: "backward-walk"}, phase: "downregulation", role: "downregulation", sets: 1, optional: true, intent: "Short diagnostic coordination dose, not conditioning."},
			]
			completion: {mechanicalFailureAllowed: false, compensationAllowed: false, requiresGaitReadout: true}
		},
	]

	transition: {
		sequence: ["posterior", "anterior", "distal-integrated"]
		fixedWeekdays: false
		recoveryGated: true
		posteriorRecoveryHours: {min: 48, max: 72}
		anteriorRecoveryHours: {min: 24, max: 48}
		distalRecoveryHours: {min: 24, max: 48}
		advanceOnlyInsideRecoveryBudget: true
	}

	observation: {
		mechanicalQualityRequired: true
		recoveryCostRequired: true
		partialRunsComparable: false
		progressOneDimensionAtATime: true
	}
}
