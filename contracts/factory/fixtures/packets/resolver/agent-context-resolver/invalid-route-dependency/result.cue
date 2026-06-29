package invalidroutedependency

import fixtures "github.com/fatb4f/factory/fixtures/resolver/agent-context-resolver:agentcontextresolver"

invalid: fixtures.#FixturePlan & {
	routes: [{
		fixtures.#FixtureRoute
		dependsOn: ["route.unknown"]
	}]
}
