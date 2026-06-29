package invalidworkermissingcommandbudget

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#ValidWorkerRequest & {
	commandBudget?: _|_
}
