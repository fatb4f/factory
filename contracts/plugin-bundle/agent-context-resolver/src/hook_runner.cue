package agentcontextresolver

#RunnerCommand: close({
	id:           string & !=""
	sourceEvalID: string & !=""
	command: [string & !="", ...string & !=""]
	expect:       "pass" | "fail"
	reasonClass?: "structural_bottom" | "missing_selector" | "load_error" | "syntax_error" | "tool_failure"
})

#EvalRunnerPlan: close({
	schema: "agent-context-resolver.eval-runner-plan.v1"

	sourcePlan: #EvalPlan

	commands: [
		for e in sourcePlan.evals {
			#RunnerCommand & {
				id:           e.id
				sourceEvalID: e.id
				command:      e.command
				expect:       e.expect
			}
		},
	]

	authority: {
		cue:     true
		runner:  false
		shell:   false
		adapter: false
	}
})

#ObservedRunnerResult: close({
	id:        string & !=""
	commandID: string & !=""
	status:    int

	evidence: {
		authority: false
		role:      "observed execution result only"
	}
})
