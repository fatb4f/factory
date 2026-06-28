package dotfilespluginbundle

#PluginBundlePackageFile: close({
	path: #ContainedBundlePath
	generated: true
	authority: false
})

#IdempotentPluginBundlePackage: close({
	schema: "factory.plugin-bundle.idempotent-package.v1"
	id: #NonEmptyString
	packageRoot: #ContainedBundlePath
	materializedRoot: #ContainedBundlePath
	projection: "dotfiles-agent-context-resolver-plugin-bundle-v1"
	files: [...#PluginBundlePackageFile] & [_, ...]
	lock: #BundleLockEvidence
	install: close({
		mode: "copy-package-tree"
		overwrite: "replace-generated"
		idempotent: true
	})
	distribution: close({
		kind: "materialized-package"
		publishAfterMaterialization: true
		sourceReferencesInPackage: false
		externalAuthorityRequired: false
	})
	invariants: close({
		sameInputsSamePackage: true
		packageContentsOnly: true
		generatedOutputAuthority: false
		runtimeGenerationRequired: false
		runtimePackagePathsSubsetOfContractPaths: true
		fullContractSurfaceRetained: true
	})
})

dotfilesAgentContextResolverPackage: #IdempotentPluginBundlePackage & {
	id: dotfilesAgentContextResolverLock.id
	packageRoot: pluginBundleRoot
	materializedRoot: pluginBundleRoot
	files: [
		for file in generatedFileInventory {
			path: file.path
			generated: true
			authority: false
		},
	]
	lock: dotfilesAgentContextResolverLock
}
