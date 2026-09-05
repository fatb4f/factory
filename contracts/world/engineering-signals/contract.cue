package engineeringsignals

#DomainID: "world.engineering-signals"
#ExecutionPhase: "event-watch" | "engineering-graph"

#EngineeringSurface:
	"power-systems" |
	"power-electronics" |
	"semiconductors" |
	"advanced-packaging" |
	"thermal-management" |
	"energy-storage" |
	"grid-control" |
	"materials" |
	"manufacturing-process" |
	"cleanrooms" |
	"compute-infrastructure" |
	"sensing-controls"

#SignalKind:
	"paper" |
	"patent" |
	"prototype" |
	"test-result" |
	"product-release" |
	"process-innovation" |
	"standard" |
	"failure-analysis"

#Maturity: "research" | "prototype" | "pilot" | "commercial"
#Disposition: "track" | "investigate" | "poc-candidate" | "low-relevance"
#WatchOutcome: "events_observed" | "no_material_events" | "source_gap"

#Provenance: close({
	source:       string
	channel:      string
	recordID:     string
	revision:     string
	publishedAt?: string
	acquiredAt:   string
})

#EngineeringEvent: close({
	kind:           "engineering-event"
	id:             string
	signalKind:     #SignalKind
	surface:        #EngineeringSurface
	headline:       string
	mechanism?:     string
	claimedChange?: string
	maturity:       #Maturity
	provenance:     #Provenance
	disposition:    #Disposition
})

#CoverageGap: close({
	id:          string
	description: string
})

#RunManifest:
	close({
		runID:        string
		generatedAt:  string
		outcome:      "events_observed"
		events:       [#EngineeringEvent, ...#EngineeringEvent]
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		runID:        string
		generatedAt:  string
		outcome:      "no_material_events"
		events:       []
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		runID:        string
		generatedAt:  string
		outcome:      "source_gap"
		events:       [...#EngineeringEvent]
		coverageGaps: [#CoverageGap, ...#CoverageGap]
	})

#EventWatchExecution: close({
	phase:                     "event-watch"
	graphQualificationEnabled: false
	industrialBridgeEnabled:   false
	pocAdmissionEnabled:       false
})

#EngineeringGraphExecution: close({
	phase:                     "engineering-graph"
	graphQualificationEnabled: true
	industrialBridgeEnabled:   true
	pocAdmissionEnabled:       false
})

#Contract: close({
	id:          #DomainID
	kind:        "world"
	execution:   #EventWatchExecution | #EngineeringGraphExecution
	graphTarget: #EngineeringGraphExecution
	surfaces:    [...#EngineeringSurface] & [_, ...]
	authority: close({
		semantic:  "contracts/world/engineering-signals"
		procedure: "world/engineering-signals/.agents"
		runs:      "world/engineering-signals/runs"
	})
})

contract: #Contract & {
	id: "world.engineering-signals"
	execution: #EventWatchExecution
	graphTarget: #EngineeringGraphExecution
	surfaces: [
		"power-systems",
		"power-electronics",
		"semiconductors",
		"advanced-packaging",
		"thermal-management",
		"energy-storage",
		"grid-control",
		"materials",
		"manufacturing-process",
		"cleanrooms",
		"compute-infrastructure",
		"sensing-controls",
	]
	authority: {
		semantic:  "contracts/world/engineering-signals"
		procedure: "world/engineering-signals/.agents"
		runs:      "world/engineering-signals/runs"
	}
}
