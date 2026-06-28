package agentcontextresolver

baselineImplementationSliceIssue: #ParsedImplementationSliceIssue & {
	number: 44
	title:  "cue: implement agent-context-resolver implementation-slice issue materializer"
	sourceTemplateRef: ".github/ISSUE_TEMPLATE/cue-implementation-slice.md"
	contract: {
		path:    "contracts/agent-context-resolver"
		package: "resolver"
		slice:   "implementation-slice-issue-materializer"
		authority: {
			owns: [
				"parsed implementation-slice issue shape",
				"issue materialization candidate/admissible surface",
				"issue-specific eval obligation projection",
				"issue-specific eval-plan projection",
				"issue-specific runner-plan projection",
				"runner result classification shape",
				"negative fixtures and bottom-check surfaces proving parser/materializer failure modes",
				"forbidden-attractor checks for static eval plans, stringified checks, and any-nonzero failure semantics",
			]
			doesNotOwn: [
				"GitHub API behavior",
				"Codex/Claude reasoning",
				"shell process execution",
				"VCS mutation",
				"CI orchestration",
				"downstream effect application",
			]
		}
	}
	primitives: [
		"#RawImplementationSliceIssue",
		"#ParsedImplementationSliceIssue",
		"#ImplementationSliceMaterialization",
		"#ImplementationSliceEvalObligations",
		"#ImplementationSliceEvalPlan",
		"#ImplementationSliceRunnerPlan",
		"#ClassifiedRunnerResult",
		"#IssueMaterializationCandidate",
	]
	surfaces: {
		admissible: ["#IssueMaterializationCandidate", "#ImplementationSliceMaterialization"]
		observed: ["#RawImplementationSliceIssue"]
		candidates: ["implementationSliceMaterializationReport"]
		fixtures: [
			"negativeFixtures.routeOnlyPacket",
			"negativeFixtures.missingContractPath",
			"negativeFixtures.staticEvalPlan",
			"negativeFixtures.missingNegativeCheckExpression",
			"negativeFixtures.anyNonzeroAsPass",
		]
		checks: [
			"_negativeBottomChecks.routeOnlyPacket",
			"_negativeBottomChecks.missingContractPath",
			"_negativeBottomChecks.staticEvalPlan",
			"_negativeBottomChecks.missingNegativeCheckExpression",
			"_negativeBottomChecks.anyNonzeroAsPass",
		]
		publicExports: [
			"implementationSliceIssueBaseline",
			"implementationSliceMaterializationReport",
			"implementationSliceEvalPlan",
			"implementationSliceRunnerPlan",
			"implementationSliceFeedbackShape",
		]
	}
	filePlan: [
		{path: "contracts/agent-context-resolver/implementation_slice_materializer.cue", purpose: "raw parsed materialized issue primitives and admissible surfaces"},
		{path: "contracts/agent-context-resolver/implementation_slice_eval_projection.cue", purpose: "issue-specific eval obligation eval-plan and runner-plan projections"},
		{path: "contracts/agent-context-resolver/implementation_slice_runner_result.cue", purpose: "classified runner result and wrong-failure rejection surface"},
		{path: "tools/agent-context-resolver/parse-implementation-slice-issue", purpose: "minimal markdown-to-json observation adapter"},
		{path: "tools/agent-context-resolver/materialize-implementation-slice", purpose: "minimal CUE load and export adapter"},
		{path: "tools/hooks/run-eval-plan.sh", purpose: "classified expected structural bottom runner"},
	]
	evalSurfaces: surfaces.publicExports
	fixtures: surfaces.fixtures
	checks: surfaces.checks
	validation: {
		positive: [
			{id: "vet", argv: ["cue", "vet", "./contracts/agent-context-resolver"]},
			{id: "baseline", argv: ["cue", "export", "./contracts/agent-context-resolver", "-e", "implementationSliceIssueBaseline"]},
			{id: "plan", argv: ["cue", "export", "./contracts/agent-context-resolver", "-e", "implementationSliceEvalPlan"]},
		]
		negative: [
			{
				id:          "negative.routeOnlyPacket"
				argv:        ["cue", "export", "./contracts/agent-context-resolver", "-e", "_negativeBottomChecks.routeOnlyPacket"]
				expect:      "fail"
				reasonClass: "structural_bottom"
			},
		]
	}
	gates: ["admit loaded implementation-slice issue materializer"]
}

