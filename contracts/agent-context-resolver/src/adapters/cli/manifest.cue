package cliadapter

import (
	adapters "github.com/fatb4f/factory/contracts/adapters"
)

boundary: adapters.#AdapterBoundary & {
	id:   "agent-context-resolver.adapters.cli"
	kind: "cli"
}
