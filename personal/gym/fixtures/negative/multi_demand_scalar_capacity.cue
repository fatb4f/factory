package negative

import gym "github.com/fatb4f/factory/contracts/personal/gym"

// NormalizedCapacity accepts exactly one demand. A multi-demand result must use
// NormalizedCapacityVector and any scalar aggregate must use CapacityAggregate.
invalid: gym.#NormalizedCapacity & {
	id: "bad-vector-scalar"
	demand: [
		{id: "demand-a"},
		{id: "demand-b"},
	]
	grant:         {id: "grant-left"}
	normalization: {kind: "body-mass"}
	value: {value: 0.83, source: "derived", evidence: [baseEvidenceLink]}
}
