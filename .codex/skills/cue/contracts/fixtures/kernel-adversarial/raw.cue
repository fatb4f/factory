package kerneladversarial

import kernel "github.com/fatb4f/factory/cue-skill/kernel"

#ClosedStateSchema:           kernel.#ClosedObligationState
#ExactKeyCompatibilitySchema: kernel.#ExactKeyCompatibilityProof

base: kernel.#ClosedObligationState & {
	id: "base"
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
}

raw: {
	danglingRead: {
		id: "dangling-read"
		resources: {input: {id: "input", path: "input.cue", role: "authority"}}
		operations: {inspect: {
			id: "inspect", kind: "inspect", description: "dangling read"
			reads: {missing: true}, writes: {}, creates: {}, requiresGates: {}, requiresWitnesses: {}
		}}
		gates: {}, witnesses: {}
	}
	danglingWrite: {
		id: "dangling-write"
		resources: {input: {id: "input", path: "input.cue", role: "authority"}}
		operations: {update: {
			id: "update", kind: "update", description: "dangling write"
			reads: {}, writes: {missing: true}, creates: {}, requiresGates: {}, requiresWitnesses: {}
		}}
		gates: {}, witnesses: {}
	}
	danglingCreate: {
		id: "dangling-create"
		resources: {}
		operations: {build: {
			id: "build", kind: "derive", description: "dangling create"
			reads: {}, writes: {}, creates: {missing: true}, requiresGates: {}, requiresWitnesses: {}
		}}
		gates: {}, witnesses: {}
	}
	danglingGate: {
		id: "dangling-gate", resources: {}
		operations: {build: {
			id: "build", kind: "derive", description: "dangling gate"
			reads: {}, writes: {}, creates: {}, requiresGates: {missing: true}, requiresWitnesses: {}
		}}, gates: {}, witnesses: {}
	}
	danglingWitness: {
		id: "dangling-witness", resources: {}
		operations: {build: {
			id: "build", kind: "derive", description: "dangling witness"
			reads: {}, writes: {}, creates: {}, requiresGates: {}, requiresWitnesses: {missing: true}
		}}, gates: {}, witnesses: {}
	}
	wrongCreateRole: {
		id: "wrong-create-role"
		resources: {output: {id: "output", path: "output.cue", role: "authority"}}
		operations: {build: {
			id: "build", kind: "derive", description: "wrong generated role"
			reads: {}, writes: {}, creates: {output: true}, requiresGates: {}, requiresWitnesses: {}
		}}
		gates: {}, witnesses: {}
	}
	extraStateKey: base & {resources: {extra: {id: "extra", path: "extra.cue", role: "authority"}}}
	missingStateKey: kernel.#ClosedObligationState & {
		id: "base"
		resources: {input: {id: "input", path: "input.cue", role: "authority"}}
		operations: {
			build: {
				id: "build", kind: "derive", description: "derive output"
				reads: {input: true}, writes: {}, creates: {}
				requiresGates: {schema: true}, requiresWitnesses: {source: true}
			}
		}
		gates: {schema: {id: "schema", description: "schema gate"}}
		witnesses: {source: {id: "source", description: "source witness"}}
	}
	widenedReads: base & {operations: {build: {reads: {output: true}}}}
	narrowedReads: kernel.#ClosedObligationState & {
		id:        "base"
		resources: base.resources
		operations: {
			build: {
				id: "build", kind: "derive", description: "derive output"
				reads: {}, writes: {}, creates: {output: true}
				requiresGates: {schema: true}, requiresWitnesses: {source: true}
			}
		}
		gates:     base.gates
		witnesses: base.witnesses
	}
}
