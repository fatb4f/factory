package dotfilespluginbundle

#TemplateApplicationAddition: close({
	path: #ContainedBundlePath
	kind: "resolver-output"
	generated: true
	authority: false
	reason: #NonEmptyString
})

#PluginBundleTemplateApplication: close({
	schema: "factory.plugin-bundle.template-application.v1"
	template: close({
		id: "agent-context-resolver"
		root: "contracts/plugin-bundle/template"
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
