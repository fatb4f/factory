package dotfilespluginbundle

negativeFixtures: {
	codexAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {codexAuthority: true}}
	generatedAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {generatedAuthority: true}}
	externalDependency: {input: dotfilesAgentContextResolverBundleInput & {externalFactoryRootLookup: true}}
	contractCuemodDependency: {input: dotfilesAgentContextResolverBundleInput & {externalContractCuemodLookup: true}}
	providerOutputAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {providerOutputIsAuthority: true}}
	topLevelPluginRoot: {input: dotfilesAgentContextResolverBundleInput & {topLevelPluginRoot: true}}
	proseReferenceAuthority: {input: dotfilesAgentContextResolverBundleInput & {proseReferenceAuthority: true}}
	materializationWithoutLock: {input: {
		repo: dotfilesTarget.repo
		root: dotfilesTarget.root
		files: generatedFileInventory
		overwrite: "replace-generated"
		provenance: {
			kind: "projection"
			contractRoot: pluginBundleContractRoot
			sourceRoot: pluginBundleSourceRoot
			templateRoot: pluginBundleTemplateRoot
			instanceRoot: pluginBundleContractRoot
			materializedRoot: pluginBundleRoot
			projection: "dotfiles-agent-context-resolver-plugin-bundle-v1"
			lockID: "missing-lock-evidence"
			authority: false
		}
	}}
}
