package probefixtures

import "github.com/fatb4f/factory/cue-skill/probe"

validConflict: probe.#ProbeSpec & {
	id:        "reference-conflict", version: "v1", family: "negative-fixture", candidate: "reference-accepted"
	operation: "negative-fixture-conflict"
	module: {moduleRoot: ".", package: "conflictfixture", declaredFiles: ["reference.cue"], value: "authority"}
	operands: {authority: "authority", mutation: "mutation"}
	inputs: {}
	policy: {permitted: {bottoms: true}, requiredAny: ["bottoms"], requiredEach: ["bottoms"]}
}

validIngress: probe.#ProbeSpec & {
	id:        "reference-ingress", version: "v1", family: "closed-ingress", candidate: "reference-accepted"
	operation: "ingress-reject"
	module: {moduleRoot: ".", package: "invalidingress", declaredFiles: ["raw.cue"], value: "raw.unknownField"}
	operands: {raw: "raw.unknownField", schema: "kernel.#ClosedObligationState"}
	inputs: {}
	policy: {permitted: {bottoms: true}, requiredAny: ["bottoms"], requiredEach: []}
}
