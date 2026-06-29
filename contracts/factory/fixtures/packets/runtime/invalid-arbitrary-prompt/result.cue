package invalidarbitraryprompt

import fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"

invalid: fixtures.#FixtureInvocation & {
	arbitraryPrompt: "Inspect anything relevant."
}
