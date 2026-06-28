package agentcontextresolver

#HookTemplateGate: close({
	schema: "agent-context-resolver.hook-template-gate.v1"
	id:     string & !=""
	action: "admit" | "reject" | "defer" | "block"
	reason: string & !=""

	authority: {
		cue:       true
		adapters:  false
		generated: false
		runtime:   false
	}

	publicExports:    [...string & !=""]
	negativeCheckIDs: [...string & !=""]

	evidence: [...string & !=""]
	nextState: string & !=""
})
