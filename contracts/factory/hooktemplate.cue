package factory

#ImplementationSliceIssue: close({
	kind: "cueImplementationSlice"

	contract: {
		path:    string & !=""
		package: string & !=""
		slice:   string & !=""
		authority: {
			owns: [...string & !=""]
			doesNotOwn: [...string & !=""]
		}
	}

	primitives: [...{
		name: string & !=""
		role: string & !=""
		requiredFields?: [...string & !=""]
		constraints?: [...string & !=""]
	}]

	surfaces: {
		admissible: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [...string & !=""]
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
})

#ObservedHookEvent: close({
	source: "claude" | "codex" | "git" | "githubActions" | "manual"
	event:  "preToolUse" | "postToolUse" | "preCommit" | "pullRequest" | "manual"

	cwd: string & !=""

	changedFiles?: [...{
		path:      string & !=""
		operation: "create" | "update" | "delete" | "rename" | "unknown"
	}]

	tool?: {
		name:      string & !=""
		input?:    _
		response?: _
	}
})

#EvalObligation: close({
	id:   string & !=""
	kind: "cueVet" | "cueExport" | "cueBottom" | "grepAbsent"
	command: [string & !="", ...string & !=""]
	expect: "pass" | "fail"
})

#EvalPlan: close({
	schema: "factory.eval-plan.v1"
	event:  #ObservedHookEvent
	evals: [...#EvalObligation]
})

#IssueEvalObligations: close({
	input: #ImplementationSliceIssue

	required: {
		vet: #EvalObligation & {
			id:   "issue.cue-vet"
			kind: "cueVet"
			command: ["cue", "vet", "./\(input.contract.path)"]
			expect: "pass"
		}

		publicExports: [
			for e in input.surfaces.publicExports {
				#EvalObligation & {
					id:   "issue.export.\(e)"
					kind: "cueExport"
					command: ["cue", "export", "./\(input.contract.path)", "-e", e]
					expect: "pass"
				}
			},
		]

		negativeChecks: [
			for c in input.surfaces.checks {
				#EvalObligation & {
					id:   "issue.bottom.\(c)"
					kind: "cueBottom"
					command: ["cue", "export", "./\(input.contract.path)", "-e", c]
					expect: "fail"
				}
			},
		]
	}
})

#EvalPlanFromIssue: close({
	event: #ObservedHookEvent
	issue: #ImplementationSliceIssue

	obligations: #IssueEvalObligations & {
		input: issue
	}

	plan: #EvalPlan & {
		schema: "factory.eval-plan.v1"
		event:  _event
		evals: [
			obligations.required.vet,
			for e in obligations.required.publicExports {e},
			for e in obligations.required.negativeChecks {e},
		]
	}

	let _event = event
})

#HookTemplateGate: close({
	schema: "factory.hook-template-gate.v1"
	issue:  #ImplementationSliceIssue
	plan:   #EvalPlan
	publicExports: [...string & !=""]
	negativeCheckIDs: [...string & !=""]
	authority: {
		cue:      true
		adapters: false
	}
})

