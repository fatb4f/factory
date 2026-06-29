package invalidresultbudgetmismatch

import (
	runtime "github.com/fatb4f/factory/contracts/agent-runtime:agentruntime"
	fixtures "github.com/fatb4f/factory/fixtures/agent-runtime:agentruntime"
)

invalid: runtime.#RuntimeResult & fixtures.validResult & {
	budget: id: "validate-standard"
}
