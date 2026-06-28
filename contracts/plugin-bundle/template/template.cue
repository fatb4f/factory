package pluginbundletemplate

#NonEmptyString: string & !=""
#RelativePath: string & !="" & !~"^/" & !~"(^|/)\.\.(/|$)"

#TemplateFile: close({
	path: #RelativePath
	required: true
	generated: bool | *true
	authority: false
})

#PluginBundleTemplate: close({
	schema: "factory.plugin-bundle.template.v1"
	id: #NonEmptyString
	materializedRoot: #RelativePath
	requiredFiles: [...#TemplateFile] & [_, ...]
	requiredSubtrees: [...#RelativePath] & [_, ...]
	containsCueAuthorityBlock: true
	containsResolverContracts: bool | *false
	containsConstructorContracts: bool | *false
	denies: [...#NonEmptyString]
	topLevelPluginRoot?: false
	externalFactoryReference?: false
	externalContractCuemodReference?: false
	proseReferenceAuthority?: false
})

agentContextResolverPluginBundleTemplate: #PluginBundleTemplate & {
	id: "agent-context-resolver"
	materializedRoot: ".codex/plugins/agent-context-resolver"
	containsCueAuthorityBlock: true
	containsResolverContracts: true
	containsConstructorContracts: true
	requiredSubtrees: [
		"scripts",
		"generated",
		"contracts/agent-context-resolver",
		"contracts/meta/impl",
	]
	requiredFiles: [
		{path: "SKILL.md", required: true, authority: false},
		{path: "manifest.json", required: true, authority: false},
		{path: "scripts/agent-context-resolver-hook", required: true, authority: false},
		{path: "scripts/resolve-agent-context", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_materializer.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_eval_projection.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_runner_result.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue", required: true, authority: false},
		{path: "contracts/meta/impl/primitive.cue", required: true, authority: false},
		{path: "contracts/meta/impl/surface.cue", required: true, authority: false},
		{path: "contracts/meta/impl/predicate.cue", required: true, authority: false},
		{path: "contracts/meta/impl/promotion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/fixture.cue", required: true, authority: false},
		{path: "contracts/meta/impl/bottom.cue", required: true, authority: false},
		{path: "contracts/meta/impl/validation.cue", required: true, authority: false},
		{path: "contracts/meta/impl/completion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/exports.cue", required: true, authority: false},
	]
	denies: [
		"external factory lookup from materialized plugin",
		"external contract.cuemod lookup from materialized plugin",
		"top-level plugins runtime root",
		"prose references as authority",
	]
}

pluginBundleTemplateComplianceReport: {
	schema: "factory.plugin-bundle.template.compliance.v1"
	status: "admitted"
	template: agentContextResolverPluginBundleTemplate.id
	materializedRoot: agentContextResolverPluginBundleTemplate.materializedRoot
	requiredSubtrees: agentContextResolverPluginBundleTemplate.requiredSubtrees
	checks: ["topLevelPluginRoot", "externalFactoryReference", "externalContractCuemodReference", "proseReferenceAuthority", "missingCueAuthorityBlock"]
}
