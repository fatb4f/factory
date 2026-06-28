package agentcontextresolver

baselineResolverHookTemplateIssue: #ImplementationSliceIssue & {
	kind: "cueImplementationSlice"

	contract: {
		path:    "contracts/agent-context-resolver"
		package: "agentcontextresolver"
		slice:   "hook-template-eval-authority-relocation"

		authority: {
			owns: [
				"hook event shape",
				"issue-template intent shape",
				"eval obligation derivation",
				"eval plan derivation",
				"runner plan derivation",
				"generated hook projection descriptors",
				"resolver-local hook template fixtures",
				"resolver-local negative bottom checks",
			]
			doesNotOwn: [
				"runtime execution",
				"shell semantic policy",
				"tools hook adapter implementation details",
				"factory root promotion semantics",
				"resolver freshness policy",
				"go-git observation",
				"factoryctl inspect or apply",
				"VCS mutation",
				"GitHub Projects mutation",
				"Claude, Codex, or git hook installation",
			]
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
	}

	rootQuestion: {
		id:   "N0.contract-question"
		text: "What CUE authority must exist so this state, transition, or projection is representable and checkable?"
	}

	primitives: [
		{
			name: "ObservedHookEvent"
			role: "normalized observed hook event fact"
			requiredFields: ["source", "event", "cwd"]
			constraints: ["observations carry no semantic authority", "adapter-local policy is inadmissible"]
		},
		{
			name: "ImplementationSliceIssue"
			role: "typed issue-template implementation intent"
			requiredFields: ["contract.path", "contract.package", "contract.slice", "contract.authority.owns", "contract.authority.doesNotOwn", "surfaces.publicExports", "surfaces.checks"]
			constraints: ["represents issue-template intent", "projected runtime and adapters remain authority false"]
		},
		{
			name: "IssueEvalObligations"
			role: "derived obligations from implementation-slice intent"
			requiredFields: ["input", "required.vet", "required.publicExports", "required.negativeChecks"]
			constraints: ["vet derives from contract path", "exports derive from publicExports", "bottom checks derive from checks"]
		},
		{
			name: "EvalPlanFromIssue"
			role: "candidate eval plan derived from issue intent and observed hook event"
			requiredFields: ["event", "issue", "plan"]
			constraints: ["plan evals derive from issue obligations", "adapter event cannot define semantic policy"]
		},
		{
			name: "EvalRunnerPlan"
			role: "runner-facing command plan derived from #EvalPlan"
			requiredFields: ["schema", "sourcePlan", "commands", "authority"]
			constraints: ["commands derive from sourcePlan.evals", "runner shell and adapter authority are false"]
		},
		{
			name: "RunnerCommand"
			role: "executable command vector admitted by CUE"
			requiredFields: ["id", "sourceEvalID", "command", "expect"]
			constraints: ["command is a non-empty string list", "expect is pass or fail", "no shell string command policy"]
		},
		{
			name: "GeneratedHookProjection"
			role: "downstream generated projection descriptor"
			requiredFields: ["id", "target", "authority", "runnerPlan", "adapter", "generatedFrom"]
			constraints: ["authority is false", "source plan references resolver-local plans", "adapter authority is false"]
		},
		{
			name: "HookTemplateGate"
			role: "public summary gate for this slice"
			requiredFields: ["id", "action", "authority", "publicExports", "negativeCheckIDs"]
			constraints: ["reports check IDs only", "real check authority remains bottom intersections"]
		},
	]

	surfaces: {
		admissible: ["#ObservedHookEvent", "#ImplementationSliceIssue", "#IssueEvalObligations", "#EvalPlan", "#EvalPlanFromIssue", "#EvalRunnerPlan", "#RunnerCommand", "#GeneratedHookProjection", "#HookTemplateGate"]
		observed: ["#ObservedHookEvent", "#ObservedRunnerResult"]
		candidates: ["resolverHookTemplateIssue", "resolverHookTemplateEvalPlan", "resolverHookEvalRunnerPlan", "resolverHookGeneratedProjection", "resolverHookTemplateGate"]
		fixtures: [
			"baselineResolverHookTemplateIssue",
			"baselineResolverHookEvent",
			"baselineResolverHookEvalPlan",
			"baselineResolverHookEvalRunnerPlan",
			"hookTemplateNegativeFixtures.generatedProjectionAuthority",
			"hookTemplateNegativeFixtures.shellSemanticAuthority",
			"hookTemplateNegativeFixtures.emptyRunnerCommand",
			"hookTemplateNegativeFixtures.undeclaredRunnerCommand",
			"hookTemplateNegativeFixtures.stringifiedBottomCheck",
		]
		publicExports: [
			"resolverHookTemplateIssue",
			"resolverHookTemplateEvalPlan",
			"resolverHookEvalRunnerPlan",
			"resolverHookGeneratedProjection",
			"resolverHookTemplateGate",
		]
		checks: [
			"_negativeBottomChecks.hookTemplate.generatedProjectionAuthority",
			"_negativeBottomChecks.hookTemplate.shellSemanticAuthority",
			"_negativeBottomChecks.hookTemplate.emptyRunnerCommand",
			"_negativeBottomChecks.hookTemplate.undeclaredRunnerCommand",
			"_negativeBottomChecks.hookTemplate.stringifiedBottomCheck",
		]
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

	dag: {
		nodes: {
			N0: {
				id:       "N0.contract-question"
				question: rootQuestion.text
			}
			N1: {
				id:       "N1.authority-boundary"
				question: "What does CUE own, and what remains outside this slice?"
				answer:   "Move hook template eval authority into contracts/agent-context-resolver. Keep tools/hooks as execution adapter only. Keep contracts/factory as root factory policy, not resolver internals."
			}
			N2: {
				id:       "N2.primitive-model"
				question: "Which first-class CUE primitives are introduced or extended?"
				answer:   "Introduce resolver-local hook event, issue intent, eval obligation, eval plan, runner plan, generated projection, and gate primitives."
			}
			N3: {
				id:       "N3.admissible-surface"
				question: "Which candidate/admissible surfaces constrain valid state?"
				answer:   "Eval obligations derive from implementation-slice intent, eval plans derive from obligations, and runner plans derive from eval plans."
			}
			N4: {
				id:       "N4.fixtures"
				question: "Which valid and invalid concrete examples exercise the contract?"
				answer:   "Resolver-local baseline fixtures plus structural negatives for projection authority, shell authority, empty commands, undeclared commands, and stringified check attempts."
			}
			N5: {
				id:       "N5.eval-surfaces"
				question: "Which public exports and check surfaces prove the slice works?"
				answer:   "Public exports are resolverHookTemplateIssue, resolverHookTemplateEvalPlan, resolverHookEvalRunnerPlan, resolverHookGeneratedProjection, and resolverHookTemplateGate."
			}
			N6: {
				id:       "N6.validation"
				question: "Which commands validate the CUE package and its expected bottoms?"
				answer:   "Validation uses resolver-local cue vet and exports, fail-closed negative exports, forbidden attractor search, and the hook runner adapter against the exported runner plan."
			}
			N7: {
				id:       "N7.next-state"
				question: "What bounded admitted state exists after this slice?"
				answer:   "Hook template eval authority is resolver-local; factory can later consume resolver exports through an explicit bridge."
			}
		}
		allowedEdges: [
			"N0 -> N1",
			"N1 -> N2",
			"N2 -> N3",
			"N3 -> N4",
			"N3 -> N5",
			"N4 -> N5",
			"N5 -> N6",
			"N6 -> N7",
		]
		forbiddenEdges: [
			"vocabulary -> accepted slice without eval surface",
			"diagnostic boolean -> authority",
			"review metadata -> proof",
			"stringified check text -> check",
			"projection artifact -> authority",
			"adapter output -> policy authority",
			"shell command -> semantic authority",
		]
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

baselineResolverHookEvent: #ObservedHookEvent & {
	source: "codex"
	event:  "postToolUse"
	cwd:    "/home/_404/src/factory"
	changedFiles: [
		{
			path:      "contracts/agent-context-resolver/hook_event.cue"
			operation: "create"
		},
	]
	tool: {
		name: "apply_patch"
	}
}

baselineResolverHookEvalPlanFromIssue: #EvalPlanFromIssue & {
	event: baselineResolverHookEvent
	issue: baselineResolverHookTemplateIssue
}

baselineResolverHookEvalPlan: baselineResolverHookEvalPlanFromIssue.plan

baselineResolverHookEvalRunnerPlan: #EvalRunnerPlan & {
	schema:     "agent-context-resolver.eval-runner-plan.v1"
	sourcePlan: baselineResolverHookEvalPlan
}

