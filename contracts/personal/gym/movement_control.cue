package gym

// Movement control separates internal athlete state from imposed training inputs.
// Derived exposure/cost metrics are projections over both, not raw capture facts.

#VariableParty: "first-party" | "second-party" | "derived"

#DemandBand: "minimal" | "low" | "moderate" | "high" | "very-high" | "unknown"

#DemandEstimate: close({
	band:        #DemandBand
	score?:      number & >=0 & <=1
	confidence?: number & >=0 & <=1
	note?:       string
})

#ROMUnit: "deg" | "fraction"

#ROMRegion: "shortened" | "mid" | "lengthened" | "full" | "mixed" | "unknown"

#ROMWindow: close({
	axis:       string
	unit:       #ROMUnit
	start:      number
	end:        number
	region?:    #ROMRegion
	estimated?: bool
	note?:      string
})

#ROMIncrement: close({
	unit:  #ROMUnit
	value: number & >0
})

// ROM is an internal range property. Distinguish what is available, established,
// supported under the movement contract, demonstrated, targeted, and novel.
#ROMCapacity: close({
	available?:   #ROMWindow
	established?: #ROMWindow
	supported?:   #ROMWindow
	demonstrated?: #ROMWindow
	target?:      #ROMWindow
	novel?:       #ROMWindow
	progressionStep?: #ROMIncrement
})

#LandmarkKind: "mv" | "mev" | "mav-lower" | "mav-upper" | "mrv"

#LandmarkDomain: "local" | "support" | "integration" | "coordination" | "systemic" | "cognitive" | "effective"

#LandmarkEstimate: close({
	kind:       #LandmarkKind
	domain:     #LandmarkDomain
	metric:     string
	value:      number
	unit:       string
	confidence?: number & >=0 & <=1
	observations?: int & >=0
	note?:      string
})

#RIRTarget: close({
	min: number & >=0
	max: number & >=0
})

#FunctionalContext: "exercise" | "stance" | "gait" | "transition" | "carry" | "other"

#MovementPhase: "setup" | "eccentric" | "transition" | "concentric" | "isometric" | "terminal" | "stance" | "swing" | "other"

// A complex can change roles across phase, ROM, and functional context. A trunk
// complex acting as the driver is not equivalent to the same complex acting as
// the stabilizer/transmitter for another movement.
#ComplexRole: "driver" | "stabilizer" | "transmitter" | "brake" | "counterbalance" | "support" | "mixed" | "unknown"

#ComplexParticipation: close({
	complex:    string
	context:    #FunctionalContext
	phase:      #MovementPhase
	role:       #ComplexRole
	primary?:   bool
	adjacent?:  bool
	rom?:       #ROMWindow
	recruitment?: #DemandEstimate
	stability?:   #DemandEstimate
	coordination?: #DemandEstimate
	note?:      string
})

#IntegrationCostDriver: "rom" | "rom-novelty" | "role" | "role-transition" | "stability" | "adjacent-recruitment" | "coordination" | "lever" | "load" | "fatigue" | "breathing" | "other"

#IntegrationContract: close({
	participation: [...#ComplexParticipation]
	costDrivers?:  [...#IntegrationCostDriver]
	note?:         string
})

#TempoInput: close({
	eccentricS?:  number & >=0
	pauseS?:      number & >=0
	concentricS?: number & >=0
})

// Second-party variables are imposed externally by the prescription.
#SecondPartyInputs: close({
	sets?:           int & >=0
	repsPerSet?:     int & >=0
	restS?:          number & >=0
	frequencyPer7d?: number & >=0
	externalLoad?:   #ExternalLoad
	assistance?:     #Assistance
	tempo?:          #TempoInput
})

// First-party variables describe the internal movement/capacity state against
// which a prescription is executed.
#FirstPartyState: close({
	rom:                #ROMCapacity
	rirTarget?:         #RIRTarget
	qualityInvariants?: [...string]
	integration?:       #IntegrationContract
	landmarks?:         [...#LandmarkEstimate]
})

