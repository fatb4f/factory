package invalidrawregistry

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#FixtureInvocation & {
	routeRef: context: rawRegistry: {contracts: []}
}
