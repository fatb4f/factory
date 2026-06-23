package factory

#CUEImplementationSlice: close({
	contract: {
		path:    string & !=""
		package: string & !=""
		slice:   string & !=""

		authority: {
			owns:       [...string & !=""]
			doesNotOwn: [...string & !=""]
		}

		boundaries: {
			adapters: {
				authority: false
				role:      "observe/project/execute declared behavior only"
			}
			generated: {
				authority: false
				role:      "downstream projection or materialized evidence only"
			}
			runtime: {
				authority: false
				role:      "external substrate, not contract truth"
			}
		}
	}

	rootQuestion: {
		id:   "N0.contract-question"
		text: "What CUE authority must exist so this state, transition, or projection is representable and checkable?"
	}

	primitives: [...{
		name:           string & !=""
		role:           string & !=""
		requiredFields: [...string & !=""]
		constraints:    [...string & !=""]
	}]

	surfaces: {
		admissible:    [...string & !=""]
		observed:      [...string & !=""]
		candidates:    [...string & !=""]
		fixtures:      [...string & !=""]
		checks:        [...string & !=""]
		publicExports: [...string & !=""]
	}

	constraints: {
		noVocabularyOnlyPatch:          true
		noDiagnosticBooleanAuthority:   true
		noReviewMetadataAsProof:        true
		noStringifiedEvalExpressions:   true
		noGeneratedArtifactAsAuthority: true
		noAdapterLocalPolicyAuthority:  true
		noShellOnlySemanticValidation:  true
		noSidePackageSprawl:            true
	}

	acceptanceCriteria: {
		rootQuestionAnsweredBeforeImplementation: true
		authorityBoundaryDeclared:                true
		primitiveModelDeclared:                   true
		admissibleSurfaceDeclared:                true
		validFixtureExports:                      true
		publicEvalSurfaceExports:                 true
		negativeFixturesBottomIfPresent:          true
		forbiddenAttractorSearchPasses:           true
		validationCommandsReported:               true
	}
})

#RunnerCommand: close({
	id:           string & !=""
	sourceEvalID: string & !=""
	command:      [string & !="", ...string & !=""]
	expect:       "pass" | "fail"
})

#EvalRunnerPlan: close({
	schema: "factory.eval-runner-plan.v1"

	sourcePlan: #EvalPlan & {
		evals: [#EvalObligation, ...#EvalObligation]
	}

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

let _forbiddenAttractorSelector = "\("bottom")CheckSurface|\("expression"):|\("expected")Bottom|\("is")Invalid|\("resolver")Staleness|\("go")GitObservation|\("factoryctl")Inspect"

#HookRunnerGate: close({
	schema: "factory.hook-runner-gate.v1"

	issue:          #CUEImplementationSlice
	runnerPlan:     #EvalRunnerPlan
	projection:     #GeneratedHookProjection
	publicExports:  [...string & !=""]
	negativeChecks: [...string & !=""]

	control: {
		action:    "admit" | "reject" | "defer" | "block"
		reason:    string & !=""
		evidence:  [...string & !=""]
		nextState: string & !=""
	}

	authority: {
		cue:       true
		adapters:  false
		generated: false
	}
})

hookRunnerImplementationSlice: #CUEImplementationSlice & {
	contract: {
		path:    "contracts/factory"
		package: "factory"
		slice:   "hook-eval-plan-runner"

		authority: {
			owns: [
				"normalized hook event contract",
				"eval-plan projection shape",
				"runner contract for command and expectation comparison",
				"generated hook adapter projection shape",
				"negative fixtures for runner authority violations",
			]
			doesNotOwn: [
				"resolver freshness policy",
				"go-git inspection implementation",
				"factoryctl implementation",
				"GitHub Projects mutation",
				"VCS mutation",
				"runtime semantics outside exported eval plans",
			]
		}
	}

	rootQuestion: {
		id:   "N0.contract-question"
		text: "What CUE authority must exist so this state, transition, or projection is representable and checkable?"
	}

	primitives: [
		{
			name: "EvalRunnerPlan"
			role: "admissible runner input derived from #EvalPlan"
			requiredFields: ["schema", "sourcePlan", "commands"]
			constraints: ["commands are non-empty", "commands are projected from sourcePlan.evals", "runner owns no semantics"]
		},
		{
			name: "RunnerCommand"
			role: "executable adapter command with expected outcome"
			requiredFields: ["id", "sourceEvalID", "command", "expect"]
			constraints: ["command is non-empty", "expect is pass or fail", "no shell-only semantic field"]
		},
		{
			name: "GeneratedHookProjection"
			role: "downstream hook adapter config projection"
			requiredFields: ["id", "target", "generatedFrom", "authority"]
			constraints: ["authority is false", "generatedFrom references the CUE eval-plan surface"]
		},
		{
			name: "ObservedRunnerResult"
			role: "observed execution result after adapter runs command"
			requiredFields: ["id", "commandID", "status"]
			constraints: ["observed result is evidence only", "observed result is not policy authority"]
		},
	]

	surfaces: {
		admissible: ["#EvalRunnerPlan", "#RunnerCommand", "#GeneratedHookProjection", "#ObservedRunnerResult"]
		observed: ["#ObservedHookEvent", "#ObservedRunnerResult"]
		candidates: ["hookEvalRunnerPlan", "hookGeneratedProjection", "hookRunnerGate"]
		fixtures: [
			"baselineHookEvalRunnerPlan",
			"hookRunnerNegativeFixtures.generatedProjectionAuthority",
			"hookRunnerNegativeFixtures.shellSemanticAuthority",
			"hookRunnerNegativeFixtures.emptyRunnerCommand",
			"hookRunnerNegativeFixtures.undeclaredRunnerCommand",
		]
		checks: [
			"_negativeBottomChecks.hookRunner.generatedProjectionAuthority",
			"_negativeBottomChecks.hookRunner.shellSemanticAuthority",
			"_negativeBottomChecks.hookRunner.emptyRunnerCommand",
			"_negativeBottomChecks.hookRunner.undeclaredRunnerCommand",
		]
		publicExports: ["hookTemplateEvalPlan", "hookEvalRunnerPlan", "hookGeneratedProjection", "hookRunnerGate"]
	}

	constraints: {
		noVocabularyOnlyPatch:          true
		noDiagnosticBooleanAuthority:   true
		noReviewMetadataAsProof:        true
		noStringifiedEvalExpressions:   true
		noGeneratedArtifactAsAuthority: true
		noAdapterLocalPolicyAuthority:  true
		noShellOnlySemanticValidation:  true
		noSidePackageSprawl:            true
	}

	acceptanceCriteria: {
		rootQuestionAnsweredBeforeImplementation: true
		authorityBoundaryDeclared:                true
		primitiveModelDeclared:                   true
		admissibleSurfaceDeclared:                true
		validFixtureExports:                      true
		publicEvalSurfaceExports:                 true
		negativeFixturesBottomIfPresent:          true
		forbiddenAttractorSearchPasses:           true
		validationCommandsReported:               true
	}
}

