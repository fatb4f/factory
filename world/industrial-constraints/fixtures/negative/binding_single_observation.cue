package negative

import domain "github.com/fatb4f/factory/contracts/world/industrial-constraints:industrialconstraints"

// A binding constraint must be backed by multi-record correlation and at least
// two evidence records. This fixture is intentionally invalid.
invalidBinding: domain.#ConstraintClaim & {
	kind:      "constraint-claim"
	id:        "fixture.constraint.invalid-binding"
	subject:   {id: "fixture.project"}
	mechanism: "capital"
	state:     "binding"
	basis:     "single-observation"
	evidence: [
		{record: {kind: "event", id: "fixture.event.only"}, class: "event"},
	]
	affectedRelations: []
	confidence:        "low"
}
