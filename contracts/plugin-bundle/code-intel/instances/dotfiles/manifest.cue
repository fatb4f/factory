package codeintelpluginbundle

import (
	impl "github.com/fatb4f/factory/contracts/meta"
)

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
_negativeBottomChecks: {
	generatedAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "generatedAsAuthority"
			input: {
				evidence: "generated code-intel artifacts are inadmissible as authority"
				value:    negativeFixtures.generatedAsAuthority.input
			}
			target: {
				name: "#AdmissibleCodeIntelPluginBundleProjection"
				contract: {
					evidence: "code-intel plugin bundle projection rejects generated authority"
					value:    #AdmissibleCodeIntelPluginBundleProjection
				}
			}
		}
	}).out.generatedAsAuthority
	mcpOutputAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "mcpOutputAsAuthority"
			input: {
				evidence: "MCP output is inadmissible as authority"
				value:    negativeFixtures.mcpOutputAsAuthority.input
			}
			target: {
				name: "#AdmissibleCodeIntelPluginBundleProjection"
				contract: {
					evidence: "code-intel plugin bundle projection rejects MCP authority"
					value:    #AdmissibleCodeIntelPluginBundleProjection
				}
			}
		}
	}).out.mcpOutputAsAuthority
	lspDiagnosticsAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "lspDiagnosticsAsAuthority"
			input: {
				evidence: "LSP diagnostics are inadmissible as authority"
				value:    negativeFixtures.lspDiagnosticsAsAuthority.input
			}
			target: {
				name: "#AdmissibleCodeIntelPluginBundleProjection"
				contract: {
					evidence: "code-intel plugin bundle projection rejects LSP diagnostics authority"
					value:    #AdmissibleCodeIntelPluginBundleProjection
				}
			}
		}
	}).out.lspDiagnosticsAsAuthority
	weztermTypesAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "weztermTypesAsAuthority"
			input: {
				evidence: "WezTerm types are inadmissible as authority"
				value:    negativeFixtures.weztermTypesAsAuthority.input
			}
			target: {
				name: "#AdmissibleCodeIntelPluginBundleProjection"
				contract: {
					evidence: "code-intel plugin bundle projection rejects WezTerm type authority"
					value:    #AdmissibleCodeIntelPluginBundleProjection
				}
			}
		}
	}).out.weztermTypesAsAuthority
	luaWorkflowGeneratedAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "luaWorkflowGeneratedAsAuthority"
			input: {
				evidence: "generated Lua workflow artifacts are inadmissible as authority"
				value:    negativeFixtures.luaWorkflowGeneratedAsAuthority.input
			}
			target: {
				name: "#AdmissibleCodeIntelPluginBundleProjection"
				contract: {
					evidence: "code-intel plugin bundle projection rejects generated Lua workflow authority"
					value:    #AdmissibleCodeIntelPluginBundleProjection
				}
			}
		}
	}).out.luaWorkflowGeneratedAsAuthority
	resolverContractsLeak!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "resolverContractsLeak"
			input: {
				evidence: "resolver contracts are inadmissible as code-intel authority"
				value:    negativeFixtures.resolverContractsLeak.input
			}
			target: {
				name: "#AdmissibleCodeIntelPluginBundleProjection"
				contract: {
					evidence: "code-intel plugin bundle projection rejects resolver contract leakage"
					value:    #AdmissibleCodeIntelPluginBundleProjection
				}
			}
		}
	}).out.resolverContractsLeak
}

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
pluginBundleRoot:         ".codex/plugins/code-intel"
pluginBundleTemplateRoot: "contracts/plugin-bundle/src"
pluginBundleContractRoot: "contracts/plugin-bundle/code-intel/instances/dotfiles"
pluginBundleSourceRoot:   "\(pluginBundleContractRoot)/src"
pluginBundlePackage:      "codeintelpluginbundle"

codeIntelRequiredPaths: [
	"SKILL.md",
	"manifest.json",
	"generated/mcp/server-manifest.json",
	"generated/mcp/tool-registry.json",
	"generated/mcp/context-projection.json",
	"generated/lsp/cue-lsp.json",
	"generated/lsp/lua-language-server.json",
	"generated/lsp/provider-routing.json",
	"generated/types/wezterm/wezterm.lua",
	"generated/types/wezterm/events.lua",
	"generated/types/wezterm/config-builder.lua",
	"generated/types/nvim/vim.lua",
	"generated/workflows/lua-first/workflow.json",
	"generated/workflows/lua-first/entrypoints.json",
	"generated/workflows/lua-first/diagnostic-map.json",
	"contracts/code-intel/manifest.cue",
]

