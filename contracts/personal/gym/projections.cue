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
	mechanicalAdmission?: #MechanicalAdmission
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
})
