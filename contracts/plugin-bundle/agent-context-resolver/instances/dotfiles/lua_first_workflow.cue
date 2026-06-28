package dotfilespluginbundle

#WorkflowProviderSurface: close({
	id: #NonEmptyString
	kind: "cue" | "mcp" | "lsp" | "types" | "filesystem" | "git"
	paths?: [...#ContainedBundlePath]
	authority: bool
	evidenceOnly: bool
	defaultReadOnly: bool | *true
})

#LuaWorkflowEntrypoint: close({
	id: #NonEmptyString
	language: "lua"
	path: #ContainedBundlePath
	domain: "nvim" | "wezterm" | "dotfiles"
	authority: "dotfiles-source"
	lspProvider: "lua-language-server"
	typeOverlay?: #NonEmptyString
})

#LuaWorkflowStep: close({
	order: int & >0
	id: #NonEmptyString
	goal: #NonEmptyString
	inputs: [...#NonEmptyString]
	outputs: [...#NonEmptyString]
	authority: "cue-contract" | "dotfiles-source" | "evidence-only"
})

#LuaWorkflowGate: close({
	id: #NonEmptyString
	checks: [...#NonEmptyString] & [_, ...]
	denies: [...#NonEmptyString] & [_, ...]
})

#DotfilesLuaFirstWorkflow: close({
	schema: "factory.plugin-bundle.dotfiles.lua-first-workflow.v1"
	id: #NonEmptyString
	intent: #NonEmptyString
	authority: close({
		owns: [...#NonEmptyString] & [_, ...]
		doesNotOwn: [...#NonEmptyString] & [_, ...]
	})
	entrypoints: [...#LuaWorkflowEntrypoint] & [_, ...]
	providers: [...#WorkflowProviderSurface] & [_, ...]
	steps: [...#LuaWorkflowStep] & [_, ...]
	gates: [...#LuaWorkflowGate] & [_, ...]
	generatedArtifacts: [...#ContainedBundlePath] & [_, ...]
})

dotfilesLuaFirstWorkflow: #DotfilesLuaFirstWorkflow & {
	schema: "factory.plugin-bundle.dotfiles.lua-first-workflow.v1"
	id: "dotfiles-lua-first"
	intent: "Prefer Lua source and Lua-aware diagnostics first when resolving dotfiles work, while keeping MCP, LSP, and generated type overlays evidence-only."

	authority: {
		owns: [
			"Lua-first resolver workflow shape",
			"provider ordering for dotfiles Lua work",
			"generated non-authority artifact inventory for MCP, CUE/Lua LSP, and WezTerm type overlays",
			"negative authority boundaries for MCP output, LSP diagnostics, type stubs, and generated workflow artifacts",
		]
		doesNotOwn: [
			"fatb4f/dotfiles source authority",
			"runtime execution of MCP servers",
			"truth of LSP diagnostics",
			"WezTerm runtime behavior",
			"Neovim runtime behavior",
		]
	}

	entrypoints: [
		{id: "nvim-init", language: "lua", path: ".config/nvim/init.lua", domain: "nvim", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "nvim-vim-types"},
		{id: "nvim-lua-modules", language: "lua", path: ".config/nvim/lua", domain: "nvim", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "nvim-vim-types"},
		{id: "wezterm-config", language: "lua", path: ".config/wezterm/wezterm.lua", domain: "wezterm", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "wezterm-types"},
		{id: "wezterm-modules", language: "lua", path: ".config/wezterm", domain: "wezterm", authority: "dotfiles-source", lspProvider: "lua-language-server", typeOverlay: "wezterm-types"},
	]

	providers: [
		{
			id: "cue-contracts"
			kind: "cue"
			paths: ["contracts/dotfiles/lua-first-workflow.cue", "contracts/agent-context-resolver"]
			authority: true
			evidenceOnly: false
			defaultReadOnly: true
		},
		{
			id: "mcp-tool-registry"
			kind: "mcp"
			paths: ["generated/mcp/server-manifest.json", "generated/mcp/tool-registry.json", "generated/mcp/context-projection.json"]
			authority: false
			evidenceOnly: true
			defaultReadOnly: true
		},
		{
			id: "cue-lsp"
			kind: "lsp"
			paths: ["generated/lsp/cue-lsp.json"]
			authority: false
			evidenceOnly: true
			defaultReadOnly: true
		},
		{
			id: "lua-language-server"
			kind: "lsp"
			paths: ["generated/lsp/lua-language-server.json", "generated/lsp/provider-routing.json"]
			authority: false
			evidenceOnly: true
			defaultReadOnly: true
		},
		{
			id: "wezterm-types"
			kind: "types"
			paths: ["generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua"]
			authority: false
			evidenceOnly: true
			defaultReadOnly: true
		},
		{
			id: "nvim-vim-types"
			kind: "types"
			paths: ["generated/types/nvim/vim.lua"]
			authority: false
			evidenceOnly: true
			defaultReadOnly: true
		},
	]

	steps: [
		{
			order: 1
			id: "collect-lua-entrypoints"
			goal: "Resolve Lua entrypoints before generic dotfiles paths."
			inputs: ["dotfiles source paths", "generated/workflows/lua-first/entrypoints.json"]
			outputs: ["ordered Lua entrypoint set"]
			authority: "dotfiles-source"
		},
		{
			order: 2
			id: "load-type-overlays"
			goal: "Attach Neovim and WezTerm type overlays to reduce false unknown-global diagnostics."
			inputs: ["generated/types/nvim/vim.lua", "generated/types/wezterm/wezterm.lua"]
			outputs: ["Lua LSP library overlay"]
			authority: "evidence-only"
		},
		{
			order: 3
			id: "project-lsp-diagnostics"
			goal: "Project Lua and CUE diagnostics as route evidence, not as mutation authority."
			inputs: ["generated/lsp/lua-language-server.json", "generated/lsp/cue-lsp.json"]
			outputs: ["diagnostic-map"]
			authority: "evidence-only"
		},
		{
			order: 4
			id: "merge-mcp-context"
			goal: "Merge MCP file, git, and CUE query surfaces into a read-only context packet."
			inputs: ["generated/mcp/server-manifest.json", "generated/mcp/tool-registry.json", "generated/mcp/context-projection.json"]
			outputs: ["read-only MCP context packet"]
			authority: "evidence-only"
		},
		{
			order: 5
			id: "emit-lua-first-prompt-surface"
			goal: "Emit the compact prompt surface with Lua route hints before broader dotfiles context."
			inputs: ["ordered Lua entrypoint set", "diagnostic-map", "read-only MCP context packet"]
			outputs: ["generated/workflows/lua-first/workflow.json"]
			authority: "cue-contract"
		},
	]

	gates: [
		{
			id: "mcp-read-only"
			checks: ["MCP provider surfaces are defaultReadOnly", "MCP output is evidenceOnly"]
			denies: ["MCP output treated as authority", "MCP operation selected as source authority"]
		},
		{
			id: "lsp-evidence-only"
			checks: ["Lua and CUE LSP providers are evidenceOnly", "diagnostics are projected through diagnostic-map"]
			denies: ["LSP diagnostics treated as authority", "diagnostics directly mutate source"]
		},
		{
			id: "type-overlay-boundary"
			checks: ["WezTerm and Neovim type overlays are generated artifacts", "type overlays are not dotfiles source"]
			denies: ["type stubs treated as runtime truth", "type stubs treated as dotfiles source authority"]
		},
		{
			id: "lua-first-routing"
			checks: ["Lua entrypoints route before generic dotfiles context", "CUE contracts own route shape"]
			denies: ["generated workflow artifacts treated as authority", "generic context shadows Lua entrypoints"]
		},
	]

	generatedArtifacts: [
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
	]
}
