package industrialsignalsfixtures

import state "github.com/fatb4f/factory/contracts/state"

industrialWorkbookSubject: state.#SemanticRef & graphAnalyticalSource.semanticRef
industrialWorkbookProject: state.#SemanticRef & {
	authority: industrialWorkbookSubject.authority
	subject:   "project.capacity-expansion"
	kind:      "project"
}

industrialWorkbookBinding: state.#DirectoryBinding & {
	id: "binding:world.industrial-signals"
	directory: {
		repository: "github.com/fatb4f/factory"
		revision:   "fixture"
		path:       "world/industrial-signals"
	}
	subjects: [industrialWorkbookSubject]
}

workbookDocumentationOccurrence: state.#SourceOccurrence & {
	id: "occ-industrial-documentation"
	source: {kind: "document", id: "industrial-signals-contract"}
	locator:       "contracts/world/industrial-signals/contract.cue"
	payloadDigest: "sha256:1010101010101010101010101010101010101010101010101010101010101010"
	acquiredAt:    "2026-09-06T01:20:00Z"
}

workbookProposalOccurrence: state.#SourceOccurrence & {
	id: "occ-observatory-proposal"
	source: {kind: "document", id: "factory-observatory-architecture"}
	locator:       "docs/architecture/factory-observatory.md"
	payloadDigest: "sha256:2020202020202020202020202020202020202020202020202020202020202020"
	acquiredAt:    "2026-09-06T01:20:01Z"
}

workbookDecisionOccurrence: state.#SourceOccurrence & {
	id: "occ-industrial-execution-decision"
	source: {kind: "document", id: "industrial-signals-execution-policy"}
	locator:       "world/industrial-signals/.agents/AGENTS.md"
	payloadDigest: "sha256:3030303030303030303030303030303030303030303030303030303030303030"
	acquiredAt:    "2026-09-06T01:20:02Z"
}

workbookTrackerOccurrence: state.#SourceOccurrence & {
	id: "occ-industrial-workbook-tracker"
	source: {
		kind: "github-issue"
		id:   "engineering:graph:world.industrial-signals:projection:reference-workbook"
	}
	locator:       "issues/149"
	revisionHint:  "fixture"
	payloadDigest: "sha256:4040404040404040404040404040404040404040404040404040404040404040"
	acquiredAt:    "2026-09-06T01:20:03Z"
}

workbookEventWatchOccurrence: state.#SourceOccurrence & {
	id: "occ-industrial-event-watch"
	source: {kind: "run", id: "world.industrial-signals:event-watch"}
	locator:       "fixture-run/fixture.watch.award"
	payloadDigest: "sha256:5050505050505050505050505050505050505050505050505050505050505050"
	acquiredAt:    "2026-09-06T01:20:04Z"
}

workbookDocumentationArtifact: state.#ContextArtifact & {
	id: "artifact-industrial-documentation"
	plane: "documentary"
	role: "documentation"
	subjects: [industrialWorkbookSubject]
	occurrence: workbookDocumentationOccurrence
}

workbookProposalArtifact: state.#ContextArtifact & {
	id: "artifact-observatory-proposal"
	plane: "documentary"
	role: "proposal"
	subjects: [industrialWorkbookSubject]
	occurrence: workbookProposalOccurrence
}

workbookDecisionArtifact: state.#ContextArtifact & {
	id: "artifact-industrial-execution-decision"
	plane: "documentary"
	role: "decision"
	subjects: [industrialWorkbookSubject]
	occurrence: workbookDecisionOccurrence
}

workbookTrackerArtifact: state.#ContextArtifact & {
	id: "artifact-industrial-workbook-tracker"
	plane: "operational"
	role: "tracker-projection"
	subjects: [industrialWorkbookSubject]
	occurrence: workbookTrackerOccurrence
}

workbookEventWatchArtifact: state.#ContextArtifact & {
	id: "artifact-industrial-event-watch"
	plane: "evidential"
	role: "event-watch-observation"
	subjects: [industrialWorkbookSubject]
	occurrence: workbookEventWatchOccurrence
}

industrialWorkbookSemanticRelation: state.#SemanticRelation & {
	plane: "semantic"
	authority: industrialWorkbookSubject.authority
	predicate: {
		authority: industrialWorkbookSubject.authority
		id: "contains-project"
	}
	snapshot: {
		authority: industrialWorkbookSubject.authority
		id: graphRealizationFixture.snapshot.snapshotID
		digest: graphRealizationFixture.snapshot.digest
	}
	source: industrialWorkbookSubject
	target: industrialWorkbookProject
	basis: {occurrences: [workbookDocumentationOccurrence.id]}
}

workbookDocumentaryRelations: [...state.#DocumentaryRelation] & [
	{
		plane: "documentary", relation: "documented-by"
		source: {kind: "semantic", semantic: industrialWorkbookSubject}
		target: {kind: "artifact", artifact: {id: workbookDocumentationArtifact.id}}
		basis: {occurrences: [workbookDocumentationOccurrence.id]}
	},
	{
		plane: "documentary", relation: "proposed-by"
		source: {kind: "semantic", semantic: industrialWorkbookSubject}
		target: {kind: "artifact", artifact: {id: workbookProposalArtifact.id}}
		basis: {occurrences: [workbookProposalOccurrence.id]}
	},
	{
		plane: "documentary", relation: "governed-by"
		source: {kind: "semantic", semantic: industrialWorkbookSubject}
		target: {kind: "artifact", artifact: {id: workbookDecisionArtifact.id}}
		basis: {occurrences: [workbookDecisionOccurrence.id]}
	},
]

