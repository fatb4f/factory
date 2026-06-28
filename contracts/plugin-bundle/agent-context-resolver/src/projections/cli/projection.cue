package cliprojection

import resolver "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

domain: {
	id:          "agent-context-resolver/projections/cli"
	kind:        "projection"
	authority:   false
	extractable:  false
	imports:     ["agent-context-resolver"]
}

#CLICommand: close({
	name: "inventory" | "resolve-prompt" | "plan-route" | "validate" | "export"
	routeID?: resolver.#DeclaredID
})
