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
#ExecutionPhase: "event-watch" | "relational-pipeline"
#EventWatchOutcome: "events_observed" | "no_material_events" | "source_gap"
#RelationalPipelineOutcome: "admitted" | "rejected" | "coverage_gap"

#Scope: close({
	geographies:        [...#GeographyScope] & [_, ...]
	industrialSurfaces: [...#IndustrialSurface] & [_, ...]
	institutions:       [...#InstitutionScope] & [_, ...]
	selectionClasses:   [...#SelectionClass] & [_, ...]
})

#AuthorityBoundary: close({
	semantic:    "contracts/world/industrial-constraints"
	procedure:   "world/industrial-constraints/.agents"
	queries:     "world/industrial-constraints/queries"
	projections: "world/industrial-constraints/projections"
	runs:        "world/industrial-constraints/runs"
})

#EventWatchExecution: close({
	phase:                         "event-watch"
	admittedState:                 "source-qualified-event-bundles"
	sourceQualifiedEventTracking:  true
	relationalProjectionRequired:  false
	canonicalIdentityRequired:     false
	graphQualificationEnabled:     false
	constraintQualificationEnabled: false
	industrialSignalsSnapshotRequired: false
	outcomes: ["events_observed", "no_material_events", "source_gap"]
})

#RelationalPipelineExecution: close({
	phase:                         "relational-pipeline"
	admittedState:                 "relational"
	sourceQualifiedEventTracking:  true
	relationalProjectionRequired:  true
	canonicalIdentityRequired:     true
	graphQualificationEnabled:     true
	constraintQualificationEnabled: true
	industrialSignalsSnapshotRequired: true
	outcomes: ["admitted", "rejected", "coverage_gap"]
})

#Contract: close({
	id:             #DomainID
	kind:           "world"
	execution:      #EventWatchExecution | #RelationalPipelineExecution
	pipelineTarget: #RelationalPipelineExecution
	pipelineInput:  #IndustrialSignalsInputContract
	graphRole:      "constraint-projection"
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
	execution: #EventWatchExecution & {
		phase: "event-watch"
	}
	pipelineTarget: #RelationalPipelineExecution & {
		phase: "relational-pipeline"
	}
	pipelineInput: {
		sourceDomain: "world.industrial-signals"
		admission:    "snapshot-qualified"
		schema:       "#RelationalConstraintInput"
	}
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
