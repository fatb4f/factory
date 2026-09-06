package statefixtures

import state "github.com/fatb4f/factory/contracts/state"

semanticAuthority: state.#SemanticAuthorityRef & {
	id:       "world.industrial-signals"
	contract: "contracts/world/industrial-signals/contract.cue"
}

semanticSubject: state.#SemanticRef & {
	authority: semanticAuthority
	subject:   "world.industrial-signals"
	kind:      "graph"
}

secondarySubject: state.#SemanticRef & {
	authority: semanticAuthority
	subject:   "fixture-project-alpha"
	kind:      "project"
}

admittedDomainSnapshot: state.#AdmittedDomainSnapshotRef & {
	authority: semanticAuthority
	id:        "fixture-industrial-snapshot-v1"
	digest:    "sha256:1111111111111111111111111111111111111111111111111111111111111111"
}

cueAuthorityOccurrence: state.#SourceOccurrence & {
	id: "occ-cue-authority"
	source: {
		kind: "repository"
		id:   "github.com/fatb4f/factory"
	}
	locator:       "contracts/world/industrial-signals/contract.cue"
	revisionHint:  "312ef3a9f41fd241695c084b7b0441d11f8b7d3a"
	payloadDigest: "sha256:2222222222222222222222222222222222222222222222222222222222222222"
	lineStart:     1
	lineEnd:       120
	byteStart:     0
	byteEnd:       4096
	acquiredAt:    "2026-09-06T00:40:00Z"
}

markdownOccurrence: state.#SourceOccurrence & {
	id: "occ-markdown-observatory"
	source: {
		kind: "document"
		id:   "factory-observatory-architecture"
	}
	locator:       "docs/architecture/factory-observatory.md"
	revisionHint:  "312ef3a9f41fd241695c084b7b0441d11f8b7d3a"
	payloadDigest: "sha256:3333333333333333333333333333333333333333333333333333333333333333"
	lineStart:     1
	lineEnd:       80
	byteStart:     0
	byteEnd:       8192
	acquiredAt:    "2026-09-06T00:40:01Z"
}

githubIssueOccurrence: state.#SourceOccurrence & {
	id: "occ-github-issue-144"
	source: {
		kind: "github-issue"
		id:   "github.com/fatb4f/factory"
	}
	locator:       "issues/144"
	revisionHint:  "updatedAt=2026-09-06T00:38:54Z"
	payloadDigest: "sha256:4444444444444444444444444444444444444444444444444444444444444444"
	acquiredAt:    "2026-09-06T00:40:02Z"
}

runOccurrence: state.#SourceOccurrence & {
	id: "occ-industrial-run"
	source: {
		kind: "run"
		id:   "world.industrial-signals"
	}
	locator:       "world/industrial-signals/runs/fixture/manifest.json"
	payloadDigest: "sha256:5555555555555555555555555555555555555555555555555555555555555555"
	acquiredAt:    "2026-09-06T00:40:03Z"
}

evidenceOccurrence: state.#SourceOccurrence & {
	id: "occ-industrial-evidence"
	source: {
		kind: "evidence"
		id:   "world.industrial-signals"
	}
	locator:       "world/industrial-signals/runs/fixture/evidence.json"
	payloadDigest: "sha256:6666666666666666666666666666666666666666666666666666666666666666"
	acquiredAt:    "2026-09-06T00:40:04Z"
}

structuralArtifact: state.#ContextArtifact & {
	id:       "artifact-cue-authority"
	plane:    "structural"
	role:     "semantic-authority-source"
	subjects: [semanticSubject]
	occurrence: cueAuthorityOccurrence
}

documentaryArtifact: state.#ContextArtifact & {
	id:       "artifact-observatory-doc"
	plane:    "documentary"
	role:     "architecture-document"
	subjects: [semanticSubject]
	occurrence: markdownOccurrence
}

operationalArtifact: state.#ContextArtifact & {
	id:       "artifact-github-issue-144"
	plane:    "operational"
	role:     "tracker-projection"
	subjects: [semanticSubject]
	occurrence: githubIssueOccurrence
}

runArtifact: state.#ContextArtifact & {
	id:       "artifact-industrial-run"
	plane:    "evidential"
	role:     "run-manifest"
	subjects: [semanticSubject]
	occurrence: runOccurrence
}

evidenceArtifact: state.#ContextArtifact & {
	id:       "artifact-industrial-evidence"
	plane:    "evidential"
	role:     "evidence-artifact"
	subjects: [semanticSubject]
	occurrence: evidenceOccurrence
}