codeIntelSourceInventory: [
	for relativePath in codeIntelRequiredPaths {
		"\(pluginBundleSourceRoot)/\(relativePath)"
	},
]

#CodeIntelAuthorityBlock: close({
	root: "contracts"
	codeIntel: close({
		root: "contracts/code-intel"
		files: [...#ContainedBundlePath] & [_, ...]
		contiguous: true
	})
	externalFactoryReference?:        false
	externalContractCuemodReference?: false
	resolverContractsLeak?:           false
})

codeIntelAuthorityBlock: #CodeIntelAuthorityBlock & {
	codeIntel: {files: ["manifest.cue", "manifest.cue"]}
}

#CodeIntelBundleContract: close({
	schema:           "factory.plugin-bundle.code-intel.contract.v1"
	contractRoot:     pluginBundleContractRoot
	package:          pluginBundlePackage
	targetRepo:       "github.com/fatb4f/dotfiles"
	templateRoot:     pluginBundleTemplateRoot
	instanceRoot:     pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	requiredPaths: [...#ContainedBundlePath] & [_, ...]
	bundledCueAuthority: #CodeIntelAuthorityBlock
	containment: close({
		pluginRootOnly:                  true
		topLevelPluginRoot:              false
		externalFactoryReference:        false
		externalContractCuemodReference: false
		resolverContractsLeak:           false
		proseReferenceAuthority:         false
	})
})

codeIntelBundleContract: #CodeIntelBundleContract & {
	requiredPaths:       codeIntelRequiredPaths
	bundledCueAuthority: codeIntelAuthorityBlock
	containment: {
		pluginRootOnly:                  true
		topLevelPluginRoot:              false
		externalFactoryReference:        false
		externalContractCuemodReference: false
		resolverContractsLeak:           false
		proseReferenceAuthority:         false
	}
}

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
negativeFixtures: {
	generatedAsAuthority: {input: codeIntelBundleInput & {generatedAuthority: true}}
	mcpOutputAsAuthority: {input: codeIntelBundleInput & {mcpOutputIsAuthority: true}}
	lspDiagnosticsAsAuthority: {input: codeIntelBundleInput & {lspDiagnosticsAreAuthority: true}}
	weztermTypesAsAuthority: {input: codeIntelBundleInput & {weztermTypesAreAuthority: true}}
	luaWorkflowGeneratedAsAuthority: {input: codeIntelBundleInput & {luaWorkflowGeneratedAsAuthority: true}}
	resolverContractsLeak: {input: codeIntelBundleInput & {resolverContractsLeak: true}}
}

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
#CodeIntelProviderSurface: close({
	id:   #NonEmptyString
	kind: "cue" | "mcp" | "lsp" | "types"
	paths: [...#ContainedBundlePath]
	authority:       false
	evidenceOnly:    true
	defaultReadOnly: true
})

#LuaWorkflowEntrypoint: close({
	id:           #NonEmptyString
	language:     "lua"
	path:         #ContainedBundlePath
	domain:       "nvim" | "wezterm" | "dotfiles"
	authority:    "dotfiles-source"
	lspProvider:  "lua-language-server"
	typeOverlay?: #NonEmptyString
})

#LuaWorkflowStep: close({
	order: int & >0
	id:    #NonEmptyString
	goal:  #NonEmptyString
	inputs: [...#NonEmptyString]
	outputs: [...#NonEmptyString]
	authority: "dotfiles-source" | "evidence-only"
})

