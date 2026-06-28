package pluginbundletemplate

#NonEmptyString: string & !=""
#RelativePath:   string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#TemplateFile: close({
	path:      #RelativePath
	required:  true
	generated: bool | *true
	authority: false
})

#ShapeCuePackage: close({
	id:   #NonEmptyString
	path: #RelativePath
})

#GeneratedEvidenceFile: close({
	path:         #RelativePath
	required:     true
	evidenceOnly: true
})

#ShapeForbiddenAttractor: close({
	pattern: #NonEmptyString
	scope:   #NonEmptyString
})

#PluginBundleSrcRootShape: close({
	schema:  "factory.plugin-bundle.src-root-shape.v1"
	srcRoot: #RelativePath
	contracts: close({
		root: #RelativePath
		cuePackages: [...#ShapeCuePackage]
		requiredPaths: [...#RelativePath]
	})
	generated: close({
		root:         #RelativePath
		evidenceOnly: true
		artifacts: [...#GeneratedEvidenceFile]
	})
	validation: close({
		commands: [...#NonEmptyString] & [_, ...]
		negativeChecks: [...#NonEmptyString]
		forbiddenAttractors: [...#ShapeForbiddenAttractor]
	})
	manifest: close({
		bundleID:                          #NonEmptyString
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/template/template.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride?:         false
	})
	bundleLocalShapeOverride?: false
})

#PluginBundleTemplate: close({
	schema:           "factory.plugin-bundle.template.v1"
	id:               #NonEmptyString
	materializedRoot: #RelativePath
	requiredFiles: [...#TemplateFile] & [_, ...]
	requiredSubtrees: [...#RelativePath] & [_, ...]
	containsCueAuthorityBlock:    bool | *false
	containsResolverContracts:    bool | *false
	containsConstructorContracts: bool | *false
	denies: [...#NonEmptyString]
	topLevelPluginRoot?:              false
	externalFactoryReference?:        false
	externalContractCuemodReference?: false
	proseReferenceAuthority?:         false
})

agentContextResolverPluginBundleTemplate: #PluginBundleTemplate & {
	id:                           "agent-context-resolver"
	materializedRoot:             ".codex/plugins/agent-context-resolver"
	containsCueAuthorityBlock:    true
	containsResolverContracts:    true
	containsConstructorContracts: true
	requiredSubtrees: [
		"scripts",
		"generated",
		"cue.mod",
		"contracts/agent-context-resolver",
		"contracts/agent-context-resolver/checks",
		"contracts/meta/impl",
		"contracts/meta/impl/checks",
	]
	requiredFiles: [
		{path: "SKILL.md", required: true, authority: false},
		{path: "manifest.json", required: true, authority: false},
		{path: "package.json", required: true, authority: false},
		{path: "package.lock.json", required: true, authority: false},
		{path: "cue.mod/module.cue", required: true, authority: false},
		{path: "scripts/agent-context-resolver-hook", required: true, authority: false},
		{path: "scripts/resolve-agent-context", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_materializer.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_eval_projection.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_runner_result.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/fixtures.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/checks.cue", required: true, authority: false},
		{path: "contracts/agent-context-resolver/checks/checks.cue", required: true, authority: false},
		{path: "contracts/meta/impl/catalog.cue", required: true, authority: false},
		{path: "contracts/meta/impl/primitive.cue", required: true, authority: false},
		{path: "contracts/meta/impl/surface.cue", required: true, authority: false},
		{path: "contracts/meta/impl/predicate.cue", required: true, authority: false},
		{path: "contracts/meta/impl/promotion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/fixture.cue", required: true, authority: false},
		{path: "contracts/meta/impl/bottom.cue", required: true, authority: false},
		{path: "contracts/meta/impl/validation.cue", required: true, authority: false},
		{path: "contracts/meta/impl/completion.cue", required: true, authority: false},
		{path: "contracts/meta/impl/exports.cue", required: true, authority: false},
		{path: "contracts/meta/impl/checks/checks.cue", required: true, authority: false},
	]
	denies: [
		"external factory lookup from materialized plugin",
		"external contract.cuemod lookup from materialized plugin",
		"top-level plugins runtime root",
		"prose references as authority",
	]
}

codeIntelPluginBundleTemplate: #PluginBundleTemplate & {
	id:                           "code-intel"
	materializedRoot:             ".codex/plugins/code-intel"
	containsCueAuthorityBlock:    true
	containsResolverContracts:    false
	containsConstructorContracts: false
	requiredSubtrees: [
		"generated/mcp",
		"generated/lsp",
		"generated/types/wezterm",
		"generated/types/nvim",
		"generated/workflows/lua-first",
		"contracts/code-intel",
	]
	requiredFiles: [
		{path: "SKILL.md", required: true, authority: false},
		{path: "manifest.json", required: true, authority: false},
		{
			path:      "generated/mcp/server-manifest.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/mcp/tool-registry.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/mcp/context-projection.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/lsp/cue-lsp.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/lsp/lua-language-server.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/lsp/provider-routing.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/types/wezterm/wezterm.lua"
			required:  true
			authority: false
		},
		{
			path:      "generated/types/wezterm/events.lua"
			required:  true
			authority: false
		},
		{
			path:      "generated/types/wezterm/config-builder.lua"
			required:  true
			authority: false
		},
		{
			path:      "generated/types/nvim/vim.lua"
			required:  true
			authority: false
		},
		{
			path:      "generated/workflows/lua-first/workflow.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/workflows/lua-first/entrypoints.json"
			required:  true
			authority: false
		},
		{
			path:      "generated/workflows/lua-first/diagnostic-map.json"
			required:  true
			authority: false
		},
		{path: "contracts/code-intel/lua-first-workflow.cue", required: true, authority: false},
		{path: "contracts/code-intel/checks.cue", required: true, authority: false},
	]
	denies: [
		"MCP output treated as authority",
		"LSP diagnostics treated as authority",
		"WezTerm type stubs treated as dotfiles source authority",
		"Lua workflow artifacts are evidence-only",
		"code-intel bundle carrying agent-context-resolver contracts",
	]
}

pluginBundleTemplateShapeBaseline: #PluginBundleSrcRootShape & {
	srcRoot: "contracts/plugin-bundle/template"
	contracts: {
		root: "contracts/plugin-bundle/template"
		cuePackages: [
			{id: "pluginbundletemplate", path: "template.cue"},
		]
		requiredPaths: ["template.cue"]
	}
	generated: {
		root:         "contracts/plugin-bundle/template/generated"
		evidenceOnly: true
		artifacts: []
	}
	validation: {
		commands: [
			"cue vet ./contracts/plugin-bundle/template",
			"cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateShapeBaseline",
		]
		negativeChecks: ["bundleLocalShapeOverrideAccepted"]
		forbiddenAttractors: [
			{pattern: "bundle-local shape override", scope: "template shape source"},
		]
	}
	manifest: {
		bundleID:                          "plugin-bundle-template"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/template/template.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride:          false
	}
	bundleLocalShapeOverride: false
}

normalizedPluginBundleTemplateShapeManifest: close({
	issue:    80
	title:    "cue(plugin-bundle): define template shape authority"
	template: pluginBundleTemplateShapeBaseline
	publicExports: [
		"pluginBundleTemplateShapeBaseline",
		"normalizedPluginBundleTemplateShapeManifest",
		"pluginBundleTemplateShapeValidationPlan",
		"pluginBundleTemplateShapeCompletionReportContract",
	]
	requiredFields: ["srcRoot", "contracts", "generated", "validation", "manifest"]
	invariants: [
		"template owns structure only",
		"bundle-specific semantics stay in materialized values",
		"generated outputs are evidence-only",
	]
})

pluginBundleTemplateShapeValidationPlan: close({
	path:     "contracts/plugin-bundle/template"
	positive: pluginBundleTemplateShapeBaseline.validation.commands
	negative: [
		"! cue export ./contracts/issues/80/checks -e _negativeBottomChecks.bundleLocalShapeOverrideAccepted",
	]
	forbiddenAttractors: pluginBundleTemplateShapeBaseline.validation.forbiddenAttractors
})

pluginBundleTemplateShapeCompletionReportContract: close({
	summary: [
		"template package defines canonical plugin-bundle src-root structure",
		"shape fields are srcRoot, contracts, generated, validation, and manifest",
		"bundle-local shape overrides are rejected by issue-local checks",
	]
	exportsAdded: normalizedPluginBundleTemplateShapeManifest.publicExports
	validation:   pluginBundleTemplateShapeValidationPlan
	finalResult:  "issue #80 close-ready once template exports and negative check pass"
})

pluginBundleTemplateComplianceReports: {
	agentContextResolver: {
		schema:           "factory.plugin-bundle.template.compliance.v1"
		status:           "admitted"
		template:         agentContextResolverPluginBundleTemplate.id
		materializedRoot: agentContextResolverPluginBundleTemplate.materializedRoot
		requiredSubtrees: agentContextResolverPluginBundleTemplate.requiredSubtrees
		checks: ["topLevelPluginRoot", "externalFactoryReference", "externalContractCuemodReference", "proseReferenceAuthority", "missingCueAuthorityBlock"]
	}
	codeIntel: {
		schema:           "factory.plugin-bundle.template.compliance.v1"
		status:           "admitted"
		template:         codeIntelPluginBundleTemplate.id
		materializedRoot: codeIntelPluginBundleTemplate.materializedRoot
		requiredSubtrees: codeIntelPluginBundleTemplate.requiredSubtrees
		checks: ["mcpOutputAsAuthority", "lspDiagnosticsAsAuthority", "weztermTypesAsAuthority", "luaWorkflowGeneratedAsAuthority", "resolverContractsLeak"]
	}
}
