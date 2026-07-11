package code_intel_cue

import "quicue.ca/vocab@v0"

resources: profile: vocab.#Resource & {
	name: "code-intel-cue"
	"@type": {CodeIntelCueProfile: true}
	entrypoint: "code_intel_cue.py"
}
