package dotfilespluginbundle

#TemplateApplicationAddition: close({
	path: #ContainedBundlePath
	kind: "resolver-output" | "mcp" | "lsp" | "types" | "workflow" | "cue-authority"
	generated: true
	authority: false
	reason: #NonEmptyString
})

#PluginBundleTemplateApplication: close({
	schema: "factory.plugin-bundle.template-application.v1"
	template: close({
		id: "agent-context-resolver"
		root: "contracts/plugin-bundle/agent-context-resolver/template"
		materializedRoot: ".codex/plugins/agent-context-resolver"
	})
	instance: close({
		id: "dotfiles"
		root: pluginBundleContractRoot
		targetRepo: "github.com/fatb4f/dotfiles"
		materializedRoot: pluginBundleRoot
	})
	baseRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	additions: [...#TemplateApplicationAddition]
	resultRequiredPaths: [...#ContainedBundlePath] & [_, ...]
	generatedOutputAuthority: false
	instanceOwnsTemplate: false
})

baseTemplateRequiredPaths: [
	"SKILL.md",
	"manifest.json",
	"package.json",
	"package.lock.json",
	"cue.mod/module.cue",
	"scripts/agent-context-resolver-hook",
	"scripts/resolve-agent-context",
	"contracts/agent-context-resolver/implementation_slice_materializer.cue",
	"contracts/agent-context-resolver/implementation_slice_eval_projection.cue",
	"contracts/agent-context-resolver/implementation_slice_runner_result.cue",
	"contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue",
	"contracts/agent-context-resolver/fixtures.cue",
	"contracts/agent-context-resolver/checks.cue",
	"contracts/agent-context-resolver/checks/checks.cue",
	"contracts/meta/impl/catalog.cue",
	"contracts/meta/impl/primitive.cue",
	"contracts/meta/impl/surface.cue",
	"contracts/meta/impl/predicate.cue",
	"contracts/meta/impl/promotion.cue",
	"contracts/meta/impl/fixture.cue",
	"contracts/meta/impl/bottom.cue",
	"contracts/meta/impl/validation.cue",
	"contracts/meta/impl/completion.cue",
	"contracts/meta/impl/exports.cue",
	"contracts/meta/impl/checks/checks.cue",
]

dotfilesTemplateApplicationAdditions: [
	{path: "generated/turn_start_fragments.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver turn-start fragment projection"},
	{path: "generated/prompt_routes.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver prompt route projection"},
	{path: "generated/route_inventory.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver route inventory projection"},
	{path: "generated/fragment_inventory.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver fragment inventory projection"},
	{path: "generated/provider_inventory.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle resolver provider inventory projection"},
	{path: "generated/dotfiles.schema-map.json", kind: "resolver-output", generated: true, authority: false, reason: "bundle dotfiles schema-map projection"},
	{path: "generated/mcp/server-manifest.json", kind: "mcp", generated: true, authority: false, reason: "bundle read-only MCP server metadata for dotfiles context projection"},
	{path: "generated/mcp/tool-registry.json", kind: "mcp", generated: true, authority: false, reason: "bundle read-only MCP tool registry evidence"},
	{path: "generated/mcp/context-projection.json", kind: "mcp", generated: true, authority: false, reason: "bundle read-only MCP context projection evidence"},
	{path: "generated/lsp/cue-lsp.json", kind: "lsp", generated: true, authority: false, reason: "bundle CUE LSP provider metadata"},
	{path: "generated/lsp/lua-language-server.json", kind: "lsp", generated: true, authority: false, reason: "bundle Lua language server provider metadata"},
	{path: "generated/lsp/provider-routing.json", kind: "lsp", generated: true, authority: false, reason: "bundle LSP provider routing evidence"},
	{path: "generated/types/wezterm/wezterm.lua", kind: "types", generated: true, authority: false, reason: "bundle WezTerm Lua type overlay"},
	{path: "generated/types/wezterm/events.lua", kind: "types", generated: true, authority: false, reason: "bundle WezTerm event type overlay"},
	{path: "generated/types/wezterm/config-builder.lua", kind: "types", generated: true, authority: false, reason: "bundle WezTerm config-builder type overlay"},
	{path: "generated/types/nvim/vim.lua", kind: "types", generated: true, authority: false, reason: "bundle Neovim vim global type overlay"},
	{path: "generated/workflows/lua-first/workflow.json", kind: "workflow", generated: true, authority: false, reason: "bundle Lua-first prompt workflow projection"},
	{path: "generated/workflows/lua-first/entrypoints.json", kind: "workflow", generated: true, authority: false, reason: "bundle Lua-first entrypoint projection"},
	{path: "generated/workflows/lua-first/diagnostic-map.json", kind: "workflow", generated: true, authority: false, reason: "bundle Lua-first diagnostic projection"},
	{path: "contracts/dotfiles/lua-first-workflow.cue", kind: "cue-authority", generated: true, authority: false, reason: "bundle dotfiles workflow contract as materialized non-authority copy"},
]

dotfilesAgentContextResolverTemplateApplication: #PluginBundleTemplateApplication & {
	template: {
		id: "agent-context-resolver"
		root: pluginBundleTemplateRoot
		materializedRoot: pluginBundleRoot
	}
	instance: {
		id: "dotfiles"
		root: pluginBundleContractRoot
		targetRepo: dotfilesTarget.repo
		materializedRoot: pluginBundleRoot
	}
	baseRequiredPaths: baseTemplateRequiredPaths
	additions: dotfilesTemplateApplicationAdditions
	resultRequiredPaths: pluginBundleRequiredPaths
	generatedOutputAuthority: false
	instanceOwnsTemplate: false
}
