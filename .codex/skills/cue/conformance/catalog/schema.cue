package catalog

import (
	"strings"
	upstream "github.com/fatb4f/factory/cue-lattice-conformance/upstream"
)

#NonEmptyString: string & strings.MinRunes(1)
#ConceptID:      #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#ArtifactID:
	"language-specification" |
	"standard-library-list" |
	"go-api-value" |
	"cli-vet" |
	"subsumption-tests" |
	"implementation-reference" |
	"language-features-context" |
	"cue-version-identity"

#LocatorKind: "section" | "line-range" | "go-symbol" | "test-family" | "command-contract"
#AuthorityUse: "defines" | "constrains" | "corroborates" | "context"
#ObservationMode:
	"cue-language-expression" |
	"go-api-subsume" |
	"go-api-unify" |
	"go-api-validate" |
	"go-api-syntax" |
	"cue-cli-structural" |
	"specification-analysis"

#ApplicabilityScope:
	"plain-values" |
	"all-values" |
	"primitive-values" |
	"struct-values" |
	"list-values" |
	"default-bearing-values" |
	"evaluation-state" |
	"tooling-boundary"

#SourceReference: close({
	artifact:    #ArtifactID
	locatorKind: #LocatorKind
	locator:     #NonEmptyString
	use:         #AuthorityUse
})

#Applicability: close({
	scopes: [...#ApplicabilityScope] & [_, ...]
	limits: [...#NonEmptyString]
})

#Concept: close({
	id:                    #ConceptID
	term:                  #NonEmptyString
	statement:             #NonEmptyString
	relations:             [...#NonEmptyString]
	applicability:         #Applicability
	observationModes:      [...#ObservationMode] & [_, ...]
	sources:               [...#SourceReference] & [_, ...]
	applicationVocabulary: false
})

#ConceptCatalog: close({
	id:                "cue-lattice-concept-catalog-v1"
	authorityID:       "cue-upstream-authority-v1"
	authorityRevision: upstream.#GitCommit
	concepts:          {[#ConceptID]: #Concept}
})
