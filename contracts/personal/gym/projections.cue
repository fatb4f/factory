package gym

// These row contracts are qualification targets for generated projections.
// They are not independent semantic authority. The intended generation path is:
// CUE -> JSON Schema -> Pydantic -> projection policy -> Ibis/Malloy/storage.
projectionPolicy: close({
	authority: "derived-qualification-target"
	generationPath: ["cue", "json-schema", "pydantic", "projection-policy", "relational"]
})

#ExposureRow: close({
	sessionID:           #SessionID
	exposureID:          #ExposureID
	exerciseID:          #ExerciseID
	sequence?:           int & >=1
	reps?:               int & >=0
	loadValue?:          number & >=0
	loadUnit?:           #Unit
	assistanceKind?:     string
	assistanceLevel?:    string
	rangeStage?:         string
	rangeOrder?:         int & >=0
	mechanicalAdmission?: #MechanicalQualityState
	mechanicalAdmissionID?: #MechanicalAdmissionDecisionID
	limiterRegion?:      string
	limiterSide?:        #Side
	sourceObservationID: #ObservationID
})

#ConstraintRow: close({
	sessionID:           #SessionID
	exposureID:          #ExposureID
	exerciseID:          #ExerciseID
	constraintKey:       string
	state:               #ConstraintState
	side?:               #Side
	sourceObservationID: #ObservationID
})

#RecoveryRow: close({
	sessionID:          #SessionID
	recoveryID:         #RecoveryID
	elapsedHours?:      number & >=0
	energyAvailable?:   #Ordinal0to4
	cognitiveAvailable?: #Ordinal0to4
	taskInitiation?:    string
	sleepiness?:        string
	subjectiveRecovery?: string
	gait?:              #GaitState
})

#DomsRow: close({
	sessionID:    #SessionID
	recoveryID:   #RecoveryID
	elapsedHours?: number & >=0
	region:       string
	score:        #Ordinal0to5
})

#DualLoadRow: close({
	sessionID?:           #SessionID
	measurementID:        #MeasurementID
	left:                 number & >=0
	right:                number & >=0
	unit:                 #Unit
	total:                number & >=0
	differenceRightMinusLeft: number
	leftShare?:           number
	rightShare?:          number
	signedAsymmetryRatio?: number
	stance?:              string
	at?:                  #Timestamp
})

#VideoMetricRow: close({
	sessionID?:     #SessionID
	exposureID?:    #ExposureID
	exerciseID?:    #ExerciseID
	measurementID:  #MeasurementID
	mediaID:        #MediaID
	metric:         string
	metricKind:     #VideoMetricKind
	value:          number
	unit:           #Unit
	certainty:      #Certainty
	frameStart?:    int & >=0
	frameEnd?:      int & >=0
})

#IssueEvidenceRow: close({
	issueID:      #IssueID
	evidenceID:   #IssueEvidenceID
	relation:     #IssueEvidenceRelation
	sourceKind:   string
	sourceID:     string
	exerciseID?:  #ExerciseID
	side?:        #Side
	at?:          #Timestamp
})

#SessionAssessmentRow: close({
	sessionID:            #SessionID
	recoveryComplete:     bool
	recoveryLevel?:       #RecoveryCostLevel
	progressEligibility:  #ProgressEligibility
	checkpointCount?:     int & >=0
	energyDrop?:          #Ordinal0to4
	cognitiveDrop?:       #Ordinal0to4
	maxDoms?:             #Ordinal0to5
	recoveredByHours?:    number & >=0
})

#AdaptationDimensionRow: close({
	baselineSessionID: #SessionID
	currentSessionID:  #SessionID
	group:             "capacity" | "quality" | "recovery"
	metric:            string
	direction:         #Direction
	classification:    #AdaptationClass
})

#EquilibriumRow: close({
	programID:           #ProgramID
	equilibriumMetricID: #EquilibriumMetricID
	outputMetricID:      #MetricID
	state:               #EquilibriumObservationState
	value?:              number
	protocolID?:         #ProtocolID
	sourceCount:         int & >=1
	evaluatedAt?:        #Timestamp
})

#ProgramTargetRow: close({
	programID:   #ProgramID
	targetID:    #TargetID
	status:      "unmeasured" | "baselining" | "below-target" | "at-target" | "sustained" | "regressed" | "insufficient-evidence"
	evidenceCount: int & >=0
	latestNumber?: number
	latestState?:  string
	evaluatedAt?:  #Timestamp
})

// Evidence is relationally first-class. Domain rows never collapse a one-to-many
// evidence relation into a single source/class pair.
#EvidenceRow: close({
	evidenceID:   #EvidenceID
	class:        #EvidenceClass
	sourceID:     string
	providerID?:  #EvidenceProviderID
	method?:      string
	modelVersion?: string
	confidence?:  number & >=0 & <=1
	uncertaintyKind?:       "interval" | "score" | "qualitative"
	uncertaintyLower?:      number
	uncertaintyUpper?:      number
	uncertaintyConfidence?: number & >=0 & <=1
})

#ObjectEvidenceRow: close({
	objectKind: string
	objectID:   string
	evidenceID: #EvidenceID
	role:       #EvidenceRole
	ordinal?:   int & >=0
})

#MechanicalDemandRow: close({
	demandID:     #MechanicalDemandID
	objectiveID:  #MechanicalObjectiveID
	movementID:   #MovementPatternID
	phaseID:      #PatternPhaseID
	targetKind:   #MechanicalTargetKind
	targetID:     string
	dof?:         string
	quantity:     #MechanicalQuantity
	plane?:       #MovementPlane
	axis?:        string
	direction?:   string
	legacyChannelID?: #DemandChannelID
})

