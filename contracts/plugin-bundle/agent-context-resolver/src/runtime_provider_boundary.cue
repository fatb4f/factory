package agentcontextresolver

#RuntimeProviderExecutionBoundary: close({
	schema: "agent.runtime-provider-boundary.v1"
	runtimeInventoryContainsProviderExecutionRequirements: false
	mcpRouteExecutor: "absent"
	requiresMCPAdapter: false
	providerOutputAuthority: false
})

#RuntimeProviderExecutionFreeProjection: #RuntimeProjection & {
	requirements: {
		mcpRouteExecutor: "absent"
	}
	execution: {
		requiresMCPAdapter: false
	}
}

runtimeProviderExecutionBoundary: #RuntimeProviderExecutionBoundary & {
	schema: "agent.runtime-provider-boundary.v1"
	runtimeInventoryContainsProviderExecutionRequirements: false
	mcpRouteExecutor: "absent"
	requiresMCPAdapter: false
	providerOutputAuthority: false
}
