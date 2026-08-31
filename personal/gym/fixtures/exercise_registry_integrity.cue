package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

// Each prescription resolves independently. Keeping the per-exposure result in
// a list prevents repeated fields from unifying across one session object.
triSessionExerciseResolution: [for session in gym.ankleKneePelvisTriSessionV1.sessions {
	kind: session.kind
	exposures: [for exposure in session.exposures {
		exercise: exposure.exercise
		matches: [for key, profile in gym.exerciseProfiles if key == exposure.exercise.id {
			profile & {id: key}
		}] & [_, ...]
	}]
}]
