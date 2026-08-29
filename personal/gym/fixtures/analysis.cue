package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

fixtureDualProjection: gym.#DualLoadProjection & {
	sample: fixtureDualLoad
}

fixtureSessionAssessment: gym.#SessionAssessment & {
	session: "session-fixture-001"
	exposures: [{
		exposure:   "exposure-ghr-001"
		mechanical: "clean"
		capacity: {
			assistanceKind:  "band"
			assistanceLevel: "blue"
			rangeStage:      "R2"
			rangeOrder:      2
			reps:            6
		}
		sources: [{id: "obs-ghr-001"}]
	}]
	recovery: {
		level: "low"
		summary: {
			checkpointCount: 1
			energyDrop:      0
			cognitiveDrop:   0
			maxDoms:         2
		}
		sources: [{id: "recovery-024h-001"}]
	}
	recoveryComplete:    true
	progressEligibility: "eligible"
}

fixtureAdaptationComparison: gym.#AdaptationComparison & {
	baselineSession: "session-fixture-baseline"
	currentSession:  "session-fixture-001"
	dimensions: [
		{group: "capacity", metric: "ghr-rom-stage", direction: "improved"},
		{group: "quality", metric: "mechanical-admission", direction: "unchanged"},
		{group: "recovery", metric: "recovery-cost", direction: "improved"},
	]
	classification: "dominates-previous"
}
