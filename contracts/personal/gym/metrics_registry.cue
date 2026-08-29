package gym

#MetricID: string
#MetricRef: close({id: #MetricID})

#MetricDomain:
	"capacity" |
	"mechanical-quality" |
	"range" |
	"symmetry" |
	"load-distribution" |
	"kinematic" |
	"temporal" |
	"movement" |
	"systemic-recovery"

#MetricClass: "raw" | "derived" | "assessment"
#MetricValueType: "number" | "ordinal" | "state" | "stage"
#MetricSource: "direct-observation" | "video" | "scale" | "derived"
#MetricDirection: "higher" | "lower" | "target-range" | "none"

#Metric: close({
	id:         #MetricID
	label:      string
	domain:     #MetricDomain
	class:      #MetricClass
	valueType:  #MetricValueType
	source:     #MetricSource
	unit?:      string
	direction?: #MetricDirection
})

#MetricLineage: close({
	metric:      #MetricRef
	inputs?:     [...#MetricRef]
	derivation?: string
})

metrics: close({
	"clean-rom-stage": #Metric & {id: "clean-rom-stage", label: "Highest clean ROM stage", domain: "range", class: "derived", valueType: "stage", source: "derived", direction: "higher"}
	"rep-count": #Metric & {id: "rep-count", label: "Repetition count", domain: "capacity", class: "raw", valueType: "number", source: "direct-observation", direction: "higher"}
	"assistance-level": #Metric & {id: "assistance-level", label: "Assistance level", domain: "capacity", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"external-load": #Metric & {id: "external-load", label: "External load", domain: "capacity", class: "raw", valueType: "number", source: "direct-observation", direction: "higher"}
	"eccentric-duration": #Metric & {id: "eccentric-duration", label: "Eccentric duration", domain: "temporal", class: "raw", valueType: "number", source: "video", unit: "s", direction: "target-range"}
	"mechanical-admission": #Metric & {id: "mechanical-admission", label: "Mechanical admission", domain: "mechanical-quality", class: "assessment", valueType: "state", source: "derived", direction: "none"}
	"constraint-state": #Metric & {id: "constraint-state", label: "Mechanical constraint state", domain: "mechanical-quality", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"limiter-onset": #Metric & {id: "limiter-onset", label: "Limiter onset", domain: "mechanical-quality", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"left-scale-load": #Metric & {id: "left-scale-load", label: "Left scale load", domain: "load-distribution", class: "raw", valueType: "number", source: "scale", direction: "none"}
	"right-scale-load": #Metric & {id: "right-scale-load", label: "Right scale load", domain: "load-distribution", class: "raw", valueType: "number", source: "scale", direction: "none"}
	"stance-asymmetry-ratio": #Metric & {id: "stance-asymmetry-ratio", label: "Signed stance asymmetry ratio", domain: "symmetry", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"gait-state": #Metric & {id: "gait-state", label: "Gait state", domain: "movement", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"ankle-push-off-state": #Metric & {id: "ankle-push-off-state", label: "Ankle push-off state", domain: "movement", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"energy-available": #Metric & {id: "energy-available", label: "Energy available", domain: "systemic-recovery", class: "raw", valueType: "ordinal", source: "direct-observation", direction: "higher"}
	"cognitive-available": #Metric & {id: "cognitive-available", label: "Cognitive availability", domain: "systemic-recovery", class: "raw", valueType: "ordinal", source: "direct-observation", direction: "higher"}
	"energy-drop": #Metric & {id: "energy-drop", label: "Energy drop", domain: "systemic-recovery", class: "derived", valueType: "ordinal", source: "derived", direction: "lower"}
	"cognitive-drop": #Metric & {id: "cognitive-drop", label: "Cognitive availability drop", domain: "systemic-recovery", class: "derived", valueType: "ordinal", source: "derived", direction: "lower"}
	"recovered-by-hours": #Metric & {id: "recovered-by-hours", label: "Recovered by elapsed hours", domain: "systemic-recovery", class: "derived", valueType: "number", source: "derived", unit: "h", direction: "lower"}
	"recovery-cost": #Metric & {id: "recovery-cost", label: "Recovery cost", domain: "systemic-recovery", class: "assessment", valueType: "state", source: "derived", direction: "none"}
})

metricLineage: [
	#MetricLineage & {metric: {id: "stance-asymmetry-ratio"}, inputs: [{id: "left-scale-load"}, {id: "right-scale-load"}], derivation: "(right-left)/(right+left)"},
	#MetricLineage & {metric: {id: "energy-drop"}, inputs: [{id: "energy-available"}], derivation: "session baseline minus lowest recovery availability"},
	#MetricLineage & {metric: {id: "cognitive-drop"}, inputs: [{id: "cognitive-available"}], derivation: "session baseline minus lowest recovery availability"},
]
