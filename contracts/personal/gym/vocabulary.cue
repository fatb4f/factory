package gym

#SessionID: string
#ExposureID: string
#ObservationID: string
#RecoveryID: string
#IssueID: string
#MediaID: string
#DeviceID: string
#Timestamp: string

#Side: "left" | "right" | "bilateral" | "midline"
#Certainty: "direct" | "approximate"
#Presence: "present" | "absent" | "unobserved"
#ConstraintState: "met" | "marginal" | "failed" | "unobserved"
#AvailabilityState: "available" | "restricted" | "unobserved"
#GaitState: "normal" | "altered" | "unobserved"

#Ordinal0to4: int & >=0 & <=4
#Ordinal0to5: int & >=0 & <=5

#SourceKind:
	"user-statement" |
	"video" |
	"scale" |
	"device" |
	"import"

#Unit:
	"lb" |
	"kg" |
	"n" |
	"s" |
	"ms" |
	"deg" |
	"cm" |
	"m" |
	"m/s" |
	"ratio" |
	"percent" |
	string

#MetricKind:
	"load" |
	"body-mass" |
	"force" |
	"duration" |
	"angle" |
	"distance" |
	"velocity" |
	"custom"

#ObservationRef: close({
	id: #ObservationID
})

#MediaRef: close({
	id: #MediaID
})

#Provenance: close({
	sourceKind: #SourceKind
	certainty:  #Certainty
	capturedAt: #Timestamp
	deviceID?:  #DeviceID
	media?:     #MediaRef
	note?:      string
})
