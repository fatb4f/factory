package gym

#AnkleDorsiflexionProfile: #ExerciseProfile & {
	id:                  "ankle-dorsiflexion"
	name:                "Ankle dorsiflexion"
	requiredConstraints: []
	rangeRequired:       false
	supportedMetrics:    ["reps"]
}

#AssistedSLRDLProfile: #ExerciseProfile & {
	id:   "assisted-slrdl"
	name: "Assisted single-leg Romanian deadlift"
	requiredConstraints: [
		"pelvic-control",
		"femoral-rotation-control",
	]
	rangeRequired:    false
	setupDimensions:  ["assistance", "stance-side"]
	supportedMetrics: ["reps"]
	videoPerspectives: ["front", "side", "oblique"]
}

#BackwardWalkProfile: #ExerciseProfile & {
	id:                  "backward-walk"
	name:                "Backward walk"
	requiredConstraints: []
	rangeRequired:       false
	setupDimensions:     ["surface", "resistance", "speed", "incline"]
	supportedMetrics:    ["duration", "distance"]
}

#DeadBugProfile: #ExerciseProfile & {
	id:   "dead-bug"
	name: "Dead bug"
	requiredConstraints: [
		"pelvic-control",
		"rib-flare-control",
	]
	rangeRequired:    false
	supportedMetrics: ["reps"]
}

#GHDKneeToChestProfile: #ExerciseProfile & {
	id:   "ghd-knee-to-chest"
	name: "GHD knee-to-chest"
	requiredConstraints: [
		"pelvic-control",
		"lumbar-substitution-avoided",
		"rib-flare-control",
	]
	rangeRequired:    false
	setupDimensions:  ["pad-position", "knee-angle"]
	supportedMetrics: ["reps", "hip-angle"]
	videoPerspectives: ["left-side", "right-side", "oblique"]
}

#HeelDigBridgeProfile: #ExerciseProfile & {
	id:   "heel-dig-bridge"
	name: "Heel-dig bridge"
	requiredConstraints: [
		"pelvic-control",
		"lumbar-substitution-avoided",
	]
	rangeRequired:    false
	supportedMetrics: ["duration"]
}

#PallofPressProfile: #ExerciseProfile & {
	id:   "pallof-press"
	name: "Pallof press"
	requiredConstraints: [
		"pelvic-rotation-control",
		"rib-flare-control",
	]
	rangeRequired:    false
	setupDimensions:  ["band-height", "band-tension", "stance"]
	supportedMetrics: ["reps", "duration"]
}

#RomanChairSideBendProfile: #ExerciseProfile & {
	id:   "roman-chair-side-bend"
	name: "Roman-chair side bend"
	requiredConstraints: [
		"pelvic-control",
		"hip-hike-control",
	]
	rangeRequired:    false
	setupDimensions:  ["pad-position", "side", "external-load"]
	supportedMetrics: ["reps", "duration"]
	videoPerspectives: ["front", "rear"]
}

#TreadmillWalkProfile: #ExerciseProfile & {
	id:                  "treadmill-walk"
	name:                "Treadmill walk"
	requiredConstraints: []
	rangeRequired:       false
	setupDimensions:     ["speed", "incline", "direction"]
	supportedMetrics:    ["duration", "distance"]
	videoPerspectives:   ["front", "rear", "left-side", "right-side"]
}

#EaglePoseProfile: #ExerciseProfile & {
	id:   "eagle-pose"
	name: "Eagle pose"
	requiredConstraints: ["pelvic-control", "femoral-rotation-control"]
	rangeRequired: false
	setupDimensions: ["stance-side", "support"]
	supportedMetrics: ["duration"]
	videoPerspectives: ["front", "rear"]
}

#StandingBowPoseProfile: #ExerciseProfile & {
	id:   "standing-bow-pose"
	name: "Standing Bow pose"
	requiredConstraints: ["pelvic-control", "femoral-rotation-control"]
	rangeRequired: false
	setupDimensions: ["stance-side", "support"]
	supportedMetrics: ["duration"]
	videoPerspectives: ["front", "side", "oblique"]
}

#BalancingStickPoseProfile: #ExerciseProfile & {
	id:   "balancing-stick-pose"
	name: "Balancing Stick pose"
	requiredConstraints: ["pelvic-control", "femoral-rotation-control"]
	rangeRequired: false
	setupDimensions: ["stance-side", "support"]
	supportedMetrics: ["duration"]
	videoPerspectives: ["front", "side", "oblique"]
}

#TrianglePoseProfile: #ExerciseProfile & {
	id:   "triangle-pose"
	name: "Triangle pose"
	requiredConstraints: ["pelvic-control", "femoral-rotation-control"]
	rangeRequired: false
	setupDimensions: ["lead-side", "stance-width"]
	supportedMetrics: ["duration"]
	videoPerspectives: ["front", "rear", "oblique"]
}

#FrogGluteBridgeProfile: #ExerciseProfile & {
	id:   "frog-glute-bridge"
	name: "Soles-together frog glute bridge"
	requiredConstraints: ["pelvic-control", "lumbar-substitution-avoided"]
	optionalConstraints: ["symmetric-outward-knee-pressure"]
	rangeRequired: false
	setupDimensions: ["knee-angle", "external-load"]
	supportedMetrics: ["reps"]
	videoPerspectives: ["front", "side"]
}

#CossackSquatProfile: #ExerciseProfile & {
	id:   "cossack-squat"
	name: "Cossack squat"
	requiredConstraints: ["pelvic-control", "femoral-rotation-control"]
	optionalConstraints: ["receiving-foot-control", "extended-leg-control"]
	rangeRequired: false
	setupDimensions: ["assistance", "external-load", "stance-width"]
	supportedMetrics: ["reps"]
	videoPerspectives: ["front", "rear", "oblique"]
}

