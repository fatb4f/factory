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

	_fragmentRefs: {for item in selected_fragments {(item.id): fragments[item.id].id}}
	_stepRefs: {for item in implementation_plan {(item.id): steps[item.id].id}}
	_checkRefs: {for item in checks {(item.id): checks[item.id].id}}
	_gateRefs: {for item in gates {(item.id): gates[item.id].id}}
}

output: {fragments: fragments, steps: steps, checks: checks, gates: gates, topology: topology}
