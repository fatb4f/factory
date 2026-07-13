package authority

#GitObject: close({
	repository: string & !=""
	commit:     string & =~"^[0-9a-f]{40}$"
})

cue: #GitObject & {
	repository: "https://github.com/cue-lang/cue"
	commit:     "829b565633abb51541be4f8b7ad6d3372c689d2d"
}

cuePy: #GitObject & {
	repository: "https://github.com/cue-lang/cue-py"
	commit:     "81e6fb15247ed7050e5bd987db032f757e06c8f0"
}

libcue: #GitObject & {
	repository:    "https://github.com/cue-lang/libcue"
	commit:        "96d0572450429fa28d7a2345c04a8c47c85b47e4"
	engineModule:  "cuelang.org/go"
	engineVersion: "v0.15.3"
}

sources: {
	languageSpec: {
		path:       "doc/ref/spec.md"
		gitBlobSHA: "846d5d8dae3d4eed96e649b0f8125661ace77c35"
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
