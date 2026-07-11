package context_resolver

import "quicue.ca/vocab@v0"

resources: profile: vocab.#Resource & {
	name: "context-resolver"
	"@type": {ContextResolverProfile: true}
	entrypoint: "context_resolver.py"
}