baselineImplementationSlice: #ImplementationSliceIssue & {
	kind: "cueImplementationSlice"

	contract: {
		path:    "contracts/factory"
		package: "factory"
		slice:   "hook-template-eval-model"
		authority: {
			owns: [
				"issue-template implementation-slice schema",
				"normalized hook event schema",
				"eval obligation schema",
				"eval plan admissibility",
				"positive export obligations",
				"negative bottom-check obligations",
				"forbidden-attractor checks",
			]
			doesNotOwn: [
				"runtime execution",
				"VCS mutation",
				"go-git inspection implementation",
				"resolver staleness policy",
				"Claude hook installation",
				"Codex hook installation",
				"GitHub Projects mutation",
			]
		}
	}

	primitives: [
		{
			name: "ImplementationSliceIssue"
			role: "typed issue-template intent"
			requiredFields: ["kind", "contract", "primitives", "surfaces", "constraints"]
			constraints: ["generated artifacts and adapters cannot claim authority"]
		},
		{
			name: "ObservedHookEvent"
			role: "normalized observed runtime fact"
			requiredFields: ["source", "event", "cwd"]
			constraints: ["events are observations only"]
		},
		{
			name: "EvalObligation"
			role: "CUE-admitted executable validation obligation"
			requiredFields: ["id", "kind", "command", "expect"]
			constraints: ["commands are non-empty and execution-only"]
		},
		{
			name: "EvalPlan"
			role: "CUE-derived validation plan"
			requiredFields: ["schema", "event", "evals"]
			constraints: ["adapters execute the plan but do not define policy"]
		},
	]

	surfaces: {
		admissible: ["#ImplementationSliceIssue", "#ObservedHookEvent", "#EvalObligation", "#EvalPlan"]
		fixtures: ["baselineImplementationSlice", "baselineHookEvent", "baselineEvalPlan", "hookTemplateNegativeFixtures.generatedAuthority", "hookTemplateNegativeFixtures.stringifiedBottomCheck", "hookTemplateNegativeFixtures.shellSemanticAuthority", "hookTemplateNegativeFixtures.emptyEvalCommand"]
		checks: ["_negativeBottomChecks.hookTemplate.generatedAuthority", "_negativeBottomChecks.hookTemplate.stringifiedBottomCheck", "_negativeBottomChecks.hookTemplate.shellSemanticAuthority", "_negativeBottomChecks.hookTemplate.emptyEvalCommand"]
		publicExports: ["hookTemplateIssue", "hookTemplateEvalPlan", "hookTemplateGate"]
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
}

baselineHookEvent: #ObservedHookEvent & {
	source: "codex"
	event:  "postToolUse"
	cwd:    "/home/_404/src/factory"
	changedFiles: [
		{
			path:      "contracts/factory/hooktemplate.cue"
			operation: "create"
		},
	]
	tool: {
		name: "apply_patch"
	}
}

baselineIssueEvalObligations: #IssueEvalObligations & {
	input: baselineImplementationSlice
}

baselineEvalPlanFromIssue: #EvalPlanFromIssue & {
	event: baselineHookEvent
	issue: baselineImplementationSlice
}

baselineEvalPlan: baselineEvalPlanFromIssue.plan

hookTemplateNegativeFixtures: {
	generatedAuthority: {
		input: {
			kind:        "cueImplementationSlice"
			contract:    baselineImplementationSlice.contract
			primitives:  baselineImplementationSlice.primitives
			surfaces:    baselineImplementationSlice.surfaces
			constraints: baselineImplementationSlice.constraints
			generatedArtifact: {
				authority: true
			}
		}
	}

	stringifiedBottomCheck: {
		input: {
			schema: "factory.eval-plan.v1"
			event:  baselineHookEvent
			evals:  baselineEvalPlan.evals
			bottomCheck: {
				expr: "hookTemplateNegativeFixtures.stringifiedBottomCheck.input & #EvalPlan"
			}
		}
	}

	shellSemanticAuthority: {
		input: {
			schema: "factory.eval-plan.v1"
			event:  baselineHookEvent
			evals: [{
				id:   "bad.shell-semantic-authority"
				kind: "grepAbsent"
				command: ["rg", "semantic-policy", "./contracts/factory"]
				expect: "pass"
				semanticAuthority: {
					claimedBy: "shell"
				}
			}]
		}
	}

	emptyEvalCommand: {
		input: {
			id:   "bad.empty-eval-command"
			kind: "cueVet"
			command: []
			expect: "pass"
		}
	}
}

hookTemplateIssue: baselineImplementationSlice

hookTemplateEvalPlan: baselineEvalPlan

hookTemplateGate: #HookTemplateGate & {
	schema: "factory.hook-template-gate.v1"
	issue:  hookTemplateIssue
	plan:   hookTemplateEvalPlan
	publicExports: ["hookTemplateIssue", "hookTemplateEvalPlan", "hookTemplateGate"]
	negativeCheckIDs: [
		"generatedAuthority",
		"stringifiedBottomCheck",
		"shellSemanticAuthority",
		"emptyEvalCommand",
	]
	authority: {
		cue:      true
		adapters: false
	}
}
