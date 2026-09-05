package industrialsignals

#RecordID: string
#EntityID: string
#Timestamp: string
#Digest: string & =~"^sha256:[0-9a-f]{64}$"

#IndustrialSurface:
	"semiconductors" |
	"advanced-packaging" |
	"cleanrooms" |
	"ai-compute" |
	"transformers-switchgear" |
	"electricity-grid" |
	"critical-minerals" |
	"energy-storage" |
	"manufacturing-process" |
	"logistics" |
	"industrial-workforce"

#EntityKind:
	"organization" |
	"facility" |
	"project" |
	"technology" |
	"product-component" |
	"infrastructure-asset" |
	"government-program" |
	"geography" |
	"industry"

#ActorRole:
	"manufacturer" |
	"supplier" |
	"operator" |
	"developer" |
	"integrator" |
	"customer" |
	"contract-manufacturer" |
	"equipment-vendor" |
	"technology-provider" |
	"logistics-provider" |
	"utility" |
	"research-partner"

#ObservedPartyRole:
	"recipient" |
	"funder" |
	"manufacturer" |
	"supplier" |
	"operator" |
	"customer" |
	"partner" |
	"regulator" |
	"other"

#SignalClass:
	"demand" |
	"capacity" |
	"supply" |
	"technology" |
	"innovation" |
	"procurement" |
	"investment" |
	"workforce" |
	"pricing" |
	"lead-time" |
	"failure" |
	"quality" |
	"logistics" |
	"strategic-intent" |
	"localization" |
	"regulatory-response"

#ActionKind:
	"capacity-expansion" |
	"new-facility" |
	"facility-upgrade" |
	"retooling" |
	"technology-adoption" |
	"technology-pilot" |
	"supplier-qualification" |
	"supplier-diversification" |
	"vertical-integration" |
	"localization" |
	"inventory-build" |
	"procurement-change" |
	"partnership" |
	"joint-venture" |
	"licensing" |
	"acquisition" |
	"workforce-expansion" |
	"process-change" |
	"product-redesign" |
	"substitution" |
	"curtailment" |
	"shutdown"

#AdoptionState:
	"observing" |
	"evaluating" |
	"testing" |
	"piloting" |
	"qualifying" |
	"adopting" |
	"deploying" |
	"scaling" |
	"mature" |
	"abandoned"

#OutcomeDimension:
	"capacity" |
	"throughput" |
	"yield" |
	"cost" |
	"lead-time" |
	"reliability" |
	"energy-use" |
	"material-use" |
	"workforce" |
	"quality" |
	"schedule" |
	"utilization" |
	"availability" |
	"revenue-capacity"

#OutcomeDirection: "improved" | "degraded" | "unchanged" | "mixed" | "unknown"

#FundingInstrument:
	"grant" |
	"contribution" |
	"tax-credit" |
	"loan" |
	"loan-guarantee" |
	"equity" |
	"procurement" |
	"other-public-support"

#FundingFlowKind:
	"commitment" |
	"disbursement" |
	"recipient-reported-expenditure" |
	"audited-expenditure" |
	"recovery" |
	"cancellation"

#FundingEvidenceBasis:
	"funder-record" |
	"recipient-report" |
	"audited-report" |
	"procurement-record" |
	"regulatory-filing" |
	"other-primary"

#SpendCategory:
	"capital-equipment" |
	"facility-construction" |
	"research-development" |
	"workforce" |
	"materials" |
	"energy-infrastructure" |
	"supplier-development" |
	"operations" |
	"other"

#MilestoneKind:
	"site-selected" |
	"construction-started" |
	"equipment-ordered" |
	"equipment-installed" |
	"commissioned" |
	"production-started" |
	"capacity-target" |
	"hiring-target" |
	"technology-qualified" |
	"other"

#MilestoneState: "announced" | "started" | "completed" | "delayed" | "cancelled"
#AccountabilityCoverageState: "evidence-present" | "coverage-gap" | "not-yet-due" | "not-applicable"
#Disposition: "track" | "investigate" | "high-signal" | "low-relevance"
#WatchOutcome: "events_observed" | "no_material_events" | "source_gap"
#ExecutionPhase: "event-watch" | "industrial-graph"

#RecordKind:
	"entity" |
	"actor-role-assignment" |
	"industrial-signal" |
	"industrial-action" |
	"response-hypothesis" |
	"admitted-response" |
	"innovation-exposure" |
	"outcome-observation" |
	"funding-award" |
	"funding-flow" |
	"project-milestone" |
	"funding-accountability-coverage"

#RecordRef: close({
	kind: #RecordKind
	id:   #RecordID
})

#EntityRef: close({
	id: #EntityID
})

#Provenance: close({
	source:           string
	channel:          string
	publisher?:       string
	recordID:         string
	revision:         string
	observedSurface?: string
	observedAt?:      #Timestamp
	acquiredAt:       #Timestamp
})

#TypedValue:
	close({kind: "string", value: string}) |
	close({kind: "number", value: number}) |
	close({kind: "boolean", value: bool}) |
	close({kind: "timestamp", value: #Timestamp})

#Money: close({
	amount:   number & >=0
	currency: string & =~"^[A-Z]{3}$"
})
