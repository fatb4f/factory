package industrialconstraints

#DomainID: "world.industrial-constraints"

#GeographyScope: "canada" | "quebec"

#IndustrialSurface:
	"semiconductors" |
	"advanced-packaging" |
	"cleanrooms" |
	"ai-compute" |
	"transformers-switchgear" |
	"electricity-grid" |
	"critical-minerals"

#InstitutionScope:
	"government-of-canada" |
	"government-of-quebec" |
	"hydro-quebec" |
	"nrc" |
	"nserc" |
	"ised" |
	"nrcan" |
	"c2mi" |
	"cmc"

#SelectionClass: "selected-universities" | "selected-operators-suppliers"

#Scope: close({
	geographies:       [...#GeographyScope] & [_, ...]
	industrialSurfaces: [...#IndustrialSurface] & [_, ...]
	institutions:      [...#InstitutionScope] & [_, ...]
	selectionClasses:  [...#SelectionClass] & [_, ...]
})

#AuthorityBoundary: close({
	semantic:    "contracts/world/industrial-constraints"
	procedure:   "world/industrial-constraints/.agents"
	queries:     "world/industrial-constraints/queries"
	projections: "world/industrial-constraints/projections"
	runs:        "world/industrial-constraints/runs"
})

#Contract: close({
	id:             #DomainID
	kind:           "world"
	canonicalState: "relational"
	graphRole:      "projection"
	constraintRole: "evidence-backed-claim"
	scope:          #Scope
	authority:      #AuthorityBoundary
	publication: close({
		contract: "contracts/world/industrial-constraints/public.cue"
		template: "world/industrial-constraints/.agents/report-template.md"
	})
})

contract: #Contract & {
	id: "world.industrial-constraints"
	scope: {
		geographies: ["canada", "quebec"]
		industrialSurfaces: [
			"semiconductors",
			"advanced-packaging",
			"cleanrooms",
			"ai-compute",
			"transformers-switchgear",
			"electricity-grid",
			"critical-minerals",
		]
		institutions: [
			"government-of-canada",
			"government-of-quebec",
			"hydro-quebec",
			"nrc",
			"nserc",
			"ised",
			"nrcan",
			"c2mi",
			"cmc",
		]
		selectionClasses: ["selected-universities", "selected-operators-suppliers"]
	}
	authority: {
		semantic:    "contracts/world/industrial-constraints"
		procedure:   "world/industrial-constraints/.agents"
		queries:     "world/industrial-constraints/queries"
		projections: "world/industrial-constraints/projections"
		runs:        "world/industrial-constraints/runs"
	}
	publication: {
		contract: "contracts/world/industrial-constraints/public.cue"
		template: "world/industrial-constraints/.agents/report-template.md"
	}
}
