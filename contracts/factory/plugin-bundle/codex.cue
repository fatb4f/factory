package pluginbundle

#CodexFile: close({
	path:      string & =~"^\\.codex/.+"
	generated: true
	source:    #NonEmptyString
})

#CodexHook: close({
	id:        #NonEmptyString
	command:   #NonEmptyString
	inputs:    [#NonEmptyString, ...#NonEmptyString]
	outputs:   [#NonEmptyString, ...#NonEmptyString]
	boundedBy: [#NonEmptyString, ...#NonEmptyString]
})

#CodexFragment: close({
	id:     #NonEmptyString
	source: #NonEmptyString
})

#CodexRuntime: close({
	root:      ".codex"
	files:     [#CodexFile, ...#CodexFile]
	hooks:     [...#CodexHook]
	fragments: [...#CodexFragment]
})

#AdmissibleCodexRuntime: close(#CodexRuntime)
