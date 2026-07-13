package conflictfixture

import kernel "github.com/fatb4f/factory/cue-skill/kernel"

#State: kernel.#ClosedObligationState & {
	id: "conflict-state"
	resources: {document: {id: "document", path: "document.cue", role: "authority"}}
	operations: {}
	gates: {}
	witnesses: {}
}

// Both operands validate independently. The runner's
// negative-fixture-conflict operation performs their destructive unification.
authority: #State & {resources: {document: {visibility: "internal"}}}
mutation: #State & {resources: {document: {visibility: "restricted"}}}
