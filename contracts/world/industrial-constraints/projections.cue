package industrialconstraints

#ProjectionPurpose:
	"acquisition" |
	"normalization" |
	"identity" |
	"admission" |
	"graph" |
	"correlation" |
	"constraint-evidence"

#ProjectionState: "candidate" | "normalized" | "admitted" | "derived"

#LogicalRelation:
	"documents" |
	"entities" |
	"observations" |
	"events" |
	"measurements" |
	"relations"

#ProjectionRelation:
	#LogicalRelation |
	"graph-nodes" |
	"graph-edges" |
	"constraint-evidence"

#ProjectionInput:
	close({
		kind:    "source-channel"
		source:  #SourceID
		channel: #ChannelID
	}) |
	close({
		kind:     "relation"
		relation: #ProjectionRelation
		state:    #ProjectionState
	})

#ProjectionOutput: close({
	relation: #ProjectionRelation
	state:    #ProjectionState
})

#Projection: close({
	id:      string
	engine:  "ibis"
	purpose: #ProjectionPurpose
	inputs:  [...#ProjectionInput] & [_, ...]
	output:  #ProjectionOutput
	backend: close({
		read:  "bigquery" | "adapter" | "duckdb" | "memory"
		write: "duckdb" | "memory"
	})
	deterministic: true
})

#GraphNode: close({
	id:     #EntityID
	entity: #EntityRef
})

#GraphEdge: close({
	id:        #RecordID
	source:    #EntityRef
	target:    #EntityRef
	predicate: #Predicate
	evidence:  [...#RecordRef]
})

#AdmittedState: close({
	backend:     "duckdb"
	interchange: "parquet"
	relations: close({
		documents:    "documents"
		entities:     "entities"
		observations: "observations"
		events:       "events"
		measurements: "measurements"
		relations:    "relations"
	})
})

admittedState: #AdmittedState & {
	backend:     "duckdb"
	interchange: "parquet"
	relations: {
		documents:    "documents"
		entities:     "entities"
		observations: "observations"
		events:       "events"
		measurements: "measurements"
		relations:    "relations"
	}
}

projections: close({
	"acquire-gdelt-events": #Projection & {
		id:      "acquire-gdelt-events"
		purpose: "acquisition"
		inputs: [{kind: "source-channel", source: "gdelt", channel: "events"}]
		output: {relation: "documents", state: "candidate"}
		backend: {read: "bigquery", write: "memory"}
	}

	"acquire-google-patents": #Projection & {
		id:      "acquire-google-patents"
		purpose: "acquisition"
		inputs: [{kind: "source-channel", source: "google-bigquery", channel: "google-patents"}]
		output: {relation: "documents", state: "candidate"}
		backend: {read: "bigquery", write: "memory"}
	}

	"acquire-primary-records": #Projection & {
		id:      "acquire-primary-records"
		purpose: "acquisition"
		inputs: [
			{kind: "source-channel", source: "gc-grants", channel: "awards"},
			{kind: "source-channel", source: "canadabuys", channel: "procurement"},
			{kind: "source-channel", source: "quebec-enterprise-register", channel: "enterprises"},
		]
		output: {relation: "documents", state: "candidate"}
		backend: {read: "adapter", write: "memory"}
	}

	"acquire-measurements": #Projection & {
		id:      "acquire-measurements"
		purpose: "acquisition"
		inputs: [
			{kind: "source-channel", source: "statcan", channel: "tables"},
			{kind: "source-channel", source: "hydro-quebec", channel: "open-data"},
		]
		output: {relation: "measurements", state: "candidate"}
		backend: {read: "adapter", write: "memory"}
	}

	"normalize-source-records": #Projection & {
		id:      "normalize-source-records"
		purpose: "normalization"
		inputs: [
			{kind: "relation", relation: "documents", state: "candidate"},
			{kind: "relation", relation: "measurements", state: "candidate"},
		]
		output: {relation: "observations", state: "normalized"}
		backend: {read: "memory", write: "memory"}
	}

	"resolve-identities": #Projection & {
		id:      "resolve-identities"
		purpose: "identity"
		inputs: [{kind: "relation", relation: "observations", state: "normalized"}]
		output: {relation: "entities", state: "normalized"}
		backend: {read: "memory", write: "memory"}
	}

	"admit-relational-state": #Projection & {
		id:      "admit-relational-state"
		purpose: "admission"
		inputs: [
			{kind: "relation", relation: "documents", state: "normalized"},
			{kind: "relation", relation: "entities", state: "normalized"},
			{kind: "relation", relation: "observations", state: "normalized"},
			{kind: "relation", relation: "events", state: "normalized"},
			{kind: "relation", relation: "measurements", state: "normalized"},
			{kind: "relation", relation: "relations", state: "normalized"},
		]
		output: {relation: "relations", state: "admitted"}
		backend: {read: "memory", write: "duckdb"}
	}

	"project-graph-nodes": #Projection & {
		id:      "project-graph-nodes"
		purpose: "graph"
		inputs: [{kind: "relation", relation: "entities", state: "admitted"}]
		output: {relation: "graph-nodes", state: "derived"}
		backend: {read: "duckdb", write: "memory"}
	}

	"project-graph-edges": #Projection & {
		id:      "project-graph-edges"
		purpose: "graph"
		inputs: [{kind: "relation", relation: "relations", state: "admitted"}]
		output: {relation: "graph-edges", state: "derived"}
		backend: {read: "duckdb", write: "memory"}
	}
})

_projectionIdentity: [for id, projection in projections {
	_value: projection & {id: id}
}]
