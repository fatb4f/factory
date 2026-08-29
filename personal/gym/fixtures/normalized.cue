package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

fixtureNormalized: gym.#NormalizedSession & {
	id:    "session-fixture-001"
	start: fixtureSessionStart
	exposures: [{
		session:  "session-fixture-001"
		exposure: "exposure-ghr-001"
		exercise: {id: "ghr"}
		sequence: 1
		effectiveSetup: {
			variant:   "band-assisted"
			equipment: "ghd"
		}
		dose: {
			reps: 6
			assistance: {
				kind:  "band"
				level: "blue"
			}
		}
		range: {stage: "R2", qualifier: "clean"}
		constraints: [
			{key: "hips-torso-stack", state: "met"},
			{key: "pelvic-control", state: "met"},
			{key: "lumbar-substitution-avoided", state: "met"},
		]
		limiter: {region: "medial-hamstring", kind: "force", onset: "late"}
		media: [{id: "media-ghr-001"}]
		sourceObservations: [{id: "obs-ghr-001"}]
	}]
	recovery: [fixtureRecovery]
	measurements: [fixtureVideoMeasurement, fixtureDualLoad]
	media: [fixtureVideo]
}
