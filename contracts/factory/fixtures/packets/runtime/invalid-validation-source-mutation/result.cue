package invalidvalidationsourcemutation

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#ValidWorkerRequest & {
	actions: ["inspect", "mutate_source", "run_validation"]
}
