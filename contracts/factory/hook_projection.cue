package factory

#GeneratedHookProjection: close({
	schema: "factory.generated-hook-projection.v1"

	id:     string & !=""
	target: "generated/hooks/claude/settings.json" | "tools/hooks/run-eval-plan.sh"

	generatedFrom: "hookEvalRunnerPlan" | "hookTemplateEvalPlan"
	authority:     false

	runnerPlan: #EvalRunnerPlan

	adapter: {
		role:      "execute declared behavior only"
		authority: false
	}

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

hookGeneratedProjection: #GeneratedHookProjection & {
	schema:        "factory.generated-hook-projection.v1"
	id:            "generated-hook-projection.claude.eval-runner"
	target:        "tools/hooks/run-eval-plan.sh"
	generatedFrom: "hookEvalRunnerPlan"
	authority:     false
	runnerPlan:    hookEvalRunnerPlan
	adapter: {
		role:      "execute declared behavior only"
		authority: false
	}
}
