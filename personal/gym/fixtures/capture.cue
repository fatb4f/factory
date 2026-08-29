package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

fixtureSessionStart: gym.#SessionStart & {
	kind:      "session-start"
	id:        "obs-session-start-001"
	session:   "session-fixture-001"
	startedAt: "2026-01-01T10:00:00-05:00"
	intent:    "Posterior-chain quality exposure"
	planned: [{id: "ghr"}, {id: "reverse-hyper"}, {id: "copenhagen"}]
	baseline: {
		energyAvailable:    3
		cognitiveAvailable: 3
	}
	movement: {gait: "normal"}
	provenance: {
		sourceKind: "user-statement"
		certainty:  "direct"
		capturedAt: "2026-01-01T10:00:00-05:00"
	}
}

fixtureGHR: gym.#ExposureObservation & {
	kind:     "exposure-observation"
	id:       "obs-ghr-001"
	session:  "session-fixture-001"
	exposure: "exposure-ghr-001"
	exercise: {id: "ghr"}
	sequence: 1
	setup: {
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
	provenance: {
		sourceKind: "user-statement"
		certainty:  "direct"
		capturedAt: "2026-01-01T10:12:00-05:00"
	}
}

fixtureVideo: gym.#MediaArtifact & {
	kind:        "media"
	id:          "media-ghr-001"
	mediaKind:   "video"
	capturedAt:  "2026-01-01T10:12:00-05:00"
	perspective: "right-side"
	durationS:   18.2
	frameRate:   60
	widthPx:     1920
	heightPx:    1080
}

fixtureVideoMeasurement: gym.#Measurement & {
	kind:       "measurement"
	id:         "measurement-ghr-eccentric-001"
	metric:     "eccentric-duration"
	metricKind: "duration"
	value:      2.8
	unit:       "s"
	provenance: {
		sourceKind: "video"
		certainty:  "approximate"
		capturedAt: "2026-01-01T10:12:00-05:00"
		media: {id: "media-ghr-001"}
	}
}

fixtureDualLoad: gym.#DualLoadSample & {
	kind: "dual-load"
	id:   "measurement-stance-001"
	left:  {value: 39.8, unit: "kg"}
	right: {value: 40.6, unit: "kg"}
	stance: "quiet bilateral stance"
	provenance: {
		sourceKind: "scale"
		certainty:  "direct"
		capturedAt: "2026-01-01T10:45:00-05:00"
		deviceID:   "dual-scale-fixture"
	}
}

fixtureRecovery: gym.#RecoveryCheckpoint & {
	kind:         "recovery-checkpoint"
	id:           "recovery-024h-001"
	session:      "session-fixture-001"
	elapsedHours: 24
	doms: {
		"medial-hamstring": 2
		adductor:            1
	}
	systemic: {
		energyAvailable:    3
		cognitiveAvailable: 3
		taskInitiation:      "normal"
		subjectiveRecovery: "normal"
	}
	movement: {gait: "normal"}
	provenance: {
		sourceKind: "user-statement"
		certainty:  "direct"
		capturedAt: "2026-01-02T10:00:00-05:00"
	}
}
