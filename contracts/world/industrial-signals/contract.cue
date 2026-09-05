package industrialsignals

#DomainID: "world.industrial-signals"

#ObservedParty: close({
	label:      string
	partyRole?: #ObservedPartyRole
	externalID?: string
})

#WatchDetail:
	close({kind: "signal", signalClass: #SignalClass}) |
	close({kind: "action", actionKind: #ActionKind}) |
	close({
		kind:       "funding-award"
		instrument: #FundingInstrument
		program?:   string
		amount?:    #Money
	}) |
	close({
		kind:          "funding-flow"
		flowKind:      #FundingFlowKind
		awardExternalID?: string
		amount?:       #Money
		spendCategory?: #SpendCategory
		basis:         #FundingEvidenceBasis
	}) |
	close({
		kind:          "project-milestone"
		milestoneKind: #MilestoneKind
		state:         #MilestoneState
	}) |
	close({
		kind:       "innovation-exposure"
		technology: string
		state:      #AdoptionState
	}) |
	close({
		kind:      "outcome"
		dimension: #OutcomeDimension
		direction: #OutcomeDirection
		value?:    #TypedValue
	})

#IndustrialWatchEvent: close({
	kind:       "industrial-watch-event"
	id:         #RecordID
	headline:   string
	surface:    #IndustrialSurface
	actors:     [...#ObservedParty] & [_, ...]
	detail:     #WatchDetail
	occurredAt?:  #Timestamp
	announcedAt?: #Timestamp
	disposition: #Disposition
	provenance: #Provenance & {
		publisher:       string
		observedSurface: string
	}
})

#CoverageGap: close({
	id:          string
	description: string
	source?:     string
	channel?:    string
})

#RunManifest:
	close({
		runID:        string
		generatedAt:  #Timestamp
		outcome:      "events_observed"
		events:       [#IndustrialWatchEvent, ...#IndustrialWatchEvent]
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		runID:        string
		generatedAt:  #Timestamp
		outcome:      "no_material_events"
		events:       []
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		runID:        string
		generatedAt:  #Timestamp
		outcome:      "source_gap"
		events:       [...#IndustrialWatchEvent]
		coverageGaps: [#CoverageGap, ...#CoverageGap]
	})

#EventWatchExecution: close({
	phase:                            "event-watch"
	canonicalIdentityRequired:        false
	graphQualificationEnabled:        false
	responseAdmissionEnabled:         false
	fundingAccountabilityEnabled:     false
	outcomeQualificationEnabled:      false
	immutableGraphSnapshotsEnabled:   false
})

#IndustrialGraphExecution: close({
	phase:                            "industrial-graph"
	canonicalIdentityRequired:        true
	graphQualificationEnabled:        true
	responseAdmissionEnabled:         true
	fundingAccountabilityEnabled:     true
	outcomeQualificationEnabled:      true
	immutableGraphSnapshotsEnabled:   true
})

#Contract: close({
	id:          #DomainID
	kind:        "world"
	execution:   #EventWatchExecution | #IndustrialGraphExecution
	graphTarget: #IndustrialGraphExecution
	surfaces:    [...#IndustrialSurface] & [_, ...]
	authority: close({
		semantic:  "contracts/world/industrial-signals"
		procedure: "world/industrial-signals/.agents"
		runs:      "world/industrial-signals/runs"
	})
	boundaries: close({
		constraintQualification: "world.industrial-constraints"
		crossDomainAllocation:   "world.resource-allocation"
		financialQualification:  "world.financial-signals"
		pocDecision:             "projects.engineering-pocs"
	})
})

contract: #Contract & {
	id: "world.industrial-signals"
	execution: #EventWatchExecution
	graphTarget: #IndustrialGraphExecution
	surfaces: [
		"semiconductors",
		"advanced-packaging",
		"cleanrooms",
		"ai-compute",
		"transformers-switchgear",
		"electricity-grid",
		"critical-minerals",
		"energy-storage",
		"manufacturing-process",
		"logistics",
		"industrial-workforce",
	]
	authority: {
		semantic:  "contracts/world/industrial-signals"
		procedure: "world/industrial-signals/.agents"
		runs:      "world/industrial-signals/runs"
	}
	boundaries: {
		constraintQualification: "world.industrial-constraints"
		crossDomainAllocation:   "world.resource-allocation"
		financialQualification:  "world.financial-signals"
		pocDecision:             "projects.engineering-pocs"
	}
}
