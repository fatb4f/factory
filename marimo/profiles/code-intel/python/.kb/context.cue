package kb

#ContextFragment: close({
	id:          string & !=""
	description: string & !=""
	source: close({
		path:   string & !=""
		symbol?: string & !=""
		lines?: close({start: int & >=1, end: int & >=start})
	})
	selectors?:  [...string]
	depends_on?: {[string]: true}
	priority?:   int
})

fragments: workbook: #ContextFragment & {
	id:          "workbook"
	description: "Python code-intelligence Marimo workbook boundary"
	source: path: "../code_intel_python.py"
	selectors: ["python", "code-intel", "workbook"]
	priority: 100
}

#PlanStep: close({
	id:          string & !=""
	description: string & !=""
	depends_on?: {[string]: true}
	fragments?:  {[string]: true}
	checks?:     {[string]: true}
	gates?:      {[string]: true}
})

steps: inspect_python: #PlanStep & {
	id:          "inspect_python"
	description: "Inspect Python-specific context before implementation"
	fragments: {workbook: true}
	checks: {references_admitted: true}
	gates: {execution_admitted: true}
}

#Check: close({
	id:          string & !=""
	description: string & !=""
	command?:    string & !=""
	depends_on?: {[string]: true}
})

checks: references_admitted: #Check & {
	id:          "references_admitted"
	description: "Every packet reference resolves to an admitted Python declaration"
}

#Gate: close({
	id:          string & !=""
	description: string & !=""
	requires:    {[string]: true}
})

gates: execution_admitted: #Gate & {
	id:          "execution_admitted"
	description: "Python implementation is admitted after reference validation"
	requires: {references_admitted: true}
}

output: close({
	fragments: fragments
	steps:     steps
	checks:    checks
	gates:     gates
})
