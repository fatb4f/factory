package codeintelpluginbundle

#CodeIntelProviderSurface: close({
	id: #NonEmptyString
	kind: "cue" | "mcp" | "lsp" | "types"
	paths: [...#ContainedBundlePath]
	authority: false
	evidenceOnly: true
	defaultReadOnly: true
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
	authority: "dotfiles-source" | "evidence-only"
})

#CodeIntelLuaFirstWorkflow: close({
	schema: "factory.plugin-bundle.code-intel.lua-first-workflow.v1"
	id: #NonEmptyString
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
	id: "dotfiles-code-intel-lua-first"
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
		{order: 2, id: "load-type-overlays", goal: "Attach Neovim and WezTerm type overlays as read-only evidence.", inputs: ["generated/types/nvim/vim.lua", "generated/types/wezterm/wezterm.lua"], outputs: ["Lua library overlay"], authority: "evidence-only"},
		{order: 3, id: "project-diagnostics", goal: "Project Lua and CUE diagnostics as evidence, not mutation authority.", inputs: ["generated/lsp/lua-language-server.json", "generated/lsp/cue-lsp.json"], outputs: ["diagnostic-map"], authority: "evidence-only"},
	]
	generatedArtifacts: codeIntelRequiredPaths
	authority: {
		owns: ["code-intel bundle workflow shape", "provider ordering for Lua-first dotfiles work", "negative authority boundaries for generated code-intel artifacts"]
		doesNotOwn: ["agent-context-resolver bundle", "fatb4f/dotfiles source authority", "runtime execution", "truth of LSP diagnostics", "WezTerm runtime behavior", "Neovim runtime behavior"]
	}
}
