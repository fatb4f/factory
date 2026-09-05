package climatereadiness

#DomainID: "world.canada-climate-readiness"
#ExecutionPhase: "event-watch" | "resilience-graph"
#Geography: "canada" | "quebec"

#Surface:
	"flood-resilience" |
	"wildfire-resilience" |
	"extreme-heat" |
	"storm-resilience" |
	"water-resilience" |
	"electrical-resilience" |
	"building-infrastructure" |
	"transport-infrastructure" |
	"climate-design-standards" |
	"adaptation-finance"

#EventKind:
	"adaptation-program-launched" |
	"adaptation-program-updated" |
	"resilience-funding-awarded" |
	"standard-code-changed" |
	"hazard-guidance-changed" |
	"resilience-project-announced" |
	"resilience-project-milestone" |
	"risk-requirement-changed" |
	"procurement-issued"

#Disposition: "track" | "investigate" | "cross-domain-candidate" | "low-relevance"
#WatchOutcome: "events_observed" | "no_material_events" | "source_gap"

#Provenance: close({
	source:       string
	channel:      string
	recordID:     string
	revision:     string
	publishedAt?: string
	acquiredAt:   string
})

#EventObservation: close({
	kind:        "climate-readiness-event"
	id:          string
	eventKind:   #EventKind
	headline:    string
	geographies: [...#Geography] & [_, ...]
	surfaces:    [...#Surface] & [_, ...]
	provenance:  #Provenance
	disposition: #Disposition
})

#CoverageGap: close({id: string, description: string})

#RunManifest:
	close({runID: string, generatedAt: string, outcome: "events_observed", events: [#EventObservation, ...#EventObservation], coverageGaps: [...#CoverageGap]}) |
	close({runID: string, generatedAt: string, outcome: "no_material_events", events: [], coverageGaps: [...#CoverageGap]}) |
	close({runID: string, generatedAt: string, outcome: "source_gap", events: [...#EventObservation], coverageGaps: [#CoverageGap, ...#CoverageGap]})

#EventWatchExecution: close({
	phase:                     "event-watch"
	graphQualificationEnabled: false
	resourceDemandEnabled:     false
})

#ResilienceGraphExecution: close({
	phase:                     "resilience-graph"
	graphQualificationEnabled: true
	resourceDemandEnabled:     true
})

#Contract: close({
	id:          #DomainID
	kind:        "world"
	execution:   #EventWatchExecution | #ResilienceGraphExecution
	graphTarget: #ResilienceGraphExecution
	geographies: ["canada", "quebec"]
	surfaces:    [...#Surface] & [_, ...]
	authority: close({
		semantic:  "contracts/world/canada-climate-readiness"
		procedure: "world/canada-climate-readiness/.agents"
		runs:      "world/canada-climate-readiness/runs"
	})
})

contract: #Contract & {
	id: "world.canada-climate-readiness"
	execution: #EventWatchExecution
	graphTarget: #ResilienceGraphExecution
	geographies: ["canada", "quebec"]
	surfaces: [
		"flood-resilience",
		"wildfire-resilience",
		"extreme-heat",
		"storm-resilience",
		"water-resilience",
		"electrical-resilience",
		"building-infrastructure",
		"transport-infrastructure",
		"climate-design-standards",
		"adaptation-finance",
	]
	authority: {
		semantic:  "contracts/world/canada-climate-readiness"
		procedure: "world/canada-climate-readiness/.agents"
		runs:      "world/canada-climate-readiness/runs"
	}
}
