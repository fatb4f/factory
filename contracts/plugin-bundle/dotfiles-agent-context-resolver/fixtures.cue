package dotfilespluginbundle

negativeFixtures: {
	codexAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {codexAuthority: true}}
	generatedAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {generatedAuthority: true}}
	externalDependency: {input: dotfilesAgentContextResolverBundleInput & {externalFactoryRootLookup: true}}
	contractCuemodDependency: {input: dotfilesAgentContextResolverBundleInput & {externalContractCuemodLookup: true}}
	providerOutputAsAuthority: {input: dotfilesAgentContextResolverBundleInput & {providerOutputIsAuthority: true}}
	topLevelPluginRoot: {input: dotfilesAgentContextResolverBundleInput & {topLevelPluginRoot: true}}
	proseReferenceAuthority: {input: dotfilesAgentContextResolverBundleInput & {proseReferenceAuthority: true}}
	materializationWithoutLock: {input: dotfilesAgentContextResolverMaterializationInput & {provenance: {lockID: "missing-lock-evidence"}}}
}
