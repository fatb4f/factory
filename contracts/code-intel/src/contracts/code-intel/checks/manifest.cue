package codeintelchecks

import (
	impl "github.com/fatb4f/factory/contracts/meta"
	codeintel "github.com/fatb4f/factory/contracts/code-intel/src/contracts/code-intel:codeintel"
)

_negativeBottomChecks: {
	generatedAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "generatedAsAuthority"
			input: {
				evidence: "generated code-intel artifacts are inadmissible as authority"
				value: {
					generatedAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects generated authority"
					value:    codeintel.#CodeIntelBoundary
				}
			}
		}
	}).out.generatedAsAuthority

	mcpOutputAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "mcpOutputAsAuthority"
			input: {
				evidence: "MCP output is inadmissible as authority"
				value: {
					mcpOutputIsAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects MCP authority"
					value:    codeintel.#CodeIntelBoundary
				}
			}
		}
	}).out.mcpOutputAsAuthority

	lspDiagnosticsAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "lspDiagnosticsAsAuthority"
			input: {
				evidence: "LSP diagnostics are inadmissible as authority"
				value: {
					lspDiagnosticsAreAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects LSP diagnostics authority"
					value:    codeintel.#CodeIntelBoundary
				}
			}
		}
	}).out.lspDiagnosticsAsAuthority

	weztermTypesAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "weztermTypesAsAuthority"
			input: {
				evidence: "WezTerm types are inadmissible as authority"
				value: {
					weztermTypesAreAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects WezTerm type authority"
					value:    codeintel.#CodeIntelBoundary
				}
			}
		}
	}).out.weztermTypesAsAuthority

	luaWorkflowGeneratedAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "luaWorkflowGeneratedAsAuthority"
			input: {
				evidence: "generated Lua workflow artifacts are inadmissible as authority"
				value: {
					luaWorkflowGeneratedAsAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects generated Lua workflow authority"
					value:    codeintel.#CodeIntelBoundary
				}
			}
		}
	}).out.luaWorkflowGeneratedAsAuthority

	resolverContractsLeak!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "resolverContractsLeak"
			input: {
				evidence: "resolver contracts are inadmissible as code-intel authority"
				value: {
					resolverContractsLeak: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects resolver contract leakage"
					value:    codeintel.#CodeIntelBoundary
				}
			}
		}
	}).out.resolverContractsLeak
}
