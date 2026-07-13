package catalog

import (
	"strings"
	upstream "github.com/fatb4f/factory/cue-skill/lattice/conformance/upstream"
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

#LocatorKind:  "section" | "line-range" | "go-symbol" | "test-family" | "command-contract"
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

	let artifactID = artifact
	let sourceUse = use
	let artifactRecord = upstream.authority.artifacts[artifactID]
	let sourcePolicy = upstream.authority.boundary[artifactRecord.class]

	if sourceUse == "defines" {
		_definePolicy: sourcePolicy.mayDefineConcepts & true
	}
	if sourceUse == "constrains" {
		_constrainPolicy: sourcePolicy.role & ("normative" | "supporting")
	}
	if sourceUse == "corroborates" {
		_corroboratePolicy: sourcePolicy.role & "supporting"
	}
	if sourceUse == "context" {
		_contextPolicy: sourcePolicy.role & "context-only"
	}
})

#Applicability: close({
	scopes: [...#ApplicabilityScope] & [_, ...]
	limits: [...#NonEmptyString]
})

#Concept: close({
	id:        #ConceptID
	term:      #NonEmptyString
	statement: #NonEmptyString
	relations: [...#NonEmptyString]
	applicability: #Applicability
	observationModes: [...#ObservationMode] & [_, ...]
	sources: [...#SourceReference] & [_, ...]
	applicationVocabulary: false
})

#ConceptCatalog: close({
	id:                "cue-lattice-concept-catalog-v1"
	authorityID:       "cue-upstream-authority-v1"
	authorityRevision: upstream.#GitCommit
	concepts: {[#ConceptID]: #Concept}
})
