package dotfilespluginbundle

#FileLock: close({
	path: #NonEmptyString
	generated: true
	authority: false
})

#BundleLockEvidence: close({
	id: #NonEmptyString
	authority: false
	contractRoot: pluginBundleContractRoot
	sourceRoot: pluginBundleSourceRoot
	templateRoot: pluginBundleTemplateRoot
	instanceRoot: pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	projection: "dotfiles-agent-context-resolver-plugin-bundle-v1"
	target: close({
		repo: "github.com/fatb4f/dotfiles"
		root: "."
	})
	files: [...#FileLock] & [_, ...]
	gates: [#NonEmptyString]: close({
		required: true
		result: "pass" | "pending"
	})
})

dotfilesAgentContextResolverLock: #BundleLockEvidence & {
	id: "dotfiles-agent-context-resolver-plugin-bundle-v1"
	authority: false
	contractRoot: pluginBundleContractRoot
	sourceRoot: pluginBundleSourceRoot
	templateRoot: pluginBundleTemplateRoot
	instanceRoot: pluginBundleContractRoot
	materializedRoot: pluginBundleRoot
	projection: "dotfiles-agent-context-resolver-plugin-bundle-v1"
	target: dotfilesTarget
	files: [
		for file in generatedFileInventory {
			path: file.path
			generated: true
			authority: false
		},
	]
	gates: {
		for gate in projectionGates {
			"\(gate.id)": {
				required: true
				result: "pending"
			}
		}
	}
}
