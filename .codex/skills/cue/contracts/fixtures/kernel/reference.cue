package kernelfixture

import kernel "github.com/fatb4f/factory/cue-skill/kernel"

#ReferenceState: kernel.#ClosedObligationState & {
	id: "fixture-state"
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

referenceState: #ReferenceState
referenceKeys: (kernel.#StateKeySet & {state: referenceState})
referenceOperationKeys: (kernel.#OperationRefKeySet & {operation: referenceState.operations.build})
constructedState: (kernel.#MakeClosedObligationState & {in: {
	id: "fixture-state"
	resources: {
		input: {id: "input", path: "input.cue", role: "authority"}
		output: {id: "output", path: "output.cue", role: "generated-output"}
	}
	operations: {
		build: {
			id: "build", kind: "derive", description: "derive output"
			reads: {input: true}, writes: {}, creates: {output: true}
			requiresGates: {schema: true}, requiresWitnesses: {source: true}
		}
	}
	gates: {schema: {id: "schema", description: "schema gate"}}
	witnesses: {source: {id: "source", description: "source witness"}}
}}).out
exactKeyCompatibility: (kernel.#ExactKeyCompatibilityProof & {authority: referenceState, target: constructedState})

kernelSatisfaction: referenceKeys.resources == ["input", "output"] &&
	referenceKeys.operations == ["build"] &&
	referenceKeys.gates == ["schema"] &&
	referenceKeys.witnesses == ["source"] &&
	referenceOperationKeys.reads == ["input"] &&
	referenceOperationKeys.writes == [] &&
	referenceOperationKeys.creates == ["output"] &&
	referenceOperationKeys.requiresGates == ["schema"] &&
	referenceOperationKeys.requiresWitnesses == ["source"] &&
	constructedState.resources.output.role == "generated-output" &&
	constructedState.gates.schema.required == true &&
	constructedState.witnesses.source.required == true
