package kb

#WorkbookRequest: {
	prompt: string & !=""
	scope?: {boundaries?: [...string], selectors?: [...string], paths?: [...string]}
	budget: {maxFragments: int & >=1, maxSteps: int & >=1, maxTokens: int & >=1}
}

#CheckResult: {id: string, status: "pending" | "pass" | "fail" | "blocked", reason?: string, evidence?: [...string]}
#GateResult: {id: string, satisfied: bool, reason: string}

#WorkbookResult: {
	request: #WorkbookRequest
	selected_fragments: [...{id: string, source: #ContextFragment.source, content: string, reason: string}]
	implementation_plan: [...{id: string, description: string, depends_on: [...string], fragments: [...string], checks: [...string], gates: [...string]}]
	checks: [...#CheckResult]
	gates:  [...#GateResult]
	unresolved_context: [...{description: string, reason: string}]
}

let OutputFragments = fragments
let OutputSteps = steps
let OutputChecks = checks
let OutputGates = _validatedGates
let OutputContext = context
let OutputWorkflow = workflow

output: {
	fragments: OutputFragments
	steps:     OutputSteps
	checks:    OutputChecks
	gates:     OutputGates
	context:   OutputContext
	workflow:  OutputWorkflow
	topology:  OutputWorkflow.topology
}
