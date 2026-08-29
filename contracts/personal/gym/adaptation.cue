package gym

#AdaptationDimension: close({
	group:     "capacity" | "quality" | "recovery"
	metric:    string
	direction: #Direction
})

#AdaptationClass:
	"dominates-previous" |
	"mixed" |
	"equivalent" |
	"dominated-by-previous" |
	"insufficient-evidence"

#AdaptationComparison: close({
	baselineSession: #SessionID
	currentSession:  #SessionID
	dimensions:      [...#AdaptationDimension]
	classification:  #AdaptationClass
	note?:           string
})