#MechanicalContributionRow: close({
	contributionID: #MechanicalContributionID
	movementID:     #MovementPatternID
	phaseID:        #PatternPhaseID
	contributorID:  #ContributorID
	demandID:       #MechanicalDemandID
	contractionMode?: #ContractionMode
	confidence?:    number & >=0 & <=1
})

#MechanicalRoleAssignmentRow: close({
	contributionID: #MechanicalContributionID
	objectiveID:    #MechanicalObjectiveID
	role:           #MechanicalRole
})

#MechanicalAdmissionRow: close({
	decisionID:   #MechanicalAdmissionDecisionID
	exposureID:   #ExposureID
	familyID:     #ExerciseFamilyID
	state:        #MechanicalAdmissionState
	patternID:    #MovementPatternID
	normalizationClass: #NormalizationKind
	grantID?:     #MechanicalAdmissionGrantID
})

#MechanicalAdmissionGrantRow: close({
	grantID:    #MechanicalAdmissionGrantID
	decisionID: #MechanicalAdmissionDecisionID
	exposureID: #ExposureID
	demandID:   #MechanicalDemandID
})

#NormalizedCapacityRow: close({
	capacityID:  #NormalizedCapacityID
	grantID:     #MechanicalAdmissionGrantID
	demandID:    #MechanicalDemandID
	value:       number
	unit?:       #Unit
	source:      #DerivedSource
	normalizationClass: #NormalizationKind
	normalizationProtocolID?: #ProtocolID
	uncertaintyKind?:       "interval" | "score" | "qualitative"
	uncertaintyLower?:      number
	uncertaintyUpper?:      number
	uncertaintyConfidence?: number & >=0 & <=1
})

#ComparisonAdmissionRow: close({
	decisionID: #ComparisonAdmissionDecisionID
	leftCapacityID:  #NormalizedCapacityID
	rightCapacityID: #NormalizedCapacityID
	state:      #ComparisonAdmissionState
	movementID: #MovementPatternID
	phaseID?:   #PatternPhaseID
	referenceVersion: string
	grantID?:   #ComparisonAdmissionGrantID
})

#ComparisonAdmissionGrantRow: close({
	grantID:    #ComparisonAdmissionGrantID
	decisionID: #ComparisonAdmissionDecisionID
	leftCapacityID:  #NormalizedCapacityID
	rightCapacityID: #NormalizedCapacityID
})

#ContributionDistributionRow: close({
	distributionID: #ContributionDistributionID
	movementID:     #MovementPatternID
	phaseID:        #PatternPhaseID
	demandID:       #MechanicalDemandID
	contributorID:  #ContributorID
	contributionID?: #MechanicalContributionID
	allocation?:    number
	projectionVersion: string
})

#CompensationObservationRow: close({
	observationID: #CompensationObservationID
	markerID:      #CompensationMarkerID
	movementID:    #MovementPatternID
	phaseID:       #PatternPhaseID
	side?:         #Side
	onset?:        number
	onsetUnit?:    #Unit
	peak?:         number
	peakUnit?:     #Unit
	integral?:     number
	integralUnit?: #Unit
	duration?:     number
	durationUnit?: #Unit
	deviationFromReference?:     number
	deviationFromReferenceUnit?: #Unit
	confidence?:   number & >=0 & <=1
})

#CompensationQualificationRow: close({
	observationID: #CompensationObservationID
	classification: #CompensationClassification
	qualifier?:     #CompensationQualifier
	policyVersion:  string
})

#FunctionalEquilibriumRow: close({
	programID?:    #ProgramID
	movementID:    #MovementPatternID
	phaseID:       #PatternPhaseID
	demandID:      #MechanicalDemandID
	residual:      number
	unit?:         #Unit
	distributionID?: #ContributionDistributionID
	compensationProjectionID?: #CompensationProjectionID
	projectionVersion: string
})

projectionRelations: close({
	exposures:             "#ExposureRow"
	constraints:           "#ConstraintRow"
	recovery:              "#RecoveryRow"
	doms:                  "#DomsRow"
	dualLoad:              "#DualLoadRow"
	videoMetrics:          "#VideoMetricRow"
	issueEvidence:         "#IssueEvidenceRow"
	sessionAssessments:    "#SessionAssessmentRow"
	adaptationDimensions:  "#AdaptationDimensionRow"
	equilibrium:           "#EquilibriumRow"
	programTargets:        "#ProgramTargetRow"
	evidence:              "#EvidenceRow"
	objectEvidence:        "#ObjectEvidenceRow"
	mechanicalDemands:     "#MechanicalDemandRow"
	mechanicalContributions: "#MechanicalContributionRow"
	mechanicalRoles:       "#MechanicalRoleAssignmentRow"
	mechanicalAdmissions:  "#MechanicalAdmissionRow"
	mechanicalAdmissionGrants: "#MechanicalAdmissionGrantRow"
	normalizedCapacities:  "#NormalizedCapacityRow"
	comparisonAdmissions:  "#ComparisonAdmissionRow"
	comparisonAdmissionGrants: "#ComparisonAdmissionGrantRow"
	contributionDistribution: "#ContributionDistributionRow"
	compensationObservations: "#CompensationObservationRow"
	compensationQualifications: "#CompensationQualificationRow"
	functionalEquilibrium: "#FunctionalEquilibriumRow"
})
