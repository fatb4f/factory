package assertions

import (
	rootadapters "github.com/fatb4f/factory/contracts/adapters"
)

adapterBoundaryAssertions: {
	rootVocabulary: rootadapters.adapterVocabularyBoundary & {
		authority:   true
		extractable: true
	}

	resolverAdapters: {
		id:   "agent-context-resolver.adapters"
		kind: "adapters"
		path: "adapters"
	}

	invariants: {
		cueOwnsValidation: true
		adapterOwnsIO:     true
		duplicateLogic:    false
		semanticAuthority: false
	}
}
