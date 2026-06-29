package agentcontextresolver

import "list"

_matcherBoundaryChecks: {
	providerStandalone:
		*(#PromptMatcherGuard & {route: promptMatcherNegativeFixtures.providerStandalone.input}) | _

	dotfilesStandalone:
		*(#PromptMatcherGuard & {route: promptMatcherNegativeFixtures.dotfilesStandalone.input}) | _
}

_routeGraphBoundaryChecks: {
	unclosedDependencyGraph: *({
		input: #PromptRouteGraphExpansion & promptMatcherNegativeFixtures.unclosedRouteGraph.input
		_selectedRegisteredRoutes: [
			for route in input.routes
			if list.Contains(input.selectedRouteIDs, route.id) {route},
		]

		for route in _selectedRegisteredRoutes {
			for dependencyID in route.dependsOn {
				if !list.Contains(input.selectedRouteIDs, dependencyID) {
					_missingDependencyClosure: _|_
				}
			}
		}
	}) | _
}

_runtimeBoundaryChecks: {
	mcpAdapterRequired:
		*(#RuntimeProviderExecutionFreeProjection & runtimeProviderExecutionNegativeFixtures.providerExecutionRequired.input) | _
}