semanticRelation: state.#SemanticRelation & {
	plane:     "semantic"
	authority: semanticAuthority
	predicate: {
		authority: semanticAuthority
		id:        "fixture-relates-to-project"
	}
	snapshot: admittedDomainSnapshot
	source:   semanticSubject
	target:   secondarySubject
	basis: {
		occurrences: [cueAuthorityOccurrence.id]
		note:       "Synthetic fixture relation proving authority and snapshot qualification."
	}
}

structuralRelation: state.#StructuralRelation & {
	plane:    "structural"
	relation: "declared-by-source"
	source: {
		kind:     "semantic"
		semantic: semanticSubject
	}
	target: {
		kind: "artifact"
		artifact: {id: structuralArtifact.id}
	}
	basis: {occurrences: [cueAuthorityOccurrence.id]}
}

documentaryRelation: state.#DocumentaryRelation & {
	plane:    "documentary"
	relation: "documented-by"
	source: {
		kind:     "semantic"
		semantic: semanticSubject
	}
	target: {
		kind: "artifact"
		artifact: {id: documentaryArtifact.id}
	}
	basis: {occurrences: [markdownOccurrence.id]}
}

operationalRelation: state.#OperationalRelation & {
	plane:    "operational"
	relation: "tracked-by"
	source: {
		kind:     "semantic"
		semantic: semanticSubject
	}
	target: {
		kind: "artifact"
		artifact: {id: operationalArtifact.id}
	}
	basis: {occurrences: [githubIssueOccurrence.id]}
}

runEvidenceRelation: state.#EvidentialRelation & {
	plane:    "evidential"
	relation: "has-run-context"
	source: {
		kind:     "semantic"
		semantic: semanticSubject
	}
	target: {
		kind: "artifact"
		artifact: {id: runArtifact.id}
	}
	basis: {occurrences: [runOccurrence.id]}
}

evidenceRelation: state.#EvidentialRelation & {
	plane:    "evidential"
	relation: "has-evidence-context"
	source: {
		kind:     "semantic"
		semantic: semanticSubject
	}
	target: {
		kind: "artifact"
		artifact: {id: evidenceArtifact.id}
	}
	basis: {occurrences: [evidenceOccurrence.id]}
}

semanticContextSnapshot: state.#SemanticContextSnapshot & {
	apiVersion: "factory.semantic-context/v1"
	kind:       "SemanticContextSnapshot"
	identity: {
		algorithm: "sha256"
		digest:    "sha256:7777777777777777777777777777777777777777777777777777777777777777"
	}
	manifest: {
		rootRepository: {
			repository: "github.com/fatb4f/factory"
			revision:   "312ef3a9f41fd241695c084b7b0441d11f8b7d3a"
		}
		occurrences: [
			{id: cueAuthorityOccurrence.id, payloadDigest: cueAuthorityOccurrence.payloadDigest, revisionHint: cueAuthorityOccurrence.revisionHint},
			{id: markdownOccurrence.id, payloadDigest: markdownOccurrence.payloadDigest, revisionHint: markdownOccurrence.revisionHint},
			{id: githubIssueOccurrence.id, payloadDigest: githubIssueOccurrence.payloadDigest, revisionHint: githubIssueOccurrence.revisionHint},
			{id: runOccurrence.id, payloadDigest: runOccurrence.payloadDigest},
			{id: evidenceOccurrence.id, payloadDigest: evidenceOccurrence.payloadDigest},
		]
		compiler: {
			name:         "cue"
			version:      "v0.16.1"
			configDigest: "sha256:8888888888888888888888888888888888888888888888888888888888888888"
		}
		acquisition: {
			configDigest: "sha256:9999999999999999999999999999999999999999999999999999999999999999"
		}
		canonicalization: {
			algorithm: "rfc8785-json"
			version:   "v1"
		}
		analyzers: [
			{name: "python-ast", version: "3.14"},
			{name: "jedi", version: "0.19"},
			{name: "tree-sitter", version: "0.25", grammarRevision: "python-fixture-revision"},
		]
		admittedContentDigest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
		coverageDigest:        "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
		manifestDigest:        "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
	}
	subjects: [semanticSubject, secondarySubject]
	occurrences: [
		cueAuthorityOccurrence,
		markdownOccurrence,
		githubIssueOccurrence,
		runOccurrence,
		evidenceOccurrence,
	]
	artifacts: [
		structuralArtifact,
		documentaryArtifact,
		operationalArtifact,
		runArtifact,
		evidenceArtifact,
	]
	semanticRelations: [semanticRelation]
	contextRelations: [
		structuralRelation,
		documentaryRelation,
		operationalRelation,
		runEvidenceRelation,
		evidenceRelation,
	]
	coverageGaps: [{
		id:          "gap-audited-expenditure"
		plane:       "evidential"
		description: "Synthetic fixture intentionally has no audited expenditure occurrence."
		subject:     semanticSubject
	}]
}
