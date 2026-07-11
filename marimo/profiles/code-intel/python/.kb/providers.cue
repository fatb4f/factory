package code_intel_python

import (
	"quicue.ca/patterns@v0"
	profile_patterns "github.com/fatb4f/factory/marimo/profiles/code-intel/python/kg/template/code-intel-python/patterns"
)

providers: profile: patterns.#ProviderDecl & {
	types: {CodeIntelPythonProfile: true}
	registry: profile_patterns.#CodeIntelPythonRegistry
}