#CodeIntelLuaFirstWorkflow: close({
	schema: "factory.plugin-bundle.code-intel.lua-first-workflow.v1"
	id:     #NonEmptyString
	intent: #NonEmptyString
	entrypoints: [...#LuaWorkflowEntrypoint] & [_, ...]
	providers: [...#CodeIntelProviderSurface] & [_, ...]
	steps: [...#LuaWorkflowStep] & [_, ...]
	generatedArtifacts: [...#ContainedBundlePath] & [_, ...]
	authority: close({
		owns: [...#NonEmptyString] & [_, ...]
		doesNotOwn: [...#NonEmptyString] & [_, ...]
	})
})

codeIntelLuaFirstWorkflow: #CodeIntelLuaFirstWorkflow & {
	id:     "dotfiles-code-intel-lua-first"
	intent: "Bundle read-only code intelligence for dotfiles Lua work without merging it into the agent-context-resolver bundle."
	entrypoints: [
		{id: "nvim-init", language: "lua", path: ".config/nvim/init.lua", domain: "nvim", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "nvim-vim-types"},
		{id: "nvim-lua-modules", language: "lua", path: ".config/nvim/lua", domain: "nvim", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "nvim-vim-types"},
		{id: "wezterm-config", language: "lua", path: ".config/wezterm/wezterm.lua", domain: "wezterm", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "wezterm-types"},
	]
	providers: [
		{id: "mcp-tool-registry", kind: "mcp", paths: ["generated/mcp/tool-registry.json", "generated/mcp/context-projection.json"], authority: false, evidenceOnly: true, defaultReadOnly: true},
		{id: "cue-lsp", kind: "lsp", paths: ["generated/lsp/cue-lsp.json"], authority: false, evidenceOnly: true, defaultReadOnly: true},
		{id: "lua-language-server", kind: "lsp", paths: ["generated/lsp/lua-language-server.json", "generated/lsp/provider-routing.json"], authority: false, evidenceOnly: true, defaultReadOnly: true},
		{id: "wezterm-types", kind: "types", paths: ["generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua"], authority: false, evidenceOnly: true, defaultReadOnly: true},
		{id: "nvim-vim-types", kind: "types", paths: ["generated/types/nvim/vim.lua"], authority: false, evidenceOnly: true, defaultReadOnly: true},
	]
	steps: [
		{order: 1, id: "collect-lua-entrypoints", goal: "Resolve Lua entrypoints before generic dotfiles paths.", inputs: ["dotfiles source paths"], outputs: ["ordered Lua entrypoint set"], authority: "dotfiles-source"},
		{order: 2, id: "load-type-overlays", goal: "Attach Neovim and WezTerm type overlays as read-only evidence.", inputs: ["generated/types/nvim/vim.lua", "generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua"], outputs: ["Lua library overlay"], authority: "evidence-only"},
		{order: 3, id: "project-diagnostics", goal: "Project Lua and CUE diagnostics as evidence, not mutation authority.", inputs: ["generated/lsp/lua-language-server.json", "generated/lsp/cue-lsp.json"], outputs: ["diagnostic-map"], authority: "evidence-only"},
	]
	generatedArtifacts: codeIntelRequiredPaths
	authority: {
		owns: ["code-intel bundle workflow shape", "provider ordering for Lua-first dotfiles work", "negative authority boundaries for generated code-intel artifacts"]
		doesNotOwn: ["agent-context-resolver bundle", "fatb4f/dotfiles source authority", "runtime execution", "truth of LSP diagnostics", "WezTerm runtime behavior", "Neovim runtime behavior"]
	}
}

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
#CodeIntelOutputPlan: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
	files: [...#CodeIntelTargetFile] & [_, ...]
	authority: false
})

codeIntelOutputPlan: #CodeIntelOutputPlan & {
	repo:      codeIntelTarget.repo
	root:      codeIntelTarget.root
	files:     generatedFileInventory
	authority: false
}

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
codeIntelTarget: #CodeIntelTarget & {
	repo: "github.com/fatb4f/dotfiles"
	root: "."
}

codeIntelTargetInventory: [
	for relativePath in codeIntelRequiredPaths {
		"\(pluginBundleRoot)/\(relativePath)"
	},
]

generatedFileInventory: [
	for targetPath in codeIntelTargetInventory {
		path:      targetPath
		generated: true
		authority: false
		source:    "bundle-projection"
	},
]

projectionComponents: [
	{id: "code-intel-contract", path: pluginBundleContractRoot, role: "contract", authority: true},
	{id: "code-intel-source-tree", path: pluginBundleSourceRoot, role: "package-source", authority: true},
	{id: "plugin-bundle-template", path: pluginBundleTemplateRoot, role: "contract", authority: true},
	{id: "code-intel-materialized-root", path: pluginBundleRoot, role: "generated-package", generated: true, authority: false},
	{id: "bundled-mcp-surfaces", path: "\(pluginBundleRoot)/generated/mcp", role: "package-content", generated: true, authority: false},
	{id: "bundled-lsp-surfaces", path: "\(pluginBundleRoot)/generated/lsp", role: "package-content", generated: true, authority: false},
	{id: "bundled-wezterm-types", path: "\(pluginBundleRoot)/generated/types/wezterm", role: "package-content", generated: true, authority: false},
	{id: "bundled-nvim-types", path: "\(pluginBundleRoot)/generated/types/nvim", role: "package-content", generated: true, authority: false},
	{id: "lua-first-workflow", path: "\(pluginBundleRoot)/generated/workflows/lua-first", role: "package-content", generated: true, authority: false},
]

