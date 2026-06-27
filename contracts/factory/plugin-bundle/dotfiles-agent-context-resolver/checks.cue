package dotfilespluginbundle

_negativeBottomChecks: {
	codexAsAuthority:
		*(negativeFixtures.codexAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	generatedAsAuthority:
		*(negativeFixtures.generatedAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	externalDependency:
		*(negativeFixtures.externalDependency.input & #AdmissibleDotfilesPluginBundleProjection) | _

	providerOutputAsAuthority:
		*(negativeFixtures.providerOutputAsAuthority.input & #AdmissibleDotfilesPluginBundleProjection) | _

	materializationWithoutLock:
		*(negativeFixtures.materializationWithoutLock.input & #AdmissibleDotfilesPluginMaterialization) | _

	controllerLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.controllerLeak.input & #ResolverPromptSurface) | _

	runtimeLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.runtimeLeak.input & #ResolverPromptSurface) | _

	propagationLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.propagationLeak.input & #ResolverPromptSurface) | _

	availableFragmentIDsLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.availableFragmentIDsLeak.input & #ResolverPromptSurface) | _

	availableRouteIDsLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.availableRouteIDsLeak.input & #ResolverPromptSurface) | _

	workerProfileIDLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.workerProfileIDLeak.input & #ResolverPromptSurface) | _

	workerBindingIDLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.workerBindingIDLeak.input & #ResolverPromptSurface) | _

	preferredWorkerAdapterLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.preferredWorkerAdapterLeak.input & #ResolverPromptSurface) | _

	generatedFromLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.generatedFromLeak.input & #ResolverPromptSurface) | _

	rawRegistryLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.rawRegistryLeak.input & #ResolverPromptSurface) | _

	rawTranscriptLeak:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.rawTranscriptLeak.input & #ResolverPromptSurface) | _

	debugPacketAsDefaultOut:
		*(dotfilesAgentContextResolverPromptSurfaceNegativeFixtures.debugPacketAsDefaultOut.input & #HookEmissionContract) | _
}
