package industrialsignalsfixtures

import (
	state "github.com/fatb4f/factory/contracts/state"
	domain "github.com/fatb4f/factory/contracts/world/industrial-signals:industrialsignals"
)

manufacturerPrimary: domain.#SourceIdentity & {
	source:     "fixture-recipient"
	channel:    "project-update"
	externalID: "manufacturer-1"
}

manufacturerSecondary: domain.#SourceIdentity & {
	source:     "fixture-registry"
	channel:    "entity-record"
	externalID: "mfg-001"
}

manufacturerEntity: domain.#Entity & {
	kind: "entity"
	identity: {
		entityID:      "actor.manufacturer"
		entityKind:    "organization"
		canonicalName: "Fixture Manufacturer"
		sourceAliases: [
			{identity: manufacturerPrimary, label: "Fixture Manufacturer Ltd."},
			{identity: manufacturerSecondary, label: "Fixture Mfg"},
		]
		equivalenceEvidence: [{
			left:     manufacturerPrimary
			right:    manufacturerSecondary
			evidence: [{kind: "industrial-signal", id: "fixture.signal.award"}]
		}]
		state: "admitted"
	}
}

projectEntity: domain.#Entity & {
	kind: "entity"
	identity: {
		entityID:      "project.capacity-expansion"
		entityKind:    "project"
		canonicalName: "Fixture Capacity Expansion"
		sourceAliases: [{identity: {source: "fixture-recipient", channel: "project-update", externalID: "project-1"}, label: "Expansion Alpha"}]
		equivalenceEvidence: []
		state: "admitted"
	}
}

governmentEntity: domain.#Entity & {
	kind: "entity"
	identity: {
		entityID:      "actor.government"
		entityKind:    "organization"
		canonicalName: "Fixture Government"
		sourceAliases: [{identity: {source: "fixture-funder", channel: "award-record", externalID: "government-1"}, label: "Fixture Government"}]
		equivalenceEvidence: []
		state: "admitted"
	}
}

technologyEntity: domain.#Entity & {
	kind: "entity"
	identity: {
		entityID:      "technology.fixture-process"
		entityKind:    "technology"
		canonicalName: "Fixture Process Technology"
		sourceAliases: [{identity: {source: "fixture-recipient", channel: "technology-update", externalID: "technology-1"}, label: "Process X"}]
		equivalenceEvidence: []
		state: "admitted"
	}
}

awardSignal: domain.#IndustrialSignalRecord & {
	kind:        "industrial-signal"
	id:          "fixture.signal.award"
	signalClass: "investment"
	actor:       {id: "actor.manufacturer"}
	subject:     {id: "project.capacity-expansion"}
	surface:     "semiconductors"
	observedAt:  "2026-01-15T00:00:00Z"
	provenance: {
		source:     "fixture-funder"
		channel:    "award-record"
		recordID:   "signal-award-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "entity", id: "actor.manufacturer"}]
}

expansionAction: domain.#IndustrialActionRecord & {
	kind:       "industrial-action"
	id:         "fixture.action.expansion"
	actionKind: "capacity-expansion"
	actor:      {id: "actor.manufacturer"}
	subjects:   [{id: "project.capacity-expansion"}]
	surface:    "semiconductors"
	startedAt:  "2026-03-15T00:00:00Z"
	provenance: {
		source:     "fixture-recipient"
		channel:    "project-update"
		recordID:   "action-expansion-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "industrial-signal", id: "fixture.signal.award"}]
}

responseHypothesis: domain.#ResponseHypothesis & {
	kind:              "response-hypothesis"
	id:                "fixture.response.hypothesis"
	signal:            {kind: "industrial-signal", id: "fixture.signal.award"}
	action:            {kind: "industrial-action", id: "fixture.action.expansion"}
	proposedMechanism: "Public support may have contributed to the capacity expansion."
	evidence: [
		{kind: "industrial-signal", id: "fixture.signal.award"},
		{kind: "industrial-action", id: "fixture.action.expansion"},
	]
	state: "hypothesis"
}

admittedResponse: domain.#AdmittedResponse & {
	kind:   "admitted-response"
	id:     "fixture.response.admitted"
	signal: {kind: "industrial-signal", id: "fixture.signal.award"}
	action: {kind: "industrial-action", id: "fixture.action.expansion"}
	basis:  "actor-explicit"
	evidence: [
		{kind: "industrial-signal", id: "fixture.signal.award"},
		{kind: "industrial-action", id: "fixture.action.expansion"},
	]
	state: "admitted"
}

