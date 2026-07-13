package authority

#GitObject: close({
	repository: string & !=""
	commit:     string & =~"^[0-9a-f]{40}$"
})

#CueTarget: close({
	repository:      string & !=""
	commit:          string & =~"^[0-9a-f]{40}$"
	languageVersion: "v0.18.0"
	releaseLine:     "v0.18"
	channel:         "development"
})

// Primary semantic authority and engine target.
cue: #CueTarget & {
	repository:      "https://github.com/cue-lang/cue"
	commit:          "806821e40fae070318600a264d311517e596353b"
	languageVersion: "v0.18.0"
	releaseLine:     "v0.18"
	channel:         "development"
}

// Python binding source identity. This does not define the semantic engine.
cuePy: #GitObject & {
	repository: "https://github.com/cue-lang/cue-py"
	commit:     "81e6fb15247ed7050e5bd987db032f757e06c8f0"
}

// Native binding source identity. Upstream currently declares CUE v0.15.3;
// bootstrap rebases its Go module onto the exact v0.18 target above.
libcue: #GitObject & {
	repository: "https://github.com/cue-lang/libcue"
	commit:     "96d0572450429fa28d7a2345c04a8c47c85b47e4"
}

binding: close({
	engineModule:                 "cuelang.org/go"
	targetEngineVersion:          cue.languageVersion
	targetEngineCommit:           cue.commit
	upstreamLibcueEngineVersion:  "v0.15.3"
	libcueEngineRebindRequired:   true
	goRunnerUsesTargetCheckout:   true
	cuePyUsesReboundLibcue:        true
})

sources: {
	languageSpec: {
		path:       "doc/ref/spec.md"
		gitBlobSHA: "6a6e6fd631d96e7025e0e16cc9b54eaa6a5baa6a"
		role:       "normative"
		sections: ["Values", "Unification", "Bounds"]
	}
	goValueAPI: {
		path: "cue/types.go"
		role: "supporting"
		symbols: ["Value.Unify", "Value.Subsume", "Value.Validate", "Value.Err"]
	}
	pythonValueAPI: {
		path: "cue/value.py"
		role: "supporting"
		symbols: ["Value.unify", "Value.check_schema", "Value.validate", "Value.error"]
	}
}
