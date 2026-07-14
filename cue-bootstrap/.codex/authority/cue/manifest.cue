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

// Python extension generator identity. This does not define CUE semantics.
gopy: #GitObject & {
	repository: "https://github.com/go-python/gopy"
	commit:     "72557f647208599c726c14dc9721a6c850d2e6d9"
}

binding: close({
	engineModule:               "cuelang.org/go"
	targetEngineVersion:        cue.languageVersion
	targetEngineCommit:         cue.commit
	goBindingPackage:           "github.com/fatb4f/cue-bootstrap/runner/bindings"
	pythonExtensionGenerator:   "gopy"
	pythonObjectIdentity:       "managed-int64-handles"
	directModeEnabled:          true
	qualifiedWorkerRequired:    true
	goRunnerUsesTargetCheckout: true
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
	goLoadAPI: {
		path: "cue/load/instances.go"
		role: "supporting"
		symbols: ["load.Instances"]
	}
	goDiagnosticAPI: {
		path: "cue/errors/errors.go"
		role: "supporting"
		symbols: ["errors.Errors", "errors.Positions", "errors.Path"]
	}
}
