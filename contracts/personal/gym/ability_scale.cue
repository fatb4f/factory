package gym

#AbilityID: string
#AbilityRef: close({id: #AbilityID})
#ExerciseFamilyID: string
#ExerciseFamilyRef: close({id: #ExerciseFamilyID})
#MovementPatternID: string
#MovementPatternRef: close({id: #MovementPatternID})
#ScaleAxisID: string
#ScaleAxisRef: close({id: #ScaleAxisID})
#DemandChannelID: string
#DemandChannelRef: close({id: #DemandChannelID})

#MovementPlane: "sagittal" | "frontal" | "transverse" | "multiplanar"
#JointID: string
#JointMotionAction:
	"flexion" |
	"extension" |
	"dorsiflexion" |
	"plantarflexion" |
	"abduction" |
	"adduction" |
	"internal-rotation" |
	"external-rotation" |
	"translation" |
	"stabilization"

#CapacityAction:
	"flexion" |
	"extension" |
	"dorsiflexion" |
	"plantarflexion" |
	"abduction" |
	"adduction" |
	"internal-rotation" |
	"external-rotation" |
	"stabilization"

#ContractionMode: "eccentric" | "concentric" | "isometric" | "mixed" | "unobserved"
#PatternPhaseKind: "eccentric" | "concentric" | "isometric" | "transition" | "mixed"

// Joint motion describes what the joint is doing. It does not imply which
// capacity channel is producing or resisting that motion.
#JointMotion: close({
	joint:  #JointID
	action: #JointMotionAction
	side?:  #Side
})

// A demand channel describes the capacity being demanded. This deliberately
// differs from joint motion: knee extension motion can demand knee-flexion
// capacity eccentrically, as in a Nordic lowering phase.
#DemandChannel: close({
	id:     #DemandChannelID
	joint:  #JointID
	action: #CapacityAction
	mode?:  #ContractionMode
	side?:  #Side
})

#PatternPhase: close({
	id:           string
	kind:         #PatternPhaseKind
	motion:       [...#JointMotion]
	activeDemand: [...#DemandChannelRef]
})

#JointCouplingKind:
	"synergy" |
	"opposition" |
	"support" |
	"power-transfer" |
	"constraint" |
	"context-dependent"

#JointCoupling: close({
	kind:      #JointCouplingKind
	from:      #DemandChannelRef
	to:        #DemandChannelRef
	direction?: "proximal-to-distal" | "distal-to-proximal" | "bidirectional" | "context-dependent"
	source?:    string
	note?:      string
})

#MovementPattern: close({
	id:        #MovementPatternID
	label:     string
	plane:     #MovementPlane
	channels:  [...#DemandChannel] & [_, ...]
	phases:    [...#PatternPhase] & [_, ...]
	couplings?: [...#JointCoupling]
})

#ScaleAxisKind:
	"assistance" |
	"external-load" |
	"geometry" |
	"range" |
	"lever" |
	"limb-contribution" |
	"load-placement" |
	"tempo" |
	"volume" |
	"speed" |
	"resistance" |
	"stance" |
	"rotation" |
	"configuration"

#ScaleValueType: "number" | "ordinal" | "state"
#DifficultyEffect: "higher-is-harder" | "lower-is-harder" | "context-dependent" | "none"
#ScaleEffectRelation: "increase" | "decrease" | "transfer" | "access" | "redistribute" | "context-dependent"
#ScaleEffectBasis: "source-asserted" | "empirical" | "derived" | "unknown"

#DemandTargetKind:
	"joint-demand" |
	"movement-pattern" |
	"chain" |
	"region" |
	"mobility-requirement" |
	"stability-requirement" |
	"global-demand"

#DemandTarget: close({
	kind: #DemandTargetKind
	id:   string
})

// Scale effects describe what changing one programming variable does to the
// demand field. A transfer effect may identify both from and to targets.
#ScaleEffect: close({
	relation:   #ScaleEffectRelation
	target?:    #DemandTarget
	from?:      #DemandTarget
	to?:        #DemandTarget
	basis:      #ScaleEffectBasis
	source?:    string
	note?:      string
})

#ScaleAxis: close({
	id:               #ScaleAxisID
	label:            string
	kind:             #ScaleAxisKind
	valueType:        #ScaleValueType
	unit?:            #Unit
	difficultyEffect: #DifficultyEffect
	effects:          [...#ScaleEffect]
})

#ExerciseFamily: close({
	id:          #ExerciseFamilyID
	label:       string
	exercise?:   #ExerciseRef
	abilities:   [...#AbilityRef] & [_, ...]
	pattern:     #MovementPatternRef
	axes:        [...#ScaleAxis] & [_, ...]
	constraints?: [...string]
	sources?:     [...string]
})

#ScaleCoordinate: close({
	axis:       #ScaleAxisRef
	numeric?:   number
	state?:     string
	order?:     int & >=0
	unit?:      #Unit
	certainty?: #Certainty
})

#ScalePosition: close({
	family:      #ExerciseFamilyRef
	coordinates: [...#ScaleCoordinate] & [_, ...]
})

#NormalizationKind:
	"absolute" |
	"body-mass" |
	"contralateral-side" |
	"self-baseline" |
	"anchor-ability" |
	"movement-pattern"

// Every standard and cross-family capacity comparison must name its
// denominator/reference basis. Raw unlike exercise outputs are not a basis.
#NormalizationBasis: close({
	kind:          #NormalizationKind
	anchorAbility?: #AbilityRef
	anchorPattern?: #MovementPatternRef
	protocol?:      #ProtocolRef
	note?:          string
})

#DemandBasis: close({
	pattern:       #MovementPatternRef
	channels:      [...#DemandChannelRef] & [_, ...]
	normalization: #NormalizationBasis
})

#StandardPerformance: close({
	reps?:       int & >=0
	durationS?:  number & >=0
	load?:       #ExternalLoad
	state?:      string
})

#AbilityStandard: close({
	id:          string
	label:       string
	ability:     #AbilityRef
	family?:     #ExerciseFamilyRef
	position?:   #ScalePosition
	basis:       #DemandBasis
	performance?: #StandardPerformance
	constraints?: [...string]
	source:      string
})

#CapacityRelationKind:
	"agonist-antagonist" |
	"support" |
	"bilateral" |
	"joint-sharing" |
	"proximal-distal" |
	"pattern-balance" |
	"short-long-range"

#CapacityRelation: close({
	id:         string
	kind:       #CapacityRelationKind
	left:       #DemandBasis
	right:      #DemandBasis
	comparison: "ratio" | "difference" | "band" | "vector"
	source?:    string
	note?:      string
})
