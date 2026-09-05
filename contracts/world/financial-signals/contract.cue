package financialsignals

#DomainID: "world.financial-signals"
#ExecutionPhase: "event-watch" | "financial-graph"

#FinancialEntityKind:
	"issuer" |
	"reporting-segment" |
	"instrument" |
	"equity-class" |
	"debt-facility" |
	"project-finance-vehicle" |
	"revenue-stream" |
	"capital-claim" |
	"benchmark"

#FinancialPredicate:
	"issued-by" |
	"consolidated-into" |
	"owns-economic-interest-in" |
	"financed-by" |
	"secured-by" |
	"convertible-into" |
	"dilutes" |
	"reported-in-segment" |
	"contributes-revenue-to" |
	"contributes-earnings-to" |
	"exposed-to-price-of" |
	"hedged-by"

#SourceClass:
	"regulatory-filing" |
	"issuer-ir" |
	"exchange-reference" |
	"market-data" |
	"debt-financing-disclosure" |
	"project-finance-disclosure" |
	"ownership-capital-structure" |
	"commodity-fx-benchmark"

#FinancialEventKind:
	"filing-published" |
	"guidance-changed" |
	"financing-announced" |
	"capital-structure-changed" |
	"segment-disclosure-changed" |
	"contract-backlog-updated" |
	"project-finance-changed" |
	"market-structure-changed"

#WatchOutcome: "events_observed" | "no_material_events" | "source_gap"

#Provenance: close({
	sourceClass:  #SourceClass
	source:       string
	channel:      string
	recordID:     string
	revision:     string
	publishedAt?: string
	acquiredAt:   string
})

#FinancialEvent: close({
	kind:       "financial-event"
	id:         string
	eventKind:  #FinancialEventKind
	headline:   string
	provenance: #Provenance
})

#FinancialMeasurement: close({
	id:         string
	subject:    string
	metric:     string
	value:      number
	unit:       string
	observedAt: string
	provenance: #Provenance
})

#FinancialRelation: close({
	id:        string
	subject:   string
	predicate: #FinancialPredicate
	object:    string
	claims:    [string, ...string]
})

#CoverageGap: close({id: string, description: string})

#RunManifest:
	close({runID: string, generatedAt: string, outcome: "events_observed", events: [#FinancialEvent, ...#FinancialEvent], coverageGaps: [...#CoverageGap]}) |
	close({runID: string, generatedAt: string, outcome: "no_material_events", events: [], coverageGaps: [...#CoverageGap]}) |
	close({runID: string, generatedAt: string, outcome: "source_gap", events: [...#FinancialEvent], coverageGaps: [#CoverageGap, ...#CoverageGap]})

#EventWatchExecution: close({
	phase:                     "event-watch"
	graphQualificationEnabled: false
	bridgeQualificationEnabled: false
})

#FinancialGraphExecution: close({
	phase:                     "financial-graph"
	graphQualificationEnabled: true
	bridgeQualificationEnabled: true
})

#Contract: close({
	id:          #DomainID
	kind:        "world"
	execution:   #EventWatchExecution | #FinancialGraphExecution
	graphTarget: #FinancialGraphExecution
	authority: close({
		semantic:  "contracts/world/financial-signals"
		procedure: "world/financial-signals/.agents"
		runs:      "world/financial-signals/runs"
	})
})

contract: #Contract & {
	id: "world.financial-signals"
	execution: #EventWatchExecution
	graphTarget: #FinancialGraphExecution
	authority: {
		semantic:  "contracts/world/financial-signals"
		procedure: "world/financial-signals/.agents"
		runs:      "world/financial-signals/runs"
	}
}
