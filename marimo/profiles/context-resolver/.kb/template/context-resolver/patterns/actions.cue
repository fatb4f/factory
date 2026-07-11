package patterns

import "quicue.ca/vocab@v0"

#ContextResolver: {
	ENTRYPOINT: string
	run: vocab.#Action & {
		name:        "Run"
		description: "Run the context-resolver profile"
		command:     "uv run marimo run \(ENTRYPOINT)"
		category:    "admin"
	}
}

#ContextResolverRegistry: {
	run: vocab.#ActionDef & {
		name:        "run"
		description: "Run the context-resolver profile"
		category:    "admin"
		params: entrypoint: {from_field: "entrypoint"}
		command_template: "uv run marimo run {entrypoint}"
	}
}
