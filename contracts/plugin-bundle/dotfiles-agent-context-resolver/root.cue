package dotfilespluginbundle

#NonEmptyString: string & !=""

#DotfilesTarget: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
})

#Gate: close({
	id: #NonEmptyString
	kind: "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search" | "plugin-manifest" | "archive"
	target: #NonEmptyString
	required: true
})

#DotfilesTargetFile: close({
	path: #NonEmptyString
	generated: true
	authority: false
	source: "bundle-projection"
})

#ProjectionComponent: close({
	id: #NonEmptyString
	path: #NonEmptyString
	role: "contract" | "projection" | "generated-output" | "evidence" | "integration"
	generated: *false | bool
	authority: bool
})

#ProviderReachabilityEvidence: close({
	kind: "provider-reachability"
	authority: false
	evidenceOnly: true
	providers: [...#NonEmptyString]
})

#DotfilesPluginBundleProjection: close({
	contract: #DotfilesAgentContextResolverBundleContract
	target: #DotfilesTarget
	components: [...#ProjectionComponent] & [_, ...]
	generatedFiles: [...#DotfilesTargetFile] & [_, ...]
	materialization: #DotfilesPluginMaterialization
	lock: #BundleLockEvidence
	gates: [...#Gate] & [_, ...]
	providerReachability?: #ProviderReachabilityEvidence

	codexAuthority?: false
	generatedAuthority?: false
	providerOutputIsAuthority?: false
	externalFactoryRootLookup?: false
	externalContractCuemodLookup?: false
	topLevelPluginRoot?: false
	proseReferenceAuthority?: false
})

#AdmissibleDotfilesPluginBundleProjection: #DotfilesPluginBundleProjection & {
	codexAuthority?: false
	generatedAuthority?: false
	providerOutputIsAuthority?: false
	externalFactoryRootLookup?: false
	externalContractCuemodLookup?: false
	topLevelPluginRoot?: false
	proseReferenceAuthority?: false
}
