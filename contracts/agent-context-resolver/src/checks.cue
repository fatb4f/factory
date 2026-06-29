package agentcontextresolver

_negativeBottomChecks: {
	genericProviderTermAccepted:
		*(pluginBundleRecommendationNegativeFixtures.genericProviderTermAccepted.input & #PluginBundleMatcherAdmissible) | _

	danglingDependencyAccepted:
		*(pluginBundleRecommendationNegativeFixtures.danglingDependencyAccepted.input & #PluginBundleMatcherAdmissible) | _

	cueRuntimeDependencyAccepted:
		*(pluginBundleRecommendationNegativeFixtures.cueRuntimeDependencyAccepted.input & #PluginBundleMatcherAdmissible) | _
}
