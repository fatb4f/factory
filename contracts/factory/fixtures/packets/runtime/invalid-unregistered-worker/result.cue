package invalidunregisteredworker

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#FixtureInvocation & {
	workerID: "worker.unregistered"
}