#DemandProfile: close({
	local?:        #DemandEstimate
	support?:      #DemandEstimate
	integration?:  #DemandEstimate
	coordination?: #DemandEstimate
	systemic?:     #DemandEstimate
	cognitive?:    #DemandEstimate
})

#CueSet: close({
	setup?:   [...string]
	motion?:  [...string]
	control?: [...string]
})

#FeedbackDomain: "rom" | "support" | "integration" | "effort" | "quality" | "fatigue" | "control" | "systemic" | "cognitive" | "symptom"

#FeedbackCadence: "continuous" | "threshold" | "per-rep" | "post-set" | "post-exercise" | "recovery"

#FeedbackValueKind: "boolean" | "ordinal" | "number" | "text" | "range" | "rir" | "failure"

#FeedbackSignalDefinition: close({
	id:        string
	domain:    #FeedbackDomain
	cadence:   #FeedbackCadence
	valueKind: #FeedbackValueKind
	prompt:    string
	required?: bool
	unit?:     string
	note?:     string
})

#FailureKind: "quality" | "support" | "integration" | "compensation" | "rom" | "effort" | "local" | "systemic" | "control" | "symptom-stop"

#FailureAction: "observe" | "regress-rom" | "regress-dose" | "stop-set" | "stop-exercise" | "stop-session" | "review"

#FailureCondition: close({
	id:       string
	kind:     #FailureKind
	action:   #FailureAction
	signals:  [...string]
	rom?:     #ROMWindow
	note?:    string
})

#ProgressionAxis: "rom" | "reps" | "sets" | "load" | "density" | "frequency" | "integration-complexity"

#ProgressionContract: close({
	allowedAxes:        [...#ProgressionAxis]
	preferredAxisOrder?: [...#ProgressionAxis]
	singleAxisDefault?: bool
	romStep?:           #ROMIncrement
	gates?:             [...string]
})

#MovementContract: close({
	id:       string
	exercise: #ExerciseRef
	intent:   string
	version?: string

	firstParty:  #FirstPartyState
	secondParty: #SecondPartyInputs
	integration?: #IntegrationContract
	demand?:      #DemandProfile
	cues:         #CueSet
	feedback:     [...#FeedbackSignalDefinition]
	failures:     [...#FailureCondition]
	progression?: #ProgressionContract
})

#ObservedComplexParticipation: close({
	complex:      string
	context?:     #FunctionalContext
	phase?:       #MovementPhase
	role?:        #ComplexRole
	rom?:         #ROMWindow
	recruitment?: #DemandEstimate
	stability?:   #DemandEstimate
	coordination?: #DemandEstimate
	note?:        string
})

#FeedbackObservation: close({
	signal: string
	boolValue?:   bool
	numberValue?: number
	textValue?:   string
	rangeValue?:  #ROMWindow
	note?:        string
})

#FailureObservation: close({
	kind:      #FailureKind
	action?:   #FailureAction
	atRep?:    int & >=1
	atROM?:    #ROMWindow
	phase?:    #MovementPhase
	note?:     string
})

// Candidate normalized observation surface. It is intentionally separate from
// #ExposureObservation until per-movement contracts are projected and capture
// migration is performed.
#MovementExecutionObservation: close({
	contract:      string
	actualROM?:    #ROMWindow
	rir?:          number & >=0
	quality?:      #DemandEstimate
	controlCost?:  #DemandEstimate
	integrationCost?: #DemandEstimate
	complexes?:    [...#ObservedComplexParticipation]
	feedback?:     [...#FeedbackObservation]
	failures?:     [...#FailureObservation]
})

#DerivedMetricKind: "effective-exposure" | "rom-novelty" | "integration-cost" | "systemic-demand" | "mrv-proximity" | "mev-proximity" | "rom-sensitivity" | "rep-sensitivity" | "load-sensitivity" | "support-threshold" | "recovery-cost"

#DerivedMetric: close({
	kind:       #DerivedMetricKind
	value:      number
	unit?:      string
	confidence?: number & >=0 & <=1
	basis?:     [...string]
})

#DerivedMovementState: close({
	metrics: [...#DerivedMetric]
})
