package meta

import "quicue.ca/vocab@v0"

match: vocab.#ProviderMatch & {
	types: {ContextResolverProfile: true}
	provider: "context-resolver"
}

project: {
	"@id":       "https://github.com/fatb4f/factory/profile/context-resolver"
	description: "Agent context-resolver profile template."
	status:      "scaffold"
}
