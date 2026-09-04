package gym

#TriSessionPhaseV2: "activation" | "primer" | "main" | "integration" | "core" | "upper" | "downregulation"
#TriSessionRoleV2: "activation-gate" | "primer" | "primary" | "secondary" | "integration" | "core" | "upper-strength" | "downregulation"

#SessionExercisePrescriptionV2: close({
	exercise: #ExerciseRef
	phase:    #TriSessionPhaseV2
	role:     #TriSessionRoleV2
	sets?:    int & >=1
	reps?:    #RepRange
	hold?:    #HoldRangeSeconds
	optional?: bool
	assistance?: string
	selectionGroup?: string
	intent?:     string
	constraints?: [...string]
	stopOn?:      [...string]
	progression?: [...string]
})

#ExposureSelectionGroupV2: close({
	id:            string
	minSelections: int & >=0
	maxSelections: int & >=1
	candidates:    [...#ExerciseRef] & [_, ...]
})

#LoadedExposureBudgetV2: close({
	maxLowerWorkingExposures: int & >=0
	maxUpperWorkingExposures: int & >=0
})

#TriSessionTemplateV2: close({
	kind:      #TriSessionKind
	objective: string
	invariant: string
	exposures: [...#SessionExercisePrescriptionV2]
	selectionGroups?: [...#ExposureSelectionGroupV2]
	budget: #LoadedExposureBudgetV2
	completion?: close({
		mechanicalFailureAllowed?: bool
		compensationAllowed?:      bool
		requiresGaitReadout?:      bool
	})
})

#RecoveryCalibrationV2: close({
	posteriorLastObservedHours: int & >=1
	anteriorLastObservedHours:  int & >=1
	distalIntegratedStatus:     string
})

#TriSessionTransitionPolicyV2: close({
	sequence: [#TriSessionKind, #TriSessionKind, #TriSessionKind]
	fixedWeekdays: bool
	recoveryGated: bool
	hardNoTrainingDuringRecovery: bool
	timeAloneAdmitsNextSession: bool
	cognitiveRecoveryRequired: bool
	upperWorkCreatesSeparateSession: bool
	recoveryCalibration: #RecoveryCalibrationV2
	advanceOnlyInsideRecoveryBudget: bool
})

#TriSessionObservationPolicyV2: close({
	mechanicalQualityRequired: bool
	recoveryCostRequired: bool
	cognitiveCostRequired: bool
	partialRunsComparable: bool
	progressOneDimensionAtATime: bool
	exerciseCountIncreaseRequiresStableChain: bool
	upperProgressionRequiresQuietNeckShoulder: bool
})

#TriSessionProgramV2: close({
	id:       string
	supersedes: string
	program:  #ProgramRef
	version:  string
	status:   "draft" | "baselining" | "active" | "hold" | "retired"
	invariant: string
	sessions: [#TriSessionTemplateV2, #TriSessionTemplateV2, #TriSessionTemplateV2]
	transition:  #TriSessionTransitionPolicyV2
	observation: #TriSessionObservationPolicyV2
})

