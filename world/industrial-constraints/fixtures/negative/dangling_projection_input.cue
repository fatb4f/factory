package negative

import domain "github.com/fatb4f/factory/contracts/world/industrial-constraints:industrialconstraints"

// The consumer asks for events:admitted but the only producer emits
// documents:candidate. #ProjectionGraphIntegrity must reject this graph.
danglingProjectionInput: domain.#ProjectionGraphIntegrity & {
	projections: {
		producer: domain.#Projection & {
			id:      "producer"
			purpose: "acquisition"
			inputs: [{
				kind:    "source-channel"
				source:  "gdelt"
				channel: "events"
			}]
			outputs: [{relation: "documents", state: "candidate"}]
			backend: {read: "bigquery", write: "memory"}
		}
		consumer: domain.#Projection & {
			id:      "consumer"
			purpose: "constraint-evidence"
			inputs: [{kind: "relation", relation: "events", state: "admitted"}]
			outputs: [{relation: "constraint-evidence", state: "derived"}]
			backend: {read: "memory", write: "memory"}
		}
	}
}
