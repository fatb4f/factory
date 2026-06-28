package dotfilespluginbundle

#OverwritePolicy: "replace-generated"

#DotfilesPluginMaterialization: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
	files: [...#DotfilesTargetFile] & [_, ...]
	overwrite: #OverwritePolicy
	provenance: close({
		kind: "projection"
		contractRoot: pluginBundleContractRoot
		projection: "dotfiles-agent-context-resolver-plugin-bundle-v1"
		lockID: #NonEmptyString
		authority: false
	})
})

dotfilesAgentContextResolverMaterializationInput: {
	repo: dotfilesTarget.repo
	root: dotfilesTarget.root
	files: generatedFileInventory
	overwrite: "replace-generated"
	provenance: {
		kind: "projection"
		contractRoot: pluginBundleContractRoot
		projection: "dotfiles-agent-context-resolver-plugin-bundle-v1"
		lockID: dotfilesAgentContextResolverLock.id
		authority: false
	}
}

dotfilesAgentContextResolverMaterialization: #DotfilesPluginMaterialization & dotfilesAgentContextResolverMaterializationInput
