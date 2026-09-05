package industrialsignalsfixtures

import domain "github.com/fatb4f/factory/contracts/world/industrial-signals:industrialsignals"

award: domain.#FundingAward & {
	kind:      "funding-award"
	id:        "fixture.award.1"
	funder:    {id: "actor.government"}
	recipient: {id: "actor.manufacturer"}
	project:   {id: "project.capacity-expansion"}
	program:   "fixture-program"
	instrument: "grant"
	authorizedAmount: {amount: 1000000, currency: "CAD"}
	authorizedAt: "2026-01-15T00:00:00Z"
	provenance: {
		source:     "fixture-funder"
		channel:    "award-record"
		recordID:   "award-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "industrial-signal", id: "fixture.signal.award"}]
}

disbursement: domain.#FundingFlow & {
	kind:      "funding-flow"
	id:        "fixture.flow.disbursement"
	award:     {kind: "funding-award", id: "fixture.award.1"}
	recipient: {id: "actor.manufacturer"}
	flowKind:  "disbursement"
	amount:    {amount: 500000, currency: "CAD"}
	occurredAt: "2026-03-01T00:00:00Z"
	basis:      "funder-record"
	provenance: {
		source:     "fixture-funder"
		channel:    "disbursement-record"
		recordID:   "flow-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "funding-award", id: "fixture.award.1"}]
}

spend: domain.#FundingFlow & {
	kind:      "funding-flow"
	id:        "fixture.flow.spend"
	award:     {kind: "funding-award", id: "fixture.award.1"}
	recipient: {id: "actor.manufacturer"}
	flowKind:  "audited-expenditure"
	amount:    {amount: 350000, currency: "CAD"}
	spendCategory: "capital-equipment"
	purpose:   "production equipment"
	occurredAt: "2026-06-30T00:00:00Z"
	basis:      "audited-report"
	provenance: {
		source:     "fixture-auditor"
		channel:    "audited-report"
		recordID:   "spend-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [
		{kind: "funding-award", id: "fixture.award.1"},
		{kind: "funding-flow", id: "fixture.flow.disbursement"},
	]
}

milestone: domain.#ProjectMilestone & {
	kind:          "project-milestone"
	id:            "fixture.milestone.1"
	project:       {id: "project.capacity-expansion"}
	actors:        [{id: "actor.manufacturer"}]
	milestoneKind: "equipment-installed"
	state:         "completed"
	observedAt:    "2026-07-15T00:00:00Z"
	provenance: {
		source:     "fixture-recipient"
		channel:    "project-update"
		recordID:   "milestone-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "funding-flow", id: "fixture.flow.spend"}]
}

outcome: domain.#OutcomeObservation & {
	kind:      "outcome-observation"
	id:        "fixture.outcome.1"
	subject:   {id: "project.capacity-expansion"}
	dimension: "capacity"
	direction: "improved"
	value:     {kind: "number", value: 25}
	observedAt: "2026-08-31T00:00:00Z"
	provenance: {
		source:     "fixture-operator"
		channel:    "production-report"
		recordID:   "outcome-1"
		revision:   "r1"
		acquiredAt: "2026-09-05T00:00:00Z"
	}
	evidence: [{kind: "project-milestone", id: "fixture.milestone.1"}]
}

accountability: domain.#FundingAccountabilityCoverage & {
	kind:       "funding-accountability-coverage"
	id:         "fixture.accountability.1"
	award:      {kind: "funding-award", id: "fixture.award.1"}
	recipient:  {id: "actor.manufacturer"}
	disbursement:      "evidence-present"
	expenditure:       "evidence-present"
	milestoneProgress: "evidence-present"
	outcome:           "evidence-present"
	evidence: [
		{kind: "funding-flow", id: "fixture.flow.disbursement"},
		{kind: "funding-flow", id: "fixture.flow.spend"},
		{kind: "project-milestone", id: "fixture.milestone.1"},
		{kind: "outcome-observation", id: "fixture.outcome.1"},
	]
	coverageGaps: []
}

watchRun: domain.#RunManifest & {
	runID:       "fixture-run"
	generatedAt: "2026-09-05T00:00:00Z"
	outcome:     "events_observed"
	events: [{
		kind:     "industrial-watch-event"
		id:       "fixture.watch.award"
		headline: "Public support authorized for capacity expansion"
		surface:  "semiconductors"
		actors: [
			{label: "Fixture Government", partyRole: "funder"},
			{label: "Fixture Manufacturer", partyRole: "recipient"},
		]
		detail: {
			kind:       "funding-award"
			instrument: "grant"
			program:    "fixture-program"
			amount:     {amount: 1000000, currency: "CAD"}
		}
		disposition: "track"
		provenance: {
			source:           "fixture-funder"
			channel:          "award-record"
			publisher:        "Fixture Government"
			recordID:         "award-1"
			revision:         "r1"
			observedSurface:  "award-record"
			acquiredAt:       "2026-09-05T00:00:00Z"
		}
	}]
	coverageGaps: []
}
