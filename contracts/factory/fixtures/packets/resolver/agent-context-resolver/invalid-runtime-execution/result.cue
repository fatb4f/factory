package invalidruntimeexecution

import fixtures "github.com/fatb4f/factory/fixtures/resolver/agent-context-resolver:agentcontextresolver"

invalid: fixtures.#FixturePlan & {
	runtime: execution: allowed: true
}
