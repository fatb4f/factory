package pluginbundle_code_intelchecks

import (
	impl "github.com/fatb4f/factory/contracts/meta"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

_negativeBottomChecks: {
	generatedAuthorityAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "generatedAuthorityAccepted"
			input: {
				evidence: "standardized projection must not promote generated artifacts"
				value: {generatedAuthority: true}
			}
			target: {
				name: "#PluginBundleAuthorityPolicy"
				contract: {
					evidence: "plugin-bundle authority rejects generated authority"
					value:    tmpl.#PluginBundleAuthorityPolicy
				}
			}
		}
	}).out.generatedAuthorityAccepted
}
