package gym

#MechanicalObjectiveID: string
#MechanicalObjectiveRef: close({id: #MechanicalObjectiveID})
#MechanicalDemandID: string
#MechanicalDemandRef: close({id: #MechanicalDemandID})
#ContributorID: string
#ContributorRef: close({id: #ContributorID})
#MechanicalContributionID: string
#MechanicalContributionRef: close({id: #MechanicalContributionID})
#FunctionalGroupID: string
#FunctionalGroupRef: close({id: #FunctionalGroupID})

#MechanicalTargetKind: "com" | "segment" | "joint-dof"
#MechanicalQuantity:
	"force" |
	"moment" |
	"acceleration" |
	"angular-acceleration" |
	"power" |
	"impulse" |
	"stability-constraint"

#MechanicalEffectSign: "positive" | "negative" | "neutral" | "context-dependent"
#MechanicalRole:
	"support" |
	"stabilize" |
	"brake" |
	"propel" |
	"rotate" |
	"redirect" |
	"transfer" |
	"steer" |
	"clear" |
	"recover"

#ContributorKind:
	"muscle" |
	"muscle-group" |
	"passive-structure" |
	"skeletal-alignment" |
	"external-support" |
	"contralateral-limb" |
	"functional-aggregate"

#ContributionEvidenceClass:
	"direct-mechanical" |
	"model-derived" |
	"physiological" |
	"exercise-derived-proxy" |
	"qualitative-observation"

#DerivedSource: "measured" | "derived" | "estimated" | "imputed"

#Uncertainty: close({
	kind?:       "interval" | "score" | "qualitative"
	lower?:      number
	upper?:      number
	confidence?: number & >=0 & <=1
	note?:       string
})

#EvidenceLink: close({
	class:        #ContributionEvidenceClass
	sourceID:     string
	provider?:    string
	method?:      string
	modelVersion?: string
})

// Derived values never masquerade as observations. Provenance and evidence are
// part of the value contract so model, proxy, and measured state can coexist.
#DerivedScalar: close({
	value:       number
	unit?:       #Unit
	source:      #DerivedSource
	evidence:    [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
})

#MechanicalObjective: close({
	id:       #MechanicalObjectiveID
	label:    string
	movement: #MovementPatternRef
	phase:    string
	note?:    string
})

#MechanicalTarget: close({
	kind:  #MechanicalTargetKind
	id:    string
	dof?:  string
	side?: #Side
})

#DemandRequirement: close({
	value?: number
	min?:   number
	max?:   number
	unit?:  #Unit
})

// Demand is the mechanical requirement to be satisfied. DemandChannel remains
// a Tier-0 joint-action shorthand and may be linked through legacyChannel.
#MechanicalDemand: close({
	id:         #MechanicalDemandID
	objective:  #MechanicalObjectiveRef
	target:     #MechanicalTarget
	quantity:   #MechanicalQuantity
	plane?:     #MovementPlane
	axis?:      string
	direction?: string
	required?:  #DemandRequirement
	legacyChannel?: #DemandChannelRef
})

#MechanicalEffect: close({
	target:     #MechanicalTarget
	quantity:   #MechanicalQuantity
	sign:       #MechanicalEffectSign
	direction?: string
	magnitude?: #DerivedScalar
})

#Contributor: close({
	id:     #ContributorID
	label:  string
	kind:   #ContributorKind
	region?: #BodyRegionRef
	side?:   #Side
})

#ContributionTiming: close({
	phase:      string
	onset?:     number
	peak?:      number
	duration?:  number
	unit?:      #Unit
})

#MechanicalContribution: close({
	id:          #MechanicalContributionID
	movement:    #MovementPatternRef
	phase:       string
	contributor: #ContributorRef
	demand:      #MechanicalDemandRef
	effects:     [...#MechanicalEffect] & [_, ...]
	timing?:     #ContributionTiming
	contractionMode?: #ContractionMode
	evidence:    [...#EvidenceLink] & [_, ...]
	confidence?: number & >=0 & <=1
})

// Roles are contextual interpretations of mechanical effects, not intrinsic
// labels attached permanently to a contributor.
#MechanicalRoleAssignment: close({
	contribution: #MechanicalContributionRef
	role:         #MechanicalRole
	objective:    #MechanicalObjectiveRef
	interpretationRule?: string
	evidence:     [...#EvidenceLink] & [_, ...]
})

// Functional groups are disposable projections generated from qualifying
// contributions for a movement, phase, objective, and optional role set.
#FunctionalGroup: close({
	id:               #FunctionalGroupID
	movement:         #MovementPatternRef
	phase:            string
	objective:        #MechanicalObjectiveRef
	roles?:           [...#MechanicalRole]
	membershipRule:   string
	projectionVersion: string
})

#DemandTransformEffect: close({
	demand:      #MechanicalDemandRef
	relation:    #ScaleEffectRelation
	direction?:  string
	magnitude?:  #DerivedScalar
	confidence?: number & >=0 & <=1
})

#DemandTransformInteraction: close({
	axes:     [...#ScaleAxisRef] & [_, ...]
	context?: string
	effects:  [...#DemandTransformEffect] & [_, ...]
	evidence: [...#EvidenceLink] & [_, ...]
})

// A scale-axis intervention is modeled as a compositional transform over the
// demand field. interactions prevents coupled geometry/load effects from being
// silently treated as independent scalar changes.
#DemandTransform: close({
	axis:         #ScaleAxisRef
	context?:     string
	effects:      [...#DemandTransformEffect] & [_, ...]
	interactions?: [...#DemandTransformInteraction]
	evidence:     [...#EvidenceLink] & [_, ...]
})

#ProviderCapability:
	"kinematics" |
	"kinetics" |
	"force" |
	"emg" |
	"mechanical-contribution" |
	"scale-transform" |
	"normalization" |
	"comparison" |
	"projection"

#EvidenceProvider: close({
	id:           string
	kind:         "external-model" | "device" | "video" | "manual" | "analytics-runtime"
	adapter?:     string
	version?:     string
	capabilities: [...#ProviderCapability] & [_, ...]
	outputClass:  #ContributionEvidenceClass
})
