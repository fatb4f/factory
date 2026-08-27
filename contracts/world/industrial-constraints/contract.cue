package industrialconstraints

#DomainID: "world.industrial-constraints"

#AuthorityBoundary: close({
	semantic:   "contracts/world/industrial-constraints"
	procedure:  "world/industrial-constraints/.agents"
	queries:    "world/industrial-constraints/queries"
	projections: "world/industrial-constraints/projections"
	runs:       "world/industrial-constraints/runs"
})

#Contract: close({
	id:             #DomainID
	kind:           "world"
	canonicalState: "relational"
	graphRole:      "projection"
	constraintRole: "evidence-backed-claim"
	authority:      #AuthorityBoundary
})

contract: #Contract & {
	id: "world.industrial-constraints"
	authority: {
		semantic:   "contracts/world/industrial-constraints"
		procedure:  "world/industrial-constraints/.agents"
		queries:    "world/industrial-constraints/queries"
		projections: "world/industrial-constraints/projections"
		runs:       "world/industrial-constraints/runs"
	}
}
