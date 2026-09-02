package uqamcatalog

import state "github.com/fatb4f/factory/contracts/state"

#ProjectionFile: close({
	name: "entities.jsonl" |
		"entity_evidence.jsonl" |
		"observations.jsonl" |
		"relation_evidence.jsonl" |
		"relations.jsonl"
	sha256: state.#SHA256
	rows:   int & >=0
})

#ProjectionManifest: close({
	apiVersion:               "factory.uqam-catalog.projections/v1"
	kind:                     "UQAMCatalogRelationalProjection"
	source_run_id:            state.#RunID
	source_normalized_digest: state.#SHA256
	projection:               "catalog-relational-v1"
	files: [
		#ProjectionFile & {name: "entities.jsonl"},
		#ProjectionFile & {name: "entity_evidence.jsonl"},
		#ProjectionFile & {name: "observations.jsonl"},
		#ProjectionFile & {name: "relation_evidence.jsonl"},
		#ProjectionFile & {name: "relations.jsonl"},
	]
})
