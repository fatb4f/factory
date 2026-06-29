package runtimeprojection

import runtime "github.com/fatb4f/factory/contracts/agent-runtime:agentruntime"

domain: {
	id:          "agent-context-resolver/projections/agent-runtime"
	kind:        "projection"
	authority:   false
	extractable:  false
	imports:     ["agent-context-resolver", "agent-runtime"]
}

#RuntimeProjectionBinding: runtime.#RuntimeProjection
