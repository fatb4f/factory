package catalog

import (
	"list"
	upstream "github.com/fatb4f/factory/cue-skill/lattice/conformance/upstream"
)

let spec = "language-specification"
let api = "go-api-value"
let tests = "subsumption-tests"
let cli = "cli-vet"

catalog: #ConceptCatalog & {
	id:                "cue-lattice-concept-catalog-v1"
	authorityID:       upstream.authority.id
	authorityRevision: upstream.authority.revision
	concepts: close({
		"directional-subsumption": {
			id:        "directional-subsumption", term: "instance and subsumption partial order"
			statement: "A specific value is at or below a more general value; the direction is not interchangeable with successful unification."
			relations: ["specific ⊑ general", "general subsumes specific"]
			applicability: {scopes: ["all-values"], limits: ["The order symbol is specification notation, not a CUE language operator."]}
			observationModes: ["go-api-subsume", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:591-632", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Subsume", use: "constrains"},
				{artifact: tests, locatorKind: "test-family", locator: "internal/core/subsume", use: "corroborates"},
			]
			applicationVocabulary: false
		}
		"top-and-bottom": {
			id:        "top-and-bottom", term: "top and bottom bounds"
			statement: "Top is the unconstrained upper bound and bottom is the lower bound representing semantic inconsistency or evaluation error."
			relations: ["v ⊑ _", "_|_ ⊑ v", "v & _ = v", "v & _|_ = _|_"]
			applicability: {scopes: ["all-values"], limits: ["Infrastructure and structural command failures are not semantic bottom."]}
			observationModes: ["cue-language-expression", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:886-912", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.BottomKind and cue.TopKind", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"atoms-basic-types-concreteness": {
			id:        "atoms-basic-types-concreteness", term: "atoms, basic types, and recursive concreteness"
			statement: "Atoms have only themselves and bottom as instances; basic types order above their concrete instances; concreteness is recursive for regular struct fields."
			relations: ["atom instances = {atom, bottom}", "concrete atom ⊑ basic type"]
			applicability: {scopes: ["primitive-values", "struct-values"], limits: ["Definitions and hidden fields are not regular emitted data fields."]}
			observationModes: ["go-api-validate", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:591-657", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Validate and cue.Concrete", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"meet-unification": {
			id:        "meet-unification", term: "meet by unification"
			statement: "Unification is the greatest lower bound and is commutative, associative, and idempotent."
			relations: ["a & b = glb(a,b)", "a & a = a", "a & _ = a", "a & _|_ = _|_"]
			applicability: {scopes: ["all-values"], limits: ["Successful unification establishes compatibility, not directional subsumption by itself."]}
			observationModes: ["cue-language-expression", "go-api-unify", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:658-684", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Unify", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"join-disjunction": {
			id:        "join-disjunction", term: "join by disjunction"
			statement: "Disjunction is the least upper bound, is commutative, associative, and idempotent, and normalizes alternatives subsumed by more general alternatives."
			relations: ["a | b = lub(a,b)", "a | a = a", "a | _|_ = a", "a | _ = _"]
			applicability: {scopes: ["plain-values"], limits: ["Marked disjunctions carry additional default-pair semantics."]}
			observationModes: ["cue-language-expression", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:685-752", use: "defines"}]
			applicationVocabulary: false
		}
		"distribution": {
			id:        "distribution", term: "unification distribution over disjunction"
			statement: "For supported values, unification with a disjunction distributes over each alternative."
			relations: ["(a0 | ... | an) & b = (a0 & b) | ... | (an & b)"]
			applicability: {scopes: ["plain-values"], limits: ["Defaults and excluded forms require separate sourced treatment."]}
			observationModes: ["cue-language-expression", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:704-719", use: "defines"}]
			applicationVocabulary: false
		}
		"marked-disjunction-defaults": {
			id:        "marked-disjunction-defaults", term: "marked disjunction and value-default pairs"
			statement: "A marked disjunction associates admissible values with selected defaults and follows distinct unification, disjunction, and subsumption rules."
			relations: ["default d satisfies d ⊑ v", "marked and unmarked terms normalize through U, D, and M rules"]
			applicability: {scopes: ["default-bearing-values"], limits: ["Default selection is not ordinary concrete equality."]}
			observationModes: ["cue-language-expression", "go-api-subsume", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:753-885", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Default", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"monotonic-refinement": {
			id:        "monotonic-refinement", term: "directional monotonic refinement"
			statement: "A transformation does not widen when its effective result remains an instance of its prior effective subject."
			relations: ["after ⊑ before"]
			applicability: {scopes: ["all-values"], limits: ["Exact key equality and non-bottom compatibility are supporting checks only."]}
			observationModes: ["go-api-subsume", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:591-684", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Subsume", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"struct-ordering": {
			id:        "struct-ordering", term: "struct ordering and unification"
			statement: "A struct instance defines every field required by the more general struct with field values ordered in the same direction."
			relations: ["a ⊑ b when every field of b exists in a and a.f ⊑ b.f"]
			applicability: {scopes: ["struct-values"], limits: ["Closure adds restrictions beyond open-struct field ordering."]}
			observationModes: ["go-api-subsume", "cue-language-expression", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1045-1113", use: "defines"}]
			applicationVocabulary: false
		}
		"field-constraint-ordering": {
			id:        "field-constraint-ordering", term: "regular, required, and optional field ordering"
			statement: "Regular fields are more specific than required constraints, which are more specific than optional constraints for the same field value."
			relations: ["{a: x} ⊑ {a!: x} ⊑ {a?: x}"]
			applicability: {scopes: ["struct-values"], limits: ["Optional bottom does not invalidate the containing struct until the field is defined."]}
			observationModes: ["cue-language-expression", "go-api-subsume", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1116-1159", use: "defines"}]
			applicationVocabulary: false
		}
		"pattern-constraints-ellipsis": {
			id:        "pattern-constraints-ellipsis", term: "pattern constraints and ellipsis"
			statement: "Pattern constraints apply values to matching labels, while ellipsis controls openness and remaining-field constraints."
			relations: ["pattern & label != bottom selects the constraint"]
			applicability: {scopes: ["struct-values"], limits: ["Unimplemented default-constraint forms remain excluded where the specification says so."]}
			observationModes: ["cue-language-expression", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1216-1260", use: "defines"}]
			applicationVocabulary: false
		}
		"explicit-struct-closure": {
			id:        "explicit-struct-closure", term: "open and closed struct boundary"
			statement: "Structs are open by default; explicit close and recursive definition closure constrain additional fields according to declared labels and patterns."
			relations: ["open instances may add fields", "closed instances may add only permitted fields"]
			applicability: {scopes: ["struct-values"], limits: ["Explicit close and definition closure remain separate mechanisms."]}
			observationModes: ["cue-language-expression", "go-api-subsume", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1363-1444", use: "defines"}]
			applicationVocabulary: false
		}
		"embedding-closure": {
			id:        "embedding-closure", term: "embedding and closure interaction"
			statement: "Embedding contributes a value structurally and has documented interactions with closed structures that differ from ordinary field selection."
			relations: ["{A} = A for embedded A"]
			applicability: {scopes: ["struct-values"], limits: ["Non-struct embeddings restrict regular sibling fields."]}
			observationModes: ["cue-language-expression", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1445-1490", use: "defines"}]
			applicationVocabulary: false
		}
		"definition-closure": {
			id:        "definition-closure", term: "recursive definition closure"
			statement: "Referencing a definition recursively closes it and rejects fields not already defined or explicitly permitted."
			relations: ["definition reference implies recursive closure"]
			applicability: {scopes: ["struct-values"], limits: ["Definition closure is distinct from an explicit close call and embedding may alter the interaction."]}
			observationModes: ["cue-language-expression", "go-api-subsume", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1491-1558", use: "defines"}]
			applicationVocabulary: false
		}
		"list-ordering": {
			id:        "list-ordering", term: "open and closed list ordering"
			statement: "Lists are ordered sequences with exact or open cardinality and element constraints; their subsumption relation follows the documented structural model."
			relations: ["closed length is exact", "open length has a lower bound and unbounded upper bound"]
			applicability: {scopes: ["list-values"], limits: ["List order is semantically significant."]}
			observationModes: ["go-api-subsume", "cue-language-expression", "specification-analysis"]
			sources: [{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:1767-1805", use: "defines"}]
			applicationVocabulary: false
		}
		"cycles-recursion-fixed-points": {
			id:        "cycles-recursion-fixed-points", term: "cycle, recursion, and fixed-point classes"
			statement: "References may form graph structures whose benign, convergent, incomplete, arithmetic, and structural cycle outcomes require separate classification."
			relations: ["evaluation seeks a well-formed fixed point", "a cross-reference alone is not a cycle verdict"]
			applicability: {scopes: ["evaluation-state", "struct-values"], limits: ["The implementation reference is explanatory; executable classification is required before semantic admission."]}
			observationModes: ["go-api-validate", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:2925-3093", use: "defines"},
				{artifact: "implementation-reference", locatorKind: "line-range", locator: "doc/ref/impl.md:30-47", use: "context"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Validate and cue.Value.Err", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"selector-outcomes": {
			id:        "selector-outcomes", term: "selector and index outcomes"
			statement: "Selectors and indexes distinguish successful lookup, missing fields, incomplete lookup, non-struct operands, out-of-range indexes, and default selection."
			relations: ["missing selector yields bottom with incomplete cause", "out-of-range index yields bottom"]
			applicability: {scopes: ["evaluation-state", "struct-values", "list-values"], limits: ["Diagnostic wording is not the semantic outcome identity."]}
			observationModes: ["cue-language-expression", "go-api-syntax", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:2109-2234", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.LookupPath and cue.Value.Index", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"validation-finality-exportability": {
			id:        "validation-finality-exportability", term: "validation, concreteness, finality, and exportability"
			statement: "Validation options and syntax or export operations observe different properties and must not be collapsed into one success state."
			relations: ["concrete implies no incomplete regular data fields", "finality and exportability are independently observed"]
			applicability: {scopes: ["evaluation-state", "tooling-boundary"], limits: ["Later slices must bind exact API modes and fact-only outcomes."]}
			observationModes: ["go-api-validate", "go-api-syntax", "cue-cli-structural"]
			sources: [
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Validate, cue.Concrete, cue.Final, cue.Value.Syntax", use: "defines"},
				{artifact: cli, locatorKind: "line-range", locator: "cmd/cue/cmd/vet.go:27-35", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"semantic-outcomes": {
			id:        "semantic-outcomes", term: "semantic outcome distinctions"
			statement: "Accept, semantic bottom, incomplete, concrete, final, exportable, structural failure, and infrastructure failure are distinct observation classes."
			relations: ["bottom is semantic", "incomplete is not bottom", "CLI failure is not bottom"]
			applicability: {scopes: ["evaluation-state", "tooling-boundary"], limits: ["The full closed outcome taxonomy is refined by later executable slices."]}
			observationModes: ["go-api-validate", "go-api-syntax", "cue-cli-structural", "specification-analysis"]
			sources: [
				{artifact: spec, locatorKind: "line-range", locator: "doc/ref/spec.md:886-912", use: "defines"},
				{artifact: api, locatorKind: "go-symbol", locator: "cue.Value.Validate, cue.Value.Syntax, cue.Value.Err", use: "constrains"},
				{artifact: cli, locatorKind: "command-contract", locator: "cue vet -c and -c=false", use: "constrains"},
			]
			applicationVocabulary: false
		}
		"structural-cli-gates": {
			id:        "structural-cli-gates", term: "structural CUE CLI gates"
			statement: "CUE CLI validation can require or waive concreteness, but command success or failure does not establish directional subsumption or semantic bottom."
			relations: ["cue vet -c requires concrete regular fields", "cue vet -c=false permits incomplete values"]
			applicability: {scopes: ["tooling-boundary"], limits: ["Structural gates remain separate from semantic operations."]}
			observationModes: ["cue-cli-structural"]
			sources: [{artifact: cli, locatorKind: "line-range", locator: "cmd/cue/cmd/vet.go:27-35", use: "defines"}]
			applicationVocabulary: false
		}
	})
}

conceptIDs: list.SortStrings([for id, _ in catalog.concepts {id}])
expectedConceptIDs: [
	"atoms-basic-types-concreteness", "cycles-recursion-fixed-points", "definition-closure", "directional-subsumption",
	"distribution", "embedding-closure", "explicit-struct-closure", "field-constraint-ordering",
	"join-disjunction", "list-ordering", "marked-disjunction-defaults", "meet-unification",
	"monotonic-refinement", "pattern-constraints-ellipsis", "selector-outcomes", "semantic-outcomes",
	"struct-ordering", "structural-cli-gates", "top-and-bottom", "validation-finality-exportability",
]

_conceptIdentityProof: {
	for id, concept in catalog.concepts {
		"\(id)-key":          concept.id & id
		"\(id)-domain":       concept.applicationVocabulary & false
		"\(id)-source-count": len(concept.sources) > 0
		for index, source in concept.sources {
			"\(id)-source-\(index)": upstream.authority.artifacts[source.artifact].id & source.artifact
		}
	}
}

_normativeCoverageProof: {
	for id, concept in catalog.concepts {
		let definingAdmissionSources = [for source in concept.sources
			if source.use == "defines" &&
				upstream.authority.boundary[upstream.authority.artifacts[source.artifact].class].requiredForAdmission {
				source
			}]
		"\(id)-required-defining-source": len(definingAdmissionSources) > 0
	}
}

sourceInventory: {
	for id, concept in catalog.concepts {
		"\(id)": {conceptID: id, references: concept.sources}
	}
}
sourceInventoryComplete: len(sourceInventory) == len(catalog.concepts)

catalogComplete: conceptIDs == expectedConceptIDs && len(conceptIDs) == 20 &&
	len(_conceptIdentityProof) >= len(conceptIDs)*4 &&
	len(_normativeCoverageProof) == len(conceptIDs) &&
	!list.Contains([for _, covered in _normativeCoverageProof {covered}], false) &&
	catalog.authorityRevision == upstream.authority.revision && sourceInventoryComplete
