package meta

import "quicue.ca/vocab@v0"

match: vocab.#ProviderMatch & {
	types: {CodeIntelPythonProfile: true}
	provider: "code-intel-python"
}

project: {
	"@id":       "https://github.com/fatb4f/factory/profile/code-intel-python"
	description: "Python code-intelligence profile template."
	status:      "scaffold"
}
