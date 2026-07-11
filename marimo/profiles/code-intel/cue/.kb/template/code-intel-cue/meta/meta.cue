package meta

import "quicue.ca/vocab@v0"

match: vocab.#ProviderMatch & {
	types: {CodeIntelCueProfile: true}
	provider: "code-intel-cue"
}

project: {
	"@id":       "https://github.com/fatb4f/factory/profile/code-intel-cue"
	description: "CUE code-intelligence profile template."
	status:      "scaffold"
}
