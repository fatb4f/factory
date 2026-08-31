package industrialconstraints

#ProjectionPurpose:
	"acquisition" |
	"normalization" |
	"identity" |
	"admission" |
	"graph" |
	"correlation" |
	"constraint-evidence" |
	"claim" |
	"assessment" |
	"constraint"

#ProjectionState: "candidate" | "normalized" | "admitted" | "derived"

#LogicalRelation:
	"documents" |
	"entities" |
	"observations" |
	"events" |
	"measurements" |
	"relations" |
	"claims" |
	"assessments" |
	"constraints"

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
	outputs: [#ProjectionOutput, ...#ProjectionOutput]
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
		claims:       "claims"
		assessments:  "assessments"
		constraints:  "constraints"
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
		claims:       "claims"
		assessments:  "assessments"
		constraints:  "constraints"
	}
}

projections: close({
	"acquire-gdelt-events": #Projection & {
		id:      "acquire-gdelt-events"
		purpose: "acquisition"
		inputs: [{kind: "source-channel", source: "gdelt", channel: "events"}]
		outputs: [{relation: "documents", state: "candidate"}]
		backend: {read: "bigquery", write: "memory"}
	}

	"acquire-google-patents": #Projection & {
		id:      "acquire-google-patents"
		purpose: "acquisition"
		inputs: [{kind: "source-channel", source: "google-bigquery", channel: "google-patents"}]
		outputs: [{relation: "documents", state: "candidate"}]
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
		outputs: [{relation: "documents", state: "candidate"}]
		backend: {read: "adapter", write: "memory"}
	}

	"acquire-measurements": #Projection & {
		id:      "acquire-measurements"
		purpose: "acquisition"
		inputs: [
			{kind: "source-channel", source: "statcan", channel: "tables"},
			{kind: "source-channel", source: "hydro-quebec", channel: "open-data"},
		]
		outputs: [{relation: "measurements", state: "candidate"}]
		backend: {read: "adapter", write: "memory"}
	}

	"normalize-documents": #Projection & {
		id:      "normalize-documents"
		purpose: "normalization"
		inputs: [{kind: "relation", relation: "documents", state: "candidate"}]
		outputs: [{relation: "documents", state: "normalized"}]
		backend: {read: "memory", write: "memory"}
	}

	"extract-observations": #Projection & {
		id:      "extract-observations"
		purpose: "normalization"
		inputs: [{kind: "relation", relation: "documents", state: "candidate"}]
		outputs: [{relation: "observations", state: "normalized"}]
		backend: {read: "memory", write: "memory"}
	}

	"extract-events": #Projection & {
		id:      "extract-events"
		purpose: "normalization"
		inputs: [{kind: "relation", relation: "documents", state: "candidate"}]
		outputs: [{relation: "events", state: "normalized"}]
		backend: {read: "memory", write: "memory"}
	}

	"normalize-measurements": #Projection & {
		id:      "normalize-measurements"
		purpose: "normalization"
		inputs: [{kind: "relation", relation: "measurements", state: "candidate"}]
		outputs: [{relation: "measurements", state: "normalized"}]
		backend: {read: "memory", write: "memory"}
	}

	"resolve-identities": #Projection & {
		id:      "resolve-identities"
		purpose: "identity"
		inputs: [
			{kind: "relation", relation: "observations", state: "normalized"},
			{kind: "relation", relation: "events", state: "normalized"},
		]
		outputs: [{relation: "entities", state: "normalized"}]
		backend: {read: "memory", write: "memory"}
	}

	"extract-relations": #Projection & {
		id:      "extract-relations"
		purpose: "normalization"
		inputs: [
			{kind: "relation", relation: "observations", state: "normalized"},
			{kind: "relation", relation: "events", state: "normalized"},
			{kind: "relation", relation: "entities", state: "normalized"},
		]
		outputs: [{relation: "relations", state: "normalized"}]
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
		outputs: [
			{relation: "documents", state: "admitted"},
			{relation: "entities", state: "admitted"},
			{relation: "observations", state: "admitted"},
			{relation: "events", state: "admitted"},
			{relation: "measurements", state: "admitted"},
			{relation: "relations", state: "admitted"},
		]
		backend: {read: "memory", write: "duckdb"}
	}

	"project-graph-nodes": #Projection & {
		id:      "project-graph-nodes"
		purpose: "graph"
		inputs: [{kind: "relation", relation: "entities", state: "admitted"}]
		outputs: [{relation: "graph-nodes", state: "derived"}]
		backend: {read: "duckdb", write: "memory"}
	}

	"project-graph-edges": #Projection & {
		id:      "project-graph-edges"
		purpose: "graph"
		inputs: [{kind: "relation", relation: "relations", state: "admitted"}]
		outputs: [{relation: "graph-edges", state: "derived"}]
		backend: {read: "duckdb", write: "memory"}
	}

	"project-supply-pressure": #Projection & {
		id:      "project-supply-pressure"
		purpose: "constraint-evidence"
		inputs: [
			{kind: "relation", relation: "events", state: "admitted"},
			{kind: "relation", relation: "measurements", state: "admitted"},
			{kind: "relation", relation: "relations", state: "admitted"},
		]
		outputs: [{relation: "constraint-evidence", state: "derived"}]
		backend: {read: "duckdb", write: "memory"}
	}

	"project-infrastructure-dependency": #Projection & {
		id:      "project-infrastructure-dependency"
		purpose: "constraint-evidence"
		inputs: [
			{kind: "relation", relation: "relations", state: "admitted"},
			{kind: "relation", relation: "events", state: "admitted"},
			{kind: "relation", relation: "measurements", state: "admitted"},
		]
		outputs: [{relation: "constraint-evidence", state: "derived"}]
		backend: {read: "duckdb", write: "memory"}
	}

	"derive-constraint-claims": #Projection & {
		id:      "derive-constraint-claims"
		purpose: "claim"
		inputs: [{kind: "relation", relation: "constraint-evidence", state: "derived"}]
		outputs: [{relation: "claims", state: "derived"}]
		backend: {read: "memory", write: "memory"}
	}

	"assess-constraint-claims": #Projection & {
		id:      "assess-constraint-claims"
		purpose: "assessment"
		inputs: [{kind: "relation", relation: "claims", state: "derived"}]
		outputs: [{relation: "assessments", state: "derived"}]
		backend: {read: "memory", write: "memory"}
	}

	"derive-constraints": #Projection & {
		id:      "derive-constraints"
		purpose: "constraint"
		inputs: [
			{kind: "relation", relation: "claims", state: "derived"},
			{kind: "relation", relation: "assessments", state: "derived"},
		]
		outputs: [{relation: "constraints", state: "derived"}]
		backend: {read: "memory", write: "memory"}
	}

	"admit-qualified-constraints": #Projection & {
		id:      "admit-qualified-constraints"
		purpose: "admission"
		inputs: [
			{kind: "relation", relation: "claims", state: "derived"},
			{kind: "relation", relation: "assessments", state: "derived"},
			{kind: "relation", relation: "constraints", state: "derived"},
		]
		outputs: [
			{relation: "claims", state: "admitted"},
			{relation: "assessments", state: "admitted"},
			{relation: "constraints", state: "admitted"},
		]
		backend: {read: "memory", write: "duckdb"}
	}

	"project-funding-response": #Projection & {
		id:      "project-funding-response"
		purpose: "correlation"
		inputs: [
			{kind: "relation", relation: "constraints", state: "admitted"},
			{kind: "relation", relation: "events", state: "admitted"},
			{kind: "relation", relation: "relations", state: "admitted"},
		]
		outputs: [{relation: "constraint-evidence", state: "derived"}]
		backend: {read: "duckdb", write: "memory"}
	}
})

_projectionIdentity: [for id, projection in projections {
	_value: projection & {id: id}
}]
