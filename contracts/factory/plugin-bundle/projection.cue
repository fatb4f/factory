package pluginbundle

#Renderer: close({
	kind: "cue-export" | "template" | "copy"
})

#AdapterTarget: close({
	adapter:       "codex" | "generic"
	path:          #NonEmptyString
	definesPolicy: false
})

#Projection: close({
	id:            #NonEmptyString
	from:          #NonEmptyString
	to:            #AdapterTarget
	renderer:      #Renderer
	deterministic: *true | true
})
