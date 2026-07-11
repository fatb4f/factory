package main

import (
	profile_patterns "github.com/fatb4f/factory/marimo/profiles/context-resolver/kg/template/context-resolver/patterns"
	"quicue.ca/patterns@v0"
	"quicue.ca/vocab@v0"
)

resources: profile: vocab.#Resource & {
	name:       "context-resolver"
	entrypoint: "context_resolver.py"
	"@type": {ContextResolverProfile: true}
	actions: profile_patterns.#ContextResolver & {ENTRYPOINT: entrypoint}
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
