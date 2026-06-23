package factory

hookRunnerNegativeFixtures: {
	generatedProjectionAuthority: {
		input: {
			schema:        "factory.generated-hook-projection.v1"
			id:            "bad.generated-hook-projection-authority"
			target:        "generated/hooks/claude/settings.json"
			generatedFrom: "hookEvalRunnerPlan"
			authority:     true
			runnerPlan:    hookEvalRunnerPlan
			adapter: {
				role:      "execute declared behavior only"
				authority: false
			}
		}
	}

	shellSemanticAuthority: {
		input: {
			schema:     "factory.eval-runner-plan.v1"
			sourcePlan: hookTemplateEvalPlan
			commands: [
				for e in hookTemplateEvalPlan.evals {
					{
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
			shellSemanticPolicy: {
				claimedBy: "runner"
			}
		}
	}

	emptyRunnerCommand: {
		input: {
			id:           "bad.empty-runner-command"
			sourceEvalID: "bad.empty-runner-command"
			command:      []
			expect:       "pass"
		}
	}

	undeclaredRunnerCommand: {
		input: {
			schema: "factory.eval-runner-plan.v1"
			sourcePlan: #EvalPlan & {
				schema: "factory.eval-plan.v1"
				event:  baselineHookEvent
				evals: [{
					id:      "declared.cue-vet"
					kind:    "cueVet"
					command: ["cue", "vet", "./contracts/factory"]
					expect:  "pass"
				}]
			}
			commands: [{
				id:           "undeclared.runner-command"
				sourceEvalID: "undeclared.runner-command"
				command:      ["cue", "export", "./contracts/factory", "-e", "hookRunnerGate"]
				expect:       "pass"
			}]
			authority: {
				cue:     true
				runner:  false
				shell:   false
				adapter: false
			}
		}
	}
}
