package codeintelpluginbundle

negativeFixtures: {
	generatedAsAuthority: {input: codeIntelBundleInput & {generatedAuthority: true}}
	mcpOutputAsAuthority: {input: codeIntelBundleInput & {mcpOutputIsAuthority: true}}
	lspDiagnosticsAsAuthority: {input: codeIntelBundleInput & {lspDiagnosticsAreAuthority: true}}
	weztermTypesAsAuthority: {input: codeIntelBundleInput & {weztermTypesAreAuthority: true}}
	luaWorkflowGeneratedAsAuthority: {input: codeIntelBundleInput & {luaWorkflowGeneratedAsAuthority: true}}
	resolverContractsLeak: {input: codeIntelBundleInput & {resolverContractsLeak: true}}
}
