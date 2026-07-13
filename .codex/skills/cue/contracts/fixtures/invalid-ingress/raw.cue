package invalidingress

import kernel "github.com/fatb4f/factory/cue-skill/kernel"

#ClosedStateSchema: kernel.#ClosedObligationState
#ResourceSchema:    kernel.#Resource

raw: {
	unknownField: {id: "bad", resources: {}, operations: {}, gates: {}, witnesses: {}, surprise: true}
	invalidKey: {id: "bad", resources: {"Not-Kebab": {id: "Not-Kebab"}}}
	danglingReference: {id: "bad", resources: {}, operations: {op: {id: "op", reads: {missing: true}}}, gates: {}, witnesses: {}}
	wrongGeneratedRole: {id: "bad", resources: {out: {id: "out", path: "out", role: "authority"}}, operations: {op: {id: "op", creates: {out: true}}}, gates: {}, witnesses: {}}
	malformedType: {id: 42}
	incomplete: {id: "bad"}
}
