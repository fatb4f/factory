package gym

#VideoMetricKind:
	"joint-angle" |
	"segment-angle" |
	"rom-landmark" |
	"rep-duration" |
	"eccentric-duration" |
	"concentric-duration" |
	"velocity" |
	"symmetry" |
	"custom"

#VideoMetricProjection: close({
	media:       #MediaRef
	measurement: #MeasurementRef
	metricKind:  #VideoMetricKind
	exercise?:   #ExerciseRef
	exposure?:   #ExposureRef
	frameStart?: int & >=0
	frameEnd?:   int & >=0
	note?:       string
})
