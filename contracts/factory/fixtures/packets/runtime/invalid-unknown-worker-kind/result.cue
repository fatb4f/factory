package invalidunknownworkerkind

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#ValidWorkerRequest & {
	worker: "unknown-worker"
}
