package engineeringpocs

#POCState: "proposed" | "qualified" | "prototype-ready" | "executed" | "invalidated" | "coverage-gap"

#ExternalRef: close({
	domain:   string
	snapshot: string
	record:   string
})

#POCHypothesis: close({
	id:                   string
	engineeringPath:      #ExternalRef & {domain: "world.engineering-signals"}
	industrialProblem:    #ExternalRef & {domain: "world.industrial-constraints"}
	initiativeDemand?:    [...#ExternalRef]
	allocationCandidate?: #ExternalRef & {domain: "world.resource-allocation"}
	proposition:          string
	mechanism:
		"capacity-relief" |
		"substitution" |
		"efficiency-improvement" |
		"resilience-improvement" |
		"cost-reduction" |
		"manufacturing-simplification" |
		"control-improvement"
	expectedLearning: [string, ...string]
	falsifiers:       [string, ...string]
	state:            #POCState
})

#POCDecision: close({
	hypothesis: string
	decision:   "admit" | "reject" | "coverage-gap"
	reasons:    [string, ...string]
})

#Contract: close({
	id:        "projects.engineering-pocs"
	kind:      "project"
	execution: "contract-only" | "qualification"
	authority: close({
		semantic:  "contracts/projects/engineering-pocs"
		procedure: "projects/engineering-pocs/.agents"
	})
})

contract: #Contract & {
	id: "projects.engineering-pocs"
	execution: "contract-only"
	authority: {
		semantic:  "contracts/projects/engineering-pocs"
		procedure: "projects/engineering-pocs/.agents"
	}
}