#ModifiedStandingBowSLRDLProfile: #ExerciseProfile & {
	id:   "modified-standing-bow-slrdl"
	name: "Modified Standing-Bow single-leg Romanian deadlift"
	requiredConstraints: ["pelvic-control", "femoral-rotation-control", "lumbar-substitution-avoided"]
	optionalConstraints: ["stance-foot-control", "rear-leg-counterforce", "contralateral-reach-control"]
	rangeRequired: false
	setupDimensions: ["assistance", "stance-side", "external-load"]
	supportedMetrics: ["reps"]
	videoPerspectives: ["front", "side", "oblique"]
}

#RearDeltHighRowProfile: #ExerciseProfile & {
	id:   "rear-delt-high-row"
	name: "Rear-delt high row"
	requiredConstraints: ["neck-quiet", "controlled-scapular-excursion", "humeral-horizontal-abduction-control"]
	optionalConstraints: ["levator-not-dominant", "no-forced-retraction"]
	rangeRequired: false
	setupDimensions: ["machine", "attachment", "grip", "seat-position", "external-load"]
	supportedMetrics: ["reps", "load"]
	videoPerspectives: ["front", "rear", "oblique"]
}

#OverheadPressProfile: #ExerciseProfile & {
	id:   "overhead-press"
	name: "Overhead press"
	requiredConstraints: ["rib-flare-control", "neck-quiet", "scapular-upward-rotation-control", "humeral-centering-control"]
	optionalConstraints: ["no-forced-shoulder-depression"]
	rangeRequired: false
	setupDimensions: ["implement", "grip", "stance", "external-load"]
	supportedMetrics: ["reps", "load"]
	videoPerspectives: ["front", "side", "oblique"]
}

#LateralRaiseProfile: #ExerciseProfile & {
	id:   "lateral-raise"
	name: "Lateral raise"
	requiredConstraints: ["neck-quiet", "scapular-plane-control", "humeral-position-control"]
	optionalConstraints: ["no-shrug-dominance"]
	rangeRequired: false
	setupDimensions: ["implement", "body-support", "external-load"]
	supportedMetrics: ["reps", "load"]
	videoPerspectives: ["front", "rear"]
}

#YRaiseProfile: #ExerciseProfile & {
	id:   "y-raise"
	name: "Y raise"
	requiredConstraints: ["neck-quiet", "scapular-upward-rotation-control"]
	optionalConstraints: ["no-shrug-dominance"]
	rangeRequired: false
	setupDimensions: ["implement", "body-support", "external-load"]
	supportedMetrics: ["reps", "load"]
	videoPerspectives: ["front", "rear", "oblique"]
}

exerciseProfiles: close({
	ghr:                              #GHRProfile
	"reverse-hyper":                  #ReverseHyperProfile
	copenhagen:                       #CopenhagenProfile
	"reverse-nordic":                 #ReverseNordicProfile
	"atg-split-squat":                #ATGSplitSquatProfile
	"poliquin-step-up":               #PoliquinStepUpProfile
	"resisted-hip-flexion":           #ResistedHipFlexionProfile
	"curtsey-stepdown":               #CurtseyStepdownProfile
	"cross-supported-bridge-march":   #BridgeMarchProfile
	"ankle-inversion-eversion":       #AnkleInversionEversionProfile
	"calf-raise-neutral":             #CalfRaiseProfile
	"ankle-dorsiflexion":             #AnkleDorsiflexionProfile
	"assisted-slrdl":                 #AssistedSLRDLProfile
	"backward-walk":                  #BackwardWalkProfile
	"dead-bug":                       #DeadBugProfile
	"ghd-knee-to-chest":              #GHDKneeToChestProfile
	"heel-dig-bridge":                #HeelDigBridgeProfile
	"pallof-press":                   #PallofPressProfile
	"roman-chair-side-bend":          #RomanChairSideBendProfile
	"treadmill-walk":                 #TreadmillWalkProfile
	"eagle-pose":                     #EaglePoseProfile
	"standing-bow-pose":              #StandingBowPoseProfile
	"balancing-stick-pose":           #BalancingStickPoseProfile
	"triangle-pose":                  #TrianglePoseProfile
	"frog-glute-bridge":              #FrogGluteBridgeProfile
	"cossack-squat":                  #CossackSquatProfile
	"modified-standing-bow-slrdl":    #ModifiedStandingBowSLRDLProfile
	"rear-delt-high-row":             #RearDeltHighRowProfile
	"overhead-press":                 #OverheadPressProfile
	"lateral-raise":                  #LateralRaiseProfile
	"y-raise":                        #YRaiseProfile
})

// Registry identity is canonical: every key must equal the profile's own ID.
_exerciseProfileIdentity: [for key, profile in exerciseProfiles {
	_value: profile & {id: key}
}]

// Each exposure gets an independent non-empty lookup result. Do not emit the
// same _matches field repeatedly into one session struct: repeated fields unify
// in CUE and would incorrectly require all exercise profiles to be identical.
_triSessionExerciseIntegrityV1: [for session in ankleKneePelvisTriSessionV1.sessions {
	_exposures: [for exposure in session.exposures {
		_matches: [for key, profile in exerciseProfiles if key == exposure.exercise.id {
			profile & {id: key}
		}] & [_, ...]
	}]
}]

_triSessionExerciseIntegrityV2: [for session in ankleKneePelvisTriSessionV2.sessions {
	_exposures: [for exposure in session.exposures {
		_matches: [for key, profile in exerciseProfiles if key == exposure.exercise.id {
			profile & {id: key}
		}] & [_, ...]
	}]
}]
