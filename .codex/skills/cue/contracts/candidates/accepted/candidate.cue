package accepted

import kernel "github.com/fatb4f/factory/cue-skill/kernel"

candidate: close({
	id:    "reference-accepted"
	class: "accepted"
	state: kernel.#ClosedObligationState
}) & {
	state: {
		id: "reference-state"
		resources: {
			input: {id: "input", path: "input.cue", role: "authority", visibility: "internal"}
			output: {id: "output", path: "output.cue", role: "generated-output", visibility: "public"}
		}
		operations: {
			build: {
				id: "build", kind: "derive", description: "derive output"
				reads: {input: true}, writes: {}, creates: {output: true}
				requiresGates: {schema: true}, requiresWitnesses: {source: true}
			}
		}
		gates: {schema: {id: "schema", description: "schema gate", required: true}}
		witnesses: {source: {id: "source", description: "source witness", required: true}}
	}
}
