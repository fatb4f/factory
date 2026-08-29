package gym

#ExternalLoad: close({
	value: number & >=0
	unit:  #Unit
})

#Assistance: close({
	kind:  "band" | "counterweight" | "manual" | "none" | "other"
	level?: string
	load?: #ExternalLoad
})

#Dose: close({
	reps?:       int & >=0
	durationS?:  number & >=0
	externalLoad?: #ExternalLoad
	assistance?: #Assistance
	tempo?: close({
		eccentricS?:  number & >=0
		pauseS?:      number & >=0
		concentricS?: number & >=0
	})
})

#RangeObservation: close({
	stage: string
	estimatedFraction?: number & >=0 & <=1
	qualifier?: "clean" | "marginal" | "failed" | "unobserved"
})

#ConstraintObservation: close({
	key:   string
	state: #ConstraintState
	side?: #Side
	note?: string
})

#Limiter: close({
	region: string
	side?:  #Side
	kind?:  "force" | "fatigue" | "cramp" | "coordination" | "discomfort" | "unknown"
	onset?: "early" | "mid" | "late" | "terminal" | "unknown"
	relativeToOtherSide?: "earlier" | "similar" | "later" | "unknown"
})

#ExposureObservation: close({
	kind:       "exposure-observation"
	id:         #ObservationID
	session:    #SessionID
	exposure:   #ExposureID
	exercise:   #ExerciseRef
	sequence?:  int & >=1
	setup?: close({
		variant?:   string
		equipment?: string
		lever?:     string
		support?:   string
		note?:      string
	})
	dose?:        #Dose
	range?:       #RangeObservation
	constraints?: [...#ConstraintObservation]
	limiter?:     #Limiter
	measurements?: [...#MeasurementRef]
	media?:        [...#MediaRef]
	provenance:    #Provenance
})
