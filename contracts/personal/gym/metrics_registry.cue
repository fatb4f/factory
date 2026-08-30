package gym

#MetricID: string
#MetricRef: close({id: #MetricID})

#MetricDomain:
	"capacity" |
	"mechanical-quality" |
	"range" |
	"symmetry" |
	"load-distribution" |
	"equilibrium" |
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
	"available-rom-stage": #Metric & {id: "available-rom-stage", label: "Available reference ROM stage", domain: "range", class: "raw", valueType: "stage", source: "direct-observation", direction: "none"}
	"controlled-rom-fraction": #Metric & {id: "controlled-rom-fraction", label: "Controlled fraction of available range", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "higher"}
	"rep-count": #Metric & {id: "rep-count", label: "Repetition count", domain: "capacity", class: "raw", valueType: "number", source: "direct-observation", direction: "higher"}
	"assistance-level": #Metric & {id: "assistance-level", label: "Assistance level", domain: "capacity", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"external-load": #Metric & {id: "external-load", label: "External load", domain: "capacity", class: "raw", valueType: "number", source: "direct-observation", direction: "higher"}
	"normalized-capacity-index": #Metric & {id: "normalized-capacity-index", label: "Protocol-relative admitted capacity index", domain: "capacity", class: "derived", valueType: "number", source: "derived", direction: "higher"}
	"eccentric-duration": #Metric & {id: "eccentric-duration", label: "Eccentric duration", domain: "temporal", class: "raw", valueType: "number", source: "video", unit: "s", direction: "target-range"}
	"mechanical-admission": #Metric & {id: "mechanical-admission", label: "Mechanical admission", domain: "mechanical-quality", class: "assessment", valueType: "state", source: "derived", direction: "none"}
	"constraint-state": #Metric & {id: "constraint-state", label: "Mechanical constraint state", domain: "mechanical-quality", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"limiter-onset": #Metric & {id: "limiter-onset", label: "Limiter onset", domain: "mechanical-quality", class: "raw", valueType: "state", source: "direct-observation", direction: "none"}
	"limiter-concentration": #Metric & {id: "limiter-concentration", label: "Limiter concentration across regions", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "lower"}
	"left-scale-load": #Metric & {id: "left-scale-load", label: "Left scale load", domain: "load-distribution", class: "raw", valueType: "number", source: "scale", direction: "none"}
	"right-scale-load": #Metric & {id: "right-scale-load", label: "Right scale load", domain: "load-distribution", class: "raw", valueType: "number", source: "scale", direction: "none"}
	"stance-asymmetry-ratio": #Metric & {id: "stance-asymmetry-ratio", label: "Signed stance asymmetry ratio", domain: "symmetry", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"stance-asymmetry-variability": #Metric & {id: "stance-asymmetry-variability", label: "Stance asymmetry variability", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "lower"}
	"bilateral-capacity-asymmetry": #Metric & {id: "bilateral-capacity-asymmetry", label: "Signed bilateral admitted-capacity asymmetry", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"reciprocal-capacity-ratio": #Metric & {id: "reciprocal-capacity-ratio", label: "Agonist-antagonist admitted-capacity ratio", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"anterior-posterior-capacity-ratio": #Metric & {id: "anterior-posterior-capacity-ratio", label: "Anterior-posterior admitted-capacity ratio", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"distal-proximal-capacity-ratio": #Metric & {id: "distal-proximal-capacity-ratio", label: "Distal-proximal admitted-capacity ratio", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"frontal-sagittal-capacity-ratio": #Metric & {id: "frontal-sagittal-capacity-ratio", label: "Frontal-sagittal admitted-capacity ratio", domain: "equilibrium", class: "derived", valueType: "number", source: "derived", direction: "target-range"}
	"inter-region-phase-lag": #Metric & {id: "inter-region-phase-lag", label: "Inter-region movement phase lag", domain: "temporal", class: "derived", valueType: "number", source: "derived", unit: "s", direction: "target-range"}
	"recovery-normalized-capacity-state": #Metric & {id: "recovery-normalized-capacity-state", label: "Capacity redistribution relative to recovery cost", domain: "equilibrium", class: "assessment", valueType: "state", source: "derived", direction: "none"}
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
	#MetricLineage & {metric: {id: "stance-asymmetry-ratio"}, inputs: [{id: "left-scale-load"}, {id: "right-scale-load"}], derivation: "(right-left)/(right+left); preserve sign"},
	#MetricLineage & {metric: {id: "stance-asymmetry-variability"}, inputs: [{id: "stance-asymmetry-ratio"}], derivation: "within-protocol variability across repeated stance samples"},
	#MetricLineage & {metric: {id: "normalized-capacity-index"}, inputs: [{id: "clean-rom-stage"}, {id: "rep-count"}, {id: "assistance-level"}, {id: "external-load"}, {id: "mechanical-admission"}], derivation: "protocol-relative normalization of the mechanically admitted capacity vector; never divide raw unlike exercise outputs"},
	#MetricLineage & {metric: {id: "bilateral-capacity-asymmetry"}, inputs: [{id: "normalized-capacity-index"}], derivation: "signed left-right asymmetry of comparable protocol-relative capacity indices"},
	#MetricLineage & {metric: {id: "reciprocal-capacity-ratio"}, inputs: [{id: "normalized-capacity-index"}], derivation: "ratio of comparable agonist and antagonist protocol-relative capacity indices"},
	#MetricLineage & {metric: {id: "anterior-posterior-capacity-ratio"}, inputs: [{id: "normalized-capacity-index"}], derivation: "ratio of baseline-normalized anterior and posterior admitted-capacity indices"},
	#MetricLineage & {metric: {id: "distal-proximal-capacity-ratio"}, inputs: [{id: "normalized-capacity-index"}], derivation: "ratio of baseline-normalized distal and proximal admitted-capacity indices"},
	#MetricLineage & {metric: {id: "frontal-sagittal-capacity-ratio"}, inputs: [{id: "normalized-capacity-index"}], derivation: "ratio of baseline-normalized frontal and sagittal admitted-capacity indices"},
	#MetricLineage & {metric: {id: "controlled-rom-fraction"}, inputs: [{id: "clean-rom-stage"}, {id: "available-rom-stage"}], derivation: "controlled range divided by matched available reference range under one protocol"},
	#MetricLineage & {metric: {id: "limiter-concentration"}, inputs: [{id: "limiter-onset"}], derivation: "concentration of first/terminal limiters across regions over comparable exposures"},
	#MetricLineage & {metric: {id: "recovery-normalized-capacity-state"}, inputs: [{id: "normalized-capacity-index"}, {id: "recovery-cost"}], derivation: "joint state comparison of capacity redistribution and recovery vector; no scalar recovery score implied"},
	#MetricLineage & {metric: {id: "energy-drop"}, inputs: [{id: "energy-available"}], derivation: "session baseline minus lowest recovery availability"},
	#MetricLineage & {metric: {id: "cognitive-drop"}, inputs: [{id: "cognitive-available"}], derivation: "session baseline minus lowest recovery availability"},
]
