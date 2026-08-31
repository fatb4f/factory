package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

triSessionExerciseResolution: [for session in gym.ankleKneePelvisTriSessionV1.sessions {
	for exposure in session.exposures {
		exercise: exposure.exercise
		matches: [for id, profile in gym.exerciseProfiles if id == exposure.exercise.id {
			profile & {id: id}
		}] & [_, ...]
	}
}]
