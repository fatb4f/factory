package agentcontextresolver

resolverHookTemplateIssue: baselineResolverHookTemplateIssue

resolverHookTemplateEvalPlan: baselineResolverHookEvalPlan

resolverHookEvalRunnerPlan: baselineResolverHookEvalRunnerPlan

resolverHookGeneratedProjection: #GeneratedHookProjection & {
	schema:        "agent-context-resolver.generated-hook-projection.v1"
	id:            "resolver-generated-hook-projection.eval-runner"
	target:        "tools/hooks/run-eval-plan.sh"
	generatedFrom: "resolverHookEvalRunnerPlan"
	authority:     false
	runnerPlan:    resolverHookEvalRunnerPlan
	adapter: {
		role:      "execute declared behavior only"
		authority: false
	}
	mode:    "0755"
	content: "adapter file is tools/hooks/run-eval-plan.sh; this descriptor is authority false"
}

resolverHookTemplateGate: #HookTemplateGate & {
	schema: "agent-context-resolver.hook-template-gate.v1"
	id:     "resolver.hook-template-eval-authority-relocation"
	action: "admit"
	reason: "hook/template/eval-plan authority is resolver-local and adapters remain authority=false"
	authority: {
		cue:       true
		adapters:  false
		generated: false
		runtime:   false
	}
	publicExports:    resolverHookTemplateIssue.surfaces.publicExports
	negativeCheckIDs: resolverHookTemplateIssue.surfaces.checks
	evidence: [
		"cue vet ./contracts/agent-context-resolver",
		"resolver hook template public exports",
		"resolver-local hook template negative bottom checks",
		"tools/hooks/run-eval-plan.sh consumes resolverHookEvalRunnerPlan",
	]
	nextState: "reassess resolver freshness and go-git observation as a separate evidence slice"
}
