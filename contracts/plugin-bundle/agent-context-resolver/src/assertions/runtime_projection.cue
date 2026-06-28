package assertions

import runtimeprojection "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src/projections/agent-runtime:runtimeprojection"

runtimeProjectionAssertions: {
	projection: runtimeprojection.domain & {
		authority:   false
		extractable: false
		imports: ["agent-context-resolver", "agent-runtime"]
	}

	routeResultsAreAuthority: false
}
