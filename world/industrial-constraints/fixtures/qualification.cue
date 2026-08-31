package qualification

import domain "github.com/fatb4f/factory/contracts/world/industrial-constraints:industrialconstraints"

document: domain.#Document & {
	kind:         "document"
	id:           "fixture.document.grant"
	documentKind: "grant-award"
	provenance: {
		source:     "gc-grants"
		channel:    "awards"
		recordID:   "fixture-award-001"
		revision:   "fixture-v1"
		observedAt: "2026-08-27T00:00:00Z"
		acquiredAt: "2026-08-27T00:00:00Z"
	}
}

program: domain.#Entity & {
	kind: "entity"
	identity: {
		entityID:      "fixture.program"
		entityKind:    "government-program"
		canonicalName: "Fixture Program"
		sourceAliases: [{
			identity: {
				source:     "gc-grants"
				channel:    "awards"
				externalID: "fixture-program"
			}
			label: "Fixture Program"
		}]
		equivalenceEvidence: []
		state:               "admitted"
	}
}

project: domain.#Entity & {
	kind: "entity"
	identity: {
		entityID:      "fixture.project"
		entityKind:    "project"
		canonicalName: "Fixture Project"
		sourceAliases: [{
			identity: {
				source:     "canadabuys"
				channel:    "procurement"
				externalID: "fixture-project"
			}
			label: "Fixture Project"
		}]
		equivalenceEvidence: []
		state:               "admitted"
	}
}

relation: domain.#Relation & {
	kind:      "relation"
	id:        "fixture.relation.funded-by"
	subject:   {id: project.id}
	predicate: "funded-by"
	object:    {id: program.id}
	provenance: {
		source:     "gc-grants"
		channel:    "awards"
		recordID:   "fixture-award-001"
		revision:   "fixture-v1"
		observedAt: "2026-08-27T00:00:00Z"
		acquiredAt: "2026-08-27T00:00:00Z"
	}
	evidence: [{kind: "document", id: document.id}]
}

event: domain.#Event & {
	kind:        "event"
	id:          "fixture.event.grant-awarded"
	eventKind:   "grant-awarded"
	actors:      [{id: program.id}]
	subjects:    [{id: project.id}]
	occurredAt:  "2026-08-27T00:00:00Z"
	announcedAt: "2026-08-27T00:00:00Z"
	provenance: {
		source:     "gc-grants"
		channel:    "awards"
		recordID:   "fixture-award-001"
		revision:   "fixture-v1"
		observedAt: "2026-08-27T00:00:00Z"
		acquiredAt: "2026-08-27T00:00:00Z"
	}
	evidence: [{kind: "document", id: document.id}]
}

claim: domain.#EvidenceClaim & {
	kind:        "claim"
	id:          "fixture.claim.funding"
	proposition: "Qualification fixture only: the project has explicit funding evidence."
	subject:     {id: project.id}
	evidence: [
		{record: {kind: "event", id: event.id}, class: "event"},
		{record: {kind: "relation", id: relation.id}, class: "relation"},
	]
}

assessment: domain.#Assessment & {
	kind:  "assessment"
	id:    "fixture.assessment.funding"
	claim: {id: claim.id}
	state: "supported"
	evidence: [
		{record: {kind: "event", id: event.id}, class: "event"},
		{record: {kind: "relation", id: relation.id}, class: "relation"},
	]
	coverageGaps: []
}

constraint: domain.#ConstraintClaim & {
	kind:      "constraint-claim"
	id:        "fixture.constraint.capital"
	subject:   {id: project.id}
	mechanism: "capital"
	state:     "binding"
	basis:     "multi-record-correlation"
	evidence: [
		{record: {kind: "event", id: event.id}, class: "event"},
		{record: {kind: "relation", id: relation.id}, class: "relation"},
	]
	affectedRelations: [{kind: "relation", id: relation.id}]
	confidence:        "moderate"
	assessment:        {id: assessment.id}
}

manifest: domain.#RunManifest & {
	runID:            "qualification-fixture"
	generatedAt:      "2026-08-27T00:00:00Z"
	contractPath:     "contracts/world/industrial-constraints/contract.cue"
	contractRevision: "qualification-fixture"
	immutable:        true
	artifacts: {
		report:   "report.md"
		summary:  "summary.md"
		evidence: "evidence.json"
	}
	digests: {
		report:   "sha256:0000000000000000000000000000000000000000000000000000000000000000"
		summary:  "sha256:1111111111111111111111111111111111111111111111111111111111111111"
		evidence: "sha256:2222222222222222222222222222222222222222222222222222222222222222"
	}
	publication: {
		decision: "admit"
		claims: [{
			claim:           {kind: "constraint-claim", id: constraint.id}
			assessment:      {kind: "assessment", id: assessment.id}
			assessmentState: "supported"
		}]
		coverageGaps: []
	}
}

report: domain.#PublicReport & {
	runID:                  manifest.runID
	materialStateChanges:   [{kind: "event", id: event.id}]
	emergingConstraints:    []
	bindingConstraints:     [{kind: "constraint-claim", id: constraint.id}]
	relievingConstraints:   []
	resolvedConstraints:    []
	institutionalResponses: []
	fundingProcurement:     [{kind: "relation", id: relation.id}]
	coverageGaps:           []
}

bundle: domain.#RunBundle & {
	manifest: manifest
	report:   report
	summary:  "Contract qualification fixture; contains no real-world industrial claim."
	evidence: [document, program, project, relation, event, claim, assessment, constraint]
}
