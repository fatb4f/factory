package code_intel_cue

import (
	"quicue.ca/patterns@v0"
	profile_patterns "github.com/fatb4f/factory/marimo/profiles/code-intel/cue/kg/template/code-intel-cue/patterns"
)

providers: profile: patterns.#ProviderDecl & {
	types: {CodeIntelCueProfile: true}
	registry: profile_patterns.#CodeIntelCueRegistry
}
