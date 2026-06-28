package agentcontextresolver

_matcherBoundaryChecks: {
	providerStandalone:
		*(#PromptMatcherGuard & {route: promptMatcherNegativeFixtures.providerStandalone.input}) | _

	dotfilesStandalone:
		*(#PromptMatcherGuard & {route: promptMatcherNegativeFixtures.dotfilesStandalone.input}) | _
}

_routeGraphBoundaryChecks: {
	unclosedDependencyGraph:
		*(#PromptRouteGraphExpansion & promptMatcherNegativeFixtures.unclosedRouteGraph.input) | _
}

_runtimeBoundaryChecks: {
	mcpAdapterRequired:
		*(#RuntimeProviderExecutionFreeProjection & runtimeProviderExecutionNegativeFixtures.providerExecutionRequired.input) | _
}
