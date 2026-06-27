package dotfilespluginbundle

#PluginRoot: close({
	path: #RelativePath
	isDirectory: true
	manifest: close({
		path: ".codex-plugin/plugin.json"
		exists: true
	})
})

#NoEscapingPluginRoot: close({
	resourcePath: #RelativePath
	rootRelative: true
	forbidParentEscape: true
	forbidAbsolute: true
})

#BundleArchiveGate: close({
	pluginRootIsDirectory: true
	manifestExists:        true
	noSymlinks:            true
	noHardlinks:           true
	noUnsupportedEntries:  true
	maxArchiveBytes:       int & >0
	maxExtractedBytes:     int & >0
	archiveName:           #NonEmptyString
	format:                "tar.gz"
	deterministicTraversal: true
	packageFromPluginRootOnly: true
})

resolverPluginRoot: #PluginRoot & {
	path: "plugins/agent-context-resolver"
}

resolverPluginResourcePaths: [
	".codex-plugin/plugin.json",
	"skills/agent-context-resolver/SKILL.md",
	"skills/agent-context-resolver/references/implementation-contract.md",
	"skills/agent-context-resolver/references/validation.md",
	"skills/agent-context-resolver/scripts/validate_contract_surface.py",
]

resolverPluginRootContainment: [
	for path in resolverPluginResourcePaths {
		#NoEscapingPluginRoot & {
			resourcePath: path
		}
	},
]

resolverBundleArchiveGate: #BundleArchiveGate & {
	pluginRootIsDirectory: true
	manifestExists:        true
	noSymlinks:            true
	noHardlinks:           true
	noUnsupportedEntries:  true
	maxArchiveBytes:       10485760
	maxExtractedBytes:     52428800
	archiveName:           "resolver-plugin.tar.gz"
	format:                "tar.gz"
	deterministicTraversal: true
	packageFromPluginRootOnly: true
}
