package agentcontextresolver

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
