package agentcontextresolver

#EvalPlan: close({
	schema: "agent-context-resolver.eval-plan.v1"
	event:  #ObservedHookEvent
	evals: [#EvalObligation, ...#EvalObligation]
})

#EvalPlanFromIssue: close({
	event: #ObservedHookEvent
	issue: #ImplementationSliceIssue

	obligations: #IssueEvalObligations & {
		input: issue
	}

	plan: #EvalPlan & {
		schema: "agent-context-resolver.eval-plan.v1"
		event:  _event
		evals: [
			obligations.required.vet,
			for e in obligations.required.publicExports {e},
			for e in obligations.required.negativeChecks {e},
		]
	}

	let _event = event
})
