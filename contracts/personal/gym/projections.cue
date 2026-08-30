package gym

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
	mechanicalAdmissionID?: #MechanicalAdmissionID
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

// Mechanical semantic projections. These are deliberately relational and
// stable enough to map directly into Ibis/DuckDB/BigQuery and Malloy models.
#MechanicalDemandRow: close({
	demandID:     #MechanicalDemandID
	objectiveID:  #MechanicalObjectiveID
	movementID:   #MovementPatternID
	phase:        string
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
	phase:          string
	contributorID:  #ContributorID
	demandID:       #MechanicalDemandID
	contractionMode?: #ContractionMode
	confidence?:    number & >=0 & <=1
	evidenceClass:  #ContributionEvidenceClass
	sourceID:       string
})

#MechanicalRoleAssignmentRow: close({
	contributionID: #MechanicalContributionID
	objectiveID:    #MechanicalObjectiveID
	role:           #MechanicalRole
})

#MechanicalAdmissionRow: close({
	admissionID: #MechanicalAdmissionID
	exposureID:  #ExposureID
	familyID:    #ExerciseFamilyID
	state:       #MechanicalAdmissionState
	patternID:   #MovementPatternID
	evidenceCount: int & >=1
})

#NormalizedCapacityRow: close({
	capacityID:  #NormalizedCapacityID
	admissionID: #MechanicalAdmissionID
	patternID:   #MovementPatternID
	value:       number
	unit?:       #Unit
	source:      #DerivedSource
	normalizationClass: #NormalizationKind
	referenceVersion: string
})

#ContributionDistributionRow: close({
	distributionID: #ContributionDistributionID
	movementID:     #MovementPatternID
	phase:          string
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
	phase:         string
	side?:         #Side
	peak?:         number
	duration?:     number
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
	phase:         string
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
	mechanicalDemands:     "#MechanicalDemandRow"
	mechanicalContributions: "#MechanicalContributionRow"
	mechanicalRoles:       "#MechanicalRoleAssignmentRow"
	mechanicalAdmissions:  "#MechanicalAdmissionRow"
	normalizedCapacities:  "#NormalizedCapacityRow"
	contributionDistribution: "#ContributionDistributionRow"
	compensationObservations: "#CompensationObservationRow"
	compensationQualifications: "#CompensationQualificationRow"
	functionalEquilibrium: "#FunctionalEquilibriumRow"
})
