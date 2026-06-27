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
}