workbookOperationalRelation: state.#OperationalRelation & {
	plane: "operational", relation: "tracked-by"
	source: {kind: "semantic", semantic: industrialWorkbookSubject}
	target: {kind: "artifact", artifact: {id: workbookTrackerArtifact.id}}
	basis: {occurrences: [workbookTrackerOccurrence.id]}
}

workbookEvidentialRelation: state.#EvidentialRelation & {
	plane: "evidential", relation: "observed-in-event-watch"
	source: {kind: "semantic", semantic: industrialWorkbookSubject}
	target: {kind: "artifact", artifact: {id: workbookEventWatchArtifact.id}}
	basis: {occurrences: [workbookEventWatchOccurrence.id]}
}

industrialWorkbookContextSnapshot: state.#SemanticContextSnapshot & {
	apiVersion: "factory.semantic-context/v1"
	kind: "SemanticContextSnapshot"
	identity: {
		algorithm: "sha256"
		digest: "sha256:6060606060606060606060606060606060606060606060606060606060606060"
	}
	manifest: {
		rootRepository: {repository: "github.com/fatb4f/factory", revision: "fixture"}
		occurrences: [
			{id: workbookDocumentationOccurrence.id, payloadDigest: workbookDocumentationOccurrence.payloadDigest},
			{id: workbookProposalOccurrence.id, payloadDigest: workbookProposalOccurrence.payloadDigest},
			{id: workbookDecisionOccurrence.id, payloadDigest: workbookDecisionOccurrence.payloadDigest},
			{id: workbookTrackerOccurrence.id, payloadDigest: workbookTrackerOccurrence.payloadDigest, revisionHint: workbookTrackerOccurrence.revisionHint},
			{id: workbookEventWatchOccurrence.id, payloadDigest: workbookEventWatchOccurrence.payloadDigest},
		]
		compiler: {name: "cue", version: "v0.16.1", configDigest: "sha256:7070707070707070707070707070707070707070707070707070707070707070"}
		acquisition: {configDigest: "sha256:8080808080808080808080808080808080808080808080808080808080808080"}
		canonicalization: {algorithm: "rfc8785-json", version: "v1"}
		analyzers: []
		admittedContentDigest: "sha256:9090909090909090909090909090909090909090909090909090909090909090"
		coverageDigest: "sha256:a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0"
		manifestDigest: "sha256:b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0"
	}
	subjects: [industrialWorkbookSubject, industrialWorkbookProject]
	occurrences: [workbookDocumentationOccurrence, workbookProposalOccurrence, workbookDecisionOccurrence, workbookTrackerOccurrence, workbookEventWatchOccurrence]
	artifacts: [workbookDocumentationArtifact, workbookProposalArtifact, workbookDecisionArtifact, workbookTrackerArtifact, workbookEventWatchArtifact]
	semanticRelations: [industrialWorkbookSemanticRelation]
	contextRelations: [
		workbookDocumentaryRelations[0],
		workbookDocumentaryRelations[1],
		workbookDocumentaryRelations[2],
		workbookOperationalRelation,
		workbookEvidentialRelation,
	]
	coverageGaps: [{
		id: "gap-industrial-audited-expenditure-coverage"
		plane: "evidential"
		description: "Coverage gaps remain explicit context and are not inferred canonical graph facts."
		subject: industrialWorkbookSubject
	}]
}

industrialDenseTableRequest: state.#AnalyticalRequest & {
	apiVersion: "factory.analytics-ir/v1"
	kind: "AnalyticalRequest"
	id: "industrial-workbook-dense-table"
	source: graphAnalyticalSource
	grain: {keys: ["kind", "id"], unit: "industrial-graph-record"}
	operations: [{
		kind: "project"
		fields: ["kind", "id", "state", "surface", "flowKind", "authorizedAt", "occurredAt", "observedAt", "startedAt", "provenance", "evidence"]
	}]
}

fundingTrajectoryRequest: state.#AnalyticalRequest & {
	apiVersion: "factory.analytics-ir/v1"
	kind: "AnalyticalRequest"
	id: "industrial-workbook-funding-trajectory"
	source: graphAnalyticalSource
	grain: {keys: ["kind", "id"], unit: "funding-accountability-event"}
	operations: [
		{
			kind: "filter"
			predicate: "funding award | disbursement | audited expenditure | project milestone | outcome observation"
			basis: ["contracts/world/industrial-signals/ecosystem.cue"]
		},
		{
			kind: "project"
			fields: ["kind", "id", "flowKind", "authorizedAt", "occurredAt", "observedAt", "amount", "authorizedAmount", "value", "provenance"]
		},
		{kind: "order", by: [{field: "event-time", direction: "asc"}]},
	]
}

industrialContextAnalyticalSource: state.#AnalyticalSourceRef & {
	id: "industrial-workbook-context"
	snapshotDigest: industrialWorkbookContextSnapshot.identity.digest
	semanticRef: industrialWorkbookSubject
	provenance: ["factory.repository-context:admitted", "world.industrial-signals:workbook-context"]
	admissibility: {
		state: "admitted"
		authority: "contracts/state/repository-context.cue"
		basis: ["factory.semantic-context/v1"]
	}
}

industrialContextIndexRequest: state.#AnalyticalRequest & {
	apiVersion: "factory.analytics-ir/v1"
	kind: "AnalyticalRequest"
	id: "industrial-workbook-context-index"
	source: industrialContextAnalyticalSource
	grain: {keys: ["id"], unit: "repository-context-record"}
	operations: [{
		kind: "project"
		fields: ["id", "plane", "role", "sourceKind", "sourceID", "locator", "occurrence", "factoryIssueKey", "coverageGap"]
	}]
}
