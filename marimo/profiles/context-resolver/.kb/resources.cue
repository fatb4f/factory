package context_resolver

import "quicue.ca/vocab"

// Populate with profile resources. Each entry must satisfy the shared
// quicue resource vocabulary.
resources: [Name=string]: vocab.#Resource & {
	name: Name
}
