package ivacworkbench

import (
	"strings"
	state "github.com/fatb4f/factory/contracts/state:state"
)

// A comparison records what ran. A reviewer decides whether it addresses the report.
#ReviewDeskFeedback: close({
	feedbackID:   string & !=""
	invocationID: string & !=""
	note:         string & !="" & strings.MaxRunes(2000)
	verification: null | close({
		replayInvocationID:    string & !=""
		candidateInvocationID: string & !="" & !=replayInvocationID
		candidateVersion:      string & !=""
		originalOutputDigest:  state.#SHA256
		candidateOutputDigest: state.#SHA256
		changed:               bool
		if changed {
			candidateOutputDigest: !=originalOutputDigest
		}
		if !changed {
			candidateOutputDigest: originalOutputDigest
		}
	})
})
