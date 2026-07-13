package boundedint

#Fixture: close({
	id:       string & !=""
	class:    "positive" | "negative" | "directional"
	path:     string & !=""
	valuePath: string & !=""
})

fixtures: [
	{id: "bounded-int.positive.min", class: "positive", path: "positive/min.cue", valuePath: "value"},
	{id: "bounded-int.positive.mid", class: "positive", path: "positive/mid.cue", valuePath: "value"},
	{id: "bounded-int.positive.max", class: "positive", path: "positive/max.cue", valuePath: "value"},
	{id: "bounded-int.negative.below", class: "negative", path: "negative/below.cue", valuePath: "value"},
	{id: "bounded-int.negative.above", class: "negative", path: "negative/above.cue", valuePath: "value"},
	{id: "bounded-int.negative.wrong-type", class: "negative", path: "negative/wrong_type.cue", valuePath: "value"},
	{id: "bounded-int.directional.general", class: "directional", path: "directional/general.cue", valuePath: "value"},
	{id: "bounded-int.directional.bounded", class: "directional", path: "directional/bounded.cue", valuePath: "value"},
	{id: "bounded-int.directional.specific", class: "directional", path: "directional/specific.cue", valuePath: "value"},
]