hookRunnerEvalPlan: #EvalPlan & {
	schema: "factory.eval-plan.v1"
	event:  baselineHookEvent
	evals: [
		{
			id:      "hook-runner.cue-vet"
			kind:    "cueVet"
			command: ["cue", "vet", "./contracts/factory"]
			expect:  "pass"
		},
		{
			id:      "hook-runner.export.hookTemplateEvalPlan"
			kind:    "cueExport"
			command: ["cue", "export", "./contracts/factory", "-e", "hookTemplateEvalPlan"]
			expect:  "pass"
		},
		{
			id:      "hook-runner.export.hookEvalRunnerPlan"
			kind:    "cueExport"
			command: ["cue", "export", "./contracts/factory", "-e", "hookEvalRunnerPlan"]
			expect:  "pass"
		},
		{
			id:      "hook-runner.export.hookGeneratedProjection"
			kind:    "cueExport"
			command: ["cue", "export", "./contracts/factory", "-e", "hookGeneratedProjection"]
			expect:  "pass"
		},
		{
			id:      "hook-runner.export.hookRunnerGate"
			kind:    "cueExport"
			command: ["cue", "export", "./contracts/factory", "-e", "hookRunnerGate"]
			expect:  "pass"
		},
		{
			id:      "hook-runner.bottom.generatedProjectionAuthority"
			kind:    "cueBottom"
			command: ["cue", "export", "./contracts/factory", "-e", "_negativeBottomChecks.hookRunner.generatedProjectionAuthority"]
			expect:  "fail"
		},
		{
			id:      "hook-runner.bottom.shellSemanticAuthority"
			kind:    "cueBottom"
			command: ["cue", "export", "./contracts/factory", "-e", "_negativeBottomChecks.hookRunner.shellSemanticAuthority"]
			expect:  "fail"
		},
		{
			id:      "hook-runner.bottom.emptyRunnerCommand"
			kind:    "cueBottom"
			command: ["cue", "export", "./contracts/factory", "-e", "_negativeBottomChecks.hookRunner.emptyRunnerCommand"]
			expect:  "fail"
		},
		{
			id:      "hook-runner.bottom.undeclaredRunnerCommand"
			kind:    "cueBottom"
			command: ["cue", "export", "./contracts/factory", "-e", "_negativeBottomChecks.hookRunner.undeclaredRunnerCommand"]
			expect:  "fail"
		},
		{
			id:      "hook-runner.forbidden-attractor-search"
			kind:    "grepAbsent"
			command: ["rg", _forbiddenAttractorSelector, "./contracts/factory"]
			expect:  "fail"
		},
	]
}

baselineHookEvalRunnerPlan: #EvalRunnerPlan & {
	schema:     "factory.eval-runner-plan.v1"
	sourcePlan: hookRunnerEvalPlan
}

hookEvalRunnerPlan: baselineHookEvalRunnerPlan

hookRunnerGate: #HookRunnerGate & {
	schema:     "factory.hook-runner-gate.v1"
	issue:      hookRunnerImplementationSlice
	runnerPlan: hookEvalRunnerPlan
	projection: hookGeneratedProjection
	publicExports: ["hookTemplateEvalPlan", "hookEvalRunnerPlan", "hookGeneratedProjection", "hookRunnerGate"]
	negativeChecks: [
		"_negativeBottomChecks.hookRunner.generatedProjectionAuthority",
		"_negativeBottomChecks.hookRunner.shellSemanticAuthority",
		"_negativeBottomChecks.hookRunner.emptyRunnerCommand",
		"_negativeBottomChecks.hookRunner.undeclaredRunnerCommand",
	]
	control: {
		action: "admit"
		reason: "runner and generated hook projection authority are declared in CUE and validated by export plus bottom checks"
		evidence: [
			"cue vet ./contracts/factory",
			"cue export ./contracts/factory -e hookEvalRunnerPlan",
			"cue export ./contracts/factory -e hookGeneratedProjection",
			"negative bottom checks under _negativeBottomChecks.hookRunner",
		]
		nextState: "thin adapter may execute exported runner commands and compare status to CUE-declared expectations"
	}
	authority: {
		cue:       true
		adapters:  false
		generated: false
	}
}
