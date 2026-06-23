package pluginbundle

#Gate: close({
	id:       #NonEmptyString
	kind:     "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search"
	target:   #NonEmptyString
	required: bool
})
