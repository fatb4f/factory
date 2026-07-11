package patterns

import "quicue.ca/vocab@v0"

#CodeIntelPython: {
	ENTRYPOINT: string
	run: vocab.#Action & {
		name:        "Run"
		description: "Run the Python code-intelligence profile"
		command:     "uv run marimo run \(ENTRYPOINT)"
		category:    "admin"
	}
}

#CodeIntelPythonRegistry: {
	run: vocab.#ActionDef & {
		name:        "run"
		description: "Run the Python code-intelligence profile"
		category:    "admin"
		params: entrypoint: {from_field: "entrypoint"}
		command_template: "uv run marimo run {entrypoint}"
	}
}
