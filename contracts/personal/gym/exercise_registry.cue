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

exerciseProfiles: close({
	ghr:                              #GHRProfile
	"reverse-hyper":                  #ReverseHyperProfile
	copenhagen:                       #CopenhagenProfile
	"reverse-nordic":                 #ReverseNordicProfile
	"curtsey-stepdown":               #CurtseyStepdownProfile
	"cross-supported-bridge-march":   #BridgeMarchProfile
	"ankle-inversion-eversion":       #AnkleInversionEversionProfile
	"calf-raise-neutral":             #CalfRaiseProfile
	"ankle-dorsiflexion":            #AnkleDorsiflexionProfile
	"assisted-slrdl":                 #AssistedSLRDLProfile
	"backward-walk":                  #BackwardWalkProfile
	"dead-bug":                       #DeadBugProfile
	"ghd-knee-to-chest":              #GHDKneeToChestProfile
	"heel-dig-bridge":                #HeelDigBridgeProfile
	"pallof-press":                   #PallofPressProfile
	"roman-chair-side-bend":          #RomanChairSideBendProfile
	"treadmill-walk":                 #TreadmillWalkProfile
})

_triSessionExerciseIntegrity: [for session in ankleKneePelvisTriSessionV1.sessions {
	for exposure in session.exposures {
		_matches: [for id, profile in exerciseProfiles if id == exposure.exercise.id {
			profile & {id: id}
		}] & [_, ...]
	}
}]