projectionGates: [
	{id: "code-intel-cue-vet", kind: "cue-vet", target: "./contracts/plugin-bundle/code-intel/instances/dotfiles", required: true},
	{id: "code-intel-contract-export", kind: "cue-export", target: "codeIntelBundleContract", required: true},
	{id: "code-intel-output-export", kind: "cue-export", target: "codeIntelOutputPlan", required: true},
	{id: "code-intel-workflow-export", kind: "cue-export", target: "codeIntelLuaFirstWorkflow", required: true},
	{id: "code-intel-negative-bottom", kind: "negative-bottom", target: "_negativeBottomChecks", required: true},
]

codeIntelBundleInput: {
	contract:       codeIntelBundleContract
	target:         codeIntelTarget
	components:     projectionComponents
	generatedFiles: generatedFileInventory
	outputPlan:     codeIntelOutputPlan
	gates:          projectionGates
	providerReachability: {
		kind:         "provider-reachability"
		authority:    false
		evidenceOnly: true
		providers: ["mcp-tool-registry", "mcp-context-projection", "cue-lsp", "lua-language-server", "wezterm-types", "nvim-vim-types", "lua-first-workflow"]
	}
}

codeIntelBundle: #AdmissibleCodeIntelPluginBundleProjection & codeIntelBundleInput

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
codeIntelBundleReport: {
	schema:           "factory.plugin-bundle.code-intel.report.v1"
	status:           "admitted"
	path:             pluginBundleContractRoot
	templateRoot:     pluginBundleTemplateRoot
	materializedRoot: pluginBundleRoot
	bundledSurfaces: {
		mcp:              true
		cueLSP:           true
		luaLSP:           true
		weztermTypes:     true
		nvimTypes:        true
		luaFirstWorkflow: true
		authority:        false
	}
}

codeIntelLuaFirstWorkflowReport: {
	schema:   "factory.plugin-bundle.code-intel.lua-first-workflow.report.v1"
	status:   "admitted"
	path:     pluginBundleContractRoot
	workflow: codeIntelLuaFirstWorkflow.id
	providers: [for provider in codeIntelLuaFirstWorkflow.providers {provider.id}]
}

// source: contracts/plugin-bundle/code-intel/instances/dotfiles/manifest.cue
#NonEmptyString:      string & !=""
#ContainedBundlePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#CodeIntelTarget: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
})

#Gate: close({
	id:       #NonEmptyString
	kind:     "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search" | "plugin-manifest" | "archive"
	target:   #NonEmptyString
	required: true
})

#CodeIntelTargetFile: close({
	path:      #NonEmptyString
	generated: true
	authority: false
	source:    "bundle-projection"
})

#ProjectionComponent: close({
	id:        #NonEmptyString
	path:      #NonEmptyString
	role:      "contract" | "package-source" | "generated-package" | "package-content" | "package-metadata" | "idempotency-lock" | "integration"
	generated: *false | bool
	authority: bool
})

#ProviderReachabilityEvidence: close({
	kind:         "provider-reachability"
	authority:    false
	evidenceOnly: true
	providers: [...#NonEmptyString]
})

#CodeIntelPluginBundleProjection: close({
	contract: #CodeIntelBundleContract
	target:   #CodeIntelTarget
	components: [...#ProjectionComponent] & [_, ...]
	generatedFiles: [...#CodeIntelTargetFile] & [_, ...]
	outputPlan: #CodeIntelOutputPlan
	gates: [...#Gate] & [_, ...]
	providerReachability: #ProviderReachabilityEvidence

	generatedAuthority?:              false
	mcpOutputIsAuthority?:            false
	lspDiagnosticsAreAuthority?:      false
	weztermTypesAreAuthority?:        false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?:           false
})

#AdmissibleCodeIntelPluginBundleProjection: #CodeIntelPluginBundleProjection & {
	generatedAuthority?:              false
	mcpOutputIsAuthority?:            false
	lspDiagnosticsAreAuthority?:      false
	weztermTypesAreAuthority?:        false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?:           false
}