negativeFixtures: {
	routeOnlyPacket: {
		violates: "predicates.requiresParsedLoadedIssue"
		input: {
			issueRef: "issue-44"
			predicates: {
				requiresParsedIssue: false
				requiresLoadedIssue: false
				evalPlanDerivedFromLoadedIssue: false
				runnerPlanDerivedFromEvalPlan: false
				expectedFailureClassified: false
				negativeSelectorsResolve: false
			}
		}
	}
	missingContractPath: {
		violates: "predicates.requiresContractPath"
		input: {
			issueRef: "issue-44"
			parsedIssue: {
				contract: {
					path: ""
					package: "resolver"
					slice: "implementation-slice-issue-materializer"
					authority: {
						owns: ["parsed implementation-slice issue shape"]
						doesNotOwn: ["GitHub API behavior"]
					}
				}
				primitives: ["#ParsedImplementationSliceIssue"]
				surfaces: {
					admissible: []
					observed: []
					candidates: []
					fixtures: []
					checks: ["_negativeBottomChecks.routeOnlyPacket"]
					publicExports: ["implementationSliceIssueBaseline"]
				}
				filePlan: []
				evalSurfaces: []
				fixtures: []
				checks: []
				validation: {
					positive: [{id: "vet", argv: ["cue", "vet", "./contracts/agent-context-resolver"]}]
					negative: []
				}
				gates: []
			}
			loadedIssue: implementationSliceLoadedIssue
			predicates: {
				requiresParsedIssue: true
				requiresLoadedIssue: true
				evalPlanDerivedFromLoadedIssue: true
				runnerPlanDerivedFromEvalPlan: true
				expectedFailureClassified: true
				negativeSelectorsResolve: true
			}
		}
	}
	staticEvalPlan: {
		violates: "predicates.evalPlanMustDeriveFromLoadedIssue"
		input: {
			issueRef: "issue-44"
			parsedIssue: baselineImplementationSliceIssue
			loadedIssue: implementationSliceLoadedIssue
			evalPlan: {
				issueID: "issue-44"
				sourceIssueRef: "static-fixture"
			}
			predicates: {
				requiresParsedIssue: true
				requiresLoadedIssue: true
				evalPlanDerivedFromLoadedIssue: false
				runnerPlanDerivedFromEvalPlan: true
				expectedFailureClassified: true
				negativeSelectorsResolve: true
			}
		}
	}
	missingNegativeCheckExpression: {
		violates: "predicates.negativeSelectorMustResolve"
		input: {
			issueRef: "issue-44"
			parsedIssue: baselineImplementationSliceIssue
			loadedIssue: implementationSliceLoadedIssue
			evalPlan: implementationSliceEvalPlan
			runnerPlan: implementationSliceRunnerPlan
			predicates: {
				requiresParsedIssue: true
				requiresLoadedIssue: true
				evalPlanDerivedFromLoadedIssue: true
				runnerPlanDerivedFromEvalPlan: true
				expectedFailureClassified: true
				negativeSelectorsResolve: false
			}
		}
	}
	anyNonzeroAsPass: {
		violates: "predicates.expectedFailureRequiresReasonClass"
		input: {
			issueRef: "issue-44"
			parsedIssue: baselineImplementationSliceIssue
			loadedIssue: implementationSliceLoadedIssue
			evalPlan: implementationSliceEvalPlan
			runnerPlan: {
				commands: [{
					id: "bad.fail"
					sourceEvalID: "bad.fail"
					command: ["false"]
					expect: "fail"
				}]
			}
			predicates: {
				requiresParsedIssue: true
				requiresLoadedIssue: true
				evalPlanDerivedFromLoadedIssue: true
				runnerPlanDerivedFromEvalPlan: true
				expectedFailureClassified: false
				negativeSelectorsResolve: true
			}
		}
	}
}

promptMatcherNegativeFixtures: {
	providerStandalone: {input: {
		id: "bad-provider-standalone"
		matcher: {
			all: []
			any: [{value: "provider", mode: "word", caseFold: true, rawContains: false}]
			none: []
			phrases: []
			paths: []
			wordTerms: [{term: "provider", boundary: "word", regexBoundary: true, rawContains: false}]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["mcp.evidence-plane"]
		invokes: ["mcp.evidence.inspect"]
		hint: "generic provider trigger must not match alone"
		priority: 1
	}}
	dotfilesStandalone: {input: {
		id: "bad-dotfiles-standalone"
		matcher: {
			all: []
			any: [{value: "dotfiles", mode: "word", caseFold: true, rawContains: false}]
			none: []
			phrases: []
			paths: []
			wordTerms: [{term: "dotfiles", boundary: "word", regexBoundary: true, rawContains: false}]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["repo.lifecycle"]
		invokes: ["repo.lifecycle.validate"]
		hint: "generic dotfiles trigger must not match alone"
		priority: 1
	}}
	unclosedRouteGraph: {input: {
		promptRouteID: "bad-unclosed-resolver"
		selectedRouteIDs: ["resolver.plan.compile"]
		routes: routeInventory.routes
	}}
}

runtimeProviderExecutionNegativeFixtures: {
	providerExecutionRequired: {input: {
		mode: "none"
		routeRefs: []
		requirements: {
			agentRuntimeRegistry: "absent"
			workerAdapterRegistry: "absent"
			mcpRouteExecutor: "present"
		}
		execution: {
			allowed: false
			preferredWorkerAdapter: "a2a"
			secondaryWorkerAdapters: []
			requiresA2AAdapter: false
			requiresMCPAdapter: true
			requiresRuntimeRegistry: false
			backend: "none"
		}
		deny: {
			directSDKSpawn: true
			rawTranscriptForwarding: true
			rawRegistryDump: true
			unselectedFragments: true
			globalMutation: true
			authorityDelegation: true
			freeFormMCPToolExposure: true
		}
		expectedResult: {schema: "agent.route-result.v1"}
	}}
}

implementationSliceIssueBaseline: baselineImplementationSliceIssue

implementationSliceLoaded: #IssueMaterializationFromParsed & {
	parsed: baselineImplementationSliceIssue
}

implementationSliceLoadedIssue: implementationSliceLoaded.loaded

implementationSliceMaterializationReport: implementationSliceLoaded.materialization

implementationSliceProjection: #ImplementationSlicePlanProjection & {
	materialization: implementationSliceMaterializationReport
}

implementationSliceEvalPlan: implementationSliceProjection.evalPlan

implementationSliceRunnerPlan: implementationSliceProjection.runnerPlan
