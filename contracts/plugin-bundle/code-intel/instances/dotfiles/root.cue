package codeintelpluginbundle

#NonEmptyString: string & !=""
#ContainedBundlePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#CodeIntelTarget: close({
	repo: "github.com/fatb4f/dotfiles"
	root: "."
})

#Gate: close({
	id: #NonEmptyString
	kind: "cue-vet" | "cue-export" | "negative-bottom" | "forbidden-search" | "plugin-manifest" | "archive"
	target: #NonEmptyString
	required: true
})

#CodeIntelTargetFile: close({
	path: #NonEmptyString
	generated: true
	authority: false
	source: "bundle-projection"
})

#ProjectionComponent: close({
	id: #NonEmptyString
	path: #NonEmptyString
	role: "contract" | "generated-package" | "package-content" | "package-metadata" | "idempotency-lock" | "integration"
	generated: *false | bool
	authority: bool
})

#ProviderReachabilityEvidence: close({
	kind: "provider-reachability"
	authority: false
	evidenceOnly: true
	providers: [...#NonEmptyString]
})

#CodeIntelPluginBundleProjection: close({
	contract: #CodeIntelBundleContract
	target: #CodeIntelTarget
	components: [...#ProjectionComponent] & [_, ...]
	generatedFiles: [...#CodeIntelTargetFile] & [_, ...]
	outputPlan: #CodeIntelOutputPlan
	gates: [...#Gate] & [_, ...]
	providerReachability: #ProviderReachabilityEvidence

	generatedAuthority?: false
	mcpOutputIsAuthority?: false
	lspDiagnosticsAreAuthority?: false
	weztermTypesAreAuthority?: false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?: false
}

#AdmissibleCodeIntelPluginBundleProjection: #CodeIntelPluginBundleProjection & {
	generatedAuthority?: false
	mcpOutputIsAuthority?: false
	lspDiagnosticsAreAuthority?: false
	weztermTypesAreAuthority?: false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?: false
}