innovationExposure: domain.#InnovationExposure & {
	kind:       "innovation-exposure"
	id:         "fixture.innovation.deploying"
	actor:      {id: "actor.manufacturer"}
	innovation: {id: "technology.fixture-process"}
	state:      "deploying"
	project:    {id: "project.capacity-expansion"}
	observedAt: "2026-07-20T00:00:00Z"
	provenance: {
		source:     "fixture-recipient"
		channel:    "technology-update"
		recordID:   "innovation-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "industrial-action", id: "fixture.action.expansion"}]
}

accountabilityGap: domain.#FundingAccountabilityCoverage & {
	kind:       "funding-accountability-coverage"
	id:         "fixture.accountability.gap"
	award:      {kind: "funding-award", id: "fixture.award.1"}
	recipient:  {id: "actor.manufacturer"}
	disbursement:      "evidence-present"
	expenditure:       "coverage-gap"
	milestoneProgress: "not-yet-due"
	outcome:           "not-yet-due"
	evidence: [
		{kind: "funding-award", id: "fixture.award.1"},
		{kind: "funding-flow", id: "fixture.flow.disbursement"},
	]
	coverageGaps: ["Recipient expenditure evidence is not available for this coverage record."]
}

graphRecords: [
	manufacturerEntity,
	projectEntity,
	governmentEntity,
	technologyEntity,
	awardSignal,
	expansionAction,
	responseHypothesis,
	admittedResponse,
	innovationExposure,
	award,
	disbursement,
	spend,
	milestone,
	outcome,
	accountability,
	accountabilityGap,
]

graphSnapshotInput: {
	snapshotID:      "industrial.fixture.v1"
	generatedAt:     "2026-09-06T01:00:00Z"
	observedThrough: "2026-08-31T00:00:00Z"
	records:         graphRecords
}

graphAnalyticalSource: state.#AnalyticalSourceRef & {
	id:             "industrial-graph-records"
	snapshotDigest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	semanticRef: {
		authority: {id: "world.industrial-signals", contract: "contracts/world/industrial-signals/contract.cue"}
		subject:   "world.industrial-signals"
		kind:      "graph"
	}
	provenance: ["industrial-signals:admitted-records"]
	admissibility: {
		state:     "admitted"
		authority: "contracts/world/industrial-signals"
		basis:     ["industrial-signals:graph-qualification"]
	}
}

graphAnalyticalRequest: state.#AnalyticalRequest & {
	apiVersion: "factory.analytics-ir/v1"
	kind:       "AnalyticalRequest"
	id:         "industrial-graph-snapshot-projection"
	source:     graphAnalyticalSource
	grain: {keys: ["kind", "id"], unit: "industrial-graph-record"}
	operations: [{kind: "project", fields: ["kind", "id", "provenance", "evidence"]}]
}

graphRelationalPlan: state.#RelationalPlan & {
	apiVersion: "factory.analytics-ir/v1"
	kind:       "RelationalPlan"
	id:         "plan:industrial-graph-snapshot"
	request:    graphAnalyticalRequest
	steps:      graphAnalyticalRequest.operations
	outputGrain: graphAnalyticalRequest.grain
	provenance: {authority: "contracts/world/industrial-signals", basis: [graphAnalyticalSource.snapshotDigest]}
}

graphStorageSnapshot: state.#StorageSnapshot & {
	apiVersion:     "factory.storage/v1"
	kind:           "StorageSnapshot"
	dataset: {
		id:               "industrial-graph-records"
		analyticalSource: graphAnalyticalSource
		grain:            graphAnalyticalRequest.grain
	}
	version:        "fixture-v1"
	digest:         "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	sourceSnapshot: graphAnalyticalSource.snapshotDigest
	location:       {scheme: "file", uri: "world/industrial-signals/snapshots/industrial.fixture.v1.json"}
	format: {
		id:             "json-fixture"
		version:        "1"
		columnar:       false
		openTable:      false
		immutableFiles: true
	}
}

graphRealizationFixture: domain.#IndustrialGraphSnapshotRealization & {
	apiVersion:     "industrial-signals.graph-snapshot/v1"
	kind:           "IndustrialGraphSnapshotRealization"
	execution:      domain.contract.graphTarget
	analyticalPlan: graphRelationalPlan
	storage:        graphStorageSnapshot
	projection: {canonicalization: "json-sort-keys-compact", version: "1"}
	snapshot: {
		snapshotID:      graphSnapshotInput.snapshotID
		generatedAt:     graphSnapshotInput.generatedAt
		observedThrough: graphSnapshotInput.observedThrough
		digest:          "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
		records:         graphRecords
	}
}
