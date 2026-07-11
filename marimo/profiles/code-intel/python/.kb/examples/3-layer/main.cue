package main

import (
	profile_patterns "github.com/fatb4f/factory/marimo/profiles/code-intel/python/kg/template/code-intel-python/patterns"
	"quicue.ca/patterns@v0"
	"quicue.ca/vocab@v0"
)

resources: profile: vocab.#Resource & {
	name:       "code-intel-python"
	entrypoint: "code_intel_python.py"
	"@type": {CodeIntelPythonProfile: true}
	actions: profile_patterns.#CodeIntelPython & {ENTRYPOINT: entrypoint}
}

output: profile: {
	resource: resources.profile.name
	actions: {
		for name, action in resources.profile.actions if action.command != _|_ {
			(name): action.command
		}
	}
}

_resources: profile: resources.profile
infra: patterns.#InfraGraph & {Input: _resources}
_viz: patterns.#VizData & {Graph: infra, Resources: _resources}
vizData: _viz.data
