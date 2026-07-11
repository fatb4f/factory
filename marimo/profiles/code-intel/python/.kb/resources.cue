package code_intel_python

import "quicue.ca/vocab@v0"

resources: profile: vocab.#Resource & {
	name: "code-intel-python"
	"@type": {CodeIntelPythonProfile: true}
	entrypoint: "code_intel_python.py"
}
