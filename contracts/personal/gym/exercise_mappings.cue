package gym

exerciseMappings: [...#ExerciseMapping] & [
	{
		exercise: {id: "ghr"}
		primaryChains: [{id: "posterior-chain"}]
		constraintInterfaces: [{id: "trunk-pelvis"}]
		controllableDimensions: ["range", "assistance", "reps", "eccentric-duration"]
		observableMetrics: [{id: "clean-rom-stage"}, {id: "rep-count"}, {id: "assistance-level"}, {id: "constraint-state"}, {id: "mechanical-admission"}, {id: "eccentric-duration"}]
	},
	{
		exercise: {id: "reverse-hyper"}
		primaryChains: [{id: "posterior-chain"}]
		secondaryChains: [{id: "trunk-pelvis"}]
		controllableDimensions: ["external-load", "range", "reps", "tempo"]
		observableMetrics: [{id: "external-load"}, {id: "rep-count"}, {id: "constraint-state"}, {id: "mechanical-admission"}]
	},
	{
		exercise: {id: "reverse-nordic"}
		primaryChains: [{id: "anterior-knee-hip"}]
		constraintInterfaces: [{id: "trunk-pelvis"}]
		controllableDimensions: ["range", "assistance", "reps", "eccentric-duration"]
		observableMetrics: [{id: "clean-rom-stage"}, {id: "rep-count"}, {id: "constraint-state"}, {id: "mechanical-admission"}, {id: "eccentric-duration"}]
	},
	{
		exercise: {id: "curtsey-stepdown"}
		primaryChains: [{id: "anterior-knee-hip"}, {id: "frontal-pelvic"}]
		secondaryChains: [{id: "distal-foot-ankle"}]
		constraintInterfaces: [{id: "trunk-pelvis"}]
		controllableDimensions: ["range", "step-height", "hand-support", "external-load", "reps"]
		observableMetrics: [{id: "clean-rom-stage"}, {id: "rep-count"}, {id: "constraint-state"}, {id: "mechanical-admission"}, {id: "limiter-onset"}]
	},
	{
		exercise: {id: "copenhagen"}
		primaryChains: [{id: "frontal-pelvic"}]
		constraintInterfaces: [{id: "trunk-pelvis"}]
		controllableDimensions: ["lever-length", "support", "reps", "duration"]
		observableMetrics: [{id: "rep-count"}, {id: "constraint-state"}, {id: "mechanical-admission"}, {id: "limiter-onset"}]
	},
	{
		exercise: {id: "cross-supported-bridge-march"}
		primaryChains: [{id: "trunk-pelvis"}]
		secondaryChains: [{id: "contralateral-cross-support"}, {id: "posterior-chain"}]
		controllableDimensions: ["support-side", "reps", "duration"]
		observableMetrics: [{id: "rep-count"}, {id: "constraint-state"}, {id: "mechanical-admission"}]
	},
	{
		exercise: {id: "ankle-inversion-eversion"}
		primaryChains: [{id: "distal-foot-ankle"}]
		controllableDimensions: ["band-tension", "range", "reps", "tempo"]
		observableMetrics: [{id: "rep-count"}, {id: "constraint-state"}, {id: "limiter-onset"}]
	},
	{
		exercise: {id: "calf-raise-neutral"}
		primaryChains: [{id: "distal-foot-ankle"}]
		secondaryChains: [{id: "global-stance-support"}]
		controllableDimensions: ["bilateral-unilateral", "range", "external-load", "reps"]
		observableMetrics: [{id: "clean-rom-stage"}, {id: "rep-count"}, {id: "external-load"}, {id: "constraint-state"}]
	},
]
