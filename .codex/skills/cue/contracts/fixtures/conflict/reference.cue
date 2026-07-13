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

let authorityOperand = authority
let mutationOperand = mutation

fixture: kernel.#NegativeFixtureSpec & {
	id:          "visibility-conflict"
	description: "independently valid states conflict destructively"
	polarity:    "negative"
	authority:   authorityOperand
	invalid:     mutationOperand
	proofStatus: "requiresDestructiveProbe"
}

operandsValid: authority.id == mutation.id &&
	authority.resources.document.visibility == "internal" &&
	mutation.resources.document.visibility == "restricted"
