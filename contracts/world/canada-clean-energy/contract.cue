package cleanenergy

#DomainID: "world.canada-clean-energy"
#ExecutionPhase: "event-watch" | "policy-project-graph"
#Geography: "canada" | "quebec"

#Surface:
	"renewable-generation" |
	"energy-storage" |
	"transmission" |
	"distribution" |
	"grid-modernization" |
	"clean-electricity-finance" |
	"electrification" |
	"interconnection" |
	"clean-energy-manufacturing"

#EventKind:
	"program-launched" |
	"program-updated" |
	"funding-awarded" |
	"tax-incentive-changed" |
	"project-announced" |
	"project-approved" |
	"procurement-issued" |
	"capacity-target-changed" |
	"grid-project-milestone" |
	"policy-changed"

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
	kind:        "clean-energy-event"
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

#PolicyProjectGraphExecution: close({
	phase:                     "policy-project-graph"
	graphQualificationEnabled: true
	resourceDemandEnabled:     true
})

#Contract: close({
	id:          #DomainID
	kind:        "world"
	execution:   #EventWatchExecution | #PolicyProjectGraphExecution
	graphTarget: #PolicyProjectGraphExecution
	geographies: ["canada", "quebec"]
	surfaces:    [...#Surface] & [_, ...]
	authority: close({
		semantic:  "contracts/world/canada-clean-energy"
		procedure: "world/canada-clean-energy/.agents"
		runs:      "world/canada-clean-energy/runs"
	})
})

contract: #Contract & {
	id: "world.canada-clean-energy"
	execution: #EventWatchExecution
	graphTarget: #PolicyProjectGraphExecution
	geographies: ["canada", "quebec"]
	surfaces: [
		"renewable-generation",
		"energy-storage",
		"transmission",
		"distribution",
		"grid-modernization",
		"clean-electricity-finance",
		"electrification",
		"interconnection",
		"clean-energy-manufacturing",
	]
	authority: {
		semantic:  "contracts/world/canada-clean-energy"
		procedure: "world/canada-clean-energy/.agents"
		runs:      "world/canada-clean-energy/runs"
	}
}
