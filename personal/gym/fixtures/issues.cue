package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

fixtureIssue: gym.#IssueDefinition & {
	id:        "issue-right-side-relative-capacity"
	title:     "Right-side relative capacity"
	createdAt: "2026-01-01T10:30:00-05:00"
	status:    "monitoring"
}

fixtureIssueEvidence: gym.#IssueEvidence & {
	id:       "issue-evidence-001"
	issue:    "issue-right-side-relative-capacity"
	relation: "supports"
	source: {
		kind: "observation"
		id:   "obs-copenhagen-001"
	}
	exercise: {id: "copenhagen"}
	side:     "right"
}

fixtureIssueProjection: gym.#IssueProjection & {
	issue:         fixtureIssue
	supporting:    1
	contradicting: 0
	contextual:    0
	contexts:      ["copenhagen"]
	trend:         "unknown"
	confidence:    "insufficient"
	evidence:      [fixtureIssueEvidence]
}

fixtureAssociation: gym.#AssociationProjection & {
	subjectMetric: "cognitive-recovery-cost"
	condition:     "ghr-range-stage>=R3"
	observations:  3
	direction:     "unknown"
	confidence:    "insufficient"
	causalClaim:   false
	sources:       ["session-fixture-001", "session-fixture-002", "session-fixture-003"]
}
