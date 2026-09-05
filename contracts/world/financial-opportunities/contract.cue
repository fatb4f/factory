package financialopportunities

#OpportunityState: "candidate" | "qualified" | "watch" | "actionable" | "rejected" | "invalidated" | "coverage-gap"
#RiskLevel: "low" | "medium" | "high" | "very-high"

#ExternalRef: close({
	domain:   string
	snapshot: string
	record:   string
})

#Scenario: close({
	id:           string
	state:        "failure" | "bear" | "base" | "bull"
	horizonYears: number & >0
	probability?: number & >=0 & <=1
	entryValue:    number
	terminalValue: number
	distributions: number & >=0
	assumptions:   [string, ...string]
	evidence:      [...string]
})

#RiskProfile: close({
	thesis:        #RiskLevel
	valuation:     #RiskLevel
	execution:     #RiskLevel
	timing:        #RiskLevel
	liquidity:     #RiskLevel
	financing:     #RiskLevel
	dilution:      #RiskLevel
	policy:        #RiskLevel
	concentration: #RiskLevel
	evidence:      [...string]
})

#OpportunityDecision: close({
	id:                  string
	allocationCandidate: #ExternalRef
	financialGraph:      #ExternalRef & {domain: "world.financial-signals"}
	instrument:          string
	valuationObservedAt: string
	scenarios:           [#Scenario, ...#Scenario]
	risk:                #RiskProfile
	state:               #OpportunityState
	claims:              [...string]
})

#Contract: close({
	id:        "world.financial-opportunities"
	kind:      "world"
	execution: "contract-only" | "qualification"
	authority: close({
		semantic:  "contracts/world/financial-opportunities"
		procedure: "world/financial-opportunities/.agents"
	})
})

contract: #Contract & {
	id: "world.financial-opportunities"
	execution: "contract-only"
	authority: {
		semantic:  "contracts/world/financial-opportunities"
		procedure: "world/financial-opportunities/.agents"
	}
}
