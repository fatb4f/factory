package fixtures

import gym "github.com/fatb4f/factory/contracts/personal/gym"

// Representative compatibility bindings prove that the composed public surface
// resolves canonical nested values rather than merely becoming concrete.
publicExportCompatibility: close({
	contract: gym.public.contract & {
		id:      "personal.gym"
		version: "0.4.1"
	}
	chain: gym.public.chains["distal-foot-ankle"] & {
		id:   "distal-foot-ankle"
		kind: "regional"
	}
	exercise: gym.public.exercises.ghr & {
		id:   "ghr"
		name: "Glute-ham raise"
	}
	program: gym.public.programs["ankle-knee-pelvis-stability"] & {
		id: "ankle-knee-pelvis-stability"
	}
})
