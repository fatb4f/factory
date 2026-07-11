package context_resolver

import (
	"quicue.ca/patterns@v0"
	profile_patterns "github.com/fatb4f/factory/marimo/profiles/context-resolver/kg/template/context-resolver/patterns"
)

providers: profile: patterns.#ProviderDecl & {
	types: {ContextResolverProfile: true}
	registry: profile_patterns.#ContextResolverRegistry
}