ankleKneePelvisTriSessionV2: #TriSessionProgramV2 & {
	id:         "ankle-knee-pelvis-tri-session-v2"
	supersedes: "ankle-knee-pelvis-tri-session-v1"
	program:    {id: "ankle-knee-pelvis-stability"}
	version:    "v2"
	status:     "baselining"
	invariant:  "Preserve lower-chain organization and academic/cognitive recovery while adding only the minimum loaded exposure required to build capacity."

	sessions: [
		{
			kind: "posterior"
			objective: "Maintain the irreducible posterior-chain foundation while adding one posterior-shoulder strength exposure without creating a separate recovery domain."
			invariant: "GHR, reverse hyper, and Copenhagen remain the posterior foundation; optional lower-chain integration does not enter while the chain is still reorganizing materially between sessions."
			budget: {maxLowerWorkingExposures: 3, maxUpperWorkingExposures: 1}
			exposures: [
				{exercise: {id: "ankle-inversion-eversion"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 10}, intent: "Make distal control available without fatigue."},
				{exercise: {id: "calf-raise-neutral"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 10}, constraints: ["ankle-neutral", "no-calf-burn"], intent: "Establish plantar-flexor output without creating a working-set exposure."},
				{exercise: {id: "heel-dig-bridge"}, phase: "activation", role: "activation-gate", sets: 1, hold: {min: 10, max: 15}, intent: "Acquire hamstring tension before long-lever loading.", constraints: ["graded-tension", "no-cramping"]},
				{exercise: {id: "cross-supported-bridge-march"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 5, max: 6}, intent: "Establish low-cost trunk-pelvis control."},
				{exercise: {id: "reverse-hyper"}, phase: "primer", role: "primer", sets: 1, reps: {min: 6, max: 10}, intent: "Very-light proximal posterior-chain primer only.", constraints: ["very-light-load", "pelvis-organized", "no-lumbar-swing", "stop-before-fatigue"]},
				{exercise: {id: "ghr"}, phase: "main", role: "primary", sets: 3, reps: {min: 5, max: 8}, assistance: "enough-to-preserve-control", constraints: ["ankle-neutral", "femoral-position-organized", "hamstring-acquired-before-rep", "hips-torso-stacked", "pelvis-neutral", "slow-eccentric", "no-lumbar-rescue"], stopOn: ["pelvic-rotation-or-tilt", "lumbar-takeover", "delayed-hamstring-acquisition", "gastroc-cramp-threat", "medial-hamstring-cramp-threat", "femoral-control-loss"], progression: ["increase-clean-eccentric-rom", "reduce-assistance", "increase-reps-or-load"]},
				{exercise: {id: "reverse-hyper"}, phase: "main", role: "secondary", sets: 3, reps: {min: 8, max: 12}, constraints: ["hip-driven-extension", "controlled-turnaround", "small-controlled-eccentric-end-range", "no-lumbar-substitution"]},
				{exercise: {id: "copenhagen"}, phase: "core", role: "core", sets: 2, hold: {min: 10, max: 20}, constraints: ["short-lever", "hips-torso-stacked", "no-rib-flare", "no-pelvic-rotation", "no-hip-hike"]},
				{exercise: {id: "rear-delt-high-row"}, phase: "upper", role: "upper-strength", sets: 2, reps: {min: 8, max: 12}, intent: "Seated cable-row rear-delt high row: Y attachment, pronated hands, elbows out, hands drawn toward sternum. Start around 3-4 RIR.", constraints: ["neck-quiet", "levator-not-dominant", "controlled-scapular-excursion", "humeral-horizontal-abduction-controlled", "no-forced-retraction"], stopOn: ["neck-or-levator-tension-rises", "sternal-tension-rises", "humeral-position-lost"], progression: ["increase-repeatable-reps", "increase-load-with-same-neck-and-scapular-state"]},
				{exercise: {id: "treadmill-walk"}, phase: "downregulation", role: "downregulation", sets: 1, intent: "Easy gait readout and circulation only.", constraints: ["easy-pace", "stop-if-gait-degrades"]},
			]
			completion: {mechanicalFailureAllowed: false, compensationAllowed: false, requiresGaitReadout: true}
		},
		{
			kind: "anterior"
			objective: "Maintain the irreducible anterior-chain foundation while adding one global shoulder press exposure inside the same recovery event."
			invariant: "ATG split squat, reverse Nordic, and resisted hip flexion remain the anterior foundation; rotational accessories do not accumulate while chain reorganization remains high."
			budget: {maxLowerWorkingExposures: 3, maxUpperWorkingExposures: 1}
			exposures: [
				{exercise: {id: "ankle-dorsiflexion"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 12}, intent: "Establish distal anterior control without fatigue."},
				{exercise: {id: "dead-bug"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 5, max: 8}, intent: "Establish anterior trunk-pelvis control."},
				{exercise: {id: "backward-walk"}, phase: "primer", role: "primer", sets: 1, optional: true, intent: "Low-cost backward locomotion only when it improves knee-extension organization.", constraints: ["low-fatigue", "controlled-knee-track"]},
				{exercise: {id: "poliquin-step-up"}, phase: "primer", role: "primer", sets: 1, reps: {min: 5, max: 8}, intent: "Measurement/primer surface, not an additional hard quad exposure.", constraints: ["pelvis-organized", "controlled-knee-track", "no-hip-hike"]},
				{exercise: {id: "atg-split-squat"}, phase: "main", role: "primary", sets: 2, reps: {min: 5, max: 8}, intent: "Load deep unilateral knee flexion, dorsiflexion, rear-hip extension tolerance, and cross-pelvic transfer.", constraints: ["pelvis-organized", "controlled-knee-track", "rear-hip-extension-without-lumbar-extension"], stopOn: ["pelvic-position-loss", "lumbar-substitution", "uncontrolled-knee-or-femoral-rotation"], progression: ["increase-clean-rom", "reduce-front-foot-elevation-or-assistance", "add-external-load"]},
				{exercise: {id: "reverse-nordic"}, phase: "main", role: "primary", sets: 3, reps: {min: 4, max: 8}, constraints: ["hips-extended", "ribs-stacked", "pelvis-organized", "starting-knee-spacing-preserved", "no-lumbar-extension-for-depth"], stopOn: ["pelvic-position-loss", "lumbar-substitution", "uncontrolled-knee-separation-or-femoral-rotation"], progression: ["increase-clean-rom", "slow-eccentric", "improve-controlled-concentric-reversal", "add-external-load"]},
				{exercise: {id: "resisted-hip-flexion"}, phase: "core", role: "core", sets: 2, reps: {min: 5, max: 10}, intent: "Required loaded anterior core/hip-flexor exposure; cable or controlled foot-suspended implementation.", constraints: ["pelvis-organized", "ribs-stacked", "no-lumbar-arching", "controlled-eccentric", "no-momentum"], stopOn: ["pelvic-position-loss", "lumbar-substitution", "uncontrolled-pelvic-rotation"], progression: ["increase-clean-rom", "increase-reps", "increase-external-load"]},
				{exercise: {id: "overhead-press"}, phase: "upper", role: "upper-strength", sets: 2, reps: {min: 6, max: 10}, intent: "Moderate-load shoulder press, initially around 3-4 RIR. The objective is global shoulder strength with clean scapular upward rotation, not maximal pressing output.", constraints: ["neck-quiet", "ribs-stacked", "scapular-upward-rotation-controlled", "humeral-centering-controlled", "no-forced-shoulder-depression"], stopOn: ["neck-or-levator-tension-rises", "sternal-tension-rises", "internal-rotation-bias-increases", "humeral-centering-lost"], progression: ["increase-repeatable-reps", "increase-load-only-with-unchanged-neck-and-shoulder-state"]},
				{exercise: {id: "treadmill-walk"}, phase: "downregulation", role: "downregulation", sets: 1, intent: "Easy gait readout without adding loaded stretching."},
			]
			completion: {mechanicalFailureAllowed: false, compensationAllowed: false, requiresGaitReadout: true}
		},
		{
			kind: "distal-integrated"
			objective: "Use the smallest integration dose that tests whether A/B adaptations can coexist, while avoiding a third large lower-chain perturbation."
			invariant: "Program C is deliberately sparse: low-cost distal state setting, one glute-adductor cooperation primer, exactly one principal integration family, one lateral-shoulder strength exposure, then gait readout."
			budget: {maxLowerWorkingExposures: 2, maxUpperWorkingExposures: 1}
			selectionGroups: [{id: "c-primary-integration", minSelections: 1, maxSelections: 1, candidates: [{id: "cossack-squat"}, {id: "modified-standing-bow-slrdl"}]}]
			exposures: [
				{exercise: {id: "backward-walk"}, phase: "primer", role: "primer", sets: 1, optional: true, intent: "Short locomotor entry only when it improves distal organization.", constraints: ["easy-pace", "no-conditioning-target"]},
				{exercise: {id: "ankle-inversion-eversion"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 12}, intent: "Make frontal-plane distal control available without consuming the session budget."},
				{exercise: {id: "ankle-dorsiflexion"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 12}, intent: "Prepare active dorsiflexion without fatigue."},
				{exercise: {id: "calf-raise-neutral"}, phase: "activation", role: "activation-gate", sets: 1, reps: {min: 8, max: 10}, intent: "Prepare plantar-flexion/push-off without chasing fatigue."},
				{exercise: {id: "frog-glute-bridge"}, phase: "integration", role: "integration", sets: 1, reps: {min: 8, max: 12}, intent: "Low-dose glute-adductor cooperation primer before the selected principal integration family.", constraints: ["soles-together", "knees-near-90-degrees", "active-outward-knee-drive", "symmetric-pelvis", "no-lumbar-extension-substitution"]},
				{exercise: {id: "cossack-squat"}, phase: "main", role: "primary", sets: 2, reps: {min: 5, max: 8}, optional: true, selectionGroup: "c-primary-integration", assistance: "as-needed-for-clean-range", intent: "Selected when frontal-plane/adductor negotiation is the higher-signal integration surface.", constraints: ["receiving-foot-organized", "controlled-knee-track", "pelvis-organized", "extended-leg-position-controlled"], stopOn: ["foot-collapse", "uncontrolled-knee-or-femoral-rotation", "pelvic-position-loss"], progression: ["increase-clean-rom", "reduce-assistance", "increase-reps", "add-external-load"]},
				{exercise: {id: "modified-standing-bow-slrdl"}, phase: "main", role: "primary", sets: 2, reps: {min: 5, max: 8}, optional: true, selectionGroup: "c-primary-integration", assistance: "enough-to-preserve-whole-body-organization", intent: "Selected when unilateral hinge, stance-hip lateral control, and contralateral integration are the higher-signal surface.", constraints: ["stance-foot-organized", "controlled-knee-track", "pelvis-organized", "rear-leg-active", "contralateral-reach-controlled", "no-lumbar-rescue"], stopOn: ["stance-foot-collapse", "uncontrolled-femoral-rotation", "pelvic-hike-or-rotation", "trunk-escape", "lumbar-substitution"], progression: ["increase-clean-range", "reduce-assistance", "increase-reps", "add-external-load"]},
				{exercise: {id: "lateral-raise"}, phase: "upper", role: "upper-strength", sets: 2, reps: {min: 10, max: 15}, intent: "Direct lateral-delt capacity in a comfortable scapular-plane path, initially around 3-4 RIR.", constraints: ["neck-quiet", "scapular-plane-controlled", "no-shrug-dominance", "humeral-position-controlled"], stopOn: ["neck-or-levator-tension-rises", "sternal-tension-rises", "humeral-position-lost"], progression: ["increase-repeatable-reps", "increase-load-with-same-neck-and-scapular-state"]},
				{exercise: {id: "treadmill-walk"}, phase: "downregulation", role: "downregulation", sets: 1, intent: "Final gait readout; no conditioning target.", constraints: ["easy-pace", "stop-if-gait-degrades"]},
			]
			completion: {mechanicalFailureAllowed: false, compensationAllowed: false, requiresGaitReadout: true}
		},
	]

	transition: {
		sequence: ["posterior", "anterior", "distal-integrated"]
		fixedWeekdays: false
		recoveryGated: true
		hardNoTrainingDuringRecovery: true
		timeAloneAdmitsNextSession: false
		cognitiveRecoveryRequired: true
		upperWorkCreatesSeparateSession: false
		recoveryCalibration: {posteriorLastObservedHours: 72, anteriorLastObservedHours: 48, distalIntegratedStatus: "provisional-unbaselined"}
		advanceOnlyInsideRecoveryBudget: true
	}

	observation: {
		mechanicalQualityRequired: true
		recoveryCostRequired: true
		cognitiveCostRequired: true
		partialRunsComparable: false
		progressOneDimensionAtATime: true
		exerciseCountIncreaseRequiresStableChain: true
		upperProgressionRequiresQuietNeckShoulder: true
	}
}
