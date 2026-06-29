package invalidmissingbudget

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#FixtureInvocation & {
	budgetID?: _|_
}
