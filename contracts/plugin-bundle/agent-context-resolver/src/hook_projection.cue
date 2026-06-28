package agentcontextresolver

#GeneratedHookProjection: close({
	schema: "agent-context-resolver.generated-hook-projection.v1"

	id:     string & !=""
	target: "tools/hooks/run-eval-plan.sh"

	generatedFrom: "resolverHookEvalRunnerPlan" | "resolverHookTemplateEvalPlan"
	authority:     false

	runnerPlan: #EvalRunnerPlan

	adapter: {
		role:      "execute declared behavior only"
		authority: false
	}

	mode?:    "0755"
	content?: string & !=""

	commands: [
		for c in runnerPlan.commands {
			{
				id:     c.id
				argv:   c.command
				expect: c.expect
			}
		},
	]
})