hookTemplateNegativeFixtures: {
	generatedProjectionAuthority: {
		input: {
			schema:        "agent-context-resolver.generated-hook-projection.v1"
			id:            "bad.projection-artifact-authority"
			target:        "tools/hooks/run-eval-plan.sh"
			generatedFrom: "resolverHookEvalRunnerPlan"
			authority:     true
			runnerPlan:    resolverHookEvalRunnerPlan
			adapter: {
				role:      "execute declared behavior only"
				authority: false
			}
		}
	}

	shellSemanticAuthority: {
		input: {
			schema:     "agent-context-resolver.eval-runner-plan.v1"
			sourcePlan: resolverHookTemplateEvalPlan
			commands: [
				for e in resolverHookTemplateEvalPlan.evals {
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
				runner:  true
				shell:   true
				adapter: false
			}
		}
	}

	emptyRunnerCommand: {
		input: {
			id:           "bad.empty-runner-command"
			sourceEvalID: "bad.empty-runner-command"
			command: []
			expect: "pass"
		}
	}

	undeclaredRunnerCommand: {
		input: {
			schema: "agent-context-resolver.eval-runner-plan.v1"
			sourcePlan: #EvalPlan & {
				schema: "agent-context-resolver.eval-plan.v1"
				event:  baselineResolverHookEvent
				evals: [{
					id:   "declared.cue-vet"
					kind: "cueVet"
					command: ["cue", "vet", "./contracts/agent-context-resolver"]
					expect: "pass"
				}]
			}
			commands: [{
				id:           "undeclared.runner-command"
				sourceEvalID: "undeclared.runner-command"
				command: ["cue", "export", "./contracts/agent-context-resolver", "-e", "resolverHookTemplateGate"]
				expect: "pass"
			}]
			authority: {
				cue:     true
				runner:  false
				shell:   false
				adapter: false
			}
		}
	}

	stringifiedBottomCheck: {
		input: {
			schema:    "agent-context-resolver.eval-plan.v1"
			event:     baselineResolverHookEvent
			evals:     baselineResolverHookEvalPlan.evals
			checkText: "hookTemplateNegativeFixtures.emptyRunnerCommand.input and RunnerCommand"
		}
	}
}
