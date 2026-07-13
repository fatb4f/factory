package authority

#GitObject: close({
	repository: string & !=""
	commit:     string & =~"^[0-9a-f]{40}$"
})

cue: #GitObject & {
	repository: "https://github.com/cue-lang/cue"
	commit:     "806821e40fae070318600a264d311517e596353b"
}

cuePy: #GitObject & {
	repository: "https://github.com/cue-lang/cue-py"
	commit:     "81e6fb15247ed7050e5bd987db032f757e06c8f0"
}

libcue: #GitObject & {
	repository: "https://github.com/cue-lang/libcue"
	commit:     "96d0572450429fa28d7a2345c04a8c47c85b47e4"
}

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
