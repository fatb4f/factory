package kb

#ContextFragment: {
	id:          string
	description: string
	source: {
		path:   string
		symbol?: string
		lines?: {start: int & >=1, end: int & >=start}
	}
	selectors?:  [...string]
	depends_on?: {[string]: true}
	priority?:   int
}

fragments: workbook: #ContextFragment & {
	id:          "workbook"
	description: "CUE code-intelligence Marimo workbook"
	source: path: "../code_intel_cue.py"
	selectors: ["cue", "code-intel"]
	priority:  100
}
